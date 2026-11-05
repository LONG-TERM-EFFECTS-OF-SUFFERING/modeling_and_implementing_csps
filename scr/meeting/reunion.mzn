% =====================================================================
% Taller 1 - Programación por Restricciones
% Ejercicio 2.5: Ubicación de personas en una reunión
% Autores: <Orlando Alexis Rengifo Mejia>
% Uso:     minizinc --solver gecode -s reunion.mzn tests/reunion_01.dzn -D "impl=1;strategy=1"
%
% Implementaciones (impl):
%   1 = Restricción de unicidad con desigualdades explícitas (!=)
%   2 = Restricción de unicidad con el predicado global alldifferent
%   3 = impl 2 + Ruptura de simetrías por reflexión (espejo de la fila)
% Estrategias (strategy):
%   1 = Orden de entrada de las variables de posición (input_order, indomain_min)
%   2 = Selección por tamaño de dominio dinámico (first_fail, indomain_min)
%   3 = Selección por valor mínimo del dominio (smallest, indomain_min)
% =====================================================================

include "alldifferent.mzn";

% =============================================================================
% 1. PARÁMETROS DE ENTRADA 
% =============================================================================
array[int] of string: personas; 
int: n = length(personas); 

array[int, 1..2] of int: next;
array[int, 1..2] of int: separate;
array[int, 1..3] of int: distance;

% ---------------------------------------------------------------------
% 2. PARÁMETROS DE EXPERIMENTACIÓN 
% ---------------------------------------------------------------------
int: impl;      
int: strategy;  
constraint assert(impl in 1..3 /\ strategy in 1..3, "impl debe estar en 1..3 y strategy en 1..3");

% =============================================================================
% 3. VARIABLES DE DECISIÓN
% =============================================================================
array[1..n] of var 1..n: pos;

% =============================================================================
% 4. RESTRICCIONES DEL PROBLEMA
% =============================================================================

% Impl 1 usa desigualdades binarias tradicionales, Impl 2 y 3 usan el predicado global unificado.
constraint if impl = 1 then 
    forall(p, q in 1..n where p < q)(pos[p] != pos[q])
else 
    alldifferent(pos)
endif;


constraint forall(k in index_set_1of2(next)) (
    abs(pos[next[k, 1]] - pos[next[k, 2]]) == 1
);

constraint forall(k in index_set_1of2(separate)) (
    abs(pos[separate[k, 1]] - pos[separate[k, 2]]) > 1
);

constraint forall(k in index_set_1of2(distance)) (
    let {
        int: pA = distance[k, 1],
        int: pB = distance[k, 2],
        int: M  = distance[k, 3]
    } in 
    abs(pos[pA] - pos[pB]) <= M + 1
);

% =============================================================================
% 5. RUPTURA DE SIMETRÍAS
% =============================================================================
constraint if impl = 3 then
    pos[1] <= pos[n]
else 
    true 
endif;

% =============================================================================
% 6. ESTRATEGIA DE BÚSQUEDA
% =============================================================================
solve :: if strategy = 2 then int_search(pos, first_fail, indomain_min)
         elseif strategy = 3 then int_search(pos, smallest, indomain_min)
         else int_search(pos, input_order, indomain_min)
         endif
      satisfy;

% =============================================================================
% 7. FORMATO DE SALIDA 
% =============================================================================
output ["impl=\(impl) strategy=\(strategy)\n"] ++
[
    "Posiciones asignadas (Persona -> Fila):\n"
] ++ [
    personas[i] ++ " en la posicion " ++ show(pos[i]) ++ "\n" | i in 1..n
] ++ [
    "\nOrden visual de la fila para la foto (de la posicion 1 a la n):\n" ++
    show([ personas[i] | p in 1..n, i in 1..n where fix(pos[i]) == p ])
];
