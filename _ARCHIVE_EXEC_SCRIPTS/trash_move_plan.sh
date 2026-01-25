#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

SCAN_DIR="${SCAN_DIR:?SCAN_DIR not set}"
PLAN="$SCAN_DIR/TRASH_MOVE_PLAN.tsv"

echo -e "reason\tpath" > "$PLAN"

# ZERO_BYTES (if any beyond header)
if [ -f "$SCAN_DIR/ZERO_BYTES_FIXATION.tsv" ]; then
  awk -F'\t' 'NR>1 {print "ZERO_BYTES\t"$1}' "$SCAN_DIR/ZERO_BYTES_FIXATION.tsv" >> "$PLAN"
fi

# DUPLICATES: move only RAW copies; NEVER touch COLD, ORIGINAL_LOCK, or HUB_LEGAL_FORENSIC canonical zips
# Parse dup hash list from DUP_HASH_MATRIX.tsv (tab-separated)
awk -F'\t' 'NR>1 {print $1}' "$SCAN_DIR/DUP_HASH_MATRIX.tsv" \
| while read h; do
    grep "$h" "$SCAN_DIR/ZIPS_INDEX.tsv" | cut -f1 \
    | while read p; do
        case "$p" in
          ./RUNTIME_ARCHIVE_PRE_V3/RAW/*)
            echo -e "DUP_HASH_RAW\t$p"
            ;;
          *)
            : # keep everything else
            ;;
        esac
      done
  done >> "$PLAN"

sort -u "$PLAN" -o "$PLAN"
sha256sum "$PLAN" > "$PLAN.sha256"

echo "OK: TRASH_MOVE_PLAN created (NO FILES MOVED)"
