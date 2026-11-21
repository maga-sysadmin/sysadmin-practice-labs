#!/bin/bash
# =====================================================================
# Лабораторная работа 2.5: Ввод клиентской станции в домен au-team.irpo
# Специальность: 09.02.06 Сетевое и системное администрирование
# =====================================================================

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
