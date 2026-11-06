#!/usr/bin/env bash
set -euo pipefail

SOLVER="${1:-gecode}"
TIMEOUT_MS="${2:-60000}"
TIMEOUT_S=$(( (TIMEOUT_MS + 999) / 1000 ))

MODELO="sudoku"
IMPLS="1 2 3"
ESTRATEGIAS="0 1 2 3"

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR"

mkdir -p results
OUT="results/${MODELO}_${SOLVER}.csv"

echo "test,impl,strategy,status,time_sec,nodes,failures,peak_depth,propagations" > "$OUT"

echo "=========================================================="
echo " Ejecutando pruebas para ${MODELO} con ${SOLVER}"
echo "=========================================================="

for test_path in tests/*.dzn; do
    test_name="$(basename "$test_path" .dzn)"
    for impl in $IMPLS; do
        for strat in $ESTRATEGIAS; do
            printf "Prueba: %-12s | Impl: %d | Estrat: %d ... " "$test_name" "$impl" "$strat"

            # Ejecutar y limpiar los retornos de carro (\r) de Windows
            set +e
            RAW_OUT=$(minizinc --solver "$SOLVER" -s \
                "${MODELO}.mzn" "$test_path" \
                -D "impl=${impl};strategy=${strat};" 2>&1 | tr -d '\r')
            set -e

            # Detección del estado
            STATUS="SAT"
            if echo "$RAW_OUT" | grep -q "UNSATISFIABLE"; then
                STATUS="UNSAT"
            elif echo "$RAW_OUT" | grep -q "UNKNOWN"; then
                STATUS="UNKNOWN"
            fi

            # Extracción limpia de estadísticas de MiniZinc
            TIME=$(echo "$RAW_OUT" | grep -m1 "solveTime=" | cut -d'=' -f2 || echo "0.0")
            if [ -z "$TIME" ]; then
                TIME=$(echo "$RAW_OUT" | grep -m1 "initTime=" | cut -d'=' -f2 || echo "0.0")
            fi

            NODES=$(echo "$RAW_OUT" | grep -m1 "nodes=" | cut -d'=' -f2 || echo "0")
            FAILS=$(echo "$RAW_OUT" | grep -m1 "failures=" | cut -d'=' -f2 || echo "0")
            DEPTH=$(echo "$RAW_OUT" | grep -m1 "peakDepth=" | cut -d'=' -f2 || echo "0")
            PROPS=$(echo "$RAW_OUT" | grep -m1 "propagations=" | cut -d'=' -f2 || echo "0")

            # Asegurar valores por defecto si vienen vacíos
            NODES=${NODES:-0}
            FAILS=${FAILS:-0}
            DEPTH=${DEPTH:-0}
            PROPS=${PROPS:-0}
            TIME=${TIME:-0.0}

            echo "${STATUS} (Nodos: ${NODES}, Fallos: ${FAILS}, Tiempo: ${TIME}s)"
            echo "${test_name},${impl},${strat},${STATUS},${TIME},${NODES},${FAILS},${DEPTH},${PROPS}" >> "$OUT"
        done
    done
done

echo "=========================================================="
echo " Resultados exportados exitosamente a ${OUT}"
echo "=========================================================="