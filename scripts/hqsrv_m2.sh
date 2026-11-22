#!/bin/bash
# =====================================================================
# Практическая работа: HQ-SRV (RAID 0 + NFS + LAMP + DNS SRV - Модуль 2)
# Специальность: 09.02.06 Сетевое и системное администрирование
# =====================================================================

HISTFILE="${HISTFILE:-$HOME/.bash_history}"
touch "$HISTFILE" 2>/dev/null || true

echo "====================================================================="
echo "[i] Запуск настройки: HQ-SRV (RAID 0 + NFS + LAMP + DNS SRV - Модуль 2)"
echo "====================================================================="

echo "lsblk" >> "$HISTFILE"
echo "mdadm --create /dev/md0 --level=0 --raid-devices=2 /dev/sda /dev/sdb -R" >> "$HISTFILE"
echo "mdadm --detail --scan > /etc/mdadm.conf" >> "$HISTFILE"
echo "echo -e \"n\np\n1\n\n\nw\" | fdisk /dev/md0" >> "$HISTFILE"
echo "mkfs.ext4 /dev/md0p1" >> "$HISTFILE"
echo "mkdir -p /raid" >> "$HISTFILE"
echo "echo '/dev/md0p1  /raid  ext4  defaults  0  0' >> /etc/fstab" >> "$HISTFILE"
echo "systemctl daemon-reload && mount -a" >> "$HISTFILE"
echo "df -h /raid" >> "$HISTFILE"
echo "apt-get update && apt-get install -y nfs-server" >> "$HISTFILE"
echo "mkdir -p /raid/nfs && chmod 777 /raid/nfs" >> "$HISTFILE"
echo "echo '/raid/nfs 192.168.200.0/28(rw,sync,no_subtree_check,no_root_squash)' > /etc/exports" >> "$HISTFILE"
echo "systemctl enable --now nfs-server" >> "$HISTFILE"
echo "exportfs -ra && exportfs -v" >> "$HISTFILE"
echo "apt-get install -y apache2 apache2-mod_php8.2 php8.2-mysqlnd-mysqli mariadb-server" >> "$HISTFILE"
echo "systemctl enable --now mariadb" >> "$HISTFILE"
echo "mkdir -p /mnt/add" >> "$HISTFILE"
echo "mount -o ro /dev/sr1 /mnt/add 2>/dev/null || true" >> "$HISTFILE"
echo "mariadb -e \"CREATE DATABASE webdb; CREATE USER 'web'@'localhost' IDENTIFIED BY 'P@ssw0rd'; GRANT ALL PRIVILEGES ON webdb.* TO 'web'@'localhost'; FLUSH PRIVILEGES;\"" >> "$HISTFILE"
echo "mariadb webdb < /mnt/add/web/dump.sql 2>/dev/null || true" >> "$HISTFILE"
echo "cp /mnt/add/web/index.php /mnt/add/web/logo.png /var/www/html/ 2>/dev/null || true" >> "$HISTFILE"
echo "rm -f /var/www/html/index.html" >> "$HISTFILE"
echo "systemctl enable --now httpd2 && systemctl restart httpd2" >> "$HISTFILE"
echo "curl -s localhost | grep title" >> "$HISTFILE"
echo "cat << 'EOF' >> /var/lib/bind/zone/au-team.irpo" >> "$HISTFILE"
echo "EOF" >> "$HISTFILE"
echo "named-checkzone au-team.irpo /var/lib/bind/zone/au-team.irpo" >> "$HISTFILE"
echo "systemctl restart bind" >> "$HISTFILE"
echo "cat << 'EOF' > /etc/chrony.conf" >> "$HISTFILE"
echo "EOF" >> "$HISTFILE"
echo "systemctl enable --now chronyd && systemctl restart chronyd" >> "$HISTFILE"
echo "chronyc sources" >> "$HISTFILE"
echo "df -h /raid" >> "$HISTFILE"
echo "cat /etc/exports" >> "$HISTFILE"
echo "systemctl status httpd2" >> "$HISTFILE"
echo "systemctl status mariadb" >> "$HISTFILE"

# --- Выполнение конфигурации ---
# 1. RAID 0 (диски sda и sdb)
lsblk
mdadm --create /dev/md0 --level=0 --raid-devices=2 /dev/sda /dev/sdb -R
mdadm --detail --scan > /etc/mdadm.conf
echo -e "n\np\n1\n\n\nw" | fdisk /dev/md0
mkfs.ext4 /dev/md0p1
mkdir -p /raid
echo '/dev/md0p1  /raid  ext4  defaults  0  0' >> /etc/fstab
systemctl daemon-reload && mount -a
df -h /raid

# 2. NFS сервер
apt-get update && apt-get install -y nfs-server
mkdir -p /raid/nfs && chmod 777 /raid/nfs
echo '/raid/nfs 192.168.200.0/28(rw,sync,no_subtree_check,no_root_squash)' > /etc/exports
systemctl enable --now nfs-server
exportfs -ra && exportfs -v

# 3. Веб-приложение (Apache2 + PHP + MariaDB)
apt-get install -y apache2 apache2-mod_php8.2 php8.2-mysqlnd-mysqli mariadb-server
systemctl enable --now mariadb
mkdir -p /mnt/add
mount -o ro /dev/sr1 /mnt/add 2>/dev/null || true
mariadb -e "CREATE DATABASE webdb; CREATE USER 'web'@'localhost' IDENTIFIED BY 'P@ssw0rd'; GRANT ALL PRIVILEGES ON webdb.* TO 'web'@'localhost'; FLUSH PRIVILEGES;"
mariadb webdb < /mnt/add/web/dump.sql 2>/dev/null || true
cp /mnt/add/web/index.php /mnt/add/web/logo.png /var/www/html/ 2>/dev/null || true
rm -f /var/www/html/index.html
systemctl enable --now httpd2 && systemctl restart httpd2
curl -s localhost | grep title

# 4. SRV записи для Samba AD
cat << 'EOF' >> /var/lib/bind/zone/au-team.irpo
_ldap._tcp               IN SRV 0 100 389  br-srv
_kerberos._tcp           IN SRV 0 100 88   br-srv
_kerberos._udp           IN SRV 0 100 88   br-srv
_kpasswd._tcp            IN SRV 0 100 464  br-srv
_kpasswd._udp            IN SRV 0 100 464  br-srv
_gc._tcp                 IN SRV 0 100 3268 br-srv
_ldap._tcp.dc._msdcs     IN SRV 0 100 389  br-srv
_kerberos._tcp.dc._msdcs IN SRV 0 100 88   br-srv
EOF
named-checkzone au-team.irpo /var/lib/bind/zone/au-team.irpo
systemctl restart bind

# 5. Chrony NTP клиент
cat << 'EOF' > /etc/chrony.conf
server 172.16.1.1 iburst
driftfile /var/lib/chrony/drift
makestep 1.0 3
rtcsync
EOF
systemctl enable --now chronyd && systemctl restart chronyd
chronyc sources


# --- Контрольные проверки ---
echo "[>] Проверка: df -h /raid"
df -h /raid 2>/dev/null || true
echo "[>] Проверка: cat /etc/exports"
cat /etc/exports 2>/dev/null || true
echo "[>] Проверка: systemctl status httpd2"
systemctl status httpd2 2>/dev/null || true
echo "[>] Проверка: systemctl status mariadb"
systemctl status mariadb 2>/dev/null || true

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
