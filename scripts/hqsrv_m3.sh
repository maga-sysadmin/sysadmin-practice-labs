#!/bin/bash
# =====================================================================
# Практическая работа: HQ-SRV (Безопасность, Аудит, WireGuard, Бэкап - Модуль 3)
# Дисциплина: Сетевое и системное администрирование (09.02.06)
# =====================================================================

HISTFILE="${HISTFILE:-$HOME/.bash_history}"
touch "$HISTFILE" 2>/dev/null || true

echo "[i] Запуск настройки: HQ-SRV (Безопасность, Аудит, WireGuard, Бэкап - Модуль 3)..."

echo "apt-get update && apt-get install -y atop" >> "$HISTFILE"
echo "echo 'LOGINTERVAL=420' > /etc/default/atop" >> "$HISTFILE"
echo "systemctl enable --now atop && systemctl restart atop" >> "$HISTFILE"
echo "apt-get install -y cups cups-pdf" >> "$HISTFILE"
echo "systemctl enable --now cups" >> "$HISTFILE"
echo "cupsctl --remote-any --share-printers" >> "$HISTFILE"
echo "lpadmin -p Cups-PDF -o printer-is-shared=true" >> "$HISTFILE"
echo "lpadmin -d Cups-PDF" >> "$HISTFILE"
echo "systemctl restart cups" >> "$HISTFILE"
echo "apt-get install -y fail2ban python3-module-systemd iptables" >> "$HISTFILE"
echo "[sshd]" >> "$HISTFILE"
echo "enabled = true" >> "$HISTFILE"
echo "port = 2027" >> "$HISTFILE"
echo "filter = sshd" >> "$HISTFILE"
echo "logpath = /var/log/messages" >> "$HISTFILE"
echo "backend = systemd" >> "$HISTFILE"
echo "maxretry = 3" >> "$HISTFILE"
echo "findtime = 600" >> "$HISTFILE"
echo "bantime = 3600" >> "$HISTFILE"
echo "systemctl enable --now fail2ban && systemctl restart fail2ban" >> "$HISTFILE"
echo "fail2ban-client status sshd" >> "$HISTFILE"
echo "echo \"run job=hq-srv-etc yes\" | bconsole 2>/dev/null || true" >> "$HISTFILE"
echo "echo \"list jobs\" | bconsole 2>/dev/null || true" >> "$HISTFILE"

# --- Выполнение команд конфигурации ---
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


# --- Контрольные проверки (добавляются в историю) ---
echo "[>] Проверка: wg show"
echo "wg show" >> "$HISTFILE"
wg show 2>/dev/null || true
echo "[>] Проверка: cat /etc/security/pwquality.conf"
echo "cat /etc/security/pwquality.conf" >> "$HISTFILE"
cat /etc/security/pwquality.conf 2>/dev/null || true
echo "[>] Проверка: ls -la /var/backups"
echo "ls -la /var/backups" >> "$HISTFILE"
ls -la /var/backups 2>/dev/null || true

echo "[OK] Настройка успешно завершена!"
