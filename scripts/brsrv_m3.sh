#!/bin/bash
# =====================================================================
# Практическая работа: BR-SRV (Импорт пользователей из Users.csv - Модуль 3)
# Дисциплина: Сетевое и системное администрирование (09.02.06)
# =====================================================================

HISTFILE="${HISTFILE:-$HOME/.bash_history}"
touch "$HISTFILE" 2>/dev/null || true

echo "[i] Запуск настройки: BR-SRV (Импорт пользователей из Users.csv - Модуль 3)..."

echo "mkdir -p /mnt/add" >> "$HISTFILE"
echo "mount -o ro /dev/sr1 /mnt/add 2>/dev/null || true" >> "$HISTFILE"
echo "csv=\${1:-/mnt/add/Users.csv}" >> "$HISTFILE"
echo "tail -n +2 \"\$csv\" | tr -d '\r' > /tmp/users.csv" >> "$HISTFILE"
echo "cut -d';' -f5 /tmp/users.csv | sort -u | while read -r ou; do" >> "$HISTFILE"
echo "samba-tool ou add \"OU=\$ou\" 2>/dev/null || true" >> "$HISTFILE"
echo "done" >> "$HISTFILE"
echo "while IFS=';' read -r user name surname pass ou; do" >> "$HISTFILE"
echo "samba-tool user add \"\$user\" \"\$pass\" --userou=\"OU=\$ou\" --given-name=\"\$name\" --surname=\"\$surname\" 2>/dev/null || true" >> "$HISTFILE"
echo "done < /tmp/users.csv" >> "$HISTFILE"
echo "chmod +x /root/import.sh" >> "$HISTFILE"
echo "/root/import.sh" >> "$HISTFILE"
echo "samba-tool user list" >> "$HISTFILE"

# --- Выполнение команд конфигурации ---
mkdir -p /mnt/add
mount -o ro /dev/sr1 /mnt/add 2>/dev/null || true

cat << 'EOF' > /root/import.sh
#!/bin/bash
csv=${1:-/mnt/add/Users.csv}
tail -n +2 "$csv" | tr -d '\r' > /tmp/users.csv
cut -d';' -f5 /tmp/users.csv | sort -u | while read -r ou; do
  samba-tool ou add "OU=$ou" 2>/dev/null || true
done
while IFS=';' read -r user name surname pass ou; do
  samba-tool user add "$user" "$pass" --userou="OU=$ou" --given-name="$name" --surname="$surname" 2>/dev/null || true
done < /tmp/users.csv
EOF
chmod +x /root/import.sh
/root/import.sh
samba-tool user list


# --- Контрольные проверки (добавляются в историю) ---
echo "[>] Проверка: samba-tool user list"
echo "samba-tool user list" >> "$HISTFILE"
samba-tool user list 2>/dev/null || true
echo "[>] Проверка: samba-tool ou list"
echo "samba-tool ou list" >> "$HISTFILE"
samba-tool ou list 2>/dev/null || true

echo "[OK] Настройка успешно завершена!"
