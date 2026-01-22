#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

export TZ="${TZ:-Asia/Jerusalem}"
PROJ="${PROJ:-/storage/emulated/0/PROJECT}"
V3="${V3:-$PROJ/RUNTIME_RW/V3}"
REG="${REG:-$V3/REGISTRY}"
OUT="${OUT:-$PROJ/_FORENSIC_SCANS}"
CAN="${CAN:-$V3/CANON}"

RD="$REG/REWRITE_DECLARATION.tsv"
mkdir -p "$REG" "$CAN" "$V3/RAW_SOURCES" "$V3/TRASH_CANDIDATES"

# Pick latest plan
PLAN="$(ls -t "$OUT/V3_BULK_REWRITE_PLAN__"*.tsv 2>/dev/null | head -n 1)"
[ -f "$PLAN" ] || { echo "[STOP] no PLAN found"; exit 66; }

# Ensure declaration header
if [ ! -f "$RD" ]; then
  printf "ts\tcanon_target\tsource_path\taction\treason\toperator\tsha256\tbytes\tstatus\n" > "$RD"
fi

ts(){ date "+%F %T"; }

# Build group -> stem signature map
# Then re-find matching files by signature (same logic as prep) and execute:
# - append a block header into CANON target file
# - do NOT unzip automatically (zip content remains), but we DO consolidate "metadata about sources" into CANON
# - move source zip into RAW_SOURCES (not delete)
#
# Why: you asked "rezip all zips minimal". First step: CANON gets a single block listing sources.
# Next step (later) you can unzip selectively if needed. No magic extraction now.

while IFS=$'\t' read -r gid target cnt bytes ex sig notes; do
  [ "$gid" = "group_id" ] && continue
  [ "$target" = "-" ] && { echo "[STOP] canon_target not set for $gid"; exit 66; }
  # normalize target
  T="$(echo "$target" | tr '[:lower:]' '[:upper:]')"
  CANON_FILE="$CAN/${T}__CANON.txt"
  [ -f "$CANON_FILE" ] || { echo "[STOP] missing canon file: $CANON_FILE"; exit 66; }

  echo "== APPLY $gid -> $T =="

  # find files belonging to this signature (re-run same stem+buckets)
  tmp="$(mktemp)"
  find "$PROJ" -type f -name "*.zip" 2>/dev/null \
    | grep -v "/SAFE_V3/" \
    | grep -v "/TRASH_CANDIDATES/" \
    | while read -r f; do
        b="$(stat -c %s "$f" 2>/dev/null || echo 0)"
        [ "$b" -gt 10737418240 ] && continue
        mb=$((b/1024/1024))
        bucket=$((mb/50))
        fn="$(basename "$f")"
        base="${fn%.*}"
        s="$base"
        s="$(echo "$s" | sed -E 's/__20[0-9]{2}-[0-9]{2}-[0-9]{2}.*$//; s/_20[0-9]{2}-[0-9]{2}-[0-9]{2}.*$//; s/[0-9]{4}-[0-9]{2}-[0-9]{2}//; s/__?[0-9]{2}-[0-9]{2}-[0-9]{2}.*$//; s/__?[0-9]{2}-[0-9]{2}.*$//; s/_+$//' )"
        s="$(echo "$s" | tr '[:lower:]' '[:upper:]')"
        this="${s}|${bucket}"
        [ "$this" = "$sig" ] && echo "$f"
      done > "$tmp"

  # append one block into CANON listing sources
  {
    echo ""
    echo "----- APPEND BLOCK -----"
    echo "TS: $(ts)"
    echo "GROUP: $gid"
    echo "CANON_TARGET: $T"
    echo "ACTION: BULK_REWRITE_SESSION (source-list only; no unzip; no delete)"
    echo "RULE: SOURCES -> CANON APPEND -> RAW_SOURCES"
    echo "SOURCES:"
    while read -r f; do
      [ -f "$f" ] || continue
      h="$(sha256sum "$f" | awk '{print $1}')"
      b="$(stat -c %s "$f" 2>/dev/null || echo 0)"
      echo "- $h  $b  $f"
    done < "$tmp"
    echo "----- END BLOCK -----"
  } >> "$CANON_FILE"

  sha256sum "$CANON_FILE" > "$CANON_FILE.sha256"

  # move sources into RAW_SOURCES/<target>/<group_id>/
  DSTDIR="$V3/RAW_SOURCES/$T/$gid"
  mkdir -p "$DSTDIR"
  while read -r f; do
    [ -f "$f" ] || continue
    h="$(sha256sum "$f" | awk '{print $1}')"
    b="$(stat -c %s "$f" 2>/dev/null || echo 0)"
    base="$(basename "$f")"
    dst="$DSTDIR/$base"
    if [ -e "$dst" ]; then
      # STOP: avoid duplicate destinations
      echo "[STOP] dst exists: $dst"
      exit 66
    fi
    mv -v "$f" "$dst"
    printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" \
      "$(ts)" "$T" "$dst" "MOVE_TO_RAW_SOURCES" "Grouped by stem+sizebucket; appended source list into CANON" "USER" "$h" "$b" "MOVED" >> "$RD"
  done < "$tmp"

  rm -f "$tmp"
done < "$PLAN"

sha256sum "$RD" > "$RD.sha256"
echo "OK: APPLY complete. RD updated + hashed."
