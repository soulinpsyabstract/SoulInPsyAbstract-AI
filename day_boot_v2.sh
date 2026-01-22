#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

TZ="Asia/Jerusalem"
ROOT="/storage/emulated/0/PROJECT/PAYTON_HUBS"
FIX="$ROOT/HUB_LEGAL_FORENSIC/FIXATIONS"

DAY="$(date +%F)"
NOW="$(date +%H-%M-%S)"

# One-day one-name folder (rewrite allowed inside same day)
BOOT="$FIX/BOOT__${DAY}"
mkdir -p "$BOOT"

# User-editable fields (optional env overrides)
LAST_CLOSE="${LAST_CLOSE:-UNKNOWN}"
PHASE_ENDED="${PHASE_ENDED:-UNKNOWN}"
UNRESOLVED="${UNRESOLVED:-NONE}"
MODE_TODAY="${MODE_TODAY:-EXECUTION}"
FOCUS_BLOCK="${FOCUS_BLOCK:-[one sentence]}"
PLAN1="${PLAN1:-[action]}"
PLAN2="${PLAN2:-[action]}"
PLAN3="${PLAN3:-[stop condition]}"
SUCCESS="${SUCCESS:-[what must exist to close the day]}"
NOTES="${NOTES:-[free text]}"

# 0) DAY_BOOT.txt (operational anchor)
cat > "$BOOT/DAY_BOOT.txt" <<EOF2
DAY BOOT · OPERATIONAL START
DATE: ${DAY}
TIME: ${NOW}
TZ: ${TZ}

EXECUTION_CONTEXT=NONE
RUNTIME=NONE
CLAIMS=NONE

STATE FROM PREVIOUS DAY:
- Last close: ${LAST_CLOSE}
- Phase ended: ${PHASE_ENDED}
- Unresolved: ${UNRESOLVED}

TODAY PHASE:
- Mode: ${MODE_TODAY}
- Focus block: ${FOCUS_BLOCK}
- Forbidden actions:
  - no retro-mutation
  - no new protocols

PLAN (REALISTIC):
1. ${PLAN1}
2. ${PLAN2}
3. ${PLAN3}

SUCCESS CONDITION (for DAY CLOSE):
- ${SUCCESS}

NOTES:
- ${NOTES}
EOF2
sha256sum "$BOOT/DAY_BOOT.txt" > "$BOOT/DAY_BOOT.txt.sha256"

# 1) HEADSHOT.txt
cat > "$BOOT/HEADSHOT.txt" <<EOF2
HEADSHOT · STATE SNAPSHOT
DATE: ${DAY}
TIME: ${NOW}
TZ: ${TZ}

Energy: ${ENERGY:-UNKNOWN}
Focus: ${FOCUS:-UNKNOWN}
Risk level: ${RISK_LEVEL:-UNKNOWN}
One priority: ${ONE_PRIORITY:-BOOTSTRAP}
EOF2
sha256sum "$BOOT/HEADSHOT.txt" > "$BOOT/HEADSHOT.txt.sha256"

# 2) TIMELINE.txt (append-only inside the day)
touch "$BOOT/TIMELINE.txt"
echo "[${NOW}] Day boot executed / rewritten." >> "$BOOT/TIMELINE.txt"
sha256sum "$BOOT/TIMELINE.txt" > "$BOOT/TIMELINE.txt.sha256"

# 3) RUNTIME_STATUS.txt
cat > "$BOOT/RUNTIME_STATUS.txt" <<EOF2
RUNTIME STATUS
DATE: ${DAY}
TIME: ${NOW}
TZ: ${TZ}

Active hubs (planned):
- HUB_LEGAL_FORENSIC
- [ADD]

Fixations planned:
- [ADD]

Packages planned:
- [ADD]
EOF2
sha256sum "$BOOT/RUNTIME_STATUS.txt" > "$BOOT/RUNTIME_STATUS.txt.sha256"

# 4) INVENTORY.tsv (in BOOT only)
find "$BOOT" -maxdepth 1 -type f ! -name '*.sha256' -printf "%f\t%s\n" \
  > "$BOOT/INVENTORY.tsv"
sha256sum "$BOOT/INVENTORY.tsv" > "$BOOT/INVENTORY.tsv.sha256"

# 5) MANIFEST.tsv (in BOOT only)
printf "filename\tbytes\tsha256\n" > "$BOOT/MANIFEST.tsv"
for f in "$BOOT"/*; do
  [ -f "$f" ] || continue
  name="$(basename "$f")"
  size="$(stat --printf='%s' "$f")"
  sum="$(sha256sum "$f" | awk '{print $1}')"
  printf "%s\t%s\t%s\n" "$name" "$size" "$sum" >> "$BOOT/MANIFEST.tsv"
done
sha256sum "$BOOT/MANIFEST.tsv" > "$BOOT/MANIFEST.tsv.sha256"

# 6) AUDIT append-only
AUDIT="$FIX/AUDIT__LEGAL_FIXATIONS.log"
touch "$AUDIT"
{
  echo "==== DAY BOOT v2: ${DAY}__${NOW} ===="
  echo "BOOT: $BOOT"
  echo "MANIFEST_SHA256: $(awk '{print $1}' "$BOOT/MANIFEST.tsv.sha256")"
  echo "EXECUTION_CONTEXT=NONE | RUNTIME=NONE | CLAIMS=NONE"
  echo
} >> "$AUDIT"
sha256sum "$AUDIT" > "$FIX/AUDIT__LEGAL_FIXATIONS.log.sha256"

echo "OK: DAY_BOOT -> $BOOT"
