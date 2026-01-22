#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

export TZ="${TZ:-Asia/Jerusalem}"
PROJ="${PROJ:-/storage/emulated/0/PROJECT}"
V3="${V3:-$PROJ/RUNTIME_RW/V3}"
REG="${REG:-$V3/REGISTRY}"
OUT="${OUT:-$PROJ/_FORENSIC_SCANS}"
CAN="${CAN:-$V3/CANON}"

mkdir -p "$REG" "$OUT"

TS="$(date +%F__%H-%M-%S)"
PLAN="$OUT/V3_BULK_REWRITE_PLAN__${TS}.tsv"

# Candidates: all *.zip <= 10GB, exclude SAFE, exclude giant archives, exclude TRASH_CANDIDATES quarantine zip-of-zip patterns
# You can widen/limit folders later, but this gets you "1-10GB first".
printf "group_id\tcanon_target\tcount\tbytes_sum\texample_path\tstemsig\tnotes\n" > "$PLAN"

tmp="$OUT/.tmp_candidates_${TS}.lst"
: > "$tmp"

find "$PROJ" -type f -name "*.zip" 2>/dev/null \
  | grep -v "/SAFE_V3/" \
  | grep -v "/TRASH_CANDIDATES/" \
  | while read -r f; do
      b="$(stat -c %s "$f" 2>/dev/null || echo 0)"
      # exclude >10GB (10*1024^3)
      [ "$b" -gt 10737418240 ] && continue
      echo -e "${b}\t${f}"
    done \
  | sort -nr > "$tmp"

# Build grouping signature:
# - stem: filename without date-ish chunks and extensions
# - date window: derived from first YYYY-MM-DD in name (optional) else mtime day
# - size bucket: rounded MB
# This creates TECH groups to then map to CANON targets.
awk -F'\t' '
function stem(fn,   x){
  x=fn
  gsub(/^.*\//,"",x)
  gsub(/\.(zip|ZIP)$/,"",x)
  gsub(/__[0-9]{4}-[0-9]{2}-[0-9]{2}.*$/,"",x)
  gsub(/_[0-9]{4}-[0-9]{2}-[0-9]{2}.*$/,"",x)
  gsub(/[0-9]{4}-[0-9]{2}-[0-9]{2}/,"",x)
  gsub(/__?[0-9]{2}-[0-9]{2}-[0-9]{2}.*/,"",x)
  gsub(/__?[0-9]{2}-[0-9]{2}.*/,"",x)
  gsub(/_+$/,"",x)
  return toupper(x)
}
{
  b=$1; p=$2
  s=stem(p)
  mb=int(b/1024/1024)
  bucket=int(mb/50)  # 50MB buckets
  sig=s "|" bucket
  cnt[sig]++
  sum[sig]+=b
  if (!(sig in ex)) ex[sig]=p
}
END{
  gid=0
  for (k in cnt){
    gid++
    printf "G%04d\t-\t%d\t%d\t%s\t%s\t%s\n", gid, cnt[k], sum[k], ex[k], k, "SET canon_target (PROTOCOL/GOVERNANCE/FORENSIC/SERVICE/DAY_FLOW or OTHER)"
  }
}' "$tmp" >> "$PLAN"

sha256sum "$PLAN" > "$PLAN.sha256"
echo "OK: PLAN created → $PLAN"
echo "NEXT: edit PLAN and replace canon_target '-' with one of: PROTOCOL GOVERNANCE FORENSIC SERVICE DAY_FLOW OTHER"
