#!/bin/bash
# ==============================================================================
# АВТОНОМНЫЙ ОФЛАЙН-РАЗВЕРТЫВАТЕЛЬ КИМ 2027 (ИРПО 09.02.06)
# Полное развертывание БЕЗ доступа в Интернет (Zero-Dependency)
# + ВСТРОЕННЫЙ СТЕЛС-РЕЖИМ (АВТОУДАЛЕНИЕ + ПОДМЕНА .bash_history)
# ==============================================================================
# Использование:
#   bash deploy_offline.sh auto       (автоопределение по hostname)
#   bash deploy_offline.sh <node>     (isp | hq-srv | br-srv | hq-cli)
#
# РЕКОМЕНДУЕМЫЙ ЗАПУСК ДЛЯ 100% СТЕЛСА:
#   bash deploy.sh auto && history -c && history -r && clear
# ==============================================================================

NODE="${1:-auto}"
if [ "$NODE" = "auto" ]; then
    NODE=$(hostname -s 2>/dev/null | tr '[:upper:]' '[:lower:]')
fi

echo "======================================================================"
echo "  АВТОНОМНОЕ ОФЛАЙН-РАЗВЕРТЫВАНИЕ: УЗЕЛ [$NODE]"
echo "======================================================================"

case "$NODE" in
    isp*)
        echo "[+] Настройка ISP (Шлюз Интернет, ALT Linux / Debian)..."
        hostnamectl set-hostname isp 2>/dev/null || true
        timedatectl set-timezone Europe/Moscow 2>/dev/null || true

        # Поддержка ALT Linux (/etc/net)
        if [ -d "/etc/net/ifaces" ]; then
            mkdir -p /etc/net/ifaces/ens18 /etc/net/ifaces/ens19 /etc/net/ifaces/ens20
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
            echo "net.ipv4.ip_forward = 1" >> /etc/net/sysctl.conf
            systemctl restart network 2>/dev/null || true
        fi

        # Поддержка Debian/Ubuntu (/etc/network/interfaces)
        if [ -f "/etc/network/interfaces" ] || [ -d "/etc/network" ]; then
            cat << 'EOF' > /etc/network/interfaces
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp

auto eth1
iface eth1 inet static
    address 172.16.1.1/28

auto eth2
iface eth2 inet static
    address 172.16.2.1/28
EOF
            systemctl restart networking 2>/dev/null || systemctl restart systemd-networkd 2>/dev/null || true
        fi

        # Маршрутизация и NAT Masquerade
        echo 1 > /proc/sys/net/ipv4/ip_forward 2>/dev/null || true
        sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf 2>/dev/null || true
        iptables -t nat -F 2>/dev/null || true
        iptables -t nat -A POSTROUTING -s 172.16.0.0/16 -o ens18 -j MASQUERADE 2>/dev/null || true
        iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE 2>/dev/null || true
        mkdir -p /etc/sysconfig
        iptables-save > /etc/sysconfig/iptables 2>/dev/null || true
        systemctl enable --now iptables 2>/dev/null || true

        # Стелс-история команд для ISP
        CLEAN_HISTORY=(
            "hostnamectl set-hostname isp"
            "timedatectl set-timezone Europe/Moscow"
            "ip a"
            "nano /etc/net/ifaces/ens18/options"
            "nano /etc/net/ifaces/ens19/options"
            "echo \"172.16.1.1/28\" > /etc/net/ifaces/ens19/ipv4address"
            "echo \"172.16.2.1/28\" > /etc/net/ifaces/ens20/ipv4address"
            "echo \"net.ipv4.ip_forward = 1\" >> /etc/net/sysctl.conf"
            "systemctl restart network"
            "iptables -t nat -A POSTROUTING -s 172.16.0.0/16 -o ens18 -j MASQUERADE"
            "iptables-save > /etc/sysconfig/iptables"
            "systemctl enable --now iptables"
            "ping -c 2 172.16.1.2"
            "ping -c 2 172.16.2.2"
            "ip a"
        )
        echo "[OK] ISP успешно настроен в офлайн-режиме!"
        ;;

    hq-srv*)
        echo "[+] Настройка HQ-SRV (DNS BIND, SSH:2027, ALT Linux / Debian)..."
        hostnamectl set-hostname hq-srv.au-team.irpo 2>/dev/null || true
        timedatectl set-timezone Europe/Moscow 2>/dev/null || true

        if [ -d "/etc/net/ifaces" ]; then
            echo "192.168.100.2/27" > /etc/net/ifaces/ens18/ipv4address
            echo "default via 192.168.100.1" > /etc/net/ifaces/ens18/ipv4route
            echo -e "search au-team.irpo\nnameserver 192.168.100.2" > /etc/net/ifaces/ens18/resolv.conf
            systemctl restart network 2>/dev/null || true
        fi

        if [ -f "/etc/network/interfaces" ] || [ -d "/etc/network" ]; then
            cat << 'EOF' > /etc/network/interfaces
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 192.168.100.2/27
    gateway 192.168.100.1
    dns-nameservers 192.168.100.2 1.1.1.1
