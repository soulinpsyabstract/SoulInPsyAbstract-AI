#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

BASE="/storage/emulated/0/PROJECT/SAFE_V3"
CORE="$BASE/SIPA_OS__CORE_PROTOCOL_v1.0"

PUB="$CORE/PUBLIC"
OP="$CORE/OPERATOR"

mkdir -p "$PUB" "$OP"

# PUBLIC: no paths, no state, no private logs
cat <<'EOT' > "$PUB/README__PUBLIC.txt"
SIPA / Soul In PsyAbstract — PUBLIC LAYER

This folder is allowed to be shown publicly.
Rules:
- No device paths
- No archives / fixations
- No hashes of private operator storage
- Descriptions, diagrams, demo protocols only
EOT

# OPERATOR: pointers only (no copying of PAYTON_HUBS)
cat <<'EOT' > "$OP/README__OPERATOR.txt"
SIPA — OPERATOR LAYER (Pointers only)

This folder is not for public distribution.
It references real operator storage locations:

SAFE_V3:
- /storage/emulated/0/PROJECT/SAFE_V3

PAYTON_HUBS:
- /storage/emulated/0/PROJECT/PAYTON_HUBS

RULE:
Do not copy PAYTON_HUBS into PUBLIC.
EOT

echo "OK: PUBLIC -> $PUB"
echo "OK: OPERATOR -> $OP"
