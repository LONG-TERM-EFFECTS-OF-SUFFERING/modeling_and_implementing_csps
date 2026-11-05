TALLER 1 - PROGRAMACIÓN POR RESTRICCIONES
Ejercicio 2.6: Construcción de un rectángulo

REQUISITOS
  MiniZinc 2.9 o superior (paquete completo, que incluye Gecode y Chuffed).
  Probado con MiniZinc 2.9.3 y Gecode 6.3.0.

ARCHIVOS
  rectangulo.mzn                 Modelo.
  tests/rectangulo_01.dzn        Ejemplo del enunciado (3,2,2,1,1,1 en 5 x 4).
  tests/rectangulo_02.dzn        Rectángulo perfecto de Moroń: 9 cuadrados distintos en 33 x 32.
  tests/rectangulo_03.dzn        Rectángulo perfecto de orden 9 en 69 x 61.
  tests/rectangulo_04.dzn        Cuadrado perfecto de Duijvestijn: 21 cuadrados distintos en 112 x 112.
  tests/rectangulo_05..07.dzn    Rectángulos generados al azar (10x8, 14x11, 20x16), muchos tamaños repetidos.
  tests/rectangulo_08.dzn        Los cuadrados de rectangulo_06 en 22 x 7 (factible, muchas simetrías).
  tests/rectangulo_09..10.dzn    Instancias INFACTIBLES (las áreas cuadran, pero no se pueden acomodar).
  run_tests.sh                   Corre todas las combinaciones instancia x implementación x estrategia.
  results/rectangulo_gecode.csv  Estadísticas de todas las corridas (nodos, fallos, tiempos, estado).

CÓMO EJECUTAR UNA PRUEBA
  El modelo tiene dos parámetros de experimentación que se pasan con -D:
    impl      = qué implementación de las restricciones usar
    strategy  = qué estrategia de búsqueda usar

  minizinc --solver gecode -s rectangulo.mzn tests/rectangulo_01.dzn -D "impl=5;strategy=3"

  -s imprime las estadísticas (nodes, failures, peakDepth, solveTime, flatTime).
  -a busca todas las soluciones (útil para ver el efecto de la ruptura de simetrías).
  En el MiniZinc IDE, al ejecutar se piden los valores de impl y strategy.

  Recomendado: impl=5 strategy=3.

  impl 1 = no solapamiento con disyunciones
  impl 2 = no solapamiento con diffn
  impl 3 = impl 2 + cumulative en x y en y (redundantes RR1, RR2)
  impl 4 = impl 3 + cobertura exacta de cada columna y fila (redundantes RR3, RR4)
  impl 5 = impl 4 + ruptura de simetrías (RS1, RS2, RS3)
  strategy 1 = cuadrado por cuadrado (x1,y1,x2,y2,...), input_order / indomain_min
  strategy 2 = primero todas las x y luego todas las y, de mayor a menor, input_order / indomain_min
  strategy 3 = como 2, con smallest / indomain_min ("llenar de izquierda a derecha")
  strategy 4 = dom_w_deg / indomain_min sobre todas las coordenadas

  Formato de datos: ancho, alto, n y lado (arreglo con el lado de cada cuadrado).
  La suma de las áreas debe ser ancho * alto (el modelo lo verifica con assert).

CÓMO REPETIR TODAS LAS PRUEBAS
  ./run_tests.sh [solver] [timeout_ms]      (por defecto: gecode 60000)
  Escribe results/rectangulo_<solver>.csv. Cada corrida que llega al límite queda con estado "timeout".
