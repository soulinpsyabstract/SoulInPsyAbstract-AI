#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

# =========================
# PAYTON HUB CLEANUP v1.0
# safe: no delete, snapshot first
# =========================

TS="$(date +%F__%H-%M-%S)"
ROOT="${PAYTON_ROOT:-/storage/emulated/0/PROJECT/PAYTON_HUBS}"

cd "$ROOT" 2>/dev/null || { echo "ERROR: cannot cd to ROOT: $ROOT"; exit 1; }

echo "== PAYTON CLEANUP START: $TS =="
echo "ROOT: $(pwd)"

# --- folders we rely on ---
mkdir -p "_FIXATION/_EXPORTS" "_FIXATION/_LOGS" "TRASH" "HUB_TXT/_ROOT_DUMPS" "HUB_TXT/_HASHES" \
         "HUB_ZIP/_ROOT_DUMPS" "HUB_PDF/_ROOT_DUMPS" "HUB_CSV/_ROOT_DUMPS" "LOGS/_ROOT_DUMPS"

REPORT="_FIXATION/_LOGS/ORDER_REPORT__${TS}.txt"
touch "$REPORT"

log(){ echo "$*" | tee -a "$REPORT" >/dev/null; }

log "=== PAYTON HUB CLEANUP REPORT ==="
log "TS: $TS"
log "ROOT: $(pwd)"
log ""

# --- 0) SNAPSHOT before moves ---
SNAPZIP="_FIXATION/_EXPORTS/${TS}__PRE_CLEAN__PAYTON_HUBS.zip"
log "[0] Snapshot: $SNAPZIP"
# zip everything except the zip itself (created in _FIXATION/_EXPORTS) is safe
zip -r "$SNAPZIP" . -x "_FIXATION/_EXPORTS/*" >/dev/null
sha256sum "$SNAPZIP" > "${SNAPZIP}.sha256"
log "    OK: snapshot+sha256 created"
log ""

# --- 1) normalize known bad names (trailing spaces) ---
# Example found: 'Licence ' -> 'Licence'
if [ -d "Licence " ] && [ ! -d "Licence" ]; then
  log "[1] Rename dir: 'Licence ' -> 'Licence'"
  mv -n "Licence " "Licence"
fi
log "[1] Rename pass done"
log ""

# --- 2) Human folders -> redirect README (do NOT delete, do NOT move) ---
# Map human-readable to canonical HUB_*
declare -A MAP=(
  ["CORE CANON"]="HUB_CORE"
  ["PUBLIC PRESENCE"]="HUB_PAYTON_UNIVERSE"
  ["ARTWORK SELLING"]="HUB_ARTWORK_SELLING"
  ["Payton"]="HUB_PAYTON_UNIVERSE"
  ["IP SCHOOL PROTECTION"]="HUB_LEGAL_FORENSIC"
  ["GOVERNANCE"]="HUB_CORE"
  ["WEB DESIGN"]="HUB_SITE_WORKSHOP"
  ["Родословная"]="HUB_GENEALOGY"
  ["Residents"]="HUB_RESEARCH"
  ["PSYCHOLOGY DEFINITION"]="HUB_RESEARCH_PSYCHOLOGY"
  ["Forensic"]="HUB_LEGAL_FORENSIC"
  ["ECONOMY HAB"]="HUB_CSV"
)

log "[2] Redirect README in human folders (no moves)"
for human in "${!MAP[@]}"; do
  canon="${MAP[$human]}"
  mkdir -p "$canon"
  if [ -d "$human" ]; then
    README="$human/README__REDIRECT.md"
    {
      echo "# REDIRECT"
      echo ""
      echo "**This folder is a human label only.**"
      echo ""
      echo "CANONICAL HUB → \`$canon/\`"
      echo ""
      echo "Rule: Work inside HUB_* only. This folder stays as a signpost."
      echo ""
      echo "TS: $TS"
    } > "$README"
    log "    OK: $human -> $canon (README written)"
  else
    log "    SKIP: missing folder: $human"
  fi
done
log ""

# --- 3) Root file cleanup: move loose files into proper hubs ---
# Keep these in root (do not move)
KEEP_ROOT_REGEX='^(README_PAYTON\.md|NAV\.md|DIRLIST\.txt|FILELIST(\.txt|_FULL\.txt)?|MANIFEST.*|TREE_MAX4\.txt|_REAL_DIR_TREE\.txt|ZIP_LIST(\.txt|\.bin)?|ZIP_SHA256\.txt|SHA256.*|SCRIPTS|LOGS|TRASH|_FIXATION|_EXPORTS|_DAILY|_BACKUPS|_OFFLOAD|_SESSION_OPEN|HUB_.*)$'

log "[3] Move loose root files into HUB_* buckets (safe moves)"
shopt -s nullglob
for f in *; do
  # skip directories
  if [ -d "$f" ]; then
    continue
  fi

  # keep important/known root files
  if echo "$f" | grep -Eq "$KEEP_ROOT_REGEX"; then
    continue
  fi

  # decide destination by extension/pattern
  dest=""
  case "$f" in
    *.zip) dest="HUB_ZIP/_ROOT_DUMPS" ;;
    *.sha256) dest="HUB_TXT/_HASHES" ;;
    *.txt) dest="HUB_TXT/_ROOT_DUMPS" ;;
    *.md) dest="HUB_TXT/_ROOT_DUMPS" ;;
    *.csv|*.tsv) dest="HUB_CSV/_ROOT_DUMPS" ;;
    *.pdf) dest="HUB_PDF/_ROOT_DUMPS" ;;
    *.tar.gz|*.tgz) dest="HUB_ZIP/_ROOT_DUMPS" ;;
    *.log) dest="LOGS/_ROOT_DUMPS" ;;
    *) dest="TRASH/_UNSORTED_ROOT_FILES__${TS}" ;;
  esac

  mkdir -p "$dest"
  mv -n "$f" "$dest/" && log "    MOVED: $f -> $dest/"
done
shopt -u nullglob
log ""

# --- 4) Create a clean hub index (what exists now) ---
log "[4] Hub index"
ls -1d HUB_* 2>/dev/null | sort | sed 's/^/    /' | tee -a "$REPORT" >/dev/null
log ""

# --- 5) Final sanity: list remaining loose root files ---
log "[5] Remaining loose root files (should be minimal)"
ls -1p | grep -v '/$' | sort | sed 's/^/    /' | tee -a "$REPORT" >/dev/null
log ""

log "== DONE: $TS =="
echo "DONE. Report: $REPORT"
echo "Snapshot: $SNAPZIP (+ .sha256)"
