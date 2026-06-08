#!/usr/bin/env bash
# Тумблер ночного режима через hyprsunset.
# Первый запуск — тёплая температура, повторный — выключает.

TEMP=4000

if pgrep -x hyprsunset >/dev/null; then
    killall hyprsunset
    notify-send -t 1500 "Ночной режим" "Выключен"
else
    hyprsunset -t "$TEMP" &
    notify-send -t 1500 "Ночной режим" "Включён (${TEMP}K)"
fi
