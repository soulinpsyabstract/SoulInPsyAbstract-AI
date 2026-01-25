#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

PROJ="/storage/emulated/0/PROJECT"
DAY="$(date +%F)"
FIXDIR="$PROJ/PAYTON_HUBS/HUB_LEGAL_FORENSIC/FIXATIONS/DAY_CLOSE"
mkdir -p "$FIXDIR"

F="$FIXDIR/DAY_CLOSE__${DAY}.txt"

if [ -f "$F" ]; then
  echo "OK: DAY_CLOSE exists → $F"
  exit 0
fi

BIN="$PROJ/RUNTIME_RW/_BIN/mod_guard_create.sh"
"$BIN" "$F" "Auto day-close placeholder (manual approval)."

cat >> "$F" <<EOF
DAY CLOSE · PLACEHOLDER
DATE: $DAY
TIME: $(date +%T)
TZ: Asia/Jerusalem

STATUS: CREATED BY CHECKER
NOTE: Fill content then re-hash if edited.
