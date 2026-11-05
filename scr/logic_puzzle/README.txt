TALLER 1 - PROGRAMACIÓN POR RESTRICCIONES
Ejercicio 2.4: Acertijo lógico

REQUISITOS
  MiniZinc 2.9 o superior (paquete completo, que incluye Gecode y Chuffed).
  Probado con MiniZinc 2.9.3 y Gecode 6.3.0.

ARCHIVOS
  acertijo.mzn                 Modelo del acertijo lógico de los tres amigos.
  tests/acertijo_01.dzn        Instancia fija de control para activar el script del acertijo.
  run_tests.sh                 Corre todas las combinaciones instancia x implementación x estrategia.
  results/acertijo_gecode.csv  Estadísticas de todas las corridas (nodos, fallos, tiempos, estado).

CÓMO EJECUTAR UNA PRUEBA
  El modelo tiene dos parámetros de experimentación que se pasan con -D:
    impl      = qué implementación de las restricciones usar
    strategy  = qué estrategia de búsqueda usar

  minizinc --solver gecode -s acertijo.mzn tests/acertijo_01.dzn -D "impl=2;strategy=1"

  -s imprime las estadísticas (nodes, failures, peakDepth, solveTime, flatTime).
  -a busca todas las soluciones.
  En el MiniZinc IDE, al ejecutar se piden los valores de impl y strategy.

  impl 1 = Unicidad con desigualdades tradicionales (!=)
  impl 2 = Unicidad con alldifferent global optimizado
  impl 3 = impl 2 + restricción redundante RR1 (poda temprana por edad y música)
  strategy 1 = input_order / indomain_min
  strategy 2 = first_fail / indomain_min
  strategy 3 = smallest / indomain_min

  Formato de datos: Instancia fija. Pistas lógicas acopladas internamente en el modelo.

CÓMO REPETIR TODAS LAS PRUEBAS
  ./run_tests.sh [solver] [timeout_ms]      (por defecto: gecode 60000)
  Escribe results/acertijo_<solver>.csv. Cada corrida que llega al límite queda con estado "timeout".
