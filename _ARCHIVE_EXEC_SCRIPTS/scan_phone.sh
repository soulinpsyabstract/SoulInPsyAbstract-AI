#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

ROOT="/storage/emulated/0"
TS="$(date +%F__%H-%M-%S)"
OUT="$ROOT/_FULL_PHONE_REPORT_$TS"

mkdir -p "$OUT"
echo "[${TS}] START ROOT: $ROOT"
echo "[${TS}] OUT: $OUT"

# 0) Где мы
pwd > "$OUT/00_PWD.txt"
ls -la "$ROOT" > "$OUT/01_LS_ROOT.txt"

# 1) Маленькие файлы (часто заглушки)
echo "[${TS}] STEP1: small files..."
find "$ROOT" \
  -path "$ROOT/Android" -prune -o \
  -path "$ROOT/.trash" -prune -o \
  -type f -size -300c -print 2>/dev/null \
  | sort > "$OUT/10_FILES_UNDER_300B.txt"
echo "[${TS}] STEP1 OK: $(wc -l < "$OUT/10_FILES_UNDER_300B.txt")"

# 2) Заглушки/шаблоны
echo "[${TS}] STEP2: placeholder hits..."
grep -R -n -E "\[PASTE HERE|\bPASTE HERE\b|TODO|PLACEHOLDER|DRAFT\b" "$ROOT" \
  --exclude-dir=Android \
  2>/dev/null > "$OUT/11_PLACEHOLDER_HITS.txt" || true
echo "[${TS}] STEP2 OK: $(wc -l < "$OUT/11_PLACEHOLDER_HITS.txt")"

# 3) Битые ZIP
echo "[${TS}] STEP3: test zips (can take long)..."
find "$ROOT" -type f -name "*.zip" 2>/dev/null \
  | while read -r z; do
      unzip -t "$z" >/dev/null 2>&1 || echo "$z"
    done > "$OUT/20_BAD_ZIPS.txt"
echo "[${TS}] STEP3 OK: $(wc -l < "$OUT/20_BAD_ZIPS.txt")"

# 4) Несходящиеся SHA256
echo "[${TS}] STEP4: check sha256 (can take long)..."
find "$ROOT" -type f -name "*.sha256" 2>/dev/null \
  | while read -r h; do
      sha256sum -c "$h" >/dev/null 2>&1 || echo "$h"
    done > "$OUT/21_BAD_SHA256_FILES.txt"
echo "[${TS}] STEP4 OK: $(wc -l < "$OUT/21_BAD_SHA256_FILES.txt")"

# 5) Итог
{
  echo "REPORT_DIR=$OUT"
  echo "FILES_UNDER_300B=$(wc -l < "$OUT/10_FILES_UNDER_300B.txt")"
  echo "PLACEHOLDER_HITS=$(wc -l < "$OUT/11_PLACEHOLDER_HITS.txt")"
  echo "BAD_ZIPS=$(wc -l < "$OUT/20_BAD_ZIPS.txt")"
  echo "BAD_SHA256=$(wc -l < "$OUT/21_BAD_SHA256_FILES.txt")"
} > "$OUT/99_SUMMARY.txt"

# 6) ZIP + HASH
zip -qr "${OUT}.zip" "$OUT"
sha256sum "${OUT}.zip" > "${OUT}.zip.sha256"

echo "[${TS}] DONE: ${OUT}.zip"
cat "$OUT/99_SUMMARY.txt"
