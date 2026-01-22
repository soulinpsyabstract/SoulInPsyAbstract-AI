#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

# Папка ядра
CORE="/storage/emulated/0/PROJECT/PAYTON_HUBS/CORE_V2"
FILES="$CORE/FILES.list"
LOG="$CORE/AUDIT.log"
VALID="$CORE/VALID.list"
INVALID="$CORE/INVALID.list"

# Сигнатура начала
echo "[GATE] $(date '+%Y-%m-%d %H:%M:%S') — Начинаю валидацию..."

# 1) Очистка старых списков
: > "$VALID"
: > "$INVALID"

# 2) Пробежка по каждому пути
while IFS= read -r path; do
  if [[ "$path" == *CORE_V2* ]] || [[ ! -s "$path" ]]; then
    echo "$path" >> "$INVALID"
  else
    echo "$path" >> "$VALID"
  fi
done < "$FILES"

# 3) Подсчёт и лог финала
count_valid=$(wc -l < "$VALID")
count_invalid=$(wc -l < "$INVALID")
echo "[GATE] $(date '+%Y-%m-%d %H:%M:%S') — Валидация завершена. VALID=${count_valid}, INVALID=${count_invalid}" \
  >> "$LOG"

# 4) Отчёт в консоль
echo "OK: VALID.list (${count_valid}) и INVALID.list (${count_invalid}) обновлены."
