% =====================================================================
% Taller 1 - Programación por Restricciones
% Ejercicio 2.6: Construcción de un rectángulo
% Autores: Brandon Calderón Prieto (2125974)
% Uso:     minizinc --solver gecode -s rectangulo.mzn tests/rectangulo_01.dzn -D "impl=5;strategy=3"
%
% Implementaciones (impl):
%   1 = R2 (no solapamiento) con disyunciones explícitas
%   2 = R2 con la restricción global diffn
%   3 = impl 2 + redundantes RR1 y RR2 (cumulative en cada eje: "a lo más")
%   4 = impl 3 + redundantes RR3 y RR4 (cobertura exacta de cada columna y fila)
%   5 = impl 4 + ruptura de simetrías RS1, RS2, RS3
% Estrategias (strategy):
%   1 = cuadrado por cuadrado en el orden de los datos: x1,y1,x2,y2,... (input_order, indomain_min)
%   2 = primero todas las x, luego todas las y, del cuadrado más grande al más pequeño
%   3 = como 2, pero eligiendo siempre la variable con el menor valor posible (smallest):
%       "llenar de izquierda a derecha"
%   4 = dom_w_deg / indomain_min sobre todas las coordenadas
% =====================================================================

include "globals.mzn";

% ---------------------------------------------------------------------
% 1. PARÁMETROS (vienen del .dzn)
% ---------------------------------------------------------------------
int: ancho;                          % W: ancho del rectángulo
int: alto;                           % H: alto del rectángulo
int: n;                              % número de cuadrados
set of int: CUADRADOS = 1..n;
array[CUADRADOS] of int: lado;       % lado[i] = longitud del lado del cuadrado i

% --- Parámetros derivados ---
% Índices de los cuadrados ordenados de mayor a menor lado (empates: menor índice primero)
array[CUADRADOS] of CUADRADOS: orden = arg_sort([ -lado[i] | i in CUADRADOS ]);
% El cuadrado más grande (si hay varios iguales, el de menor índice)
CUADRADOS: grande = orden[1];
bool: grandeUnico = (n = 1) \/ (lado[orden[2]] < lado[grande]);

% --- Validación de los datos ---
constraint assert(forall(i in CUADRADOS)(lado[i] >= 1 /\ lado[i] <= min(ancho, alto)),
  "Datos inválidos: todo cuadrado debe caber dentro del rectángulo");
constraint assert(sum(i in CUADRADOS)(lado[i] * lado[i]) = ancho * alto,
  "Datos inválidos: la suma de las áreas de los cuadrados debe ser ancho * alto");

% ---------------------------------------------------------------------
% 2. PARÁMETROS DE EXPERIMENTACIÓN (se pasan con -D "impl=..;strategy=..")
% ---------------------------------------------------------------------
int: impl;
int: strategy;
constraint assert(impl in 1..5 /\ strategy in 1..4, "impl debe estar en 1..5 y strategy en 1..4");

% ---------------------------------------------------------------------
% 3. VARIABLES DE DECISIÓN
% ---------------------------------------------------------------------
% (x[i], y[i]) = esquina inferior izquierda del cuadrado i.
% Dominios ajustados: x[i] en 0..ancho-lado[i] y y[i] en 0..alto-lado[i]
% (así R1 "el cuadrado queda dentro del rectángulo" está garantizada por el dominio).
array[CUADRADOS] of var int: x = [ let { var 0..ancho - lado[i]: v } in v | i in CUADRADOS ];
array[CUADRADOS] of var int: y = [ let { var 0..alto  - lado[i]: v } in v | i in CUADRADOS ];

% ---------------------------------------------------------------------
% 4. RESTRICCIONES DEL PROBLEMA
% ---------------------------------------------------------------------
% R1: cada cuadrado queda dentro del rectángulo -> garantizada por los dominios.

% R2: dos cuadrados distintos no se solapan
predicate no_solapan(var int: x1, var int: y1, int: s1, var int: x2, var int: y2, int: s2) =
     x1 + s1 <= x2      % 1 está a la izquierda de 2
  \/ x2 + s2 <= x1      % 2 está a la izquierda de 1
  \/ y1 + s1 <= y2      % 1 está debajo de 2
  \/ y2 + s2 <= y1;     % 2 está debajo de 1

constraint if impl = 1 then
  forall(i, j in CUADRADOS where i < j)(no_solapan(x[i], y[i], lado[i], x[j], y[j], lado[j]))
else
  diffn(x, y, lado, lado)
endif;

% R3: no quedan huecos -> implicada por R1 + R2 + (suma de áreas = ancho*alto), ver informe.

