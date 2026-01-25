#!/usr/bin/env bash
set -euo pipefail

DAY="$(date +%F)"
TZ="Asia/Jerusalem"
ROOT="/storage/emulated/0/PROJECT"
FIX="$ROOT/PAYTON_HUBS/HUB_LEGAL_FORENSIC/FIXATIONS"

SCAN_OK=$(ls "$FIX"/FIXATION__DAY_SCAN__${DAY}__* 2>/dev/null | wc -l)

if [ "$SCAN_OK" -eq 0 ]; then
  echo "GUARD BLOCKED:"
  echo "No DAY_SCAN fixation found for $DAY ($TZ)"
  echo "Destructive actions are FORBIDDEN."
  exit 99
fi

echo "GUARD OK: DAY_SCAN found. Remediation permitted."
