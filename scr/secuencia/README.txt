========================================================================
EJERCICIO 2.3: SECUENCIA MÁGICA
========================================================================

ARCHIVOS INCLUIDOS:
  secuencia.mzn:
    Modelo CSP para enumerar y encontrar secuencias mágicas de tamaño n.
    Parámetros configurables (-D):
      - impl:
          1 = Modelo base [R1] (conteo de ocurrencias).
          2 = Modelo base + Redundante 1 [R1, RR1] (suma total = n).
          3 = Modelo completo [R1, RR1, RR2] (suma ponderada = 0).
      - strategy:
          0 = Búsqueda por defecto de Gecode.
          1 = input_order con indomain_min.
          2 = first_fail con indomain_min.
          3 = dom_w_deg con indomain_min.

  tests/:
    secuencia_01.dzn: n = 4 (instancia pequeña, posee 2 soluciones).
    secuencia_02.dzn: n = 7.
    secuencia_03.dzn: n = 10.
    secuencia_04.dzn: n = 20.
    secuencia_05.dzn: n = 50 (prueba de estrés para observar poda).
    secuencia_06.dzn: n = 3 (instancia insatisfacible).

  run_tests.sh:
    Script en bash para ejecutar la matriz de pruebas y generar el CSV.

  results/:
    secuencia_gecode.csv: Métricas recolectadas del solver.

EJECUCIÓN INDIVIDUAL:
  minizinc --solver gecode -s secuencia.mzn tests/secuencia_01.dzn -D "impl=3;strategy=2"

EJECUCIÓN DE TODAS LAS PRUEBAS:
  ./run_tests.sh gecode 60000