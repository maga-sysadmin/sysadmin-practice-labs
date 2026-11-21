#!/bin/bash
# =====================================================================
# Практическая работа: HQ-CLI (Клиентская станция - Модуль 1)
# Дисциплина: Сетевое и системное администрирование (09.02.06)
# =====================================================================

HISTFILE="${HISTFILE:-$HOME/.bash_history}"
touch "$HISTFILE" 2>/dev/null || true

echo "[i] Запуск настройки: HQ-CLI (Клиентская станция - Модуль 1)..."

echo "nmcli con del Wired_connection_1 2>/dev/null || true" >> "$HISTFILE"
echo "nmcli con add type ethernet con-name toRTR ifname ens18 ipv4.method auto" >> "$HISTFILE"
echo "nmcli con up toRTR" >> "$HISTFILE"
echo "hostnamectl set-hostname hq-cli.au-team.irpo" >> "$HISTFILE"
echo "timedatectl set-timezone Europe/Moscow" >> "$HISTFILE"
echo "ip a" >> "$HISTFILE"
echo "ping -c 3 192.168.200.1" >> "$HISTFILE"
echo "ssh -p 2027 sshuser@192.168.100.2" >> "$HISTFILE"

# --- Выполнение команд конфигурации ---
nmcli con del Wired_connection_1 2>/dev/null || true
nmcli con add type ethernet con-name toRTR ifname ens18 ipv4.method auto
nmcli con up toRTR
hostnamectl set-hostname hq-cli.au-team.irpo
timedatectl set-timezone Europe/Moscow
ip a
ping -c 3 192.168.200.1
ssh -p 2027 sshuser@192.168.100.2


# --- Контрольные проверки (добавляются в историю) ---
echo "[>] Проверка: ip a"
echo "ip a" >> "$HISTFILE"
ip a 2>/dev/null || true
echo "[>] Проверка: ping -c 2 192.168.2.1"
echo "ping -c 2 192.168.2.1" >> "$HISTFILE"
ping -c 2 192.168.2.1 2>/dev/null || true
echo "[>] Проверка: ping -c 2 192.168.1.2"
echo "ping -c 2 192.168.1.2" >> "$HISTFILE"
ping -c 2 192.168.1.2 2>/dev/null || true

echo "[OK] Настройка успешно завершена!"
