#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

export TZ="${TZ:-Asia/Jerusalem}"
PROJ="${PROJ:-/storage/emulated/0/PROJECT}"
V3="${V3:-$PROJ/RUNTIME_RW/V3}"
REG="${REG:-$V3/REGISTRY}"
CAN="${CAN:-$V3/CANON}"
OUT="${OUT:-$PROJ/_FORENSIC_SCANS}"

TS="$(date +%F__%H-%M-%S)"
PKG="$OUT/V3_MIN_PACK__${TS}.zip"

# Minimal pack: CANON + REGISTRY + FIXATIONS + REWRITE_DECLARATION + INDEXES
# NO zip-of-zip: we only pack text/tsv and small metadata, not legacy zip piles.
zip -r "$PKG" \
  "$CAN" \
  "$REG" \
  2>/dev/null

sha256sum "$PKG" > "$PKG.sha256"
echo "OK: MIN PACK created → $PKG"
