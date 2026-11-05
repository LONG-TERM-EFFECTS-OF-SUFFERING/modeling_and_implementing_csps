#!/usr/bin/env bash
# Corre acertijo.mzn sobre cada instancia de tests/ con todas las combinaciones
# impl x strategy, y guarda las estadísticas de MiniZinc en results/acertijo_<solver>.csv.
#
# Uso:  ./run_tests.sh [solver] [timeout_ms]     (por defecto: gecode 60000)
#
# Columnas: tiempo_compilacion_s = flatTime (MiniZinc -> FlatZinc),
#           tiempo_s = solveTime (búsqueda), nodos, fallos, profundidad = peakDepth.
# estado: sat = encontró solución, insat = probó que no hay, timeout = se acabó el tiempo.

set -u
cd "$(dirname "$0")"
MODELO=acertijo
IMPLS="1 2 3"
ESTRATEGIAS="1 2 3"
SOLVER=${1:-gecode}; TIMEOUT=${2:-60000}
mkdir -p results
CSV="results/${MODELO}_${SOLVER}.csv"
echo "instancia,impl,estrategia,solver,estado,tiempo_compilacion_s,tiempo_s,nodos,fallos,profundidad" > "$CSV"

stat() { echo "$SALIDA" | grep -m1 "^%%%mzn-stat: $1=" | cut -d= -f2; }

for dzn in tests/*.dzn; do
  for i in $IMPLS; do
    for s in $ESTRATEGIAS; do
      SALIDA=$(minizinc --solver "$SOLVER" -s --time-limit "$TIMEOUT" \
               "${MODELO}.mzn" "$dzn" -D "impl=$i;strategy=$s" 2>&1)
      if   echo "$SALIDA" | grep -q "=====UNSATISFIABLE====="; then EST=insat
      elif echo "$SALIDA" | grep -q "^----------";              then EST=sat
      else EST=timeout; fi
      echo "$(basename "$dzn" .dzn),$i,$s,$SOLVER,$EST,$(stat flatTime),$(stat solveTime),$(stat nodes),$(stat failures),$(stat peakDepth)" >> "$CSV"
    done
  done
done
echo "Resultados en $CSV"
