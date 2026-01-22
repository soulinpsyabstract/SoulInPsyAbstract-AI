#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

# =========================
# NORMALIZE SUBMISSION v3
# trim -> gentle cleanup -> resize-by-orientation -> zip packs
# NO EXTENT CANVAS (no stupid white oceans)
# =========================

# ---- INPUT / OUTPUT ----
SRC="/storage/emulated/0/PROJECT/SAFE_V3/WORKSPACE_GRANTS/OUTPUT_SUBMISSION"

LOCK="/storage/emulated/0/PROJECT/SAFE_V3/WORKSPACE_GRANTS/OUTPUT_SUBMISSION__ORIGINAL_LOCK"
CROP="/storage/emulated/0/PROJECT/SAFE_V3/WORKSPACE_GRANTS/STEP_01_CROPPED"
FINAL="/storage/emulated/0/PROJECT/SAFE_V3/WORKSPACE_GRANTS/STEP_02_FINAL"

ZOUT="/storage/emulated/0/PROJECT/SAFE_V3/WORKSPACE_GRANTS/ZIP_FINAL"
mkdir -p "$LOCK" "$CROP" "$FINAL" "$ZOUT"

# ---- TOOLS ----
if command -v magick >/dev/null 2>&1; then
  IM="magick"
elif command -v convert >/dev/null 2>&1; then
  IM="convert"
else
  echo "ERROR: ImageMagick not found. Install: pkg install imagemagick" >&2
  exit 2
fi

need(){ command -v "$1" >/dev/null 2>&1 || { echo "ERROR: missing $1" >&2; exit 2; }; }
need find
need sha256sum
need zip
need awk

# ---- RULES ----
# Your requested targets:
TARGET_LAND_W=1240
TARGET_PORT_W=480

# Trim aggressiveness (raise fuzz if background is messy, lower if edges are eaten)
FUZZ="4%"

# Gentle cleanup: not “instagram beauty”, just submission readability.
# (UV images: we keep it mild to avoid murdering the glow)
BRICON="2x3"              # brightness-contrast
SAT="105"                 # 100 = same
SHARP="0x0.6+0.6+0.02"    # unsharp

echo "== NORMALIZE v3 START =="
echo "SRC:  $SRC"
echo "LOCK: $LOCK"
echo "CROP: $CROP"
echo "FINAL:$FINAL"
echo

# 1) LOCK originals (copy once, do not overwrite)
# If rsync exists, use it, else fallback to cp -n
if command -v rsync >/dev/null 2>&1; then
  rsync -a --ignore-existing "$SRC/" "$LOCK/"
else
  # Busybox cp may not support -n; this is best-effort.
  cp -r "$SRC/"* "$LOCK/" 2>/dev/null || true
fi

# 2) STEP_01_CROPPED (trim background noise, keep art)
find "$LOCK" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) -print0 |
while IFS= read -r -d '' IMG; do
  REL="${IMG#$LOCK/}"
  OUT="$CROP/$REL"
  mkdir -p "$(dirname "$OUT")"

  echo "→ CROP  $REL"

  "$IM" "$IMG" \
    -auto-orient \
    -colorspace sRGB \
    -strip \
    -fuzz "$FUZZ" \
    -trim +repage \
    -bordercolor white -border 8 \
    "$OUT"
done

# 3) STEP_02_FINAL (gentle cleanup + resize by orientation)
find "$CROP" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) -print0 |
while IFS= read -r -d '' IMG; do
  REL="${IMG#$CROP/}"
  OUT="$FINAL/$REL"
  mkdir -p "$(dirname "$OUT")"

  W=$("$IM" identify -format "%w" "$IMG")
  H=$("$IM" identify -format "%h" "$IMG")

  if [ "$W" -ge "$H" ]; then
    TW="$TARGET_LAND_W"
  else
    TW="$TARGET_PORT_W"
  fi

  echo "→ FINAL $REL  (W=$W H=$H -> ${TW}px wide)"

  "$IM" "$IMG" \
    -auto-orient \
    -colorspace sRGB \
    -brightness-contrast "$BRICON" \
    -modulate 100,"$SAT",100 \
    -unsharp "$SHARP" \
    -resize "${TW}x" \
    -quality 92 \
    "$OUT"
done

# 4) PACK zips (keep same folder structure)
# One zip per PACK_* directory + sha256 + manifest.
TS="$(date +%F__%H-%M-%S)"
cd "$FINAL"

# Make a global manifest too (optional but useful)
MAN_ALL="$ZOUT/MANIFEST__FINAL__${TS}.tsv"
printf "sha256\tbytes\tpath\n" > "$MAN_ALL"
find . -type f -print0 | while IFS= read -r -d '' f; do
  b="$(stat --printf='%s' "$f" 2>/dev/null || echo 0)"
  s="$(sha256sum "$f" | awk '{print $1}')"
  printf "%s\t%s\t%s\n" "$s" "$b" "$f" >> "$MAN_ALL"
done
sha256sum "$MAN_ALL" > "$MAN_ALL.sha256"

for d in PACK_*; do
  [ -d "$d" ] || continue
  ZIP="$ZOUT/${d}__FINAL__${TS}.zip"
  echo "→ ZIP  $ZIP"
  zip -qr "$ZIP" "$d"
  sha256sum "$ZIP" > "$ZIP.sha256"

  # Per-zip manifest (zip + zip.sha256 only)
  M="$ZOUT/MANIFEST__${d}__${TS}.tsv"
  printf "filename\tbytes\tsha256\n" > "$M"
  zb="$(wc -c < "$ZIP" | tr -d ' ')"
  zh="$(awk '{print $1}' "$ZIP.sha256")"
  printf "%s\t%s\t%s\n" "$(basename "$ZIP")" "$zb" "$zh" >> "$M"
  sb="$(wc -c < "$ZIP.sha256" | tr -d ' ')"
  sh="$(sha256sum "$ZIP.sha256" | awk '{print $1}')"
  printf "%s\t%s\t%s\n" "$(basename "$ZIP").sha256" "$sb" "$sh" >> "$M"
  sha256sum "$M" > "$M.sha256"
done

echo
echo "== DONE =="
echo "FINAL DIR: $FINAL"
echo "ZIP OUT:   $ZOUT"
