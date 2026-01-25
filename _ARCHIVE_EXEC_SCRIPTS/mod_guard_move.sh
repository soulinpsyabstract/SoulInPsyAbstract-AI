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
  echo "  mod_guard_move.sh <src_path> <dst_dir> <reason>"
  exit 2
}

SRC="${1:-}"
DSTDIR="${2:-}"
REASON="${3:-}"
[ -n "$SRC" ] && [ -n "$DSTDIR" ] && [ -n "$REASON" ] || usage
[ -f "$SRC" ] || { echo "[STOP] src not found: $SRC" >&2; exit 66; }

mkdir -p "$DSTDIR"
BAS="$(basename "$SRC")"
DST="$DSTDIR/$BAS"

# STOP if target exists
if [ -e "$DST" ]; then
  echo "[STOP-CRANE] dst exists: $DST" >&2
  echo "$(ts) STOP move src=$SRC dst=$DST reason=$REASON" >> "$AUD"
  exit 66
fi

h="$(sha256sum "$SRC" | awk '{print $1}')"
b="$(stat -c %s "$SRC" 2>/dev/null || echo 0)"

mv -v "$SRC" "$DST"

printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" \
  "$(ts)" "USER" "MOVE" "$SRC" "$DST" "$h" "$b" "$REASON" "-" >> "$FLOW"

echo "$(ts) OK move $DST sha=$h" >> "$AUD"
echo "OK: MOVED → $DST"
