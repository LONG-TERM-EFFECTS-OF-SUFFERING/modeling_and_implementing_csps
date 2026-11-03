#!/usr/bin/env bash
# Ejecuta un modelo con todas sus instancias y variantes, y guarda las
# estadísticas de MiniZinc en un CSV con el mismo formato para todos los ejercicios.
#
# Uso:   ./correr_pruebas.sh <modelo> "<impls>" "<estrategias>" [solver] [timeout_ms]
# Ej.:   ./correr_pruebas.sh kakuro "1 2 3 4" "1 2 3" gecode 60000
# Busca las instancias en datos/<modelo>_*.dzn y escribe resultados/<modelo>_<solver>.csv
#
# Columnas: tiempo_compilacion_s = flatTime (MiniZinc -> FlatZinc),
#           tiempo_s = solveTime (búsqueda), nodos, fallos, profundidad = peakDepth.
# estado: sat = encontró solución, insat = probó que no hay, timeout = se acabó el tiempo.

set -u
MODELO=$1; IMPLS=$2; ESTRATEGIAS=$3; SOLVER=${4:-gecode}; TIMEOUT=${5:-60000}
mkdir -p resultados
CSV="resultados/${MODELO}_${SOLVER}.csv"
echo "instancia,impl,estrategia,solver,estado,tiempo_compilacion_s,tiempo_s,nodos,fallos,profundidad" > "$CSV"

for dzn in datos/${MODELO}_*.dzn; do
  for i in $IMPLS; do
    for s in $ESTRATEGIAS; do
      SALIDA=$(minizinc --solver "$SOLVER" -s --time-limit "$TIMEOUT" \
               "${MODELO}.mzn" "$dzn" -D "impl=$i;strategy=$s" 2>&1)
      stat() { echo "$SALIDA" | grep -m1 "^%%%mzn-stat: $1=" | cut -d= -f2; }
      if   echo "$SALIDA" | grep -q "=====UNSATISFIABLE====="; then EST=insat
      elif echo "$SALIDA" | grep -q "^----------";              then EST=sat
      else EST=timeout; fi
      echo "$(basename "$dzn" .dzn),$i,$s,$SOLVER,$EST,$(stat flatTime),$(stat solveTime),$(stat nodes),$(stat failures),$(stat peakDepth)" >> "$CSV"
    done
  done
done
echo "Resultados en $CSV"
