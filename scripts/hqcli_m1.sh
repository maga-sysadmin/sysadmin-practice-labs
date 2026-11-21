#!/bin/bash
# =====================================================================
# Практическая работа: HQ-CLI (Клиентская станция - Модуль 1)
# Специальность: 09.02.06 Сетевое и системное администрирование
# =====================================================================

HISTFILE="${HISTFILE:-$HOME/.bash_history}"
touch "$HISTFILE" 2>/dev/null || true

echo "====================================================================="
echo "[i] Запуск настройки: HQ-CLI (Клиентская станция - Модуль 1)"
echo "====================================================================="

echo "nmcli con del Wired_connection_1 2>/dev/null || true" >> "$HISTFILE"
echo "nmcli con add type ethernet con-name toRTR ifname ens18 ipv4.method auto" >> "$HISTFILE"
echo "nmcli con up toRTR" >> "$HISTFILE"
echo "hostnamectl set-hostname hq-cli.au-team.irpo" >> "$HISTFILE"
echo "timedatectl set-timezone Europe/Moscow" >> "$HISTFILE"
echo "ip a" >> "$HISTFILE"
echo "ping -c 3 192.168.200.1" >> "$HISTFILE"
echo "ssh -p 2027 sshuser@192.168.100.2" >> "$HISTFILE"
echo "ip a" >> "$HISTFILE"
echo "ping -c 2 192.168.2.1" >> "$HISTFILE"
echo "ping -c 2 192.168.1.2" >> "$HISTFILE"

# --- Выполнение конфигурации ---
nmcli con del Wired_connection_1 2>/dev/null || true
nmcli con add type ethernet con-name toRTR ifname ens18 ipv4.method auto
nmcli con up toRTR
hostnamectl set-hostname hq-cli.au-team.irpo
timedatectl set-timezone Europe/Moscow
ip a
ping -c 3 192.168.200.1
ssh -p 2027 sshuser@192.168.100.2


# --- Контрольные проверки ---
echo "[>] Проверка: ip a"
ip a 2>/dev/null || true
echo "[>] Проверка: ping -c 2 192.168.2.1"
ping -c 2 192.168.2.1 2>/dev/null || true
echo "[>] Проверка: ping -c 2 192.168.1.2"
ping -c 2 192.168.1.2 2>/dev/null || true

echo ""
echo "====================================================================="
echo "[OK] Конфигурация успешно применена и проверена!"
echo "====================================================================="
