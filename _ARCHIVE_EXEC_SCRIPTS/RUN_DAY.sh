#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

BASE="/storage/emulated/0/PROJECT/SAFE_V3"

echo "=== SIPA DAY RUN START ==="
date

# 1) DAY BOOT (always)
"$BASE/day_boot_v2.sh"

# 2) DAY SCAN + CLEAN (optional but recommended)
"$BASE/day_scan_clean_v2.sh"

# 3) DAY CLOSE (optional: comment out if not closing yet)
"$BASE/day_close_v2.sh"

echo "=== SIPA DAY RUN END ==="
