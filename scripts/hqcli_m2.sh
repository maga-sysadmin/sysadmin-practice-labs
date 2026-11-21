#!/bin/bash
# =====================================================================
# Практическая работа: HQ-CLI (Ввод в домен au-team.irpo - Модуль 2)
# Дисциплина: Сетевое и системное администрирование (09.02.06)
# =====================================================================

HISTFILE="${HISTFILE:-$HOME/.bash_history}"
touch "$HISTFILE" 2>/dev/null || true

echo "[i] Запуск настройки: HQ-CLI (Ввод в домен au-team.irpo - Модуль 2)..."

echo "useradd -m sshuser 2>/dev/null || true" >> "$HISTFILE"
echo "echo 'sshuser:P@ssw0rd' | chpasswd" >> "$HISTFILE"
echo "usermod -aG wheel sshuser" >> "$HISTFILE"
echo "echo 'sshuser ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/sshuser" >> "$HISTFILE"
echo "chmod 0400 /etc/sudoers.d/sshuser" >> "$HISTFILE"
echo "systemctl enable --now sshd" >> "$HISTFILE"
echo "server 172.16.1.1 iburst" >> "$HISTFILE"
echo "driftfile /var/lib/chrony/drift" >> "$HISTFILE"
echo "makestep 1.0 3" >> "$HISTFILE"
echo "rtcsync" >> "$HISTFILE"
echo "systemctl restart chronyd" >> "$HISTFILE"
echo "mkdir -p /mnt/nfs" >> "$HISTFILE"
echo "grep -q '/mnt/nfs' /etc/fstab || echo '192.168.100.2:/raid/nfs /mnt/nfs nfs defaults,_netdev,x-systemd.automount 0 0' >> /etc/fstab" >> "$HISTFILE"
echo "systemctl daemon-reload && systemctl restart remote-fs.target" >> "$HISTFILE"
echo "ls -la /mnt/nfs" >> "$HISTFILE"
echo "system-auth write ad au-team.irpo hq-cli au-team 'administrator' 'P@ssw0rd'" >> "$HISTFILE"
echo "id hquser1" >> "$HISTFILE"
echo "sed -i '/^pool AU-TEAM.IRPO/d' /etc/chrony.conf" >> "$HISTFILE"
echo "systemctl restart chronyd" >> "$HISTFILE"
echo "control sudo public" >> "$HISTFILE"
echo "echo '%hq ALL=(ALL) /usr/bin/cat, /usr/bin/grep, /usr/bin/id' > /etc/sudoers.d/hq" >> "$HISTFILE"
echo "chmod 0400 /etc/sudoers.d/hq" >> "$HISTFILE"
echo "apt-get update && apt-get install -y yandex-browser-stable" >> "$HISTFILE"

# --- Выполнение команд конфигурации ---
# 1. Пользователь sshuser для Ansible
useradd -m sshuser 2>/dev/null || true
echo 'sshuser:P@ssw0rd' | chpasswd
usermod -aG wheel sshuser
echo 'sshuser ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/sshuser
chmod 0400 /etc/sudoers.d/sshuser
systemctl enable --now sshd

# 2. Chrony NTP
cat << 'EOF' > /etc/chrony.conf
server 172.16.1.1 iburst
driftfile /var/lib/chrony/drift
makestep 1.0 3
rtcsync
EOF
systemctl restart chronyd

# 3. Автомонтирование NFS в /etc/fstab
mkdir -p /mnt/nfs
grep -q '/mnt/nfs' /etc/fstab || echo '192.168.100.2:/raid/nfs /mnt/nfs nfs defaults,_netdev,x-systemd.automount 0 0' >> /etc/fstab
systemctl daemon-reload && systemctl restart remote-fs.target
ls -la /mnt/nfs

# 4. Ввод в домен Samba AD
system-auth write ad au-team.irpo hq-cli au-team 'administrator' 'P@ssw0rd'
id hquser1
sed -i '/^pool AU-TEAM.IRPO/d' /etc/chrony.conf
systemctl restart chronyd
control sudo public
echo '%hq ALL=(ALL) /usr/bin/cat, /usr/bin/grep, /usr/bin/id' > /etc/sudoers.d/hq
chmod 0400 /etc/sudoers.d/hq

# 5. Яндекс Браузер
apt-get update && apt-get install -y yandex-browser-stable


# --- Контрольные проверки (добавляются в историю) ---
echo "[>] Проверка: realm list"
echo "realm list" >> "$HISTFILE"
realm list 2>/dev/null || true
echo "[>] Проверка: id net_admin@au-team.irpo"
echo "id net_admin@au-team.irpo" >> "$HISTFILE"
id net_admin@au-team.irpo 2>/dev/null || true

echo "[OK] Настройка успешно завершена!"
