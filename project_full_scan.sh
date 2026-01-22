#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

ROOT="/storage/emulated/0/PROJECT"
OUT_BASE="/storage/emulated/0/PROJECT/PAYTON_HUBS/HUB_LEGAL_FORENSIC/FIXATIONS"
TS="$(date +%F__%H-%M-%S)"
OUT="$OUT_BASE/PROJECT_FULL_SCAN__${TS}__Asia-Jerusalem"

mkdir -p "$OUT"
cd "$ROOT"

# 1) Full file inventory (path + bytes + mtime)
# Notes: avoids binary hashing; just inventory first.
printf "path\tbytes\tmtime_epoch\n" > "$OUT/FILES_INDEX.tsv"
find . -type f -print0 \
| xargs -0 stat -c "%n\t%s\t%Y" \
>> "$OUT/FILES_INDEX.tsv"

sha256sum "$OUT/FILES_INDEX.tsv" > "$OUT/FILES_INDEX.tsv.sha256"

# 2) ZIP inventory + sha256 per zip
printf "path\tbytes\tsha256\n" > "$OUT/ZIPS_INDEX.tsv"
find . -type f -name "*.zip" -print0 \
| while IFS= read -r -d '' f; do
    sz="$(stat -c "%s" "$f" 2>/dev/null || echo "UNKNOWN")"
    h="$(sha256sum "$f" | awk '{print $1}')"
    printf "%s\t%s\t%s\n" "$f" "$sz" "$h"
  done >> "$OUT/ZIPS_INDEX.tsv"

sha256sum "$OUT/ZIPS_INDEX.tsv" > "$OUT/ZIPS_INDEX.tsv.sha256"

# 3) Keyword scan (text-like only)
# Limits to common text extensions to avoid garbage/slow scans.
printf "path\tline\tmatch\n" > "$OUT/KEYWORD_HITS.tsv"

# keywords (case-insensitive where possible)
KW_REGEX='fixation|log|run|line|timeline|assembly|closing|boot|close|фиксация|лог|ран|лайн|тайм|сборка|закрытие|боот|клоус'

find . -type f \( \
  -name "*.txt" -o -name "*.tsv" -o -name "*.md" -o -name "*.log" -o -name "*.csv" \
\) -print0 \
| while IFS= read -r -d '' f; do
    # grep outputs: line:content
    grep -nEai -- "$KW_REGEX" "$f" 2>/dev/null \
    | while IFS= read -r hit; do
        ln="${hit%%:*}"
        mtch="${hit#*:}"
        printf "%s\t%s\t%s\n" "$f" "$ln" "$mtch"
      done
  done >> "$OUT/KEYWORD_HITS.tsv"

sha256sum "$OUT/KEYWORD_HITS.tsv" > "$OUT/KEYWORD_HITS.tsv.sha256"

# 4) Minimal human-readable summary (optional)
cat <<SUM > "$OUT/SUMMARY.txt"
PROJECT FULL SCAN SUMMARY
ROOT: $ROOT
OUT:  $OUT
DATE: $(date +%F)
TIME: $(date +%H:%M:%S)
TZ:   Asia/Jerusalem

ARTIFACTS:
- FILES_INDEX.tsv + sha256
- ZIPS_INDEX.tsv + sha256
- KEYWORD_HITS.tsv + sha256

FACT:
- Inventory + zip hashing + keyword scan completed.
- No source files modified.
SUM

sha256sum "$OUT/SUMMARY.txt" > "$OUT/SUMMARY.txt.sha256"

echo "DONE: $OUT"
