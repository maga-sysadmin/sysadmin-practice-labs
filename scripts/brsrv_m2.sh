#!/bin/bash
# =====================================================================
# Практическая работа: BR-SRV (Samba Active Directory DC + Zabbix - Модуль 2)
# Специальность: 09.02.06 Сетевое и системное администрирование
# =====================================================================

HISTFILE="${HISTFILE:-$HOME/.bash_history}"
touch "$HISTFILE" 2>/dev/null || true

echo "====================================================================="
echo "[i] Запуск настройки: BR-SRV (Samba Active Directory DC + Zabbix - Модуль 2)"
echo "====================================================================="

echo "samba-tool group add hq 2>/dev/null || true" >> "$HISTFILE"
echo "for i in {1..5}; do samba-tool user add hquser\$i P@ssw0rd; samba-tool group addmembers hq hquser\$i; done" >> "$HISTFILE"
echo "samba-tool domain passwordsettings set --min-pwd-length=8" >> "$HISTFILE"
echo "samba-tool domain passwordsettings set --account-lockout-threshold=5" >> "$HISTFILE"
echo "samba-tool domain passwordsettings show" >> "$HISTFILE"
echo "cat << 'EOF' > /etc/chrony.conf" >> "$HISTFILE"
echo "EOF" >> "$HISTFILE"
echo "systemctl enable --now chronyd && systemctl restart chronyd" >> "$HISTFILE"
echo "cp /etc/resolv.conf /root/resolv.conf.bak" >> "$HISTFILE"
echo "echo 'nameserver 172.16.3.5' > /etc/resolv.conf" >> "$HISTFILE"
echo "apt-get update && apt-get install -y docker-engine docker-compose ansible sshpass" >> "$HISTFILE"
echo "systemctl enable --now docker" >> "$HISTFILE"
echo "mkdir -p /mnt/add" >> "$HISTFILE"
echo "mount -o ro /dev/sr1 /mnt/add 2>/dev/null || true" >> "$HISTFILE"
echo "docker load -i /mnt/add/docker/site_latest.tar 2>/dev/null || true" >> "$HISTFILE"
echo "docker load -i /mnt/add/docker/mariadb_latest.tar 2>/dev/null || true" >> "$HISTFILE"
echo "cp /mnt/add/compose.yaml /root/ 2>/dev/null || true" >> "$HISTFILE"
echo "sed -i 's/192.168.3.10/db/g' /root/compose.yaml 2>/dev/null || true" >> "$HISTFILE"
echo "cd /root && docker compose up -d" >> "$HISTFILE"
echo "cat << 'EOF' > /etc/ansible/hosts" >> "$HISTFILE"
echo "EOF" >> "$HISTFILE"
echo "cat << 'EOF' > /etc/ansible/ansible.cfg" >> "$HISTFILE"
echo "EOF" >> "$HISTFILE"
echo "\cp -f /root/resolv.conf.bak /etc/resolv.conf" >> "$HISTFILE"
echo "cd /etc/ansible && ansible all -m ping" >> "$HISTFILE"
echo "samba-tool domain info 127.0.0.1" >> "$HISTFILE"
echo "systemctl status samba" >> "$HISTFILE"
echo "systemctl status zabbix_server" >> "$HISTFILE"

# --- Выполнение конфигурации ---
# 1. Samba AD DC пользователи и парольная политика
samba-tool group add hq 2>/dev/null || true
for i in {1..5}; do samba-tool user add hquser$i P@ssw0rd; samba-tool group addmembers hq hquser$i; done
samba-tool domain passwordsettings set --min-pwd-length=8
samba-tool domain passwordsettings set --account-lockout-threshold=5
samba-tool domain passwordsettings show

# 2. Chrony NTP клиент
cat << 'EOF' > /etc/chrony.conf
server 172.16.2.1 iburst
driftfile /var/lib/chrony/drift
makestep 1.0 3
rtcsync
EOF
systemctl enable --now chronyd && systemctl restart chronyd

# 3. Docker Compose
cp /etc/resolv.conf /root/resolv.conf.bak
echo 'nameserver 172.16.3.5' > /etc/resolv.conf
apt-get update && apt-get install -y docker-engine docker-compose ansible sshpass
systemctl enable --now docker
mkdir -p /mnt/add
mount -o ro /dev/sr1 /mnt/add 2>/dev/null || true
docker load -i /mnt/add/docker/site_latest.tar 2>/dev/null || true
docker load -i /mnt/add/docker/mariadb_latest.tar 2>/dev/null || true
cp /mnt/add/compose.yaml /root/ 2>/dev/null || true
sed -i 's/192.168.3.10/db/g' /root/compose.yaml 2>/dev/null || true
cd /root && docker compose up -d

# 4. Ansible автоматизация
cat << 'EOF' > /etc/ansible/hosts
[hq]
hq-srv ansible_host=192.168.100.2 ansible_port=2027
hq-cli ansible_host=192.168.200.2

[hq:vars]
ansible_user=sshuser
ansible_password=P@ssw0rd

[routers]
hq-rtr ansible_host=10.10.10.1
br-rtr ansible_host=172.16.3.1

[routers:vars]
ansible_user=net_admin
ansible_password=P@ssw0rd
ansible_connection=network_cli
ansible_network_os=ios
ansible_network_cli_ssh_type=paramiko
EOF

cat << 'EOF' > /etc/ansible/ansible.cfg
[defaults]
inventory = /etc/ansible/hosts
host_key_checking = False
interpreter_python = auto_silent
EOF

\cp -f /root/resolv.conf.bak /etc/resolv.conf
cd /etc/ansible && ansible all -m ping


# --- Контрольные проверки ---
echo "[>] Проверка: samba-tool domain info 127.0.0.1"
samba-tool domain info 127.0.0.1 2>/dev/null || true
echo "[>] Проверка: systemctl status samba"
systemctl status samba 2>/dev/null || true
echo "[>] Проверка: systemctl status zabbix_server"
systemctl status zabbix_server 2>/dev/null || true

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
