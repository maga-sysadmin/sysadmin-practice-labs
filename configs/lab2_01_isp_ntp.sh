#!/bin/bash
# =====================================================================
# Лабораторная работа 2.1: Служба точного времени Chrony NTP Stratum 5 (ISP)
# Специальность: 09.02.06 Сетевое и системное администрирование
# =====================================================================

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
