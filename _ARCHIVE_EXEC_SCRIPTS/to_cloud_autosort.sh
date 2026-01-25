#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

# === SOURCES (откуда забирать) ===
SOURCES=(
  "/storage/emulated/0/Download"
  "/storage/emulated/0/PROJECT"
  "/storage/emulated/0/PROJECT/PAYTON_HUBS"
  "/storage/emulated/0/chaos-space"
)

# === DESTINATION ===
DEST="/storage/emulated/0/PROJECT/TO_CLOUD"

Q="$DEST/01__UNSURE__QUARANTINE"
M="$DEST/02__FUTURE__MAYBE"
K="$DEST/03__ARCHIVE__KEEP_ONLY"

mkdir -p "$Q" "$M" "$K"

TS="$(date +%F__%H-%M-%S)"
LOG="$DEST/TO_CLOUD_MOVE_$TS.log"
touch "$LOG"

echo "== TO_CLOUD AUTO MOVE ==" | tee -a "$LOG"
echo "DEST: $DEST" | tee -a "$LOG"
echo "" | tee -a "$LOG"

shopt -s nullglob

move_one() {
  local f="$1"
  local base
  base="$(basename "$f")"
  local b="${base,,}"

  # safety
  [[ "$f" == "$DEST"* ]] && return 0

  # KEEP_ONLY
  if [[ "$b" =~ (snapshot|fixation|forensic|proof|sha256|manifest|canon|core_canon|governance|enforcement|runtime|protocol|disclosure|audit) ]]; then
    echo "KEEP_ONLY   : $f" | tee -a "$LOG"
    mv -n -- "$f" "$K/" || true
    return
  fi

  # FUTURE_MAYBE
  if [[ "$b" =~ (site|full_site|htdocs|deploy|assets|media|workspace|bts|headshot|submission|kit|lux|sipa_|soulinpsyabstract|artwork|instagram|brand) ]]; then
    echo "FUTURE_MAYBE: $f" | tee -a "$LOG"
    mv -n -- "$f" "$M/" || true
    return
  fi

  # QUARANTINE
  echo "QUARANTINE  : $f" | tee -a "$LOG"
  mv -n -- "$f" "$Q/" || true
}

# === MAIN LOOP ===
for SRC in "${SOURCES[@]}"; do
  [ -d "$SRC" ] || continue
  echo "--- SCAN $SRC ---" | tee -a "$LOG"

  find "$SRC" -maxdepth 2 -type f \( -name "*.zip" -o -name "*.7z" \) 2>/dev/null | while read -r f; do
    move_one "$f"
  done
done

echo "" | tee -a "$LOG"
echo "== DONE ==" | tee -a "$LOG"
df -h /storage/emulated/0 | head -n 2 | tee -a "$LOG"
echo "LOG: $LOG"

