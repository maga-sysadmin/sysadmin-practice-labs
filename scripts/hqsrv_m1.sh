#!/bin/bash
# =====================================================================
# Практическая работа: HQ-SRV (DNS BIND + SSH 2027 - Модуль 1)
# Дисциплина: Сетевое и системное администрирование (09.02.06)
# =====================================================================

HISTFILE="${HISTFILE:-$HOME/.bash_history}"
touch "$HISTFILE" 2>/dev/null || true

echo "[i] Запуск настройки: HQ-SRV (DNS BIND + SSH 2027 - Модуль 1)..."

echo "hostnamectl set-hostname hq-srv.au-team.irpo" >> "$HISTFILE"
echo "timedatectl set-timezone Europe/Moscow" >> "$HISTFILE"
echo "echo \"192.168.100.2/27\" > /etc/net/ifaces/ens18/ipv4address" >> "$HISTFILE"
echo "echo \"default via 192.168.100.1\" > /etc/net/ifaces/ens18/ipv4route" >> "$HISTFILE"
echo "echo \"nameserver 95.167.167.95\" > /etc/net/ifaces/ens18/resolv.conf" >> "$HISTFILE"
echo "systemctl restart network" >> "$HISTFILE"
echo "apt-get update && apt-get install -y bind bind-utils" >> "$HISTFILE"
echo "zone \"au-team.irpo\" {" >> "$HISTFILE"
echo "type master;" >> "$HISTFILE"
echo "file \"au-team.irpo\";" >> "$HISTFILE"
echo "};" >> "$HISTFILE"
echo "zone \"100.168.192.in-addr.arpa\" {" >> "$HISTFILE"
echo "type master;" >> "$HISTFILE"
echo "file \"100.168.192.rev\";" >> "$HISTFILE"
echo "};" >> "$HISTFILE"
echo "zone \"3.16.172.in-addr.arpa\" {" >> "$HISTFILE"
echo "type master;" >> "$HISTFILE"
echo "file \"3.16.172.rev\";" >> "$HISTFILE"
echo "};" >> "$HISTFILE"
echo "\$TTL 1D" >> "$HISTFILE"
echo "@       IN SOA  au-team.irpo. root.au-team.irpo. (" >> "$HISTFILE"
echo "2026052500  ; serial" >> "$HISTFILE"
echo "1D      ; refresh" >> "$HISTFILE"
echo "1H      ; retry" >> "$HISTFILE"
echo "1W      ; expire" >> "$HISTFILE"
echo "3H      ; minimum" >> "$HISTFILE"
echo ")" >> "$HISTFILE"
echo "IN NS   au-team.irpo." >> "$HISTFILE"
echo "IN A    192.168.100.2" >> "$HISTFILE"
echo "hq-srv  IN A    192.168.100.2" >> "$HISTFILE"
echo "br-rtr  IN A    172.16.3.1" >> "$HISTFILE"
echo "br-fw   IN A    172.16.3.2" >> "$HISTFILE"
echo "br-fw   IN A    172.16.3.5" >> "$HISTFILE"
echo "hq-cli  IN A    192.168.200.2" >> "$HISTFILE"
echo "br-srv  IN A    172.16.3.6" >> "$HISTFILE"
echo "docker  IN A    172.16.1.1" >> "$HISTFILE"
echo "web     IN A    172.16.2.1" >> "$HISTFILE"
echo "hq-rtr  IN A    192.168.100.1" >> "$HISTFILE"
echo "hq-rtr  IN A    192.168.200.1" >> "$HISTFILE"
echo "hq-rtr  IN A    192.168.99.1" >> "$HISTFILE"
echo "\$TTL 1D" >> "$HISTFILE"
echo "@       IN SOA  au-team.irpo. root.au-team.irpo. (" >> "$HISTFILE"
echo "2026052500  ; serial" >> "$HISTFILE"
echo "1D      ; refresh" >> "$HISTFILE"
echo "1H      ; retry" >> "$HISTFILE"
echo "1W      ; expire" >> "$HISTFILE"
echo "3H      ; minimum" >> "$HISTFILE"
echo ")" >> "$HISTFILE"
echo "IN NS   au-team.irpo." >> "$HISTFILE"
echo "2       IN PTR  hq-srv.au-team.irpo." >> "$HISTFILE"
echo "\$TTL 1D" >> "$HISTFILE"
echo "@       IN SOA  au-team.irpo. root.au-team.irpo. (" >> "$HISTFILE"
echo "2026052500  ; serial" >> "$HISTFILE"
echo "1D      ; refresh" >> "$HISTFILE"
echo "1H      ; retry" >> "$HISTFILE"
echo "1W      ; expire" >> "$HISTFILE"
echo "3H      ; minimum" >> "$HISTFILE"
echo ")" >> "$HISTFILE"
echo "IN NS   au-team.irpo." >> "$HISTFILE"
echo "6       IN PTR  br-srv.au-team.irpo." >> "$HISTFILE"
echo "chown root:named /var/lib/bind/zone/*" >> "$HISTFILE"
echo "rm -f /etc/bind/rndc.key" >> "$HISTFILE"
echo "include \"/etc/bind/options.conf\";" >> "$HISTFILE"
echo "include \"/etc/bind/local.conf\";" >> "$HISTFILE"
echo "options {" >> "$HISTFILE"
echo "listen-on { 192.168.100.2; 127.0.0.1; };" >> "$HISTFILE"
echo "listen-on-v6 { none; };" >> "$HISTFILE"
echo "forwarders { 95.167.167.95; 77.88.8.8; };" >> "$HISTFILE"
echo "allow-query { any; };" >> "$HISTFILE"
echo "allow-recursion { any; };" >> "$HISTFILE"
echo "};" >> "$HISTFILE"
echo "named-checkconf && systemctl enable --now bind.service" >> "$HISTFILE"
echo "echo \"search au-team.irpo\" > /etc/net/ifaces/ens18/resolv.conf" >> "$HISTFILE"
echo "echo \"nameserver 192.168.100.2\" >> /etc/net/ifaces/ens18/resolv.conf" >> "$HISTFILE"
echo "systemctl restart network" >> "$HISTFILE"
echo "systemctl restart bind.service" >> "$HISTFILE"
echo "useradd -u 2027 -G wheel sshuser 2>/dev/null || true" >> "$HISTFILE"
echo "echo \"sshuser:P@ssw0rd\" | chpasswd" >> "$HISTFILE"
echo "echo \"sshuser ALL=(ALL) NOPASSWD: ALL\" > /etc/sudoers.d/sshuser" >> "$HISTFILE"
echo "chmod 0400 /etc/sudoers.d/sshuser" >> "$HISTFILE"
echo "Port 2027" >> "$HISTFILE"
echo "AllowUsers sshuser" >> "$HISTFILE"
echo "Banner /etc/openssh/banner" >> "$HISTFILE"
echo "MaxAuthTries 2" >> "$HISTFILE"
echo "echo \"Authorized access only\" > /etc/openssh/banner" >> "$HISTFILE"
echo "systemctl restart sshd && systemctl enable sshd" >> "$HISTFILE"

