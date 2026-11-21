#!/bin/bash
# =====================================================================
# Интерактивный установщик лабораторного комплекса (09.02.06)
# =====================================================================
BASE_URL="https://raw.githubusercontent.com/maga-sysadmin/sysadmin-practice-labs/main/scripts"

echo "====================================================================="
echo "   УЧЕБНО-ПРАКТИЧЕСКИЙ КОМПЛЕКС: 09.02.06 (КИМ 2027)"
echo "   Репозиторий: maga-sysadmin/sysadmin-practice-labs"
echo "====================================================================="
echo ""

# Автоопределение узла по hostname
HN=$(hostname -s | tr '[:upper:]' '[:lower:]')

NODE=""
case "$HN" in
    isp*)    NODE="isp" ;;
    hq-srv*) NODE="hqsrv" ;;
    br-srv*) NODE="brsrv" ;;
    hq-cli*) NODE="hqcli" ;;
    *)       NODE="" ;;
esac

if [ -n "$1" ]; then
    NODE="$1"
fi

if [ -z "$NODE" ]; then
    echo "Выберите целевой узел:"
    echo "  1) ISP    (Шлюз провайдера ALT Linux)"
    echo "  2) HQ-SRV (Сервер центра - DNS, RAID, LAMP)"
    echo "  3) BR-SRV (Сервер филиала - Samba DC, CSV)"
    echo "  4) HQ-CLI (Клиентская станция - Ввод в домен)"
    read -p "Введите номер [1-4]: " choice
    case "$choice" in
        1) NODE="isp" ;;
        2) NODE="hqsrv" ;;
        3) NODE="brsrv" ;;
        4) NODE="hqcli" ;;
        *) echo "Неверный выбор. Выход."; exit 1 ;;
    esac
fi

MODULE="${2:-1}"
if [ -z "$2" ]; then
    echo ""
    echo "Выберите модуль для настройки:"
    echo "  1) Модуль 1 (Сетевая инфраструктура)"
    echo "  2) Модуль 2 (Сетевые сервисы и домен)"
    echo "  3) Модуль 3 (Безопасность и аудит)"
    read -p "Введите номер модуля [1-3] (по умолчанию 1): " m_choice
    MODULE="${m_choice:-1}"
fi

TARGET="${NODE}_m${MODULE}.sh"
echo ""
echo "[i] Загрузка и запуск сценария: $TARGET..."
curl -sL "$BASE_URL/$TARGET" | bash

echo ""
echo "====================================================================="
echo " [OK] Модуль $MODULE на узле $NODE успешно сконфигурирован!"
echo "====================================================================="
