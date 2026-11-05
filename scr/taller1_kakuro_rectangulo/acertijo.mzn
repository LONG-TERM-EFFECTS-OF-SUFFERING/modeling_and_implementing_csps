% =====================================================================
% Taller 1 - Programación por Restricciones
% Ejercicio 2.4: Acertijo Lógico
% Autores: <Orlando Alexis Rengifo Mejia>
% Uso:     minizinc --solver gecode -s acertijo.mzn datos/acertijo_01.dzn -D "impl=1;strategy=1"
%
% Implementaciones (impl):
%   1 = Restricciones de unicidad con desigualdades tradicionales (!=)
%   2 = Restricciones de unicidad optimizadas con el predicado global alldifferent
%   3 = impl 2 + Restricción redundante (Deducción lógica directa del dominio)
% Estrategias (strategy):
%   1 = Orden de entrada de las variables (input_order, indomain_min)
%   2 = Selección por tamaño de dominio dinámico (first_fail, indomain_min)
%   3 = Selección por valor mínimo del dominio (smallest, indomain_min)
% =====================================================================

include "alldifferent.mzn";

% ---------------------------------------------------------------------
% PARÁMETROS DE EXPERIMENTACIÓN (Sincronizados con el script global)
% ---------------------------------------------------------------------
int: impl;      % Por defecto en 2 para usar lu lógica base directo en el IDE
int: strategy;  % Por defecto en 1 para el IDE

constraint assert(impl in 1..3 /\ strategy in 1..3, "impl debe estar en 1..3 y strategy en 1..3");

% =============================================================================
% 1. DEFINICIÓN DE DOMINIOS Y ENUMS
% =============================================================================
enum Nombres    = {Juan, Dario, Oscar};
enum Apellidos  = {Lopez, Gonzales, Garcia};
enum TipoMusica = {Clasica, Pop, Jazz};

% =============================================================================
% 2. DECLARACIÓN DE VARIABLES DE DECISIÓN
% =============================================================================
array [Nombres] of var 24..26: edad;
array [Nombres] of var Apellidos: apellido;
array [Nombres] of var TipoMusica: musica;

% =============================================================================
% 3. RESTRICCIONES DE UNICIDAD
% =============================================================================
constraint if impl = 1 then
    % Desigualdades explícitas binarias manuales
    (edad[Juan] != edad[Dario] /\ edad[Juan] != edad[Oscar] /\ edad[Dario] != edad[Oscar]) /\
    (apellido[Juan] != apellido[Dario] /\ apellido[Juan] != apellido[Oscar] /\ apellido[Dario] != apellido[Oscar]) /\
    (musica[Juan] != musica[Dario] /\ musica[Juan] != musica[Oscar] /\ musica[Dario] != musica[Oscar])
else
    % Predicado global optimizado 
    alldifferent(edad) /\
    alldifferent(apellido) /\
    alldifferent(musica)
endif;

% =============================================================================
% 4. RESTRICCIONES DE LÓGICA 
% =============================================================================

constraint forall(j in Nombres)(
    apellido[j] == Gonzales -> (edad[Juan] > edad[j] /\ musica[j] == Clasica)
);


constraint forall(i in Nombres)(
    musica[i] == Pop -> (apellido[i] != Garcia /\ edad[i] != 24)
);


constraint (apellido[Oscar] != Lopez /\ edad[Oscar] == 25) 
        /\ (musica[Dario] != Jazz);

% =============================================================================
% 5. RESTRICCIONES REDUNDANTES
% =============================================================================
constraint if impl = 3 then
    edad[Juan] != 24 /\ musica[Juan] != Clasica
else
    true
endif;

% =============================================================================
% 6. ESTRATEGIA DE BÚSQUEDA
% =============================================================================
array[int] of var int: vars_busqueda = [edad[i] | i in Nombres] ++ [apellido[i] | i in Nombres] ++ [musica[i] | i in Nombres];

solve :: if strategy = 2 then int_search(vars_busqueda, first_fail, indomain_min)
         elseif strategy = 3 then int_search(vars_busqueda, smallest, indomain_min)
         else int_search(vars_busqueda, input_order, indomain_min)
         endif
      satisfy;

% =============================================================================
% 7. FORMATO DE SALIDA
% =============================================================================
output ["impl=\(impl) strategy=\(strategy)\n"] ++
[
    "Nombre\tApellido\tEdad\tMusica\n"
] ++ [
    show(i) ++ "\t" ++
    show(apellido[i]) ++
    (if i == Dario then "\t" else "\t\t" endif) ++
    show(edad[i]) ++ "\t" ++
    show(musica[i]) ++ "\n"
    | i in Nombres
];
