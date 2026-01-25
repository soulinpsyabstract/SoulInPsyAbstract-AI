#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

# ==========================================================
# CORE CANON · TRUE VALUE RULE
# ID: NO_EXIT_IN_INTERACTIVE_TERMUX
# MODE: GOVERNANCE / VALIDATION ONLY
# NON-DESTRUCTIVE: TRUE
#
# CANON STATEMENT (ABSOLUTE):
# In interactive Termux sessions:
#   DO NOT use `exit` inside artifact scripts.
# Artifact ends. Shell lives.
#
# Enforcement:
# - This script itself never calls `exit`.
# - If any step fails, set -e stops execution (non-zero).
# - Success is indicated by final echo lines.
# ==========================================================

ROOT="/storage/emulated/0/PROJECT/PAYTON_HUBS"
CORE="$ROOT/HUB_CORE"

TS="$(date '+%Y-%m-%d_%H-%M-%S')"
OUTTXT="$CORE/CORE_CANON_RULE__NO_EXIT_IN_INTERACTIVE_TERMUX_$TS.txt"
OUTZIP="${OUTTXT%.txt}.zip"

cd "$ROOT"

cat > "$OUTTXT" <<TXT
CORE CANON · RULE FIXATION

RULE_ID: NO_EXIT_IN_INTERACTIVE_TERMUX
DATE: $(date '+%Y-%m-%d')
TIME: $(date '+%H:%M:%S')
TZ: Asia/Jerusalem

RULE:
In interactive Termux sessions, `exit` is forbidden inside artifact scripts.
Artifact ends. Shell lives.

REASON:
`exit` terminates the interactive shell session (human-facing failure).

ENFORCEMENT:
- Scripts must end without `exit`.
- Use set -euo pipefail for failure propagation.
- Validity is proven only by: TXT + SHA256 + ZIP + ZIP.SHA256 + sha256sum -c.

STATUS: RULE FIXED AS ARTIFACT
TXT

sha256sum "$OUTTXT" > "$OUTTXT.sha256"
zip "$OUTZIP" "$OUTTXT" "$OUTTXT.sha256" >/dev/null
sha256sum "$OUTZIP" > "$OUTZIP.sha256"
sha256sum -c "$OUTZIP.sha256" >/dev/null

echo "CORE_CANON_RULE_STATUS=VALID"
echo "ARTIFACT=$OUTZIP"
# IMPORTANT: no 'exit' here by canon.
