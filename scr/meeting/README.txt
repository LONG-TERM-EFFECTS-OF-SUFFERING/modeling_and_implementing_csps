TALLER 1 - PROGRAMACIÓN POR RESTRICCIONES
Ejercicio 2.5: Ubicación de personas en una reunión

REQUISITOS
  MiniZinc 2.9 o superior (paquete completo, que incluye Gecode y Chuffed).
  Probado con MiniZinc 2.9.3 y Gecode 6.3.0.

ARCHIVOS
  reunion.mzn                 Modelo de la ubicación de personas en la fila.
  tests/reunion_01.dzn        Ejemplo del enunciado (8 personas con preferencias de distancia).
  tests/reunion_02..05.dzn    Instancias medianas (4 a 7 personas) con restricciones densas.
  tests/reunion_06..10.dzn    Instancias grandes y pruebas de estrés (8 a 11 personas).
  run_tests.sh                Corre todas las combinaciones instancia x implementación x estrategia.
  results/reunion_gecode.csv  Estadísticas de todas las corridas (nodos, fallos, tiempos, estado).

CÓMO EJECUTAR UNA PRUEBA
  El modelo tiene dos parámetros de experimentación que se pasan con -D:
    impl      = qué implementación de las restricciones usar
    strategy  = qué estrategia de búsqueda usar

  minizinc --solver gecode -s reunion.mzn tests/reunion_01.dzn -D "impl=2;strategy=1"

  -s imprime las estadísticas (nodes, failures, peakDepth, solveTime, flatTime).
  -a busca todas las soluciones (útil para ver el efecto de la ruptura de simetrías).
  En el MiniZinc IDE, al ejecutar se piden los valores de impl y strategy.

  impl 1 = Unicidad con desigualdades binarias tradicionales (!=)
  impl 2 = Unicidad con alldifferent global optimizado
  impl 3 = impl 2 + ruptura de simetrías RS1 (por reflexión/espejo de la fila)
  strategy 1 = variables de posición en orden, input_order / indomain_min
  strategy 2 = selección por menor tamaño de dominio, first_fail / indomain_min
  strategy 3 = selección por valor mínimo del dominio, smallest / indomain_min

  Formato de datos: Arreglo de strings para personas, matrices next y separate para
                    proximidad, y matriz de distancias máximas.

CÓMO REPETIR TODAS LAS PRUEBAS
  ./run_tests.sh [solver] [timeout_ms]      (por defecto: gecode 60000)
  Escribe results/reunion_<solver>.csv. Cada corrida que llega al límite queda con estado "timeout".
