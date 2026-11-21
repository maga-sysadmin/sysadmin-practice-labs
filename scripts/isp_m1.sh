#!/bin/bash
# =====================================================================
# Практическая работа: ISP (Шлюз провайдера - Модуль 1)
# Специальность: 09.02.06 Сетевое и системное администрирование
# =====================================================================

HISTFILE="${HISTFILE:-$HOME/.bash_history}"
touch "$HISTFILE" 2>/dev/null || true

echo "====================================================================="
echo "[i] Запуск настройки: ISP (Шлюз провайдера - Модуль 1)"
echo "====================================================================="

echo "hostnamectl set-hostname isp" >> "$HISTFILE"
echo "timedatectl set-timezone Europe/Moscow" >> "$HISTFILE"
echo "mkdir -p /etc/net/ifaces/ens19" >> "$HISTFILE"
echo "mkdir -p /etc/net/ifaces/ens20" >> "$HISTFILE"
echo "cat << 'EOF' > /etc/net/ifaces/ens18/options" >> "$HISTFILE"
echo "EOF" >> "$HISTFILE"
echo "cat << 'EOF' > /etc/net/ifaces/ens19/options" >> "$HISTFILE"
echo "EOF" >> "$HISTFILE"
echo "cp /etc/net/ifaces/ens19/options /etc/net/ifaces/ens20/options" >> "$HISTFILE"
echo "echo \"172.16.1.1/28\" > /etc/net/ifaces/ens19/ipv4address" >> "$HISTFILE"
echo "echo \"172.16.2.1/28\" > /etc/net/ifaces/ens20/ipv4address" >> "$HISTFILE"
echo "cat << 'EOF' >> /etc/net/sysctl.conf" >> "$HISTFILE"
echo "EOF" >> "$HISTFILE"
echo "sysctl -p /etc/net/sysctl.conf" >> "$HISTFILE"
echo "systemctl restart network" >> "$HISTFILE"
echo "apt-get update && apt-get install -y iptables tzdata" >> "$HISTFILE"
echo "iptables -t nat -A POSTROUTING -s 172.16.1.0/28 -o ens18 -j MASQUERADE" >> "$HISTFILE"
echo "iptables -t nat -A POSTROUTING -s 172.16.2.0/28 -o ens18 -j MASQUERADE" >> "$HISTFILE"
echo "iptables-save > /etc/sysconfig/iptables" >> "$HISTFILE"
echo "systemctl enable --now iptables" >> "$HISTFILE"
echo "ip a" >> "$HISTFILE"
echo "ip a" >> "$HISTFILE"
echo "ping -c 2 172.16.1.2" >> "$HISTFILE"
echo "iptables -t nat -L -v -n" >> "$HISTFILE"

# --- Выполнение конфигурации ---
hostnamectl set-hostname isp
timedatectl set-timezone Europe/Moscow
mkdir -p /etc/net/ifaces/ens19
mkdir -p /etc/net/ifaces/ens20

cat << 'EOF' > /etc/net/ifaces/ens18/options
TYPE=eth
BOOTPROTO=dhcp
DISABLED=no
EOF

cat << 'EOF' > /etc/net/ifaces/ens19/options
TYPE=eth
BOOTPROTO=static
DISABLED=no
EOF

cp /etc/net/ifaces/ens19/options /etc/net/ifaces/ens20/options
echo "172.16.1.1/28" > /etc/net/ifaces/ens19/ipv4address
echo "172.16.2.1/28" > /etc/net/ifaces/ens20/ipv4address

cat << 'EOF' >> /etc/net/sysctl.conf
net.ipv4.ip_forward = 1
EOF

sysctl -p /etc/net/sysctl.conf
systemctl restart network

apt-get update && apt-get install -y iptables tzdata
iptables -t nat -A POSTROUTING -s 172.16.1.0/28 -o ens18 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 172.16.2.0/28 -o ens18 -j MASQUERADE
iptables-save > /etc/sysconfig/iptables
systemctl enable --now iptables
ip a


# --- Контрольные проверки ---
echo "[>] Проверка: ip a"
ip a 2>/dev/null || true
echo "[>] Проверка: ping -c 2 172.16.1.2"
ping -c 2 172.16.1.2 2>/dev/null || true
echo "[>] Проверка: iptables -t nat -L -v -n"
iptables -t nat -L -v -n 2>/dev/null || true

echo ""
echo "====================================================================="
echo "[OK] Конфигурация успешно применена и проверена!"
echo "====================================================================="
