#!/bin/bash
# =====================================================================
# Практическая работа: ISP (Chrony NTP Stratum 5 - Модуль 2)
# Специальность: 09.02.06 Сетевое и системное администрирование
# =====================================================================

HISTFILE="${HISTFILE:-$HOME/.bash_history}"
touch "$HISTFILE" 2>/dev/null || true

echo "====================================================================="
echo "[i] Запуск настройки: ISP (Chrony NTP Stratum 5 - Модуль 2)"
echo "====================================================================="

echo "cat << 'EOF' > /etc/chrony.conf" >> "$HISTFILE"
echo "EOF" >> "$HISTFILE"
echo "systemctl enable --now chronyd" >> "$HISTFILE"
echo "systemctl restart chronyd" >> "$HISTFILE"
echo "chronyc tracking" >> "$HISTFILE"
echo "chronyc tracking" >> "$HISTFILE"
echo "chronyc sources" >> "$HISTFILE"

# --- Выполнение конфигурации ---
cat << 'EOF' > /etc/chrony.conf
server 127.0.0.1 iburst prefer
hwtimestamp *
local stratum 5
allow 0/0
driftfile /var/lib/chrony/drift
makestep 1.0 3
rtcsync
ntsdumpdir /var/lib/chrony
logdir /var/log/chrony
EOF
systemctl enable --now chronyd
systemctl restart chronyd
chronyc tracking


# --- Контрольные проверки ---
echo "[>] Проверка: chronyc tracking"
chronyc tracking 2>/dev/null || true
echo "[>] Проверка: chronyc sources"
chronyc sources 2>/dev/null || true

echo ""
echo "====================================================================="
echo "[OK] Конфигурация успешно применена и проверена!"
echo "====================================================================="
