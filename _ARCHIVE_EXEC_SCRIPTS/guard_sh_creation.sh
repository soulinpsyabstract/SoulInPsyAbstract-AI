#!/usr/bin/env bash
set -euo pipefail

REGISTRY="SH_REGISTRY__CANON__2026-01-21.tsv"

if [ "$#" -ne 1 ]; then
  echo "USAGE: guard_sh_creation.sh <path/to/script.sh>"
  exit 2
fi

TARGET="$1"

if [ ! -f "$REGISTRY" ]; then
  echo "ERROR: SH registry not found"
  exit 3
fi

if grep -Fq "$TARGET" "$REGISTRY"; then
  echo "OK: $TARGET is registered"
  exit 0
else
  echo "BLOCKED: $TARGET is NOT registered in SH_REGISTRY"
  exit 1
fi
