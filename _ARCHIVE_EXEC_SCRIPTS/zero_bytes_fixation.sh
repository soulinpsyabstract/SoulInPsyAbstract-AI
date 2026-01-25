#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

SCAN_DIR="${SCAN_DIR:?SCAN_DIR not set}"
FILES="$SCAN_DIR/FILES_INDEX.tsv"
OUT="$SCAN_DIR/ZERO_BYTES_FIXATION.tsv"

echo -e "path\tbytes\tmtime_epoch" > "$OUT"
awk -F'\t' '$2==0 {print $0}' "$FILES" >> "$OUT"

sha256sum "$OUT" > "$OUT.sha256"
echo "OK: ZERO_BYTES_FIXATION created"
