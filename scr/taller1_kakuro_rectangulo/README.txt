TALLER 1 - PROGRAMACIÓN POR RESTRICCIONES
Ejercicios 2.2 (Kakuro), 2.4 (Acertijo), 2.5 (Reunión) y 2.6 (Rectángulo)

REQUISITOS
  MiniZinc 2.9 o superior (paquete completo, que incluye Gecode y Chuffed).
  Probado con MiniZinc 2.9.3 y Gecode 6.3.0.

ARCHIVOS
  acertijo.mzn                Modelo del acertijo lógico de los tres amigos.
  reunion.mzn                 Modelo de la ubicación de personas en la fila.
  kakuro.mzn                  Modelo del Kakuro.
  rectangulo.mzn              Modelo del rectángulo.
  datos/acertijo_01.dzn       Instancia fija de control para activar el script del acertijo.
  datos/reunion_01.dzn        Ejemplo del enunciado (8 personas con preferencias de distancia).
  datos/reunion_02..05.dzn    Instancias medianas (4 a 7 personas) con restricciones densas.
  datos/reunion_06..10.dzn    Instancias grandes y pruebas de estrés (8 a 11 personas).
  datos/kakuro_01.dzn         Kakuro 1 del enunciado (6 x 5).
  datos/kakuro_02.dzn         Kakuro 2 del enunciado (8 x 8).
  datos/kakuro_03..08.dzn     Kakuros 6x6 y 8x8 (easy, hard, super) del repositorio
                              oficial minizinc-benchmarks, convertidos a nuestro formato.
  datos/kakuro_09..11.dzn     Kakuros aleatorios de 12x12, 15x15 y 20x20 (más de una solución).
  datos/rectangulo_01.dzn     Ejemplo del enunciado (3,2,2,1,1,1 en 5 x 4).
  datos/rectangulo_02.dzn     Rectángulo perfecto de Moroń: 9 cuadrados distintos en 33 x 32.
  datos/rectangulo_03.dzn     Rectángulo perfecto de orden 9 en 69 x 61.
  datos/rectangulo_04.dzn     Cuadrado perfecto de Duijvestijn: 21 cuadrados distintos en 112 x 112.
  datos/rectangulo_05..07.dzn Rectángulos generados al azar (10x8, 14x11, 20x16), muchos tamaños repetidos.
  datos/rectangulo_08.dzn     Los cuadrados de rectangulo_06 en 22 x 7 (factible, muchas simetrías).
  datos/rectangulo_09..10.dzn Instancias INFACTIBLES (las áreas cuadran, pero no se pueden acomodar).
  correr_pruebas.sh           Corre todas las combinaciones instancia x implementación x estrategia.
  resultados/*.csv            Estadísticas de todas las corridas (nodos, fallos, tiempos, estado).

CÓMO EJECUTAR UNA PRUEBA
  Cada modelo tiene dos parámetros de experimentación que se pasan con -D:
    impl      = qué implementación de las restricciones usar
    strategy  = qué estrategia de búsqueda usar

  minizinc --solver gecode -s acertijo.mzn datos/acertijo_01.dzn -D "impl=2;strategy=1"
  minizinc --solver gecode -s reunion.mzn datos/reunion_01.dzn -D "impl=2;strategy=1"
  minizinc --solver gecode -s kakuro.mzn datos/kakuro_01.dzn -D "impl=3;strategy=3"
  minizinc --solver gecode -s rectangulo.mzn datos/rectangulo_01.dzn -D "impl=5;strategy=3"

  -s imprime las estadísticas (nodes, failures, peakDepth, solveTime, flatTime).
  -a busca todas las soluciones (útil para ver el efecto de la ruptura de simetrías).
  En el MiniZinc IDE, al ejecutar se piden los valores de impl y strategy.

ACERTIJO LÓGICO (acertijo.mzn)
  impl 1 = Unicidad con desigualdades tradicionales (!=)
  impl 2 = Unicidad con alldifferent global optimizado
  impl 3 = impl 2 + restricción redundante RR1 (poda temprana por edad y música)
  strategy 1 = input_order / indomain_min
  strategy 2 = first_fail / indomain_min
  strategy 3 = smallest / indomain_min
  Formato de datos: Instancia fija. Pistas lógicas acopladas internamente en el modelo.

UBICACIÓN DE PERSONAS (reunion.mzn)
  impl 1 = Unicidad con desigualdades binarias tradicionales (!=)
  impl 2 = Unicidad con alldifferent global optimizado
  impl 3 = impl 2 + ruptura de simetrías RS1 (por reflexión/espejo de la fila)
  strategy 1 = variables de posición en orden, input_order / indomain_min
  strategy 2 = selección por menor tamaño de dominio, first_fail / indomain_min
  strategy 3 = selección por valor mínimo del dominio, smallest / indomain_min
  Formato de datos: Arreglo de strings para personas, matrices next y separate para 
                    proximidad, y matriz de distancias máximas.

KAKURO (kakuro.mzn)
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

RECTÁNGULO (rectangulo.mzn)
  impl 1 = no solapamiento con disyunciones
  impl 2 = no solapamiento con diffn
  impl 3 = impl 2 + cumulative en x y en y (redundantes RR1, RR2)
  impl 4 = impl 3 + cobertura exacta de cada columna y fila (redundantes RR3, RR4)
  impl 5 = impl 4 + ruptura de simetrías (RS1, RS2, RS3)
  strategy 1 = cuadrado por cuadrado (x1,y1,x2,y2,...), input_order / indomain_min
  strategy 2 = primero todas las x y luego todas las y, de mayor a menor, input_order / indomain_min
  strategy 3 = como 2, con smallest / indomain_min ("llenar de izquierda a derecha")
  strategy 4 = dom_w_deg / indomain_min sobre todas las coordenadas
  Formato de datos: formato: ancho, alto, n y lado (arreglo con el lado de cada cuadrado).
  La suma de las áreas debe ser ancho * alto (el modelo lo verifica con assert).

CÓMO REPETIR TODAS LAS PRUEBAS
  ./correr_pruebas.sh acertijo "1 2 3" "1 2 3" gecode 60000
  ./correr_pruebas.sh reunion "1 2 3" "1 2 3" gecode 60000
  ./correr_pruebas.sh kakuro "1 2 3 4" "1 2 3" gecode 60000
  ./correr_pruebas.sh rectangulo "1 2 3 4 5" "1 2 3 4" gecode 60000
  (Argumentos: modelo, implementaciones, estrategias, solver, límite de tiempo en ms.)
  Cada corrida que llega al límite queda con estado "timeout".
