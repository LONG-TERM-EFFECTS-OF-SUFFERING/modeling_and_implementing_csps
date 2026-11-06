% =====================================================================
% Taller 1 - Programación por Restricciones
% Ejercicio 2.2: Kakuro
% Autores: Brandon Calderón Prieto (2125974)
% Uso:     minizinc --solver gecode -s kakuro.mzn tests/kakuro_01.dzn -D "impl=3;strategy=3"
%
% Implementaciones (impl):
%   1 = R1 (sum) + R2 con desigualdades por pares (x != y)
%   2 = R1 (sum) + R2 con alldifferent global
%   3 = impl 2 + restricción redundante RR1 (dígitos posibles de cada serie)
%   4 = impl 3, pero en las series de hasta 'maxTabla' casillas R1 y R2 se
%       reemplazan por una sola restricción table (tuplas válidas precalculadas)
% Estrategias (strategy):
%   1 = input_order / indomain_min    (orden de lectura, menor valor)
%   2 = first_fail  / indomain_min    (dominio más pequeño primero)
%   3 = dom_w_deg   / indomain_split  (dominio / grado ponderado, bisección)
% =====================================================================

include "globals.mzn";

% ---------------------------------------------------------------------
% 1. PARÁMETROS (vienen del .dzn)
% ---------------------------------------------------------------------
int: filas;
int: columnas;
set of int: FILAS = 1..filas;
set of int: COLS  = 1..columnas;

array[FILAS, COLS] of 0..1: blanca;   % 1 = casilla blanca (hay que llenarla), 0 = negra
array[FILAS, COLS] of int:  pistaV;   % suma de la serie que BAJA desde esta casilla negra (0 = no hay)
array[FILAS, COLS] of int:  pistaH;   % suma de la serie que va a la DERECHA desde esta casilla negra (0 = no hay)

% --- Parámetros derivados: se calculan a partir de los datos (NO son variables) ---

% Casillas blancas numeradas 1..nB en orden de lectura (fila por fila)
int: nB = sum(i in FILAS, j in COLS)(blanca[i,j]);
set of int: CASILLAS = 1..nB;
array[FILAS, COLS] of 0..nB: num = array2d(FILAS, COLS,
  [ if blanca[i,j] = 1
    then sum(i2 in FILAS, j2 in COLS where i2 < i \/ (i2 = i /\ j2 <= j))(blanca[i2,j2])
    else 0 endif
  | i in FILAS, j in COLS ]);

% Primera casilla negra (o el borde) a la derecha / debajo de (i,j)
function int: finH(int: i, int: j) = min([k | k in j+1..columnas where blanca[i,k] = 0] ++ [columnas+1]);
function int: finV(int: i, int: j) = min([k | k in i+1..filas    where blanca[k,j] = 0] ++ [filas+1]);

% Series: una por cada pista. Primero las horizontales (1..nH), luego las verticales.
array[int] of int: sumaS =
     [ pistaH[i,j] | i in FILAS, j in COLS where pistaH[i,j] > 0 ]
  ++ [ pistaV[i,j] | i in FILAS, j in COLS where pistaV[i,j] > 0 ];
array[int] of set of int: celdasS =
     [ { num[i,k] | k in j+1..finH(i,j)-1 } | i in FILAS, j in COLS where pistaH[i,j] > 0 ]
  ++ [ { num[k,j] | k in i+1..finV(i,j)-1 } | i in FILAS, j in COLS where pistaV[i,j] > 0 ];
int: nH = sum(i in FILAS, j in COLS)(bool2int(pistaH[i,j] > 0));
int: nS = length(sumaS);
set of int: SERIES = 1..nS;
array[SERIES] of int: largoS = [ card(celdasS[s]) | s in SERIES ];

% --- Validación de los datos (como en las diapositivas de clase: assert) ---
constraint assert(forall(i in FILAS, j in COLS where blanca[i,j] = 1)(pistaV[i,j] = 0 /\ pistaH[i,j] = 0),
  "Datos inválidos: una casilla blanca no puede tener pista");
constraint assert(forall(s in SERIES)(largoS[s] >= 1 /\ largoS[s] <= 9),
  "Datos inválidos: cada serie debe tener entre 1 y 9 casillas");
constraint assert(forall(s in SERIES)(
    sumaS[s] >= largoS[s] * (largoS[s] + 1) div 2 /\ sumaS[s] <= largoS[s] * (19 - largoS[s]) div 2),
  "Datos inválidos: hay una pista imposible para el largo de su serie");
constraint assert(forall(c in CASILLAS)(
    sum(s in 1..nH where c in celdasS[s])(1) = 1 /\ sum(s in nH+1..nS where c in celdasS[s])(1) = 1),
  "Datos inválidos: cada casilla blanca debe estar en exactamente una serie horizontal y una vertical");

% ---------------------------------------------------------------------
% 2. PARÁMETROS DE EXPERIMENTACIÓN (se pasan con -D "impl=..;strategy=..")
% ---------------------------------------------------------------------
int: impl;
int: strategy;
int: maxTabla = 5;    % impl 4: largo máximo de serie para usar table (las tablas crecen como L!)
constraint assert(impl in 1..4 /\ strategy in 1..3, "impl debe estar en 1..4 y strategy en 1..3");

