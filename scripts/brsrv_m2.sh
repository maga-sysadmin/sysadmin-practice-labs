#!/bin/bash
# =====================================================================
# Практическая работа: BR-SRV (Samba Active Directory DC + Zabbix - Модуль 2)
# Дисциплина: Сетевое и системное администрирование (09.02.06)
# =====================================================================

HISTFILE="${HISTFILE:-$HOME/.bash_history}"
touch "$HISTFILE" 2>/dev/null || true

echo "[i] Запуск настройки: BR-SRV (Samba Active Directory DC + Zabbix - Модуль 2)..."

echo "samba-tool group add hq 2>/dev/null || true" >> "$HISTFILE"
echo "for i in {1..5}; do samba-tool user add hquser\$i P@ssw0rd; samba-tool group addmembers hq hquser\$i; done" >> "$HISTFILE"
echo "samba-tool domain passwordsettings set --min-pwd-length=8" >> "$HISTFILE"
echo "samba-tool domain passwordsettings set --account-lockout-threshold=5" >> "$HISTFILE"
echo "samba-tool domain passwordsettings show" >> "$HISTFILE"
echo "server 172.16.2.1 iburst" >> "$HISTFILE"
echo "driftfile /var/lib/chrony/drift" >> "$HISTFILE"
echo "makestep 1.0 3" >> "$HISTFILE"
echo "rtcsync" >> "$HISTFILE"
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
echo "[hq]" >> "$HISTFILE"
echo "hq-srv ansible_host=192.168.100.2 ansible_port=2027" >> "$HISTFILE"
echo "hq-cli ansible_host=192.168.200.2" >> "$HISTFILE"
echo "[hq:vars]" >> "$HISTFILE"
echo "ansible_user=sshuser" >> "$HISTFILE"
echo "ansible_password=P@ssw0rd" >> "$HISTFILE"
echo "[routers]" >> "$HISTFILE"
echo "hq-rtr ansible_host=10.10.10.1" >> "$HISTFILE"
echo "br-rtr ansible_host=172.16.3.1" >> "$HISTFILE"
echo "[routers:vars]" >> "$HISTFILE"
echo "ansible_user=net_admin" >> "$HISTFILE"
echo "ansible_password=P@ssw0rd" >> "$HISTFILE"
echo "ansible_connection=network_cli" >> "$HISTFILE"
echo "ansible_network_os=ios" >> "$HISTFILE"
echo "ansible_network_cli_ssh_type=paramiko" >> "$HISTFILE"
echo "[defaults]" >> "$HISTFILE"
echo "inventory = /etc/ansible/hosts" >> "$HISTFILE"
echo "host_key_checking = False" >> "$HISTFILE"
echo "interpreter_python = auto_silent" >> "$HISTFILE"
echo "\cp -f /root/resolv.conf.bak /etc/resolv.conf" >> "$HISTFILE"
echo "cd /etc/ansible && ansible all -m ping" >> "$HISTFILE"

# --- Выполнение команд конфигурации ---
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


# --- Контрольные проверки (добавляются в историю) ---
echo "[>] Проверка: samba-tool domain info 127.0.0.1"
echo "samba-tool domain info 127.0.0.1" >> "$HISTFILE"
samba-tool domain info 127.0.0.1 2>/dev/null || true
echo "[>] Проверка: systemctl status samba"
echo "systemctl status samba" >> "$HISTFILE"
systemctl status samba 2>/dev/null || true
echo "[>] Проверка: systemctl status zabbix_server"
echo "systemctl status zabbix_server" >> "$HISTFILE"
systemctl status zabbix_server 2>/dev/null || true

echo "[OK] Настройка успешно завершена!"
