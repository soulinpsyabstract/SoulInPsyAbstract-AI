#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

TZ="Asia/Jerusalem"
TZ_TAG="${TZ//\//-}"

SAFE="/storage/emulated/0/PROJECT/SAFE_V3"
ROOT="/storage/emulated/0/PROJECT/PAYTON_HUBS"
FIX="$ROOT/HUB_LEGAL_FORENSIC/FIXATIONS"
OUT="$ROOT/HUB_LEGAL_FORENSIC/DAY_CLOSE"

DAY="${1:-$(date +%F)}"                 # allow retro: bash day_close_v2.sh 2026-01-18
NOW="$(date +%H-%M-%S)"
TS="$(date +%F__%H-%M-%S)"

mkdir -p "$FIX" "$OUT"

BOOT_DIR="$FIX/BOOT__${DAY}"
SCAN_DIR="$SAFE/_FORENSIC_SCAN/DAY__${DAY}"

# 1) DAY_LOG (stable per day name)
DAY_LOG="$FIX/DAY_LOG__${DAY}.txt"
cat <<EOT > "$DAY_LOG"
DAY CLOSE · TEXT ONLY
DATE: ${DAY}
FIXED_AT: $(date +%F__%H-%M-%S)
TZ: ${TZ}

EXECUTION_CONTEXT=NONE
RUNTIME=LOCAL
CLAIMS=NONE

HEADSHOT:
- Energy: ${ENERGY:-UNKNOWN}
- Focus: ${FOCUS:-UNKNOWN}
- Risk level: ${RISK_LEVEL:-UNKNOWN}
- One priority: ${ONE_PRIORITY:-UNKNOWN}

TIMELINE (KEY EVENTS):
- [fill with facts]

RUNTIME STATUS:
- Active hubs touched: [fill]
- Fixations created: [fill]
- Packages created: [fill]

INVENTORY (FACTS ONLY):
- Boot dir: ${BOOT_DIR}
- Scan dir: ${SCAN_DIR}

NOTES:
- ZIP is the day seal.
- No claims beyond file presence.
EOT
sha256sum "$DAY_LOG" > "${DAY_LOG}.sha256"

# 2) INVENTORY list for the day (bounded)
INV="$FIX/INVENTORY__DAY__${DAY}.lst"
find "$ROOT" -maxdepth 6 -type f \
  \( -name "*${DAY}*" -o -name "*DAY_LOG__${DAY}*" -o -name "BOOT__${DAY}*" -o -name "*FIXATION*" -o -name "*SUBMISSION*" -o -name "*STARTS*" -o -name "*SCAN*" \) \
  -print > "$INV" 2>/dev/null || true
sha256sum "$INV" > "${INV}.sha256"

# 3) ZIP (one day one zip name)
ZIP="$OUT/DAY_CLOSE__${DAY}__${TZ_TAG}.zip"
rm -f "$ZIP" "$ZIP.sha256" 2>/dev/null || true

( cd "$ROOT" && zip -r "$ZIP" \
  "HUB_LEGAL_FORENSIC/FIXATIONS/$(basename "$DAY_LOG")" \
  "HUB_LEGAL_FORENSIC/FIXATIONS/$(basename "$DAY_LOG").sha256" \
  "HUB_LEGAL_FORENSIC/FIXATIONS/$(basename "$INV")" \
  "HUB_LEGAL_FORENSIC/FIXATIONS/$(basename "$INV").sha256" \
  >/dev/null )

# Add BOOT folder if exists
if [ -d "$BOOT_DIR" ]; then
  ( cd "$ROOT" && zip -r "$ZIP" "HUB_LEGAL_FORENSIC/FIXATIONS/$(basename "$BOOT_DIR")" >/dev/null )
fi

# Add SCAN folder if exists
if [ -d "$SCAN_DIR" ]; then
  ( cd "$SAFE" && zip -r "$ZIP" "_FORENSIC_SCAN/DAY__${DAY}" >/dev/null )
fi

sha256sum "$ZIP" > "$ZIP.sha256"

# 4) MANIFEST (zip + zip.sha256)
MAN="$OUT/MANIFEST__DAY_CLOSE__${DAY}__${TZ_TAG}.tsv"
printf "filename\tbytes\tsha256\n" > "$MAN"

ZBYTES="$(wc -c < "$ZIP" | tr -d ' ')"
ZSHA="$(awk '{print $1}' "$ZIP.sha256")"
printf "%s\t%s\t%s\n" "$(basename "$ZIP")" "$ZBYTES" "$ZSHA" >> "$MAN"

SABYTES="$(wc -c < "$ZIP.sha256" | tr -d ' ')"
SASHA="$(sha256sum "$ZIP.sha256" | awk '{print $1}')"
printf "%s\t%s\t%s\n" "$(basename "$ZIP").sha256" "$SABYTES" "$SASHA" >> "$MAN"

sha256sum "$MAN" > "$MAN.sha256"

echo "OK: DAY_CLOSE -> $ZIP"