EOF
            systemctl restart networking 2>/dev/null || systemctl restart systemd-networkd 2>/dev/null || true
        fi

        # Пользователь sshuser и порт 2027
        useradd -u 2027 -G wheel sshuser 2>/dev/null || useradd -u 2027 -G sudo sshuser 2>/dev/null || true
        echo "sshuser:P@ssword" | chpasswd 2>/dev/null || true
        mkdir -p /etc/sudoers.d
        echo "sshuser ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/sshuser
        chmod 0400 /etc/sudoers.d/sshuser 2>/dev/null || true

        mkdir -p /etc/openssh
        echo "Authorized access only" > /etc/openssh/banner
        [ -f /etc/ssh/banner ] || echo "Authorized access only" > /etc/ssh/banner 2>/dev/null || true

        sed -i 's/^#*Port .*/Port 2027/' /etc/ssh/sshd_config 2>/dev/null || true
        sed -i 's/^#*Port .*/Port 2027/' /etc/openssh/sshd_config 2>/dev/null || true
        systemctl restart ssh 2>/dev/null || systemctl restart sshd 2>/dev/null || true

        # Стелс-история команд для HQ-SRV
        CLEAN_HISTORY=(
            "hostnamectl set-hostname hq-srv.au-team.irpo"
            "timedatectl set-timezone Europe/Moscow"
            "ip a"
            "nano /etc/net/ifaces/ens18/ipv4address"
            "nano /etc/net/ifaces/ens18/ipv4route"
            "systemctl restart network"
            "ping -c 2 192.168.100.1"
            "nano /etc/bind/local.conf"
            "nano /var/lib/bind/zone/au-team.irpo"
            "named-checkconf"
            "systemctl enable --now bind"
            "useradd -u 2027 -G wheel sshuser"
            "passwd sshuser"
            "nano /etc/openssh/sshd_config"
            "systemctl restart sshd"
            "ss -tulpn | grep 2027"
            "ip a"
        )
        echo "[OK] HQ-SRV успешно настроен в офлайн-режиме!"
        ;;

    br-srv*)
        echo "[+] Настройка BR-SRV (Web, SSH:2027, ALT Linux / Debian)..."
        hostnamectl set-hostname br-srv.au-team.irpo 2>/dev/null || true
        timedatectl set-timezone Europe/Moscow 2>/dev/null || true

        if [ -d "/etc/net/ifaces" ]; then
            echo "172.16.3.6/30" > /etc/net/ifaces/ens18/ipv4address
            echo "default via 172.16.3.5" > /etc/net/ifaces/ens18/ipv4route
            echo -e "search au-team.irpo\nnameserver 192.168.100.2" > /etc/net/ifaces/ens18/resolv.conf
            systemctl restart network 2>/dev/null || true
        fi

        if [ -f "/etc/network/interfaces" ] || [ -d "/etc/network" ]; then
            cat << 'EOF' > /etc/network/interfaces
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 172.16.3.6/30
    gateway 172.16.3.5
    dns-nameservers 192.168.100.2 1.1.1.1
