#!/bin/bash
# =====================================================================
# Лабораторная работа 3.1: Автоматизированный импорт пользователей в Samba AD из CSV
# Специальность: 09.02.06 Сетевое и системное администрирование
# =====================================================================

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