% ---------------------------------------------------------------------
% 3. VARIABLES DE DECISIÓN
% ---------------------------------------------------------------------
% x[c] = dígito escrito en la casilla blanca número c
array[CASILLAS] of var 1..9: x;

% ---------------------------------------------------------------------
% Precálculo (solo parámetros): cada subconjunto de {1..9} es una máscara m en 0..511;
% el dígito d está en m si el bit d-1 de m vale 1.
% ---------------------------------------------------------------------
set of int: MASCARAS = 0..511;
array[MASCARAS] of set of int: digitosM = array1d(MASCARAS,
  [ { d | d in 1..9 where (m div pow(2, d-1)) mod 2 = 1 } | m in MASCARAS ]);
array[MASCARAS] of int: cardM = array1d(MASCARAS, [ card(digitosM[m]) | m in MASCARAS ]);
array[MASCARAS] of int: sumaM = array1d(MASCARAS, [ sum(digitosM[m])  | m in MASCARAS ]);

% Combinaciones (conjuntos) de L dígitos distintos que suman 'suma'
function array[int] of int: combinaciones(int: L, int: suma) =
  [ m | m in MASCARAS where cardM[m] = L /\ sumaM[m] = suma ];
% RR1: dígitos posibles de cada serie = unión de sus combinaciones válidas
array[SERIES] of set of int: posiblesS =
  [ array_union([ digitosM[m] | m in combinaciones(largoS[s], sumaS[s]) ]) | s in SERIES ];

% k-ésima permutación (k = 0..|S|!-1) del arreglo S (código de Lehmer)
function array[int] of int: permutacion(array[int] of int: S, int: k) =
  if length(S) = 0 then []
  else let { int: f   = product([ i | i in 1..length(S)-1 ]);   % (|S|-1)!
             int: idx = k div f + 1; }
       in [ S[idx] ] ++ permutacion([ S[i] | i in index_set(S) where i != idx ], k mod f)
  endif;
% Todas las tuplas (ordenadas) de L dígitos distintos que suman 'suma'
function array[int,int] of int: tuplas(int: L, int: suma) =
  let { array[int] of int: cs = combinaciones(L, suma);
        int: f = product([ i | i in 1..L ]); }
  in array2d(1..length(cs) * f, 1..L,
             [ e | m in cs, k in 0..f-1, e in permutacion(set2array(digitosM[m]), k) ]);

% ---------------------------------------------------------------------
% 4. RESTRICCIONES DEL PROBLEMA
% ---------------------------------------------------------------------
% R2 (dígitos distintos en cada serie), con dos implementaciones
predicate distintos(array[int] of var int: v) =
  if impl = 1 then forall(p, q in index_set(v) where p < q)(v[p] != v[q])
  else alldifferent(v)
  endif;

constraint forall(s in SERIES)(
  let { array[int] of var int: v = [ x[c] | c in celdasS[s] ] } in
  if impl = 4 /\ largoS[s] <= maxTabla then
       table(v, tuplas(largoS[s], sumaS[s]))   % R1 /\ R2 juntas: v debe ser una tupla válida
  else
       sum(v) = sumaS[s]                       % R1: la serie suma lo que dice la pista
    /\ distintos(v)                            % R2: sin dígitos repetidos en la serie
  endif);

% ---------------------------------------------------------------------
% 5. RESTRICCIONES REDUNDANTES
% ---------------------------------------------------------------------
% RR1 (impl >= 3): cada casilla de una serie solo puede tomar dígitos que aparezcan en
% alguna combinación de largoS[s] dígitos distintos que sume sumaS[s].
% Es redundante porque cualquier solución de R1 /\ R2 la cumple.
constraint if impl >= 3 then
  forall(s in SERIES, c in celdasS[s])( x[c] in posiblesS[s] )
else true endif;

% ---------------------------------------------------------------------
% 6. RUPTURA DE SIMETRÍAS
% ---------------------------------------------------------------------
% No aplica: las pistas fijan la posición de cada número; ver informe.

% ---------------------------------------------------------------------
% 7. ESTRATEGIA DE BÚSQUEDA
% ---------------------------------------------------------------------
solve :: if strategy = 2 then int_search(x, first_fail, indomain_min)
         elseif strategy = 3 then int_search(x, dom_w_deg, indomain_split)
         else int_search(x, input_order, indomain_min)
         endif
      satisfy;

% ---------------------------------------------------------------------
% 8. SALIDA  (casilla negra = "V\H" con sus pistas; casilla blanca = dígito)
% ---------------------------------------------------------------------
function string: pV(int: v) = if v = 0 then "  " else show_int(2, v) endif;
function string: pH(int: h) = if h = 0 then "  " else show_int(-2, h) endif;
output ["impl=\(impl) strategy=\(strategy)\n"] ++
  [ if blanca[i,j] = 1 then "  " ++ show(x[num[i,j]]) ++ "   "
    elseif pistaV[i,j] + pistaH[i,j] = 0 then "  ##  "
    else pV(pistaV[i,j]) ++ "\\" ++ pH(pistaH[i,j]) ++ " " endif
    ++ if j = columnas then "\n" else "" endif
  | i in FILAS, j in COLS ];
