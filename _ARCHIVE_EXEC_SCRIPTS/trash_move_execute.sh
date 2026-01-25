#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

SCAN_DIR="${SCAN_DIR:?SCAN_DIR not set}"
PLAN="$SCAN_DIR/TRASH_MOVE_PLAN.tsv"

ROOT="/storage/emulated/0/PROJECT/PAYTON_HUBS"
FIX="$ROOT/HUB_LEGAL_FORENSIC/FIXATIONS"
AUDIT="$FIX/AUDIT__LEGAL_FIXATIONS.log"

TS="$(date +%F__%H-%M-%S__Asia-Jerusalem)"
TRASH="$ROOT/TRASH/FORENSIC_DROP__${TS}"

mkdir -p "$TRASH"

EXEC_LOG="$SCAN_DIR/TRASH_MOVE_EXECUTION.tsv"
echo -e "reason\tsrc_path\tdst_path" > "$EXEC_LOG"

# execute moves
tail -n +2 "$PLAN" | while IFS=$'\t' read -r reason path; do
  src="$ROOT/${path#./}"
  if [ -e "$src" ]; then
    dst="$TRASH/$(basename "$src")"
    mv "$src" "$dst"
    echo -e "$reason\t$src\t$dst" >> "$EXEC_LOG"
  else
    echo -e "$reason\t$src\tMISSING" >> "$EXEC_LOG"
  fi
done

# hash execution log
sha256sum "$EXEC_LOG" > "$EXEC_LOG.sha256"

# audit append-only
{
  echo "==== TRASH MOVE EXECUTION: $TS ===="
  echo "SCAN_DIR: $SCAN_DIR"
  echo "PLAN_SHA256: $(awk '{print $1}' "$PLAN.sha256")"
  echo "EXEC_LOG_SHA256: $(awk '{print $1}' "$EXEC_LOG.sha256")"
  echo "TRASH_DIR: $TRASH"
  echo "MODE: FORENSIC / EXECUTED"
  echo
} >> "$AUDIT"

sha256sum "$AUDIT" > "$FIX/AUDIT__LEGAL_FIXATIONS.log.sha256"

echo "OK: TRASH MOVE EXECUTED -> $TRASH"
