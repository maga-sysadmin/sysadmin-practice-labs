#!/bin/bash
# =====================================================================
# Лабораторная работа 1.6: Сервер филиала BR-SRV (Сетевые параметры, SSH)
# Специальность: 09.02.06 Сетевое и системное администрирование
# =====================================================================

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
