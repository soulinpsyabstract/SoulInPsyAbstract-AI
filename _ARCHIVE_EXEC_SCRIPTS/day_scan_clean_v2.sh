#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

TZ="Asia/Jerusalem"
SAFE="/storage/emulated/0/PROJECT/SAFE_V3"
TRASH="/storage/emulated/0/PROJECT/PAYTON_HUBS/TRASH/FORENSIC_DROP"
FIXROOT="/storage/emulated/0/PROJECT/PAYTON_HUBS/HUB_LEGAL_FORENSIC/FIXATIONS"

DAY="${1:-$(date +%F)}"
NOW="$(date +%H-%M-%S)"

OUT="$SAFE/_FORENSIC_SCAN/DAY__${DAY}"
mkdir -p "$OUT" "$TRASH" "$FIXROOT"

# Exclusions to reduce android pain
EX1="$SAFE/../Android"

# 1) ZERO-BYTE
ZL="$OUT/ZERO_BYTE__${DAY}.lst"
find "$SAFE" -type f -size 0 \
  ! -path "$EX1/*" \
  -print > "$ZL" 2>/dev/null || true
sha256sum "$ZL" > "$ZL.sha256"

# 2) SHA256 FAILURES (checks only sha256 files under SAFE_V3)
SL="$OUT/SHA256_FAIL__${DAY}.lst"
find "$SAFE" -type f -name "*.sha256" \
  ! -path "$EX1/*" -print0 2>/dev/null \
| while IFS= read -r -d '' s; do
    sha256sum -c "$s" >/dev/null 2>&1 || echo "$s"
  done > "$SL" || true
sha256sum "$SL" > "$SL.sha256"

# 3) DUPLICATE CONTENT by sha256 (scans images only to keep it sane)
# Adjust patterns if needed
DL="$OUT/DUP_CONTENT__${DAY}.tsv"
printf "sha256\tbytes\tpath\n" > "$DL"
find "$SAFE" -type f \
  \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.mp4" -o -iname "*.pdf" \) \
  ! -path "$EX1/*" -print0 2>/dev/null \
| while IFS= read -r -d '' f; do
    size="$(stat --printf='%s' "$f" 2>/dev/null || echo 0)"
    sum="$(sha256sum "$f" 2>/dev/null | awk '{print $1}')"
    [ -n "${sum:-}" ] && printf "%s\t%s\t%s\n" "$sum" "$size" "$f"
  done >> "$DL"
sha256sum "$DL" > "$DL.sha256"

# Identify dup hashes (keep first occurrence, move others)
DUPH="$OUT/DUP_HASHES__${DAY}.lst"
awk 'NR>1 {print $1}' "$DL" | sort | uniq -d > "$DUPH" || true
sha256sum "$DUPH" > "$DUPH.sha256"

# 4) CLEANUP (MOVE to TRASH)
DROP="$TRASH/DAY__${DAY}__${NOW}"
mkdir -p "$DROP/zero_byte" "$DROP/sha256_bad" "$DROP/dup_content"

# move zero-byte files
if [ -s "$ZL" ]; then
  while IFS= read -r p; do
    [ -f "$p" ] || continue
    mv -f -- "$p" "$DROP/zero_byte/" 2>/dev/null || true
  done < "$ZL"
fi

# move failing sha256 files themselves (NOT the targets)
if [ -s "$SL" ]; then
  while IFS= read -r p; do
    [ -f "$p" ] || continue
    mv -f -- "$p" "$DROP/sha256_bad/" 2>/dev/null || true
  done < "$SL"
fi

# move duplicate content (keep first)
if [ -s "$DUPH" ]; then
  while IFS= read -r h; do
    # list all files with that hash
    awk -v H="$h" 'NR>1 && $1==H {print $3}' "$DL" \
    | awk 'NR>1 {print}' \
    | while IFS= read -r fp; do
        [ -f "$fp" ] || continue
        mv -f -- "$fp" "$DROP/dup_content/" 2>/dev/null || true
      done
  done < "$DUPH"
fi

# 5) FIXATION (facts only)
FX="$FIXROOT/FIXATION__DAY_SCAN_CLEAN__${DAY}__${TZ}.txt"
cat > "$FX" <<EOF2
# =========================
# FIXATION · DAY SCAN + CLEAN
# =========================
SYSTEM: SIPA / Soul In PsyAbstract
DATE: ${DAY}
TIME: ${NOW}
TZ: ${TZ}

MODE: FORENSIC / EVIDENCE
EXECUTION_CONTEXT=ALLOWED (CLEANUP VIA MOVE-TO-TRASH)
RUNTIME=LOCAL
CLAIMS=NONE

SCOPE:
- SAFE_V3 scan (excluding Android restricted paths)
- zero-byte files
- failing .sha256 files (file itself)
- duplicate content (sha256-based, limited patterns)

OUTPUTS:
- ${ZL}
- ${SL}
- ${DL}
- ${DUPH}

CLEANUP ACTION:
- moved items into: ${DROP}

DECLARATION:
- No deletions executed (MOVE only).
- This record asserts file operations only.
EOF2
sha256sum "$FX" > "$FX.sha256"

# 6) MANIFEST for scan folder
MAN="$OUT/MANIFEST__DAY_SCAN__${DAY}.tsv"
printf "filename\tbytes\tsha256\n" > "$MAN"
for f in "$OUT"/*; do
  [ -f "$f" ] || continue
  n="$(basename "$f")"
  b="$(stat --printf='%s' "$f")"
  s="$(sha256sum "$f" | awk '{print $1}')"
  printf "%s\t%s\t%s\n" "$n" "$b" "$s" >> "$MAN"
done
sha256sum "$MAN" > "$MAN.sha256"

echo "OK: DAY_SCAN+CLEAN -> $OUT"
echo "TRASH DROP -> $DROP"
