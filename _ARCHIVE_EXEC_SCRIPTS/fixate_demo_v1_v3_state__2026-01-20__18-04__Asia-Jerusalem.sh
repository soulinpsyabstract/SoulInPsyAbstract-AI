#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

TZ="Asia/Jerusalem"
TZ_TAG="${TZ//\//-}"
DAY="2026-01-20"
TIME_TAG="18-04"
TS="$(date +%F__%H-%M-%S)"

ROOT="/storage/emulated/0/PROJECT/PAYTON_HUBS"
FIX="$ROOT/HUB_LEGAL_FORENSIC/FIXATIONS"
OUT="$ROOT/HUB_LEGAL_FORENSIC/FIXATION_EXPORTS"

mkdir -p "$FIX" "$OUT"

PKG="FIXATION_SET__DEMO_V1_AND_DEMO_STATE__${DAY}__${TIME_TAG}__${TZ_TAG}"
WORK="$FIX/$PKG"
mkdir -p "$WORK"

# -----------------------------
# A) DEMO DISTRIBUTION STATE (2026-01-09) – paste 1:1
# -----------------------------
FX_A="$WORK/FIXATION__DEMO_DISTRIBUTION_STATE__2026-01-09__19-19__${TZ_TAG}.txt"
cat <<'EOT' > "$FX_A"
SERVICE FIXATION · V3 · DEMO DISTRIBUTION STATE
MODE: TERMINAL · TEXT_ONLY · DECLARATIVE

Timestamp: 2026-01-09__19-19
Timezone: Asia/Jerusalem

System:
SoulInPsyAbstract AI (SIPA)

Operator:
Aelin AquaSol
(Legal identity on record)

EXECUTION_CONTEXT=NONE
RUNTIME=NONE
AUTOMATION=NONE
CLAIMS=NONE

SCOPE:
LEGAL PROTOCOL v1 · CHAIN MODE (DEMO / SAFE)

DISTRIBUTION STATE (FACTUAL):

- Technical professionals (IT): 1
- Non-technical users: 6

ACCESS LEVEL:
- DEMO TEXT ONLY
- No internal structure disclosed
- No file paths disclosed
- No artifacts disclosed
- No executable or operational material disclosed

STATUS:
- This distribution does NOT constitute publication.
- This distribution does NOT constitute release.
- This distribution does NOT grant rights, licenses, or access.
- This distribution is exploratory and observational only.

INTERPRETATION:
- Responses, silence, or refusal are not evaluated at this stage.
- No conclusions are drawn.
- Feedback may be logged later as separate artifacts.

DECLARATION:
This fixation records current demo exposure state only.
No expansion of access.
No change of system status.
No transition to public phase.

END_OF_FIXATION
EOT
sha256sum "$FX_A" > "$FX_A.sha256"

# -----------------------------
# B) DEMO v1 (2026-01-10) – you paste the contract 1:1 from your file
# -----------------------------
FX_B="$WORK/FIXATION__DEMO_V1__AI_USER_CONTRACT_FULL__2026-01-10__19-32__${TZ_TAG}.txt"
cat <<'EOT' > "$FX_B"
# =========================
# FIXATION · DEMO v1 (TEXT ONLY)
# =========================
SYSTEM: SIPA / Soul In PsyAbstract
SOURCE: AI_USER_CONTRACT__FULL__2026-01-10__19-32 (operator-provided)
DATE_ORIGIN: 2026-01-10
TIME_ORIGIN: 19-32
TZ: Asia/Jerusalem

MODE: LEGAL / DECLARATIVE · READ-ONLY
EXECUTION_CONTEXT=NONE
RUNTIME=NONE
CLAIMS=NONE

RAW_TEXT (1:1) BELOW:
--------------------------------------------------
PASTE_HERE_1_TO_1
--------------------------------------------------

STATUS:
DEMO_V1_FIXED = TRUE
RETROACTIVE_MUTATION = FORBIDDEN
EOT

# IMPORTANT:
# After you paste the raw text into FX_B, run:
# sha256sum "$FX_B" > "$FX_B.sha256"

# -----------------------------
# C) MANIFEST for WORK folder
# -----------------------------
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

# -----------------------------
# D) ZIP bundle + sha256
# -----------------------------
ZIP="$OUT/${PKG}__${TS}.zip"
rm -f "$ZIP" "$ZIP.sha256" 2>/dev/null || true
( cd "$FIX" && zip -r "$ZIP" "$(basename "$WORK")" >/dev/null )
sha256sum "$ZIP" > "$ZIP.sha256"

echo "OK: WORK -> $WORK"
echo "OK: ZIP  -> $ZIP"
