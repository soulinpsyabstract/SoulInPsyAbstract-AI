#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

TZ="Asia/Jerusalem"
SAFE="/storage/emulated/0/PROJECT/SAFE_V3"
TRASH="/storage/emulated/0/PROJECT/PAYTON_HUBS/TRASH/FORENSIC_DROP"
FIXROOT="/storage/emulated/0/PROJECT/PAYTON_HUBS/HUB_LEGAL_FORENSIC/FIXATIONS"

# usage: week_scan_clean_v2.sh 2026-01-11 2026-01-17 2026-W03
START="${1:-}"
END_EXCL="${2:-}"   # end is exclusive boundary (use next day)
WEEK="${3:-$(date +%G-W%V)}"

[ -n "$START" ] && [ -n "$END_EXCL" ] || {
  echo "USAGE: week_scan_clean_v2.sh <START:YYYY-MM-DD> <END_EXCL:YYYY-MM-DD> <WEEK:2026-W03>";
  exit 1;
}

NOW="$(date +%H-%M-%S)"
OUT="$SAFE/_FORENSIC_WEEK/WEEK__${WEEK}__${START}__to__${END_EXCL}"
mkdir -p "$OUT" "$TRASH" "$FIXROOT"

EX1="$SAFE/../Android"

# 1) Build list of files in range (mtime)
FL="$OUT/FILES__${WEEK}.lst"
find "$SAFE" -type f -newermt "$START" ! -newermt "$END_EXCL" \
  ! -path "$EX1/*" -print > "$FL" 2>/dev/null || true
sha256sum "$FL" > "$FL.sha256"

# 2) ZERO-BYTE in range
ZL="$OUT/ZERO_BYTE__${WEEK}.lst"
while IFS= read -r p; do
  [ -f "$p" ] || continue
  [ "$(stat --printf='%s' "$p" 2>/dev/null || echo 1)" -eq 0 ] && echo "$p"
done < "$FL" > "$ZL" || true
sha256sum "$ZL" > "$ZL.sha256"

# 3) SHA256 FAIL in range (.sha256 files listed)
SL="$OUT/SHA256_FAIL__${WEEK}.lst"
grep -E '\.sha256$' "$FL" | while IFS= read -r s; do
  sha256sum -c "$s" >/dev/null 2>&1 || echo "$s"
done > "$SL" || true
sha256sum "$SL" > "$SL.sha256"

# 4) DUP CONTENT by sha256 (limited patterns)
DL="$OUT/DUP_CONTENT__${WEEK}.tsv"
printf "sha256\tbytes\tpath\n" > "$DL"
grep -Ei '\.(jpg|jpeg|png|mp4|pdf)$' "$FL" | while IFS= read -r f; do
  [ -f "$f" ] || continue
  size="$(stat --printf='%s' "$f" 2>/dev/null || echo 0)"
  sum="$(sha256sum "$f" 2>/dev/null | awk '{print $1}')"
  [ -n "${sum:-}" ] && printf "%s\t%s\t%s\n" "$sum" "$size" "$f"
done >> "$DL" || true
sha256sum "$DL" > "$DL.sha256"

DUPH="$OUT/DUP_HASHES__${WEEK}.lst"
awk 'NR>1 {print $1}' "$DL" | sort | uniq -d > "$DUPH" || true
sha256sum "$DUPH" > "$DUPH.sha256"

# 5) CLEANUP (MOVE)
DROP="$TRASH/WEEK__${WEEK}__${NOW}"
mkdir -p "$DROP/zero_byte" "$DROP/sha256_bad" "$DROP/dup_content"

if [ -s "$ZL" ]; then
  while IFS= read -r p; do
    [ -f "$p" ] || continue
    mv -f -- "$p" "$DROP/zero_byte/" 2>/dev/null || true
  done < "$ZL"
fi

if [ -s "$SL" ]; then
  while IFS= read -r p; do
    [ -f "$p" ] || continue
    mv -f -- "$p" "$DROP/sha256_bad/" 2>/dev/null || true
  done < "$SL"
fi

if [ -s "$DUPH" ]; then
  while IFS= read -r h; do
    awk -v H="$h" 'NR>1 && $1==H {print $3}' "$DL" \
    | awk 'NR>1 {print}' \
    | while IFS= read -r fp; do
        [ -f "$fp" ] || continue
        mv -f -- "$fp" "$DROP/dup_content/" 2>/dev/null || true
      done
  done < "$DUPH"
fi

# 6) FIXATION
FX="$FIXROOT/FIXATION__WEEK_SCAN_CLEAN__${WEEK}__${START}__to__${END_EXCL}__${TZ}.txt"
cat > "$FX" <<EOF2
# =========================
# FIXATION · WEEK SCAN + CLEAN
# =========================
SYSTEM: SIPA / Soul In PsyAbstract
WEEK: ${WEEK}
RANGE: ${START} to ${END_EXCL} (end exclusive)
TIME: ${NOW}
TZ: ${TZ}

MODE: FORENSIC / EVIDENCE
EXECUTION_CONTEXT=ALLOWED (CLEANUP VIA MOVE-TO-TRASH)
RUNTIME=LOCAL
CLAIMS=NONE

OUTPUTS:
- ${FL}
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

# 7) MANIFEST for OUT
MAN="$OUT/MANIFEST__WEEK_SCAN__${WEEK}.tsv"
printf "filename\tbytes\tsha256\n" > "$MAN"
for f in "$OUT"/*; do
  [ -f "$f" ] || continue
  n="$(basename "$f")"
  b="$(stat --printf='%s' "$f")"
  s="$(sha256sum "$f" | awk '{print $1}')"
  printf "%s\t%s\t%s\n" "$n" "$b" "$s" >> "$MAN"
done
sha256sum "$MAN" > "$MAN.sha256"

echo "OK: WEEK_SCAN+CLEAN -> $OUT"
echo "TRASH DROP -> $DROP"
