#!/bin/bash
# =====================================================================
# Лабораторная работа 3.2: Обратный прокси-сервер Nginx (SSL/TLS, Basic Auth)
# Специальность: 09.02.06 Сетевое и системное администрирование
# =====================================================================

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
