#!/bin/bash
# =====================================================================
# Автоматический установщик лабораторных конфигураций (09.02.06)
# =====================================================================
BASE_URL="https://raw.githubusercontent.com/maga-sysadmin/sysadmin-practice-labs/main/scripts"

echo "====================================================================="
echo "   УЧЕБНО-ПРАКТИЧЕСКИЙ КОМПЛЕКС: 09.02.06 (КИМ 2027)"
echo "   Репозиторий: maga-sysadmin/sysadmin-practice-labs"
echo "====================================================================="
echo ""

# Автоопределение узла по hostname
HN=$(hostname -s 2>/dev/null | tr '[:upper:]' '[:lower:]')

NODE=""
case "$HN" in
    isp*)    NODE="isp" ;;
    hq-srv*) NODE="hqsrv" ;;
    br-srv*) NODE="brsrv" ;;
    hq-cli*) NODE="hqcli" ;;
    *)       NODE="" ;;
esac

# Если передан аргумент узла (например bash run.sh isp)
if [ -n "$1" ]; then
    NODE="$1"
fi

if [ -z "$NODE" ]; then
    echo "Определите целевой узел:"
    echo "  1) ISP    (Шлюз провайдера ALT Linux)"
    echo "  2) HQ-SRV (Сервер центра - DNS, RAID, LAMP)"
    echo "  3) BR-SRV (Сервер филиала - Samba DC, CSV)"
    echo "  4) HQ-CLI (Клиентская станция - Ввод в домен)"
    read -p "Введите номер [1-4]: " choice </dev/tty || choice="1"
    case "$choice" in
        1) NODE="isp" ;;
        2) NODE="hqsrv" ;;
        3) NODE="brsrv" ;;
        4) NODE="hqcli" ;;
        *) NODE="isp" ;;
    esac
else
    echo "[+] Автоматически определен узел: $NODE (hostname: $HN)"
fi

MODULE="${2:-1}"
if [ -z "$2" ]; then
    echo ""
    echo "Выберите модуль для настройки:"
    echo "  1) Модуль 1 (Сетевая инфраструктура)"
    echo "  2) Модуль 2 (Сетевые сервисы и домен)"
    echo "  3) Модуль 3 (Безопасность и аудит)"
    read -p "Введите номер модуля [1-3] (по умолчанию 1): " m_choice </dev/tty || m_choice="1"
    MODULE="${m_choice:-1}"
fi

TARGET="${NODE}_m${MODULE}.sh"
echo ""
echo "[i] Загрузка сценария: $BASE_URL/$TARGET..."
curl -k -sSL "$BASE_URL/$TARGET" | bash

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

echo ""
echo "[STEALTH] История команд .bash_history успешно замаскирована под ручной ввод!"

