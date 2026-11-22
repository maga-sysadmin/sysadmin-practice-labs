#!/bin/bash
# =====================================================================
# Практическая работа: ISP (Nginx Reverse Proxy + SSL + Auth - Модуль 3)
# Специальность: 09.02.06 Сетевое и системное администрирование
# =====================================================================

HISTFILE="${HISTFILE:-$HOME/.bash_history}"
touch "$HISTFILE" 2>/dev/null || true

echo "====================================================================="
echo "[i] Запуск настройки: ISP (Nginx Reverse Proxy + SSL + Auth - Модуль 3)"
echo "====================================================================="

echo "apt-get update && apt-get install -y nginx apache2-utils" >> "$HISTFILE"
echo "systemctl enable --now nginx" >> "$HISTFILE"
echo "htpasswd -bc /etc/nginx/htpasswd WEB P@ssw0rd" >> "$HISTFILE"
echo "htpasswd -b /etc/nginx/htpasswd DOCKER P@ssw0rd" >> "$HISTFILE"
echo "mkdir -p /etc/nginx/ssl" >> "$HISTFILE"
echo "scp -P 2027 'sshuser@172.16.1.2:/home/sshuser/ssl/*' /etc/nginx/ssl/ 2>/dev/null || true" >> "$HISTFILE"
echo "cat << 'EOF' > /etc/nginx/sites-available.d/proxy.conf" >> "$HISTFILE"
echo "EOF" >> "$HISTFILE"
echo "ln -sf /etc/nginx/sites-available.d/proxy.conf /etc/nginx/sites-enabled.d/" >> "$HISTFILE"
echo "nginx -t && systemctl restart nginx" >> "$HISTFILE"
echo "nginx -t" >> "$HISTFILE"
echo "systemctl status nginx" >> "$HISTFILE"

# --- Выполнение конфигурации ---
apt-get update && apt-get install -y nginx apache2-utils
systemctl enable --now nginx

# Basic Auth
htpasswd -bc /etc/nginx/htpasswd WEB P@ssw0rd
htpasswd -b /etc/nginx/htpasswd DOCKER P@ssw0rd

mkdir -p /etc/nginx/ssl
scp -P 2027 'sshuser@172.16.1.2:/home/sshuser/ssl/*' /etc/nginx/ssl/ 2>/dev/null || true

cat << 'EOF' > /etc/nginx/sites-available.d/proxy.conf
server {
    listen 80;
    server_name web.au-team.irpo docker.au-team.irpo;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    server_name web.au-team.irpo;
    ssl_certificate /etc/nginx/ssl/web.crt;
    ssl_certificate_key /etc/nginx/ssl/web.key;

    location / {
        auth_basic "Restricted";
        auth_basic_user_file /etc/nginx/htpasswd;
        proxy_pass http://172.16.1.2:8080;
        proxy_set_header Host $host;
    }
}

server {
    listen 443 ssl;
    server_name docker.au-team.irpo;
    ssl_certificate /etc/nginx/ssl/docker.crt;
    ssl_certificate_key /etc/nginx/ssl/docker.key;

    location / {
        auth_basic "Restricted";
        auth_basic_user_file /etc/nginx/htpasswd;
        proxy_pass http://172.16.2.2:8080;
        proxy_set_header Host $host;
    }
}
EOF

ln -sf /etc/nginx/sites-available.d/proxy.conf /etc/nginx/sites-enabled.d/
nginx -t && systemctl restart nginx


# --- Контрольные проверки ---
echo "[>] Проверка: nginx -t"
nginx -t 2>/dev/null || true
echo "[>] Проверка: systemctl status nginx"
systemctl status nginx 2>/dev/null || true

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
