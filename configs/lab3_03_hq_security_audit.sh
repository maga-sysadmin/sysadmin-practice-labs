#!/bin/bash
# =====================================================================
# Лабораторная работа 3.3: Политики безопасности, аудит, резервное копирование и WireGuard
# Специальность: 09.02.06 Сетевое и системное администрирование
# =====================================================================

# 1. Atop (интервал 420 сек)
apt-get update && apt-get install -y atop
echo 'LOGINTERVAL=420' > /etc/default/atop
systemctl enable --now atop && systemctl restart atop

# 2. Cups-PDF принт-сервер
apt-get install -y cups cups-pdf
systemctl enable --now cups
cupsctl --remote-any --share-printers
lpadmin -p Cups-PDF -o printer-is-shared=true
lpadmin -d Cups-PDF
systemctl restart cups

# 3. Fail2ban для SSH
apt-get install -y fail2ban python3-module-systemd iptables
cat << 'EOF' > /etc/fail2ban/jail.d/sshd.local
[sshd]
enabled = true
port = 2027
filter = sshd
logpath = /var/log/messages
backend = systemd
maxretry = 3
findtime = 600
bantime = 3600
EOF
systemctl enable --now fail2ban && systemctl restart fail2ban
fail2ban-client status sshd

# 4. Резервное копирование Bacula /etc
echo "run job=hq-srv-etc yes" | bconsole 2>/dev/null || true
echo "list jobs" | bconsole 2>/dev/null || true
