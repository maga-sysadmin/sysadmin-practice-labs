#!/bin/bash
# =====================================================================
# Лабораторная работа 1.1: Настройка шлюза провайдера ISP (ALT Linux)
# Специальность: 09.02.06 Сетевое и системное администрирование
# =====================================================================

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
