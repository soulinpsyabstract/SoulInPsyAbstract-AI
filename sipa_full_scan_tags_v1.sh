#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

TZ="Asia/Jerusalem"
export TZ

PROJECT_ROOT="/storage/emulated/0/PROJECT"
SAFE_V3="$PROJECT_ROOT/SAFE_V3"
PAYTON="$PROJECT_ROOT/PAYTON_HUBS"
FIXROOT="$PAYTON/HUB_LEGAL_FORENSIC/FIXATIONS"

[ -d "$SAFE_V3" ] || { echo "MISS: $SAFE_V3" >&2; exit 2; }
[ -d "$PAYTON" ] || { echo "MISS: $PAYTON" >&2; exit 2; }
mkdir -p "$FIXROOT"

TS="$(date +%F__%H-%M-%S)"
OUTROOT="$SAFE_V3/SCANS"
OUT="$OUTROOT/SCAN__TAGS__${TS}__${TZ}"
mkdir -p "$OUT"

TAGS=(
  "SoulInPsyAbstract"
  "Sipa"
  "SoulInPsyAbstract_OS"
  "SoulInPsyAbstract_AI_OS"
  "MLL_Protocol_Zero"
  "Forensic_Legal_Fixations"
  "Termux"
  "Timeline"
  "Logs"
  "Artefacts"
)

EXCLUDE_RE='(/Android/|/DCIM/|/Pictures/|/Movies/|/Music/|/WhatsApp/Media/|/Telegram/|/cache/|/Cache/|/tmp/|/TMP/)'

PATHS_ALL="$OUT/PATHS__ALL.txt"
: > "$PATHS_ALL"

find "$PROJECT_ROOT" -type f \
  \( -name "*.txt" -o -name "*.tsv" -o -name "*.sh" -o -name "*.md" -o -name "*.log" -o -name "*.json" -o -name "*.yaml" -o -name "*.yml" -o -name "*.sha256" -o -name "*.TAG" -o -name "*.zip" \) \
  2>/dev/null | grep -Ev "$EXCLUDE_RE" > "$PATHS_ALL" || true

TOTAL_ALL="$(wc -l < "$PATHS_ALL" | tr -d ' ')"

SKELETON="$OUT/SKELETON__ALL.tsv"
COUNTS="$OUT/COUNTS__BY_TAG.tsv"

printf "path\tfilename\text\tbytes\tmtime\tsha256\n" > "$SKELETON"
printf "tag\tfiles_count\n" > "$COUNTS"

sha_or_na() { sha256sum "$1" 2>/dev/null | awk '{print $1}' || echo "NA"; }

while IFS= read -r f; do
  [ -f "$f" ] || continue
  fn="$(basename "$f")"
  ext="${fn##*.}"
  b="$(stat --printf='%s' "$f" 2>/dev/null || echo NA)"
  t="$(stat --printf='%y' "$f" 2>/dev/null || echo NA)"
  s="$(sha_or_na "$f")"
  printf "%s\t%s\t%s\t%s\t%s\t%s\n" "$(dirname "$f")" "$fn" "$ext" "$b" "$t" "$s" >> "$SKELETON"
done < "$PATHS_ALL"

for tag in "${TAGS[@]}"; do
  C="$(grep -i "$tag" "$PATHS_ALL" | wc -l | tr -d ' ')"
  printf "%s\t%s\n" "$tag" "$C" >> "$COUNTS"
done

sha256sum "$SKELETON" > "$SKELETON.sha256"
sha256sum "$COUNTS" > "$COUNTS.sha256"

echo "OK: SCAN COMPLETE"
echo "FILES SCANNED: $TOTAL_ALL"
echo "OUT: $OUT"
