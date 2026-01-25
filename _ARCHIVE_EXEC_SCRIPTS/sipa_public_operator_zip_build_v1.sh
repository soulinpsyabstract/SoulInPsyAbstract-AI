#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

TZ="Asia/Jerusalem"
TZ_TAG="${TZ//\//-}"
TS="$(date +%F__%H-%M-%S)"

BASE="/storage/emulated/0/PROJECT/SAFE_V3/SIPA_OS__CORE_PROTOCOL_v1.0"
EXPORT="$BASE/EXPORT"

ROOT="/storage/emulated/0/PROJECT/PAYTON_HUBS"
FIXROOT="$ROOT/HUB_LEGAL_FORENSIC/FIXATIONS"

PUB="$BASE/PUBLIC"
OP="$BASE/OPERATOR"

mkdir -p "$EXPORT" "$FIXROOT"

build_zip() {
  local SRC="$1"
  local NAME="$2"

  local ZIP="$EXPORT/${NAME}__${TS}__${TZ_TAG}.zip"
  local MAN="$EXPORT/${NAME}__${TS}.tsv"

  printf "relpath\tbytes\tsha256\n" > "$MAN"

  ( cd "$SRC" && find . -type f -print0 ) | while IFS= read -r -d '' f; do
    p="${f#./}"
    b="$(stat --printf='%s' "$SRC/$p")"
    s="$(sha256sum "$SRC/$p" | awk '{print $1}')"
    printf "%s\t%s\t%s\n" "$p" "$b" "$s" >> "$MAN"
  done

  sha256sum "$MAN" > "$MAN.sha256"
  ( cd "$SRC" && zip -r "$ZIP" . >/dev/null )
  sha256sum "$ZIP" > "$ZIP.sha256"

  echo "$ZIP"
}

PUB_ZIP="$(build_zip "$PUB" "SIPA_PUBLIC")"
OP_ZIP="$(build_zip "$OP" "SIPA_OPERATOR")"

FX="$FIXROOT/FIXATION__PUBLIC_OPERATOR_ZIP__${TS}__${TZ_TAG}.txt"

cat <<EOT > "$FX"
# =========================
# FIXATION · PUBLIC / OPERATOR ZIP
# =========================
SYSTEM: SIPA / Soul In PsyAbstract
TZ: ${TZ}

MODE: LEGAL / DECLARATIVE · READ-ONLY
EXECUTION_CONTEXT=NONE
RUNTIME=NONE
CLAIMS=NONE

PUBLIC:
- ZIP: ${PUB_ZIP}
- PURPOSE: External viewer / site
- CONTENT: Demo, schemas, descriptions only

OPERATOR:
- ZIP: ${OP_ZIP}
- PURPOSE: Cold storage
- CONTENT: SAFE_V3, PAYTON_HUBS references, FIXATIONS

DECLARATION:
Separation enforced.
No state leakage between PUBLIC and OPERATOR.

RETROACTIVE_MUTATION = FORBIDDEN
EOT

sha256sum "$FX" > "$FX.sha256"

FX_MAN="$FIXROOT/MANIFEST__FIXATION__PUBLIC_OPERATOR_ZIP__${TS}.tsv"
printf "filename\tbytes\tsha256\n" > "$FX_MAN"
for f in "$FX" "$FX.sha256"; do
  b="$(stat --printf='%s' "$f")"
  s="$(sha256sum "$f" | awk '{print $1}')"
  printf "%s\t%s\t%s\n" "$(basename "$f")" "$b" "$s" >> "$FX_MAN"
done
sha256sum "$FX_MAN" > "$FX_MAN.sha256"

echo "OK: PUBLIC ZIP -> $PUB_ZIP"
echo "OK: OPERATOR ZIP -> $OP_ZIP"
echo "OK: FIXATION -> $FX"
