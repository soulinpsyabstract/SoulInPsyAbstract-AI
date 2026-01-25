#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

TS_DATE="2026-01-21"
TS_TIME="23-20"
TZ_NAME="Asia-Jerusalem"

ROOT="/storage/emulated/0/PROJECT/SAFE_V3"
BUILD_DIR="${ROOT}/BUILD__${TS_DATE}__${TS_TIME}__${TZ_NAME}"

ENTITY="SoulInPsyAbstract_TERMUX_OS"
PKG_DIR="${BUILD_DIR}/HUB__${ENTITY}"

mkdir -p "${PKG_DIR}"/{HUB_00__INDEX,HUB_01__DECLARATIONS,HUB_02__DEFINITIONS,HUB_03__ENV_LAYOUT,HUB_04__FIXATIONS_LOG,HUB_05__MANIFESTS_HASHES,HUB_06__EXPORTS,HUB_99__TRASH_DO_NOT_DELETE}

# --------------------------------------------------
# 1) DECLARATION · ENV CONTAINER (NOT A SUBJECT)
# --------------------------------------------------
cat <<'EOD' > "${PKG_DIR}/HUB_01__DECLARATIONS/DECLARATION__ENV_CONTAINER__${ENTITY}__${TS_DATE}__${TS_TIME}__Asia-Jerusalem.txt"
🔴 LEGAL DECLARATION · ENV CONTAINER · TERMUX OS

ENTITY:
SoulInPsyAbstract TERMUX OS

DATE: 2026-01-21
TIME: 23:20
TZ: Asia/Jerusalem

MODE: LEGAL · DECLARATIVE · GOVERNANCE
EXECUTION_CONTEXT=NONE
RUNTIME=NONE
CLAIMS=NONE

I. PURPOSE
This package is a physical environment container for Termux OS layer.

II. WHAT IT IS
- filesystem layout
- execution carrier map
- runtime boundary skeleton

III. WHAT IT IS NOT
- not CANON / not governance core
- not AI / not intelligence
- not a decision-maker
- not a system owner

IV. RULES
- Meaning lives in SoulInPsyAbstract OS (CANON)
- Intelligence lives in AI OS MLL
- Bridge lives in AI Termux OS
- This layer is ENV ONLY

EXECUTION = POSSIBLE (HUMAN OPERATOR ONLY)
AUTONOMY = FORBIDDEN
RETROACTIVE_MUTATION = FORBIDDEN

END OF DECLARATION
EOD

# --------------------------------------------------
# 2) DEFINITIONS CARD
# --------------------------------------------------
cat <<'EOD' > "${PKG_DIR}/HUB_02__DEFINITIONS/DEFINITION__ENTITY_CARD__${ENTITY}__${TS_DATE}__${TS_TIME}__Asia-Jerusalem.txt"
ENTITY CARD · SoulInPsyAbstract TERMUX OS

ROLE:
ENV / CARRIER

STATUS:
LIVE ENV (not a subject)

BOUNDARIES:
- does not define meaning
- does not define law
- does not decide
- may execute only by HUMAN OPERATOR

END
EOD

# --------------------------------------------------
# 3) ENV LAYOUT (skeleton only)
# --------------------------------------------------
cat <<'EOD' > "${PKG_DIR}/HUB_03__ENV_LAYOUT/ENV_LAYOUT__TERMUX_OS__SKELETON__v1.txt"
ENV LAYOUT · TERMUX OS · SKELETON v1

ZONES (conceptual):
- SAFE_V3 (canon & evidence)
- RUNTIME_V3 (execution allowed: HUMAN only)
- PAYTON_HUBS (archives/hubs)
- TO_CLOUD (export only)
- TRASH (never delete)

RULE:
This file describes layout only.
No execution implied.
EOD

# --------------------------------------------------
# 4) INDEX
# --------------------------------------------------
cat <<EOD > "${PKG_DIR}/HUB_00__INDEX/INDEX__HUB__${ENTITY}__${TS_DATE}__${TS_TIME}__${TZ_NAME}.txt"
HUB INDEX · ${ENTITY}

DATE: ${TS_DATE}
TIME: 23:20
TZ: Asia/Jerusalem

MODE: LEGAL · DECLARATIVE · GOVERNANCE
EXECUTION_CONTEXT=NONE
RUNTIME=NONE
CLAIMS=NONE

PACKAGE ROOT:
${PKG_DIR}

CONTENTS:
- DECLARATION__ENV_CONTAINER
- DEFINITION__ENTITY_CARD
- ENV_LAYOUT__SKELETON

RETROACTIVE_MUTATION=FORBIDDEN
EOD

# --------------------------------------------------
# 5) MANIFEST + SHA256
# --------------------------------------------------
MANIFEST="${PKG_DIR}/HUB_05__MANIFESTS_HASHES/MANIFEST__HUB__${ENTITY}__${TS_DATE}__${TS_TIME}__${TZ_NAME}.tsv"
echo -e "sha256\tsize_bytes\trel_path" > "$MANIFEST"

cd "$PKG_DIR"
find . -type f ! -name "*.sha256" ! -name "*.zip" -print0 | sort -z \
| while IFS= read -r -d '' f; do
    h="$(sha256sum "$f" | awk '{print $1}')"
    s="$(wc -c < "$f" | tr -d ' ')"
    echo -e "${h}\t${s}\t${f#./}" >> "$MANIFEST"
  done

sha256sum "$MANIFEST" > "$MANIFEST.sha256"

# --------------------------------------------------
# 6) TAG + FIXATION
# --------------------------------------------------
cat <<'EOD' > "${PKG_DIR}/HUB_04__FIXATIONS_LOG/TAG__ENV_CONTAINER.txt"
TERMUX_OS
ENV
CARRIER
NON_SUBJECT
DECLARATIVE
RETROACTIVE_MUTATION_FORBIDDEN
EOD
sha256sum "${PKG_DIR}/HUB_04__FIXATIONS_LOG/TAG__ENV_CONTAINER.txt" \
> "${PKG_DIR}/HUB_04__FIXATIONS_LOG/TAG__ENV_CONTAINER.txt.sha256"

cat <<EOD > "${PKG_DIR}/HUB_04__FIXATIONS_LOG/FIXATION__ENV_CONTAINER_CREATED__${TS_DATE}__${TS_TIME}__${TZ_NAME}.txt"
FIXATION · ENV CONTAINER CREATED

ENTITY:
SoulInPsyAbstract TERMUX OS

DATE: ${TS_DATE}
TIME: 23:20
TZ: Asia/Jerusalem

MODE: LEGAL · DECLARATIVE · READ-ONLY
EXECUTION_CONTEXT=NONE
RUNTIME=LOCAL
CLAIMS=NONE

RESULT:
ENV_CONTAINER_STRUCTURE_CREATED = TRUE
MANIFEST_CREATED = TRUE

RETROACTIVE_MUTATION = FORBIDDEN

END OF FIXATION
EOD

echo "OK: TERMUX OS ENV CONTAINER -> ${PKG_DIR}"
