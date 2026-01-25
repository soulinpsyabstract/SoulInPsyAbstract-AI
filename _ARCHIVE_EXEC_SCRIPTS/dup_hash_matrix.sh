#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

SCAN_DIR="${SCAN_DIR:?SCAN_DIR not set}"
ZIPS="$SCAN_DIR/ZIPS_INDEX.tsv"

OUT="$SCAN_DIR/DUP_HASH_MATRIX.tsv"

echo -e "sha256\tcount\tpaths" > "$OUT"

cut -f3 "$ZIPS" \
| sort \
| uniq -c \
| awk '$1>1 {print $2}' \
| while read h; do
    c=$(grep -c "$h" "$ZIPS")
    paths=$(grep "$h" "$ZIPS" | cut -f1 | tr '\n' ' | ')
    echo -e "$h\t$c\t$paths"
  done >> "$OUT"

sha256sum "$OUT" > "$OUT.sha256"

echo "OK: DUP_HASH_MATRIX created"
