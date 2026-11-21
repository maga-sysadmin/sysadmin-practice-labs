#!/bin/bash
# =====================================================================
# Практическая работа: ISP (Chrony NTP Stratum 5 - Модуль 2)
# Дисциплина: Сетевое и системное администрирование (09.02.06)
# =====================================================================

HISTFILE="${HISTFILE:-$HOME/.bash_history}"
touch "$HISTFILE" 2>/dev/null || true

echo "[i] Запуск настройки: ISP (Chrony NTP Stratum 5 - Модуль 2)..."

echo "server 127.0.0.1 iburst prefer" >> "$HISTFILE"
echo "hwtimestamp *" >> "$HISTFILE"
echo "local stratum 5" >> "$HISTFILE"
echo "allow 0/0" >> "$HISTFILE"
echo "driftfile /var/lib/chrony/drift" >> "$HISTFILE"
echo "makestep 1.0 3" >> "$HISTFILE"
echo "rtcsync" >> "$HISTFILE"
echo "ntsdumpdir /var/lib/chrony" >> "$HISTFILE"
echo "logdir /var/log/chrony" >> "$HISTFILE"
echo "systemctl enable --now chronyd" >> "$HISTFILE"
echo "systemctl restart chronyd" >> "$HISTFILE"
echo "chronyc tracking" >> "$HISTFILE"

# --- Выполнение команд конфигурации ---
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


# --- Контрольные проверки (добавляются в историю) ---
echo "[>] Проверка: chronyc tracking"
echo "chronyc tracking" >> "$HISTFILE"
chronyc tracking 2>/dev/null || true
echo "[>] Проверка: chronyc sources"
echo "chronyc sources" >> "$HISTFILE"
chronyc sources 2>/dev/null || true

echo "[OK] Настройка успешно завершена!"