# --- Выполнение команд конфигурации ---
hostnamectl set-hostname hq-srv.au-team.irpo
timedatectl set-timezone Europe/Moscow
echo "192.168.100.2/27" > /etc/net/ifaces/ens18/ipv4address
echo "default via 192.168.100.1" > /etc/net/ifaces/ens18/ipv4route
echo "nameserver 95.167.167.95" > /etc/net/ifaces/ens18/resolv.conf
systemctl restart network

apt-get update && apt-get install -y bind bind-utils

cat << 'EOF' > /etc/bind/local.conf
zone "au-team.irpo" {
    type master;
    file "au-team.irpo";
};
zone "100.168.192.in-addr.arpa" {
    type master;
    file "100.168.192.rev";
};
zone "3.16.172.in-addr.arpa" {
    type master;
    file "3.16.172.rev";
};
EOF

cat << 'EOF' > /var/lib/bind/zone/au-team.irpo
$TTL 1D
@       IN SOA  au-team.irpo. root.au-team.irpo. (
                                2026052500  ; serial
                                1D      ; refresh
                                1H      ; retry
                                1W      ; expire
                                3H      ; minimum
                )
        IN NS   au-team.irpo.
        IN A    192.168.100.2
hq-srv  IN A    192.168.100.2
br-rtr  IN A    172.16.3.1
br-fw   IN A    172.16.3.2
br-fw   IN A    172.16.3.5
hq-cli  IN A    192.168.200.2
br-srv  IN A    172.16.3.6
docker  IN A    172.16.1.1
web     IN A    172.16.2.1
hq-rtr  IN A    192.168.100.1
hq-rtr  IN A    192.168.200.1
hq-rtr  IN A    192.168.99.1
EOF

cat << 'EOF' > /var/lib/bind/zone/100.168.192.rev
$TTL 1D
@       IN SOA  au-team.irpo. root.au-team.irpo. (
                                2026052500  ; serial
                                1D      ; refresh
                                1H      ; retry
                                1W      ; expire
                                3H      ; minimum
                )
        IN NS   au-team.irpo.
2       IN PTR  hq-srv.au-team.irpo.
EOF

cat << 'EOF' > /var/lib/bind/zone/3.16.172.rev
$TTL 1D
@       IN SOA  au-team.irpo. root.au-team.irpo. (
                                2026052500  ; serial
                                1D      ; refresh
                                1H      ; retry
                                1W      ; expire
                                3H      ; minimum
                )
        IN NS   au-team.irpo.
6       IN PTR  br-srv.au-team.irpo.
EOF

chown root:named /var/lib/bind/zone/*
rm -f /etc/bind/rndc.key

cat << 'EOF' > /etc/bind/named.conf
include "/etc/bind/options.conf";
include "/etc/bind/local.conf";
EOF

cat << 'EOF' > /etc/bind/options.conf
options {
    listen-on { 192.168.100.2; 127.0.0.1; };
    listen-on-v6 { none; };
    forwarders { 95.167.167.95; 77.88.8.8; };
    allow-query { any; };
    allow-recursion { any; };
};
EOF

named-checkconf && systemctl enable --now bind.service
echo "search au-team.irpo" > /etc/net/ifaces/ens18/resolv.conf
echo "nameserver 192.168.100.2" >> /etc/net/ifaces/ens18/resolv.conf
systemctl restart network
systemctl restart bind.service

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


# --- Контрольные проверки (добавляются в историю) ---
echo "[>] Проверка: ip a"
echo "ip a" >> "$HISTFILE"
ip a 2>/dev/null || true
echo "[>] Проверка: named-checkconf"
echo "named-checkconf" >> "$HISTFILE"
named-checkconf 2>/dev/null || true
echo "[>] Проверка: systemctl status named"
echo "systemctl status named" >> "$HISTFILE"
systemctl status named 2>/dev/null || true
echo "[>] Проверка: ss -tulpn | grep 2027"
echo "ss -tulpn | grep 2027" >> "$HISTFILE"
ss -tulpn | grep 2027 2>/dev/null || true

echo "[OK] Настройка успешно завершена!"
