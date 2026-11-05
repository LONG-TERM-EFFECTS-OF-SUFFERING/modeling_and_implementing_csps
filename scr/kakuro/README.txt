TALLER 1 - PROGRAMACIÓN POR RESTRICCIONES
Ejercicio 2.2: Kakuro

REQUISITOS
  MiniZinc 2.9 o superior (paquete completo, que incluye Gecode y Chuffed).
  Probado con MiniZinc 2.9.3 y Gecode 6.3.0.

ARCHIVOS
  kakuro.mzn                 Modelo.
  tests/kakuro_01.dzn        Kakuro 1 del enunciado (6 x 5).
  tests/kakuro_02.dzn        Kakuro 2 del enunciado (8 x 8).
  tests/kakuro_03..08.dzn    Kakuros 6x6 y 8x8 (easy, hard, super) del repositorio
                             oficial minizinc-benchmarks, convertidos a nuestro formato.
  tests/kakuro_09..11.dzn    Kakuros aleatorios de 12x12, 15x15 y 20x20 (más de una solución).
  run_tests.sh               Corre todas las combinaciones instancia x implementación x estrategia.
  results/kakuro_gecode.csv  Estadísticas de todas las corridas (nodos, fallos, tiempos, estado).

CÓMO EJECUTAR UNA PRUEBA
  El modelo tiene dos parámetros de experimentación que se pasan con -D:
    impl      = qué implementación de las restricciones usar
    strategy  = qué estrategia de búsqueda usar

  minizinc --solver gecode -s kakuro.mzn tests/kakuro_01.dzn -D "impl=3;strategy=3"

  -s imprime las estadísticas (nodes, failures, peakDepth, solveTime, flatTime).
  -a busca todas las soluciones.
  En el MiniZinc IDE, al ejecutar se piden los valores de impl y strategy.

  Recomendado: impl=3 strategy=3.

  impl 1 = suma + desigualdades por pares
  impl 2 = suma + alldifferent
  impl 3 = impl 2 + restricción redundante RR1 (dígitos posibles de cada serie)
  impl 4 = impl 3, con table en las series de hasta 5 casillas
  strategy 1 = input_order / indomain_min
  strategy 2 = first_fail / indomain_min
  strategy 3 = dom_w_deg / indomain_split

  Formato de datos: filas, columnas y tres matrices del tamaño del tablero:
    blanca (1 = casilla a llenar), pistaV (suma hacia abajo), pistaH (suma hacia la derecha);
    0 = no hay pista.

CÓMO REPETIR TODAS LAS PRUEBAS
  ./run_tests.sh [solver] [timeout_ms]      (por defecto: gecode 60000)
  Escribe results/kakuro_<solver>.csv. Cada corrida que llega al límite queda con estado "timeout".
