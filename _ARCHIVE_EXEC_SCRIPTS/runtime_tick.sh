#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

TZ="Asia/Jerusalem"
PROJECT="/storage/emulated/0/PROJECT"

CANON="$PROJECT/SAFE_V3/SoulInPsyAbstract_AI_OS/V3"
WORKSPACE="$PROJECT/SAFE_V3/WORKSPACE_GRANTS"
PAYTON="$PROJECT/PAYTON_HUBS/HUB_LEGAL_FORENSIC"
CURRENT="$PROJECT/RUNTIME_V3/CURRENT"
HASHDIR="$CURRENT/HASH"

STATE="$CURRENT/STATE.txt"
HEADSHOT="$CURRENT/HEADSHOT.txt"
LOG="$CURRENT/LOG.log"
TIMELINE="$CURRENT/TIMELINE.log"
INDEX="$CURRENT/INDEX.tsv"

mkdir -p "$HASHDIR"

NOW_DAY="$(date +%F)"
NOW_TS="$(date +%H-%M-%S)"
NOW="$(date +%F__%H-%M-%S)"

# last tick timestamp (if missing -> epoch)
LAST_EPOCH=0
if [ -f "$STATE" ]; then
  last_line="$(grep -E '^LAST_TICK_EPOCH=' "$STATE" | tail -n 1 || true)"
  if [ -n "${last_line:-}" ]; then
    LAST_EPOCH="${last_line#LAST_TICK_EPOCH=}"
  fi
fi

# detect changes: any file newer than LAST_EPOCH in WORKSPACE or PAYTON (excluding trashy paths)
changed="NO"
if [ "$LAST_EPOCH" -gt 0 ]; then
  if find "$WORKSPACE" "$PAYTON" -type f \
      ! -path "*/TRASH/*" \
      ! -path "*/TO_CLOUD/*" \
      ! -path "*/ARCHIVE_COLD/*" \
      ! -path "*/SPACE_RECOVERY/*" \
      ! -path "*/DEDUP/*" \
      ! -path "*/LOGS/*" \
      ! -path "*/SNAPSHOT/*" \
      ! -path "*/CORE_STACK/*" \
      -newermt "@$LAST_EPOCH" \
      2>/dev/null | head -n 1 | grep -q .; then
    changed="YES"
  fi
else
  # first run = treat as change to initialize INDEX/STATE
  changed="YES"
fi

# append timeline always (single line)
printf "[%s %s %s] tick changed=%s\n" "$NOW_DAY" "$NOW_TS" "$TZ" "$changed" >> "$TIMELINE"

if [ "$changed" = "NO" ]; then
  printf "[%s %s %s] NO CANON EVENTS\n" "$NOW_DAY" "$NOW_TS" "$TZ" >> "$LOG"
else
  # overwrite HEADSHOT (minimal, you can fill later by other script)
  cat > "$HEADSHOT" <<EOT
HEADSHOT · RUNTIME_V3
DATE: $NOW_DAY
TIME: $NOW_TS
TZ: $TZ
Energy: UNKNOWN
Focus: UNKNOWN
Risk: UNKNOWN
One priority: SUBMISSIONS
EOT

  # overwrite INDEX (deterministic inventory)
  printf "path\ttype\tbytes\tmtime_epoch\n" > "$INDEX"

  # include key artifacts from WORKSPACE_GRANTS + PAYTON legal area only
  while IFS= read -r p; do
    [ -f "$p" ] || continue
    b="$(wc -c < "$p" | tr -d ' ')"
    m="$(stat -c '%Y' "$p" 2>/dev/null || echo 0)"
    printf "%s\tfile\t%s\t%s\n" "$p" "$b" "$m" >> "$INDEX"
  done < <(
    find "$WORKSPACE" "$PAYTON" -type f \
      ! -path "*/TRASH/*" \
      ! -path "*/TO_CLOUD/*" \
      ! -path "*/ARCHIVE_COLD/*" \
      ! -path "*/SPACE_RECOVERY/*" \
      ! -path "*/DEDUP/*" \
      ! -path "*/LOGS/*" \
      ! -path "*/SNAPSHOT/*" \
      ! -path "*/CORE_STACK/*" \
      \( -iname "*.txt" -o -iname "*.tsv" -o -iname "*.pdf" -o -iname "*.sha256" -o -iname "*.zip" \) \
      2>/dev/null | sort
  )

  # overwrite STATE
  cat > "$STATE" <<EOT
STATE · RUNTIME_V3 (NON-CANON)
DATE: $NOW_DAY
TIME: $NOW_TS
TZ: $TZ

BOUNDARIES_FIXATION:
$PROJECT/RUNTIME_V3/LEGAL_FIXATION__CANON_RUNTIME_BOUNDARIES__2026-01-14__12-44__Asia-Jerusalem.txt

CANON_ROOT (READ-ONLY):
$CANON

WORKSPACE_ROOT:
$WORKSPACE

PAYTON_LEGAL_ROOT:
$PAYTON

LAST_TICK_EPOCH=$(date +%s)

EXECUTION_CONTEXT=NONE
RUNTIME=GOVERNED
CLAIMS=NONE
EOT

  printf "[%s %s %s] CHANGE DETECTED → STATE/INDEX updated\n" "$NOW_DAY" "$NOW_TS" "$TZ" >> "$LOG"
fi

# hashes (overwrite)
sha256sum "$STATE" > "$HASHDIR/STATE.sha256"
sha256sum "$HEADSHOT" > "$HASHDIR/HEADSHOT.sha256" 2>/dev/null || true
sha256sum "$INDEX" > "$HASHDIR/INDEX.sha256"
