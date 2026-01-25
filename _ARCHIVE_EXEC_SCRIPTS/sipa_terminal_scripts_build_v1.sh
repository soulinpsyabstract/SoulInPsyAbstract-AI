#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

TZ="Asia/Jerusalem"
TZ_TAG="${TZ//\//-}"

BASE="/storage/emulated/0/PROJECT/SAFE_V3"
CORE="$BASE/SIPA_OS__CORE_PROTOCOL_v1.0"
EXPORT="$CORE/EXPORT"

# Payton forensic
ROOT="/storage/emulated/0/PROJECT/PAYTON_HUBS"
FIXROOT="$ROOT/HUB_LEGAL_FORENSIC/FIXATIONS"

TS="$(date +%F__%H-%M-%S)"

mkdir -p "$EXPORT" "$FIXROOT"

# -------------------------------
# REQUIRED scripts (must exist ideally)
# -------------------------------
REQ=(
  "day_boot_v2.sh"
  "day_scan_clean_v2.sh"
  "day_close_v2.sh"
  "week_scan_clean_v2.sh"
)

# CLI sipa (operator command wrapper)
CLI="$HOME/bin/sipa"

# -------------------------------
# Staging folder (inside SAFE_V3)
# -------------------------------
PKG="SIPA_TERMINAL_SCRIPTS__v1.0__${TS}__${TZ_TAG}"
STAGE="$BASE/_STAGE__${PKG}"
mkdir -p "$STAGE/REQUIRED" "$STAGE/LEGACY" "$STAGE/CLI"

MISS_LST="$STAGE/MISS__REQUIRED_OR_CLI.lst"
: > "$MISS_LST"

copy_one() {
  local src="$1"
  local dst="$2"
  if [ -f "$src" ]; then
    cp -f "$src" "$dst"
    sed -i 's/\r$//' "$dst" 2>/dev/null || true
  else
    echo "MISS: $src" >> "$MISS_LST"
  fi
}

# -------------------------------
# 1) copy REQUIRED scripts
# -------------------------------
for f in "${REQ[@]}"; do
  copy_one "$BASE/$f" "$STAGE/REQUIRED/$f"
done

# -------------------------------
# 2) copy CLI (if exists)
# -------------------------------
copy_one "$CLI" "$STAGE/CLI/sipa"

# -------------------------------
# 3) collect LEGACY .sh (non-required)
#    - scan BASE (depth limited to reduce chaos)
#    - exclude stage itself + core folder content
# -------------------------------
# Build a set for quick "is required" checks
is_required() {
  local name="$1"
  for r in "${REQ[@]}"; do
    [ "$name" = "$r" ] && return 0
  done
  return 1
}

