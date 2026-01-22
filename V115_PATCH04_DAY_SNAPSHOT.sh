#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

# =========================
# PAYTON SUIT · CORE CANON v1.1.5
# PATCH 04 — DAY SNAPSHOT (OBSERVABILITY)
# MODE: GOVERNANCE / VALIDATION ONLY
# READ-ONLY · NON-DESTRUCTIVE
# =========================

ROOT="/storage/emulated/0/PROJECT/PAYTON_HUBS"
EXPORT_ROOT="$ROOT/_FIXATION/_EXPORTS"

TS="$(date +%Y-%m-%d_%H-%M-%S)"
DAY="$(date +%Y-%m-%d)"
RUN_NAME="V115_DAY_SNAPSHOT_$TS"
OUT="$EXPORT_ROOT/$RUN_NAME"

mkdir -p "$OUT"/{FILES,HASHES,ZIP}

REPORT="$OUT/FILES/DAY_SNAPSHOT_$DAY.txt"
exec > >(tee "$OUT/FILES/console.log") 2>&1

echo "SNAPSHOT_TIME=$TS"
echo "DAY=$DAY"
echo "MODE=GOVERNANCE_VALIDATION_ONLY"
echo "RULE=OBSERVE_ONLY;NO_EXECUTION;NO_INTERPRETATION"
echo

echo "=== OBSERVED PATCHES (v1.1.5) ==="

ls -d "$EXPORT_ROOT"/V115_* 2>/dev/null || echo "NONE_FOUND"

echo
echo "=== LATEST KNOWN RUNTIMES ==="

echo "RUNTIME_4H:"
ls -d "$EXPORT_ROOT"/RUNTIME_4H_* 2>/dev/null | tail -n 1 || echo "NONE"

echo
echo "RUNTIME_DAILY_0000:"
ls -d "$EXPORT_ROOT"/RUNTIME_DAILY_0000_* 2>/dev/null | tail -n 1 || echo "NONE"

echo
echo "=== END OF SNAPSHOT ==="

# write report explicitly
cp "$OUT/FILES/console.log" "$REPORT"

sha256sum "$REPORT" > "$REPORT.sha256"

ZIPFILE="$OUT/ZIP/${RUN_NAME}.zip"
( cd "$OUT" && zip -r "ZIP/${RUN_NAME}.zip" FILES >/dev/null )

sha256sum "$ZIPFILE" > "$ZIPFILE.sha256"
sha256sum -c "$ZIPFILE.sha256"

echo "SNAPSHOT_STATUS=VALID"
echo "ARTIFACT_ZIP=$ZIPFILE"