% ---------------------------------------------------------------------
% 5. RESTRICCIONES REDUNDANTES (impl >= 3 y impl >= 4)
% ---------------------------------------------------------------------
% RR1: toda recta vertical corta cuadrados cuyos lados suman a lo más 'alto'.
%      Se ve cada cuadrado como una "tarea" que empieza en x[i], dura lado[i]
%      y consume lado[i] unidades de un recurso de capacidad 'alto'.
% RR2: lo mismo con rectas horizontales y capacidad 'ancho'.
constraint if impl >= 3 then
     cumulative(x, lado, lado, alto)
  /\ cumulative(y, lado, lado, ancho)
else true endif;

% RR3: como no hay huecos, cada columna [t, t+1) queda cubierta EXACTAMENTE:
%      los cuadrados que la atraviesan suman exactamente 'alto' (no solo "a lo más").
% RR4: lo mismo para cada fila [t, t+1) con 'ancho'.
%      No existe una global para "exactamente", así que se descompone con bool2int.
constraint if impl >= 4 then
     forall(t in 0..ancho - 1)(
       sum(i in CUADRADOS)(lado[i] * bool2int(x[i] <= t /\ t < x[i] + lado[i])) = alto)
  /\ forall(t in 0..alto - 1)(
       sum(i in CUADRADOS)(lado[i] * bool2int(y[i] <= t /\ t < y[i] + lado[i])) = ancho)
else true endif;

% ---------------------------------------------------------------------
% 6. RUPTURA DE SIMETRÍAS (impl = 5)
% ---------------------------------------------------------------------
constraint if impl = 5 then
     % RS1: cuadrados del mismo tamaño son intercambiables.
     %      Se ordenan por posición (primero x, luego y) según su índice.
     forall(k in 1..n-1 where lado[orden[k]] = lado[orden[k+1]])(
       lex_less([x[orden[k]], y[orden[k]]], [x[orden[k+1]], y[orden[k+1]]]))
     % RS2: reflejar el rectángulo (izquierda-derecha y arriba-abajo) da otra solución.
     %      Se obliga al cuadrado más grande a estar en el cuadrante inferior izquierdo.
  /\ 2 * x[grande] <= ancho - lado[grande]
  /\ 2 * y[grande] <= alto  - lado[grande]
     % RS3: si el rectángulo es un cuadrado, también se puede transponer (x <-> y).
     %      Solo es seguro si el cuadrado más grande es único.
  /\ (if ancho = alto /\ grandeUnico then x[grande] <= y[grande] else true endif)
else true endif;

% ---------------------------------------------------------------------
% 7. ESTRATEGIA DE BÚSQUEDA
% ---------------------------------------------------------------------
array[int] of var int: xyDatos = [ v | i in CUADRADOS, v in [x[i], y[i]] ];   % x1,y1,x2,y2,...
array[int] of var int: xOrd    = [ x[orden[k]] | k in CUADRADOS ];            % de mayor a menor
array[int] of var int: yOrd    = [ y[orden[k]] | k in CUADRADOS ];

solve :: if strategy = 1 then
           int_search(xyDatos, input_order, indomain_min)
         elseif strategy = 2 then
           seq_search([ int_search(xOrd, input_order, indomain_min),
                        int_search(yOrd, input_order, indomain_min) ])
         elseif strategy = 3 then
           seq_search([ int_search(xOrd, smallest, indomain_min),
                        int_search(yOrd, smallest, indomain_min) ])
         else
           int_search(xOrd ++ yOrd, dom_w_deg, indomain_min)
         endif
      satisfy;

% ---------------------------------------------------------------------
% 8. SALIDA  (coordenadas + dibujo con una letra por cuadrado; fila de arriba = y más alto)
% ---------------------------------------------------------------------
array[1..52] of string: letra = [ "A","B","C","D","E","F","G","H","I","J","K","L","M",
  "N","O","P","Q","R","S","T","U","V","W","X","Y","Z","a","b","c","d","e","f","g","h",
  "i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z" ];
output ["impl=\(impl) strategy=\(strategy)\n"] ++
  [ letra[(i - 1) mod 52 + 1] ++ " (lado \(lado[i])): x=\(x[i]) y=\(y[i])\n" | i in CUADRADOS ] ++
  if ancho <= 40 then
    [ concat([ letra[(i - 1) mod 52 + 1] | i in CUADRADOS
               where fix(x[i]) <= c /\ c < fix(x[i]) + lado[i] /\ fix(y[i]) <= r /\ r < fix(y[i]) + lado[i] ])
      ++ if c = ancho - 1 then "\n" else "" endif
    | r in reverse(0..alto - 1), c in 0..ancho - 1 ]
  else [] endif;
