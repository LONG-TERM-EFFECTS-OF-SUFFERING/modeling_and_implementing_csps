% ==============================================================================
% Curso:      Programación con Restricciones
% Taller:     Taller 1 - Modelado como CSP
% Ejercicio:  2.1 Sudoku
%
% Uso:
%   minizinc --solver gecode -s sudoku.mzn tests/sudoku_01.dzn -D "impl=2;strategy=2"
%
% Parámetros de experimentación (-D):
%   impl:
%     1 = Desigualdades binarias por pares (!=) [R1, R2, R3]
%     2 = Restricción global alldifferent [R1, R2, R3]
%     3 = Restricción global alldifferent + Redundantes de suma 45 [R1, R2, R3, RR1, RR2, RR3]
%   strategy:
%     0 = Búsqueda por defecto del solver (sin anotación)
%     1 = input_order, indomain_min, complete
%     2 = first_fail, indomain_min, complete
%     3 = dom_w_deg, indomain_min, complete
% ==============================================================================

include "alldifferent.mzn";

% ------------------------------------------------------------------------------
% Parámetros y Validación de Datos
% ------------------------------------------------------------------------------
int: n = 9;
int: b = 3;

array[1..n, 1..n] of 0..n: start;

% Validaciones defensivas de entrada (asserts)
constraint assert(
    card(index_set_1of2(start)) == n /\ card(index_set_2of2(start)) == n,
    "El tablero de entrada debe ser de dimensiones 9x9"
);
constraint assert(
    forall(i, j in 1..n)(start[i, j] >= 0 /\ start[i, j] <= n),
    "Las pistas del tablero deben estar acotadas entre 0 y 9"
);

int: impl;
int: strategy;

constraint assert(impl in 1..3, "impl debe estar entre 1 y 3");
constraint assert(strategy in 0..3, "strategy debe estar entre 0 y 3");

% ------------------------------------------------------------------------------
% Variables y Dominios
% ------------------------------------------------------------------------------
% Dominio preciso: cada celda toma un valor de 1 a 9.
array[1..n, 1..n] of var 1..n: s;

% Fijar pistas iniciales
constraint forall(i, j in 1..n where start[i, j] > 0)(
    s[i, j] = start[i, j]
);

% ------------------------------------------------------------------------------
% Restricciones del Problema (R1, R2, R3)
% ------------------------------------------------------------------------------

% [R1] Filas con valores mutuamente distintos
constraint if impl == 1 then
    forall(i in 1..n, j1, j2 in 1..n where j1 < j2)(
        s[i, j1] != s[i, j2]
    )
else
    forall(i in 1..n)(
        alldifferent([s[i, j] | j in 1..n])
    )
endif;

% [R2] Columnas con valores mutuamente distintos
constraint if impl == 1 then
    forall(j in 1..n, i1, i2 in 1..n where i1 < i2)(
        s[i1, j] != s[i2, j]
    )
else
    forall(j in 1..n)(
        alldifferent([s[i, j] | i in 1..n])
    )
endif;

% [R3] Subcuadrículas de 3x3 con valores mutuamente distintos
constraint if impl == 1 then
    forall(bi, bj in 0..2)(
        forall(r1, c1, r2, c2 in 1..3 where (r1 < r2) \/ (r1 == r2 /\ c1 < c2))(
            s[3*bi + r1, 3*bj + c1] != s[3*bi + r2, 3*bj + c2]
        )
    )
else
    forall(bi, bj in 0..2)(
        alldifferent([s[3*bi + r, 3*bj + c] | r, c in 1..3])
    )
endif;

% ------------------------------------------------------------------------------
% Restricciones Redundantes (RR1, RR2, RR3)
% ------------------------------------------------------------------------------

% [RR1] Suma de cada fila igual a 45
constraint if impl == 3 then
    forall(i in 1..n)(
        sum(j in 1..n)(s[i, j]) = 45
    )
else true endif;

% [RR2] Suma de cada columna igual a 45
constraint if impl == 3 then
    forall(j in 1..n)(
        sum(i in 1..n)(s[i, j]) = 45
    )
else true endif;

% [RR3] Suma de cada región de 3x3 igual a 45
constraint if impl == 3 then
    forall(bi, bj in 0..2)(
        sum(r, c in 1..3)(s[3*bi + r, 3*bj + c]) = 45
    )
else true endif;

% ------------------------------------------------------------------------------
% Rompimiento de Simetrías (RS1)
% ------------------------------------------------------------------------------
% [RS1] En presencia de pistas iniciales fijas (tablero parcialmente lleno),
% cualquier simetría del Sudoku vacío queda automáticamente destruida.
% Por tanto, RS1 permanece como vacía (true) para no eliminar la solución única.
constraint true;

% ------------------------------------------------------------------------------
% Estrategias de Distribución / Búsqueda
% ------------------------------------------------------------------------------
solve :: if strategy == 1 then
    int_search(array1d(s), input_order, indomain_min, complete)
elseif strategy == 2 then
    int_search(array1d(s), first_fail, indomain_min, complete)
elseif strategy == 3 then
    int_search(array1d(s), dom_w_deg, indomain_min, complete)
else
    seq_search([]) % Búsqueda por defecto de Gecode
endif satisfy;

% ------------------------------------------------------------------------------
% Salida
% ------------------------------------------------------------------------------
output [
    show(s[i, j]) ++ 
    (if j == n then 
        "\n" ++ (if i mod 3 == 0 /\ i != n then "------+-------+------\n" else "" endif)
     else 
        (if j mod 3 == 0 then " | " else " " endif)
     endif)
    | i in 1..n, j in 1..n
];