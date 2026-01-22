#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

BASE="/storage/emulated/0/PROJECT/PAYTON_HUBS"
cd "$BASE" || exit 1

OUT="_REPORTS/REPORT_$(date +%F__%H-%M-%S)"
mkdir -p "$OUT"
LOG="$OUT/00_PROGRESS.log"

log(){ echo "[$(date +%F_%T)] $*" | tee -a "$LOG"; }

log "START: $(pwd)"
log "OUT:   $OUT"

# 0) где мы
pwd > "$OUT/00_PWD.txt"
ls -la > "$OUT/01_LS_ROOT.txt"
log "STEP0 ok"

# 1) маленькие файлы (подозрительные)
find . -type f -size -300c -print 2>/dev/null | sort > "$OUT/10_FILES_UNDER_300B.txt"
log "STEP1 ok: $(wc -l < "$OUT/10_FILES_UNDER_300B.txt") files"

# 2) заглушки в тексте
grep -R -n -E "\[PASTE HERE|\bPASTE HERE\b|TODO|PLACEHOLDER|DRAFT\b" . \
  --exclude-dir=Android 2>/dev/null > "$OUT/11_PLACEHOLDER_HITS.txt" || true
log "STEP2 ok: $(wc -l < "$OUT/11_PLACEHOLDER_HITS.txt") hits"

# 3) битые zip (это ДОЛГО, но теперь ты видишь прогресс в логе)
find . -type f -name "*.zip" -print 2>/dev/null > "$OUT/20_ALL_ZIPS.txt"
log "STEP3 prep: $(wc -l < "$OUT/20_ALL_ZIPS.txt") zips found"

: > "$OUT/20_BAD_ZIPS.txt"
n=0
while IFS= read -r z; do
  n=$((n+1))
  unzip -t "$z" >/dev/null 2>&1 || echo "$z" >> "$OUT/20_BAD_ZIPS.txt"
  if (( n % 200 == 0 )); then log "STEP3 progress: checked $n zips"; fi
done < "$OUT/20_ALL_ZIPS.txt"
log "STEP3 ok: bad=$(wc -l < "$OUT/20_BAD_ZIPS.txt")"

# 4) sha256 несходятся
find . -type f -name "*.sha256" -print 2>/dev/null > "$OUT/21_ALL_SHA256.txt"
log "STEP4 prep: $(wc -l < "$OUT/21_ALL_SHA256.txt") sha256 files"

: > "$OUT/21_BAD_SHA256_FILES.txt"
m=0
while IFS= read -r h; do
  m=$((m+1))
  sha256sum -c "$h" >/dev/null 2>&1 || echo "$h" >> "$OUT/21_BAD_SHA256_FILES.txt"
  if (( m % 200 == 0 )); then log "STEP4 progress: checked $m sha256"; fi
done < "$OUT/21_ALL_SHA256.txt"
log "STEP4 ok: bad=$(wc -l < "$OUT/21_BAD_SHA256_FILES.txt")"

# 5) summary
{
  echo "REPORT_DIR=$OUT"
  echo "FILES_UNDER_300B=$(wc -l < "$OUT/10_FILES_UNDER_300B.txt")"
  echo "PLACEHOLDER_HITS=$(wc -l < "$OUT/11_PLACEHOLDER_HITS.txt")"
  echo "BAD_ZIPS=$(wc -l < "$OUT/20_BAD_ZIPS.txt")"
  echo "BAD_SHA256=$(wc -l < "$OUT/21_BAD_SHA256_FILES.txt")"
} > "$OUT/99_SUMMARY.txt"
log "STEP5 ok"

# 6) pack
zip -qr "${OUT}.zip" "$OUT"
sha256sum "${OUT}.zip" > "${OUT}.zip.sha256"
echo "$OUT" > "_REPORTS/LAST_REPORT_PATH.txt"
log "DONE: ${OUT}.zip"
cat "$OUT/99_SUMMARY.txt"
