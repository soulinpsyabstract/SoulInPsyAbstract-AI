#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

TZ="Asia/Jerusalem"
TZ_TAG="${TZ//\//-}"

BASE="/storage/emulated/0/PROJECT/SAFE_V3"
CORE="$BASE/SIPA_OS__CORE_PROTOCOL_v1.0"
TS="$(date +%F__%H-%M-%S)"

mkdir -p \
  "$CORE/CORE_CANON" \
  "$CORE/LAWS" \
  "$CORE/PATCHES" \
  "$CORE/MODULES" \
  "$CORE/TERMINAL_SCRIPTS" \
  "$CORE/FORENSIC" \
  "$CORE/EXPORT"

# --------------------------------------------------
# CORE README
# --------------------------------------------------
cat <<'EOT' > "$CORE/CORE_CANON/README__SIPA_OS__CORE_PROTOCOL_v1.0.txt"
SIPA_OS__CORE_PROTOCOL_v1.0
SYSTEM: SIPA / Soul In PsyAbstract
MODE: CANON CORE (READ-ONLY)

CORE LAW:
SOURCE_OF_TRUTH = ONE
RETROACTIVE_MUTATION = FORBIDDEN

PACKAGE STRUCTURE:
- CORE_CANON/
- LAWS/
- PATCHES/
- MODULES/
- TERMINAL_SCRIPTS/
- FORENSIC/
- EXPORT/

RULE:
New items are appended via new dated artifacts.
No overwrite of canon files without explicit value-check.
EOT

# --------------------------------------------------
# LAWS (TSV with real tabs)
# --------------------------------------------------
cat <<'EOT' > "$CORE/LAWS/LAWS__REGISTRY__v1.0.tsv"
law_idtitlestatusnotes
LAW_01SOURCE_OF_TRUTH = ONECANONSingle canonical location for truth
LAW_02RETROACTIVE_MUTATION = FORBIDDENCANONNo overwriting past fixations
LAW_03TERMINAL_DECLARATIVE_INPUT_ONLYCANONcat <<'EOF' > file ; never paste declarative text as commands
LAW_04EXECUTION_CONTEXT_DEFAULT_NONECANONEXECUTION_CONTEXT=NONE unless explicitly allowed
LAW_05ZIP_ONLY_FOR_DAY_CLOSECANONDAY_BOOT not zipped; DAY_CLOSE creates zip+sha256+manifest
EOT

# --------------------------------------------------
# PATCHES
# --------------------------------------------------
cat <<'EOT' > "$CORE/PATCHES/PATCHES__REGISTRY__v1.0.tsv"
patch_idtitlestatus
PATCH_01AMBIGUITY_STOPCANON
PATCH_02ONE_SOURCE_OF_TRUTHCANON
PATCH_03FORENSIC_EVIDENCE_REQUIREDCANON
PATCH_04PUBLIC_VS_OPERATOR_SPLITCANON
PATCH_05EXPLICIT_DAY_GUARDPLANNED
EOT

# --------------------------------------------------
# MODULES
# --------------------------------------------------
cat <<'EOT' > "$CORE/MODULES/MODULES__REGISTRY__v1.0.tsv"
module_idtitletypeprimary_script
MOD_01DAY_BOOTDAILYday_boot_v2.sh
MOD_02DAY_SCAN_CLEANDAILY_OPTIONALday_scan_clean_v2.sh
MOD_03DAY_CLOSEDAILYday_close_v2.sh
MOD_04WEEK_SCAN_CLEANWEEKLYweek_scan_clean_v2.sh
MOD_05MEDIA_INGESTPIPELINESTUB
MOD_06MEDIA_CLEANPIPELINESTUB
MOD_07EXPORT_INSTITUTIONALPIPELINESTUB
MOD_08AUDIT_LOGFORENSICAUDIT__LEGAL_FIXATIONS.log
EOT

# --------------------------------------------------
# TERMINAL SCRIPTS LOCATION
# --------------------------------------------------
cat <<'EOT' > "$CORE/TERMINAL_SCRIPTS/LOCATION__v1.0.txt"
Scripts live at:
- /storage/emulated/0/PROJECT/SAFE_V3/day_boot_v2.sh
- /storage/emulated/0/PROJECT/SAFE_V3/day_scan_clean_v2.sh
- /storage/emulated/0/PROJECT/SAFE_V3/day_close_v2.sh
- /storage/emulated/0/PROJECT/SAFE_V3/week_scan_clean_v2.sh

Operator CLI:
- sipa (recommended install into $HOME/bin)
EOT

# --------------------------------------------------
# FORENSIC NOTE (dated)
# --------------------------------------------------
cat <<EOT > "$CORE/FORENSIC/FORENSIC__NOTE__CORE_PROTOCOL__${TS}__${TZ_TAG}.txt"
FORENSIC NOTE · CORE PROTOCOL PACKAGE
DATE: $(date +%F)
TIME: $(date +%H:%M:%S)
TZ: ${TZ}

This folder is a canonical skeleton package.
It is intended to be zipped as a single evidence artifact:
- one ZIP
- one MANIFEST.tsv
- one SHA256

No operational claims beyond file presence.
EOT

# --------------------------------------------------
# MANIFEST (folder content)
# --------------------------------------------------
MAN="$CORE/EXPORT/MANIFEST__SIPA_OS__CORE_PROTOCOL_v1.0__${TS}.tsv"
printf "relpath\tbytes\tsha256\n" > "$MAN"

( cd "$CORE" && find . -type f ! -path "./EXPORT/*" -print0 ) \
| while IFS= read -r -d '' fp; do
    p="${fp#./}"
    b="$(stat --printf='%s' "$CORE/$p")"
    s="$(sha256sum "$CORE/$p" | awk '{print $1}')"
    printf "%s\t%s\t%s\n" "$p" "$b" "$s" >> "$MAN"
  done

sha256sum "$MAN" > "$MAN.sha256"

# --------------------------------------------------
# ZIP + ZIP.SHA256 (single delivery)
# --------------------------------------------------
ZIP="$CORE/EXPORT/SIPA_OS__CORE_PROTOCOL_v1.0__${TS}__${TZ_TAG}.zip"
rm -f "$ZIP" "$ZIP.sha256" 2>/dev/null || true

( cd "$CORE" && zip -r "$ZIP" \
  "CORE_CANON" "LAWS" "PATCHES" "MODULES" "TERMINAL_SCRIPTS" "FORENSIC" \
  >/dev/null )

sha256sum "$ZIP" > "$ZIP.sha256"

echo "OK: CORE BUILT -> $CORE"
echo "OK: ZIP -> $ZIP"
