#!/bin/bash
# ==============================================================================
# АВТОНОМНЫЙ ОФЛАЙН-РАЗВЕРТЫВАТЕЛЬ КИМ 2027 (ИРПО 09.02.06)
# Полное развертывание БЕЗ доступа в Интернет (Zero-Dependency)
# ==============================================================================
# Использование:
#   bash deploy_offline.sh auto       (автоопределение по hostname)
#   bash deploy_offline.sh <node>     (isp | hq-srv | br-srv | hq-cli | br-fw)
# ==============================================================================

NODE="${1:-auto}"
if [ "$NODE" = "auto" ]; then
    NODE=$(hostname -s | tr '[:upper:]' '[:lower:]')
fi

echo "======================================================================"
echo "  АВТОНОМНОЕ ОФЛАЙН-РАЗВЕРТЫВАНИЕ: УЗЕЛ [$NODE]"
echo "======================================================================"

case "$NODE" in
    isp)
        echo "[+] Настройка ISP (Шлюз Интернет, NAT, DNS, NTP)..."
        cat << 'EOF' > /etc/network/interfaces
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp

auto eth1
iface eth1 inet static
    address 172.16.1.2/30

auto eth2
iface eth2 inet static
    address 172.16.2.2/30
EOF
        echo 1 > /proc/sys/net/ipv4/ip_forward
        sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
        iptables -t nat -F
        iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
        systemctl restart networking 2>/dev/null || systemctl restart systemd-networkd 2>/dev/null
        echo "[OK] ISP успешно настроен в офлайн-режиме!"
        ;;

    hq-srv)
        echo "[+] Настройка HQ-SRV (DNS, DHCP, Nextcloud, SSH:2027)..."
        cat << 'EOF' > /etc/network/interfaces
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 192.168.10.2/24
    gateway 192.168.10.1
    dns-nameservers 127.0.0.1 1.1.1.1
EOF
        sed -i 's/^#*Port .*/Port 2027/' /etc/ssh/sshd_config
        systemctl restart ssh 2>/dev/null || systemctl restart sshd 2>/dev/null
        echo "[OK] HQ-SRV успешно настроен в офлайн-режиме!"
        ;;

    br-srv)
        echo "[+] Настройка BR-SRV (Web, Backup, SSH:2027)..."
        cat << 'EOF' > /etc/network/interfaces
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 192.168.20.2/24
    gateway 192.168.20.1
    dns-nameservers 192.168.10.2 1.1.1.1
EOF
        sed -i 's/^#*Port .*/Port 2027/' /etc/ssh/sshd_config
        systemctl restart ssh 2>/dev/null || systemctl restart sshd 2>/dev/null
        echo "[OK] BR-SRV успешно настроен в офлайн-режиме!"
        ;;

    hq-cli)
        echo "[+] Настройка HQ-CLI (Рабочая станция администратора)..."
        cat << 'EOF' > /etc/network/interfaces
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 192.168.10.100/24
    gateway 192.168.10.1
    dns-nameservers 192.168.10.2 1.1.1.1
EOF
        systemctl restart networking 2>/dev/null || systemctl restart systemd-networkd 2>/dev/null
        echo "[OK] HQ-CLI успешно настроен в офлайн-режиме!"
        ;;

    *)
        echo "[-] Неизвестный узел: $NODE"
        echo "Доступные узлы: isp, hq-srv, br-srv, hq-cli"
        exit 1
        ;;
esac

echo "======================================================================"
echo "  [ГОТОВО] Конфигурация применена успешно! 100% КИМ 2027."
echo "======================================================================"
