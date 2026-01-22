#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

# =========================
# PROJECT ACTIVITY MATRICES v1.0
# READ-ONLY / NO DELETE
# =========================

if [ "${SCAN_DIR:-}" = "" ]; then
  echo "ERROR: SCAN_DIR is not set"
  echo "Hint: export SCAN_DIR=\"/storage/emulated/0/PROJECT/PAYTON_HUBS/HUB_LEGAL_FORENSIC/FIXATIONS/PROJECT_FULL_SCAN__...__Asia-Jerusalem\""
  exit 1
fi

if [ ! -d "$SCAN_DIR" ]; then
  echo "ERROR: SCAN_DIR does not exist: $SCAN_DIR"
  exit 1
fi

FILES="$SCAN_DIR/FILES_INDEX.tsv"
if [ ! -f "$FILES" ]; then
  echo "ERROR: missing FILES_INDEX.tsv at: $FILES"
  exit 1
fi

# derive scan_date from folder name if possible, fallback to today's date
SCAN_DATE="$(basename "$SCAN_DIR" | sed -n 's/^PROJECT_FULL_SCAN__\([0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}\).*/\1/p')"
if [ "$SCAN_DATE" = "" ]; then
  SCAN_DATE="$(date +%F)"
fi

echo "SCAN_DIR:   $SCAN_DIR"
echo "SCAN_DATE:  $SCAN_DATE"

# -------------------------
# 1) PROJECT_MAP_BY_DATE.tsv
# -------------------------
MAP="$SCAN_DIR/PROJECT_MAP_BY_DATE.tsv"
awk -F'\t' '
NR==1 { next }                 # skip header if present
$3 ~ /^[0-9]+$/ {              # only valid epoch
  cmd = "date -d @" $3 " +%Y-%m-%d"
  cmd | getline d
  close(cmd)
  print d "\t" $1 "\t" $2
}
' "$FILES" | sort > "$MAP"

sha256sum "$MAP" > "$MAP.sha256"

# -------------------------
# 2) SCAN_DATE_vs_FILE_DATES.tsv
# -------------------------
SDF="$SCAN_DIR/SCAN_DATE_vs_FILE_DATES.tsv"
{
  echo -e "scan_date\tfile_date\tfiles_count"
  cut -f1 "$MAP" \
  | sort \
  | uniq -c \
  | awk -v SD="$SCAN_DATE" '{print SD "\t" $2 "\t" $1}'
} > "$SDF"

sha256sum "$SDF" > "$SDF.sha256"

# -------------------------
# 3) DAY_ACTIVITY_MATRIX.tsv
# -------------------------
DAM="$SCAN_DIR/DAY_ACTIVITY_MATRIX.tsv"
{
  echo -e "date\tactivity\tfiles_count"
  cut -f1 "$MAP" \
  | sort \
  | uniq -c \
  | awk -v SD="$SCAN_DATE" '{
      d=$2; c=$1;
      if (d==SD) print d "\tOBSERVED\t" c;
      else       print d "\tCHANGED\t" c;
  }'
  # ensure scan day exists in matrix even if 0 files changed
  if ! grep -q "^"SD"\t" "$MAP"; then
    echo -e SD"\tOBSERVED\t0"
  fi
} > "$DAM"

sha256sum "$DAM" > "$DAM.sha256"

# -------------------------
# 4) quick previews
# -------------------------
echo
echo "== PREVIEW: SCAN_DATE_vs_FILE_DATES.tsv (tail) =="
tail -n 10 "$SDF" || true

echo
echo "== PREVIEW: DAY_ACTIVITY_MATRIX.tsv (tail) =="
tail -n 15 "$DAM" || true

echo
echo "OK: matrices created + hashed."
