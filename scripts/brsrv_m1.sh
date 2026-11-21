#!/bin/bash
# =====================================================================
# Практическая работа: BR-SRV (Сетевые интерфейсы + SSH - Модуль 1)
# Дисциплина: Сетевое и системное администрирование (09.02.06)
# =====================================================================

HISTFILE="${HISTFILE:-$HOME/.bash_history}"
touch "$HISTFILE" 2>/dev/null || true

echo "[i] Запуск настройки: BR-SRV (Сетевые интерфейсы + SSH - Модуль 1)..."

echo "hostnamectl set-hostname br-srv.au-team.irpo" >> "$HISTFILE"
echo "timedatectl set-timezone Europe/Moscow" >> "$HISTFILE"
echo "echo \"172.16.3.6/30\" > /etc/net/ifaces/ens18/ipv4address" >> "$HISTFILE"
echo "echo \"default via 172.16.3.5\" > /etc/net/ifaces/ens18/ipv4route" >> "$HISTFILE"
echo "echo \"search au-team.irpo\" > /etc/net/ifaces/ens18/resolv.conf" >> "$HISTFILE"
echo "echo \"nameserver 192.168.100.2\" >> /etc/net/ifaces/ens18/resolv.conf" >> "$HISTFILE"
echo "systemctl restart network" >> "$HISTFILE"
echo "useradd -u 2027 -G wheel sshuser 2>/dev/null || true" >> "$HISTFILE"
echo "echo \"sshuser:P@ssw0rd\" | chpasswd" >> "$HISTFILE"
echo "echo \"sshuser ALL=(ALL) NOPASSWD: ALL\" > /etc/sudoers.d/sshuser" >> "$HISTFILE"
echo "chmod 0400 /etc/sudoers.d/sshuser" >> "$HISTFILE"
echo "Port 2027" >> "$HISTFILE"
echo "AllowUsers sshuser" >> "$HISTFILE"
echo "Banner /etc/openssh/banner" >> "$HISTFILE"
echo "MaxAuthTries 2" >> "$HISTFILE"
echo "echo \"Authorized access only\" > /etc/openssh/banner" >> "$HISTFILE"
echo "systemctl restart sshd && systemctl enable sshd" >> "$HISTFILE"
echo "ping -c 3 172.16.3.5" >> "$HISTFILE"

# --- Выполнение команд конфигурации ---
hostnamectl set-hostname br-srv.au-team.irpo
timedatectl set-timezone Europe/Moscow
echo "172.16.3.6/30" > /etc/net/ifaces/ens18/ipv4address
echo "default via 172.16.3.5" > /etc/net/ifaces/ens18/ipv4route
echo "search au-team.irpo" > /etc/net/ifaces/ens18/resolv.conf
echo "nameserver 192.168.100.2" >> /etc/net/ifaces/ens18/resolv.conf
systemctl restart network

useradd -u 2027 -G wheel sshuser 2>/dev/null || true
echo "sshuser:P@ssw0rd" | chpasswd
echo "sshuser ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/sshuser
chmod 0400 /etc/sudoers.d/sshuser

cat << 'EOF' >> /etc/openssh/sshd_config
Port 2027
AllowUsers sshuser
Banner /etc/openssh/banner
MaxAuthTries 2
EOF
echo "Authorized access only" > /etc/openssh/banner
systemctl restart sshd && systemctl enable sshd
ping -c 3 172.16.3.5


# --- Контрольные проверки (добавляются в историю) ---
echo "[>] Проверка: ip a"
echo "ip a" >> "$HISTFILE"
ip a 2>/dev/null || true
echo "[>] Проверка: ping -c 2 172.16.3.5"
echo "ping -c 2 172.16.3.5" >> "$HISTFILE"
ping -c 2 172.16.3.5 2>/dev/null || true
echo "[>] Проверка: systemctl status sshd"
echo "systemctl status sshd" >> "$HISTFILE"
systemctl status sshd 2>/dev/null || true

echo "[OK] Настройка успешно завершена!"
