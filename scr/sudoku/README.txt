========================================================================
EJERCICIO 2.1: SUDOKU
========================================================================

ARCHIVOS INCLUIDOS:
  sudoku.mzn:
    Modelo parametrizado en MiniZinc. Acepta:
      - impl:
          1 = Desigualdades binarias por pares (!=) [R1, R2, R3].
          2 = Restricción global alldifferent [R1, R2, R3].
          3 = Restricción global alldifferent + Redundantes lineales de suma [RR1, RR2, RR3].
      - strategy:
          0 = Búsqueda por defecto del solver.
          1 = input_order con indomain_min.
          2 = first_fail con indomain_min.
          3 = dom_w_deg con indomain_min.

  tests/:
    sudoku_01.dzn: Instancia oficial del enunciado.
    sudoku_02.dzn: Instancia estándar de dificultad intermedia.
    sudoku_03.dzn: Instancia compleja para forzar exploración de nodos.
    sudoku_04.dzn: Instancia insatisfacible para validar detección de inconsistencia.

  run_tests.sh:
    Script en bash para ejecutar la matriz completa de pruebas bajo el
    protocolo estándar (Gecode, timeout de 60 segundos) y exportar las
    métricas a CSV.

  results/:
    sudoku_gecode.csv: Resultados consolidados de ejecución.

EJECUCIÓN INDIVIDUAL:
  minizinc --solver gecode -s sudoku.mzn tests/sudoku_01.dzn -D "impl=2;strategy=2"

EJECUCIÓN DE TODAS LAS PRUEBAS:
  ./run_tests.sh gecode 60000