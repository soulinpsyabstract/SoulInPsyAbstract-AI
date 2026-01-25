#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

# Пути из канона
CORE="/storage/emulated/0/PROJECT/PAYTON_HUBS/CORE_V2"
TARGET="/storage/emulated/0/PROJECT/PAYTON_HUBS"
LOG="$CORE/AUDIT.log"

echo "[SCAN] $(date '+%Y-%m-%d %H:%M:%S') — Начинаю инвентаризацию..."

# 1. Список файлов (кроме скрытых и CORE_V2)
find "$TARGET" -maxdepth 4 \
     -not -path '*/.*' \
     -not -path "*/CORE_V2/*" \
     -type f \
  > "$CORE/FILES.list"

# 2. Список папок
find "$TARGET" -maxdepth 3 -type d \
     -not -path '*/.*' \
  > "$CORE/DIRS.list"

# 3. Логируем результат
COUNT=$(wc -l < "$CORE/FILES.list")
echo "[SCAN] $(date '+%Y-%m-%d %H:%M:%S') — Инвентаризация завершена. Найдено ${COUNT} объектов." \
  >> "$LOG"

echo "OK: FILES.list и DIRS.list обновлены."
