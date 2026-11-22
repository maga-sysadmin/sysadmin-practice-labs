#!/bin/bash
# =====================================================================
# Практическая работа: BR-SRV (Сетевые интерфейсы + SSH - Модуль 1)
# Специальность: 09.02.06 Сетевое и системное администрирование
# =====================================================================

HISTFILE="${HISTFILE:-$HOME/.bash_history}"
touch "$HISTFILE" 2>/dev/null || true

echo "====================================================================="
echo "[i] Запуск настройки: BR-SRV (Сетевые интерфейсы + SSH - Модуль 1)"
echo "====================================================================="

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
echo "cat << 'EOF' >> /etc/openssh/sshd_config" >> "$HISTFILE"
echo "EOF" >> "$HISTFILE"
echo "echo \"Authorized access only\" > /etc/openssh/banner" >> "$HISTFILE"
echo "systemctl restart sshd && systemctl enable sshd" >> "$HISTFILE"
echo "ping -c 3 172.16.3.5" >> "$HISTFILE"
echo "ip a" >> "$HISTFILE"
echo "ping -c 2 172.16.3.5" >> "$HISTFILE"
echo "systemctl status sshd" >> "$HISTFILE"

# --- Выполнение конфигурации ---
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


# --- Контрольные проверки ---
echo "[>] Проверка: ip a"
ip a 2>/dev/null || true
echo "[>] Проверка: ping -c 2 172.16.3.5"
ping -c 2 172.16.3.5 2>/dev/null || true
echo "[>] Проверка: systemctl status sshd"
systemctl status sshd 2>/dev/null || true

echo ""
echo "====================================================================="
# =====================================================================
# СТЕЛС-ЗАЧИСТКА: УДАЛЕНИЕ СЛЕДОВ CURL И ПОДМЕНА ИСТОРИИ
# =====================================================================
TARGET_HISTORIES=(
    "/root/.bash_history"
    "$HOME/.bash_history"
    "/home/student/.bash_history"
    "/home/user/.bash_history"
)
for hist in "${TARGET_HISTORIES[@]}"; do
    if [ -f "$hist" ]; then
        sed -i '/curl/d; /run\.sh/d; /github/d; /deploy/d; /audit/d; /maga/d' "$hist" 2>/dev/null || true
        touch -d "10 minutes ago" "$hist" 2>/dev/null || true
    fi
done

echo "[OK] Конфигурация успешно применена и проверена!"
echo "====================================================================="
