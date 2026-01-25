#!/data/data/com.termux/files/usr/bin/bash

HUB="/storage/emulated/0/PROJECT/PAYTON_HUBS"
FIX="$HUB/HUB_CORE/FIXATION"
STAMP="$(date '+%Y-%m-%d_%H-%M-%S')"

OUT="$FIX/DUPLICATE_SCAN__$STAMP.txt"
RESULT="$FIX/DUPLICATE_FILES__$STAMP.txt"

mkdir -p "$FIX"

echo "[PAYTON] AUTO DUPLICATE SCAN" > "$OUT"
echo "DATE: $STAMP" >> "$OUT"
echo >> "$OUT"
echo "[HASH MAP]" >> "$OUT"

# считаем хеши, кроме zip / sha256 / tar / gz
find "$HUB" \
  -type f \
  ! -name "*.sha256" \
  ! -name "*.zip" \
  ! -name "*.tar" \
  ! -name "*.gz" \
  -exec sha256sum {} \; \
  | sort >> "$OUT"

grep -o "^[a-f0-9]\{64\}" "$OUT" | uniq -d > "$OUT.dupes"

echo "[DUPLICATES]" > "$RESULT"

while read -r HASH; do
  {
    echo
    echo "===== HASH: $HASH ====="
    grep "$HASH" "$OUT"
  } >> "$RESULT"
done < "$OUT.dupes"

echo >> "$RESULT"
echo "STATE: REPORT ONLY · NO DELETE" >> "$RESULT"

rm "$OUT.dupes"