# find scripts
while IFS= read -r -d '' fp; do
  bn="$(basename "$fp")"

  # skip our own builder + required + staged + core exports
  [ "$fp" = "$BASE/sipa_terminal_scripts_build_v1.sh" ] && continue
  case "$fp" in
    "$STAGE"/*) continue ;;
    "$CORE"/*)  continue ;;
  esac
  is_required "$bn" && continue

  # copy as legacy with path-safe name
  rel="${fp#$BASE/}"
  safe_rel="${rel//\//__}"
  copy_one "$fp" "$STAGE/LEGACY/$safe_rel"
done < <(find "$BASE" -maxdepth 2 -type f -name "*.sh" -print0 2>/dev/null || true)

# -------------------------------
# 4) MANIFEST.tsv (real tabs)
# -------------------------------
MAN="$STAGE/MANIFEST__${PKG}.tsv"
printf "role\trelpath\tbytes\tsha256\n" > "$MAN"

add_manifest_row() {
  local role="$1"
  local file="$2"
  local rel="$3"
  [ -f "$file" ] || return 0
  b="$(stat --printf='%s' "$file" 2>/dev/null || echo 0)"
  s="$(sha256sum "$file" | awk '{print $1}')"
  printf "%s\t%s\t%s\t%s\n" "$role" "$rel" "$b" "$s" >> "$MAN"
}

# REQUIRED
for f in "$STAGE/REQUIRED/"*; do
  [ -f "$f" ] || continue
  add_manifest_row "REQUIRED" "$f" "REQUIRED/$(basename "$f")"
done

# CLI
for f in "$STAGE/CLI/"*; do
  [ -f "$f" ] || continue
  add_manifest_row "CLI" "$f" "CLI/$(basename "$f")"
done

# LEGACY
for f in "$STAGE/LEGACY/"*; do
  [ -f "$f" ] || continue
  add_manifest_row "LEGACY" "$f" "LEGACY/$(basename "$f")"
done

# MISS list too
add_manifest_row "REPORT" "$MISS_LST" "$(basename "$MISS_LST")"

sha256sum "$MAN" > "$MAN.sha256"

# -------------------------------
# 5) ZIP (single delivery) + SHA256
# -------------------------------
ZIP="$EXPORT/${PKG}.zip"
rm -f "$ZIP" "$ZIP.sha256" 2>/dev/null || true
( cd "$STAGE" && zip -r "$ZIP" . >/dev/null )
sha256sum "$ZIP" > "$ZIP.sha256"

# -------------------------------
# 6) FIXATION (legal / declarative)
# -------------------------------
FX_DIR="$FIXROOT/FIXATION_SET__TERMINAL_SCRIPTS__${TS}__${TZ_TAG}"
mkdir -p "$FX_DIR"

FX="$FX_DIR/FIXATION__TERMINAL_SCRIPTS_PACKAGE__${TS}__${TZ_TAG}.txt"
cat <<EOT > "$FX"
# =========================
# FIXATION · TERMINAL_SCRIPTS PACKAGE
# =========================
SYSTEM: SIPA / Soul In PsyAbstract
DATE: $(date +%F)
TIME: $(date +%H:%M:%S)
TZ: ${TZ}

MODE: LEGAL / DECLARATIVE · READ-ONLY
EXECUTION_CONTEXT=NONE
RUNTIME=LOCAL
CLAIMS=NONE

PURPOSE:
Create a single operator package of terminal scripts:
- REQUIRED (core daily/weekly scripts)
- CLI (sipa wrapper, if present)
- LEGACY (discovered *.sh in SAFE_V3, non-required)

SOURCE:
BASE: ${BASE}

OUTPUTS:
- ZIP: ${ZIP}
- ZIP.SHA256: ${ZIP}.sha256
- MANIFEST: ${MAN}
- MANIFEST.SHA256: ${MAN}.sha256

REQUIRED LIST:
- day_boot_v2.sh
- day_scan_clean_v2.sh
- day_close_v2.sh
- week_scan_clean_v2.sh

CLI:
- ${CLI}

MISSING REPORT:
- ${MISS_LST}

DECLARATION:
This fixation asserts package creation and file integrity only.
No claims about execution outcomes.

STATUS:
TERMINAL_SCRIPTS_PACKAGE = CREATED
RETROACTIVE_MUTATION = FORBIDDEN
EOT
sha256sum "$FX" > "$FX.sha256"

# Package manifest for fixation set
FX_MAN="$FX_DIR/MANIFEST__FIXATION_SET__TERMINAL_SCRIPTS__${TS}__${TZ_TAG}.tsv"
printf "filename\tbytes\tsha256\n" > "$FX_MAN"
for f in "$FX" "$FX.sha256"; do
  b="$(stat --printf='%s' "$f")"
  s="$(sha256sum "$f" | awk '{print $1}')"
  printf "%s\t%s\t%s\n" "$(basename "$f")" "$b" "$s" >> "$FX_MAN"
done
sha256sum "$FX_MAN" > "$FX_MAN.sha256"

# Zip the fixation set (one zip)
FX_ZIP="$EXPORT/FIXATION_SET__TERMINAL_SCRIPTS__${TS}__${TZ_TAG}.zip"
rm -f "$FX_ZIP" "$FX_ZIP.sha256" 2>/dev/null || true
( cd "$FIXROOT" && zip -r "$FX_ZIP" "$(basename "$FX_DIR")" >/dev/null )
sha256sum "$FX_ZIP" > "$FX_ZIP.sha256"

echo "OK: PACKAGE ZIP -> $ZIP"
echo "OK: FIXATION ZIP -> $FX_ZIP"
echo "NOTE: Stage kept at $STAGE (you may archive/move later)"
exit 0
EOT

chmod +x /storage/emulated/0/PROJECT/SAFE_V3/sipa_terminal_scripts_build_v1.sh
