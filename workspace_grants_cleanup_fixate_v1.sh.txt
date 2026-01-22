#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

TZ="Asia/Jerusalem"
TZ_TAG="${TZ//\//-}"
TS="$(date +%F__%H-%M-%S)"
DAY="$(date +%F)"

SAFE="/storage/emulated/0/PROJECT/SAFE_V3"
WG="$SAFE/WORKSPACE_GRANTS"

ROOT="/storage/emulated/0/PROJECT/PAYTON_HUBS"
FIX="$ROOT/HUB_LEGAL_FORENSIC/FIXATIONS"
OUT="$ROOT/HUB_LEGAL_FORENSIC/FIXATION_EXPORTS"
TRASH="$ROOT/TRASH/WORKSPACE_GRANTS_DIRTY_PIPELINE__${DAY}__${TS}"

mkdir -p "$FIX" "$OUT" "$TRASH"

# Target dirs (existence-checked)
CANDIDATES=(
  "OUTPUT_SUBMISSION"
  "OUTPUT_SUBMISSION_CROPPED"
  "OUTPUT_SUBMISSION_FIXED"
  "OUTPUT_SUBMISSION_NORMALIZED"
  "OUTPUT_SUBMISSION_NORMALIZED_V3"
  "STEP_01_CROPPED"
  "STEP_02_SUBMISSION"
  "IMG_PREVIEW"
)

moved=0
for d in "${CANDIDATES[@]}"; do
  if [ -d "$WG/$d" ]; then
    mv -f "$WG/$d" "$TRASH/"
    moved=$((moved+1))
  fi
done

# FIXATION TEXT
PKG="FIXATION_SET__WORKSPACE_GRANTS_CLEANUP__${DAY}__${TS}__${TZ_TAG}"
WORK="$FIX/$PKG"
mkdir -p "$WORK"

FX="$WORK/FIXATION__SYSTEM_CLEANUP__WORKSPACE_GRANTS__${DAY}__${TS}__${TZ_TAG}.txt"
cat <<EOT > "$FX"
# =========================
# FIXATION · SYSTEM CLEANUP (WORKSPACE_GRANTS)
# =========================
SYSTEM: SIPA / Soul In PsyAbstract
DATE: ${DAY}
TIME: ${TS}
TZ: ${TZ}

MODE: LEGAL / DECLARATIVE · READ-ONLY
EXECUTION_CONTEXT=ALLOWED (MOVE-TO-TRASH ONLY)
RUNTIME=LOCAL
CLAIMS=NONE

WHY (RATIONALE):
- Multiple pipeline folders create hash-chain divergence.
- Reprocessing causes quality degradation (repeat compression / trim).
- Source of Truth must be ONE.

WHAT (SCOPE):
WORKSPACE_GRANTS:
- keep: OUTPUT_SUBMISSION__ORIGINAL_LOCK (Source of Truth)
- keep: PACK_0X__Emotional_Infrastructure__INSTITUTIONAL_READY.zip (Delivery artifacts)
- move to TRASH: pipeline duplicates (OUTPUT_SUBMISSION*, STEP_*, IMG_PREVIEW)

HOW (ACTION):
- moved directories into:
  ${TRASH}

RESULT:
- moved_count = ${moved}
- no deletions performed (MOVE only)

STATUS:
WORKSPACE_GRANTS_CLEANUP = DONE
RETROACTIVE_MUTATION = FORBIDDEN
EOT
sha256sum "$FX" > "$FX.sha256"

# INVENTORY of TRASH moved content (paths)
INV="$WORK/INVENTORY__TRASH_MOVED__${DAY}__${TS}.lst"
( cd "$TRASH" && find . -maxdepth 2 -print ) > "$INV" 2>/dev/null || true
sha256sum "$INV" > "$INV.sha256"

# PACKAGE MANIFEST
MAN="$WORK/MANIFEST__${PKG}.tsv"
printf "filename\tbytes\tsha256\n" > "$MAN"
for f in "$WORK"/*; do
  [ -f "$f" ] || continue
  n="$(basename "$f")"
  b="$(stat --printf='%s' "$f")"
  s="$(sha256sum "$f" | awk '{print $1}')"
  printf "%s\t%s\t%s\n" "$n" "$b" "$s" >> "$MAN"
done
sha256sum "$MAN" > "$MAN.sha256"

# ZIP evidence bundle
ZIP="$OUT/${PKG}.zip"
rm -f "$ZIP" "$ZIP.sha256" 2>/dev/null || true
( cd "$ROOT" && zip -r "$ZIP" \
  "HUB_LEGAL_FORENSIC/FIXATIONS/$(basename "$PKG")" \
  >/dev/null )
sha256sum "$ZIP" > "$ZIP.sha256"

echo "OK: TRASH -> $TRASH"
echo "OK: FIXATION_SET -> $WORK"
echo "OK: ZIP -> $ZIP"