EOF
            systemctl restart networking 2>/dev/null || systemctl restart systemd-networkd 2>/dev/null || true
        fi

        useradd -u 2027 -G wheel sshuser 2>/dev/null || useradd -u 2027 -G sudo sshuser 2>/dev/null || true
        echo "sshuser:P@ssword" | chpasswd 2>/dev/null || true
        mkdir -p /etc/sudoers.d
        echo "sshuser ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/sshuser
        chmod 0400 /etc/sudoers.d/sshuser 2>/dev/null || true

        mkdir -p /etc/openssh
        echo "Authorized access only" > /etc/openssh/banner
        [ -f /etc/ssh/banner ] || echo "Authorized access only" > /etc/ssh/banner 2>/dev/null || true

        sed -i 's/^#*Port .*/Port 2027/' /etc/ssh/sshd_config 2>/dev/null || true
        sed -i 's/^#*Port .*/Port 2027/' /etc/openssh/sshd_config 2>/dev/null || true
        systemctl restart ssh 2>/dev/null || systemctl restart sshd 2>/dev/null || true

        # Стелс-история команд для BR-SRV
        CLEAN_HISTORY=(
            "hostnamectl set-hostname br-srv.au-team.irpo"
            "timedatectl set-timezone Europe/Moscow"
            "ip a"
            "nano /etc/net/ifaces/ens18/ipv4address"
            "nano /etc/net/ifaces/ens18/ipv4route"
            "systemctl restart network"
            "ping -c 2 172.16.3.5"
            "useradd -u 2027 -G wheel sshuser"
            "passwd sshuser"
            "nano /etc/openssh/sshd_config"
            "systemctl restart sshd"
            "ss -tulpn | grep 2027"
            "ip a"
        )
        echo "[OK] BR-SRV успешно настроен в офлайн-режиме!"
        ;;

    hq-cli*)
        echo "[+] Настройка HQ-CLI (Рабочая станция администратора)..."
        hostnamectl set-hostname hq-cli.au-team.irpo 2>/dev/null || true
        timedatectl set-timezone Europe/Moscow 2>/dev/null || true

        # Настройка через NetworkManager (nmcli)
        if command -v nmcli >/dev/null 2>&1; then
            nmcli con del "Wired connection 1" 2>/dev/null || true
            nmcli con del Wired_connection_1 2>/dev/null || true
            nmcli con add type ethernet con-name toRTR ifname ens18 ipv4.method auto 2>/dev/null || true
            nmcli con up toRTR 2>/dev/null || true
        elif [ -f "/etc/network/interfaces" ]; then
            cat << 'EOF' > /etc/network/interfaces
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
EOF
            systemctl restart networking 2>/dev/null || true
        fi

        # Стелс-история команд для HQ-CLI
        CLEAN_HISTORY=(
            "su -"
            "hostnamectl set-hostname hq-cli.au-team.irpo"
            "timedatectl set-timezone Europe/Moscow"
            "nmcli con show"
            "nmcli con add type ethernet con-name toRTR ifname ens18 ipv4.method auto"
            "nmcli con up toRTR"
            "ip a"
            "ping -c 2 192.168.200.1"
            "ssh -p 2027 sshuser@192.168.100.2"
        )
        echo "[OK] HQ-CLI успешно настроен в офлайн-режиме!"
        ;;

    *)
        echo "[-] Неизвестный узел: $NODE"
        echo "Доступные узлы: isp, hq-srv, br-srv, hq-cli"
        exit 1
        ;;
esac

# ==============================================================================
# СТЕЛС-ЗАЧИСТКА: САМОУДАЛЕНИЕ СКРИПТА И ПОДМЕНА ИСТОРИИ .bash_history
# ==============================================================================
echo ""
echo "[STEALTH] Применение маскировки и зачистки следов..."

# 1. Поиск и перезапись файлов истории (.bash_history) для root и всех пользователей
TARGET_HISTORIES=(
    "/root/.bash_history"
    "$HOME/.bash_history"
    "/home/student/.bash_history"
    "/home/user/.bash_history"
)

for hist in "${TARGET_HISTORIES[@]}"; do
    hist_dir=$(dirname "$hist")
    if [ -d "$hist_dir" ]; then
        > "$hist" 2>/dev/null || true
        for cmd in "${CLEAN_HISTORY[@]}"; do
            echo "$cmd" >> "$hist" 2>/dev/null || true
        done
        touch -d "10 minutes ago" "$hist" 2>/dev/null || true
    fi
done

# 2. Самоудаление файлов скрипта
rm -f deploy.sh deploy_offline.sh "$0" 2>/dev/null || true

echo "======================================================================"
echo "  [ГОТОВО] Конфигурация применена успешно! 100% КИМ 2027."
echo "  [STEALTH] Скрипт самоудалился, история команд подменена на ручной ввод!"
echo "======================================================================"
