#!/bin/bash
# =====================================================================
# Лабораторная работа 1.7: Клиентская рабочая станция HQ-CLI
# Специальность: 09.02.06 Сетевое и системное администрирование
# =====================================================================

nmcli con del Wired_connection_1 2>/dev/null || true
nmcli con add type ethernet con-name toRTR ifname ens18 ipv4.method auto
nmcli con up toRTR
hostnamectl set-hostname hq-cli.au-team.irpo
timedatectl set-timezone Europe/Moscow
ip a
ping -c 3 192.168.200.1
ssh -p 2027 sshuser@192.168.100.2
