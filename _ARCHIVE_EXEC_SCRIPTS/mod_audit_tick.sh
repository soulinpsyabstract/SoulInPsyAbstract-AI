#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
PROJ="/storage/emulated/0/PROJECT"
AUD="$PROJ/RUNTIME_RW/V3/REGISTRY/AUDIT_APPEND.log"

ts(){ date "+%F %T"; }

# minimal health snapshot
DF="$(df -h /storage/emulated/0 | head -n 2 | tr '\n' ' ' | sed 's/  */ /g')"
ZIPS="$(find "$PROJ" -path '*TRASH*' -prune -o -name '*.zip' -type f -print 2>/dev/null | wc -l | tr -d ' ')"

echo "$(ts) TICK df='$DF' zip_count=$ZIPS" >> "$AUD"
echo "OK: TICK"
