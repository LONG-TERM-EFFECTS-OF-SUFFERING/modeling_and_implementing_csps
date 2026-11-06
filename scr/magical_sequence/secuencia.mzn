% ==============================================================================
% Curso:      Programación con Restricciones
% Taller:     Taller 1 - Modelado como CSP
% Ejercicio:  2.3 Secuencia Mágica
%
% Uso:
%   minizinc --solver gecode -s secuencia.mzn tests/secuencia_01.dzn -D "impl=3;strategy=2"
%   Con -a enumera todas las secuencias mágicas de longitud n.
%
% Parámetros de experimentación (-D):
%   impl:
%     1 = Modelo base [R1] (conteo de ocurrencias)
%     2 = Modelo base + Redundante 1 [R1, RR1] (suma total = n)
%     3 = Modelo completo [R1, RR1, RR2] (suma ponderada = 0)
%   strategy:
%     0 = Búsqueda por defecto de Gecode (sin anotación)
%     1 = input_order, indomain_min, complete
%     2 = first_fail, indomain_min, complete
%     3 = dom_w_deg, indomain_min, complete
% ==============================================================================

% ------------------------------------------------------------------------------
% Parámetros y Validación de Entrada
% ------------------------------------------------------------------------------
int: n;
int: impl;
int: strategy;

constraint assert(n >= 1, "La longitud n debe ser al menos 1");
constraint assert(impl in 1..3, "impl debe estar entre 1 y 3");
constraint assert(strategy in 0..3, "strategy debe estar entre 0 y 3");

set of int: Index = 0..n-1;

% ------------------------------------------------------------------------------
% Variables y Dominios
% ------------------------------------------------------------------------------
array[Index] of var Index: x;

% ------------------------------------------------------------------------------
% Restricción del Problema (R1)
% ------------------------------------------------------------------------------
% [R1] El entero i ocurre exactamente x[i] veces en la secuencia
constraint forall(i in Index)(
    x[i] = sum(j in Index)( bool2int(x[j] == i) )
);

% ------------------------------------------------------------------------------
% Restricciones Redundantes (RR1, RR2)
% ------------------------------------------------------------------------------

% [RR1] La suma de las frecuencias de todos los números es igual a n
constraint if impl >= 2 then
    sum(i in Index)(x[i]) = n
else true endif;

% [RR2] Suma ponderada diofántica: (-1)*x[0] + ... + (n-2)*x[n-1] = 0
constraint if impl == 3 then
    sum(i in Index)((i - 1) * x[i]) = 0
else true endif;

% ------------------------------------------------------------------------------
% Rompimiento de Simetrías (RS1)
% ------------------------------------------------------------------------------
constraint true;

% ------------------------------------------------------------------------------
% Estrategias de Distribución / Búsqueda
% ------------------------------------------------------------------------------
solve :: if strategy == 1 then
    int_search(x, input_order, indomain_min, complete)
elseif strategy == 2 then
    int_search(x, first_fail, indomain_min, complete)
elseif strategy == 3 then
    int_search(x, dom_w_deg, indomain_min, complete)
else
    seq_search([])
endif satisfy;

% ------------------------------------------------------------------------------
% Salida
% ------------------------------------------------------------------------------
output [
    "Secuencia mágica (n = ", show(n), "):\n",
    show(x), "\n"
];