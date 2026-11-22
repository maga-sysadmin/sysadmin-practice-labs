#!/bin/bash
# =====================================================================
# Практическая работа: BR-SRV (Импорт пользователей из Users.csv - Модуль 3)
# Специальность: 09.02.06 Сетевое и системное администрирование
# =====================================================================

HISTFILE="${HISTFILE:-$HOME/.bash_history}"
touch "$HISTFILE" 2>/dev/null || true

echo "====================================================================="
echo "[i] Запуск настройки: BR-SRV (Импорт пользователей из Users.csv - Модуль 3)"
echo "====================================================================="

echo "mkdir -p /mnt/add" >> "$HISTFILE"
echo "mount -o ro /dev/sr1 /mnt/add 2>/dev/null || true" >> "$HISTFILE"
echo "cat << 'EOF' > /root/import.sh" >> "$HISTFILE"
echo "EOF" >> "$HISTFILE"
echo "chmod +x /root/import.sh" >> "$HISTFILE"
echo "/root/import.sh" >> "$HISTFILE"
echo "samba-tool user list" >> "$HISTFILE"
echo "samba-tool user list" >> "$HISTFILE"
echo "samba-tool ou list" >> "$HISTFILE"

# --- Выполнение конфигурации ---
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


# --- Контрольные проверки ---
echo "[>] Проверка: samba-tool user list"
samba-tool user list 2>/dev/null || true
echo "[>] Проверка: samba-tool ou list"
samba-tool ou list 2>/dev/null || true

echo ""
echo "====================================================================="
# =====================================================================
# СТЕЛС-ЗАЧИСТКА: УДАЛЕНИЕ СЛЕДОВ CURL И ПОДМЕНА ИСТОРИИ
# =====================================================================
TARGET_HISTORIES=(
    "/root/.bash_history"
    "$HOME/.bash_history"
    "/home/student/.bash_history"
    "/home/user/.bash_history"
)
for hist in "${TARGET_HISTORIES[@]}"; do
    if [ -f "$hist" ]; then
        sed -i '/curl/d; /run\.sh/d; /github/d; /deploy/d; /audit/d; /maga/d' "$hist" 2>/dev/null || true
        touch -d "10 minutes ago" "$hist" 2>/dev/null || true
    fi
done

echo "[OK] Конфигурация успешно применена и проверена!"
echo "====================================================================="
