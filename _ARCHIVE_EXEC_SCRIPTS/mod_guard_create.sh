#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

PROJ="/storage/emulated/0/PROJECT"
V3="$PROJ/RUNTIME_RW/V3"
REG="$V3/REGISTRY"
FLOW="$REG/FLOW_LOG.tsv"
AUD="$REG/AUDIT_APPEND.log"

ts(){ date "+%F %T"; }

usage(){
  echo "Usage:"
  echo "  mod_guard_create.sh <dst_path> <reason>"
  echo "Creates empty file safely (STOP if similar exists)."
  exit 2
}

DST="${1:-}"
REASON="${2:-}"
[ -n "$DST" ] && [ -n "$REASON" ] || usage

mkdir -p "$(dirname "$DST")"

# similarity window: same dir, name prefix, and mtime within 2 days
BASE="$(basename "$DST")"
DIR="$(dirname "$DST")"
PFX="$(echo "$BASE" | sed 's/__20[0-9][0-9]-[0-9][0-9]-[0-9][0-9].*//')"
NOW="$(date +%s)"
WIN=$((2*24*3600))

SIM="$(find "$DIR" -maxdepth 1 -type f 2>/dev/null | while read -r f; do
  b="$(basename "$f")"
  mt="$(stat -c %Y "$f" 2>/dev/null || echo 0)"
  if echo "$b" | grep -q "^$PFX" && [ $((NOW-mt)) -le $WIN ]; then
    echo "$f"
  fi
done | head -n 1 || true)"

if [ -n "${SIM:-}" ]; then
  echo "[STOP-CRANE] Similar file exists: $SIM" >&2
  echo "$(ts) STOP create dst=$DST similar=$SIM reason=$REASON" >> "$AUD"
  exit 66
fi

: > "$DST"
b="$(stat -c %s "$DST" 2>/dev/null || echo 0)"
h="$(sha256sum "$DST" | awk '{print $1}')"

printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" \
  "$(ts)" "USER" "CREATE" "-" "$DST" "$h" "$b" "$REASON" "-" >> "$FLOW"

echo "$(ts) OK create $DST sha=$h" >> "$AUD"
echo "OK: CREATED → $DST"
