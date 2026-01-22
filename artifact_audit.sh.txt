#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

BASE="${HOME}/PROJECT/PAYTON_HUBS"
OUT="${BASE}/_FIXATION/_EXPORTS"
LOG="${BASE}/HUB_CORE/FIXATION/ARTIFACT_AUDIT_LOG.txt"

mkdir -p "$(dirname "${LOG}")"

for z in "${OUT}"/*.zip; do
  [[ -f "$z" ]] || continue
  h="${z}.sha256"

  if [[ ! -f "$h" ]]; then
    echo "MISSING HASH: $z" >> "$LOG"
    continue
  fi

  if sha256sum -c "$h" >/dev/null 2>&1; then
    echo "OK: $z" >> "$LOG"
  else
    echo "BROKEN: $z" >> "$LOG"
  fi
done

echo "AUDIT DONE @ $(date)" >> "$LOG"
