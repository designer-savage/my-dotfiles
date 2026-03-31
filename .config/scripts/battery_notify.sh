#!/bin/bash

NOTIFIED_20=false
NOTIFIED_10=false

while true; do
    # Берём первую батарею, вытаскиваем процент
    CHARGE=$(acpi -b 2>/dev/null | head -1 | grep -oP '\d+(?=%)')
    STATUS=$(acpi -b 2>/dev/null | head -1 | grep -oP '(?<=: )\w+')

    # Не уведомляем если на зарядке
    if [[ "$STATUS" == "Charging" || "$STATUS" == "Full" ]]; then
        NOTIFIED_20=false
        NOTIFIED_10=false
        sleep 60
        continue
    fi

    if [[ -n "$CHARGE" ]]; then
        if [[ "$CHARGE" -le 10 && "$NOTIFIED_10" == false ]]; then
            notify-send -u critical -i battery-low "Критический заряд" "Осталось ${CHARGE}% — подключи зарядку" -t 10000
            NOTIFIED_10=true
            NOTIFIED_20=true
        elif [[ "$CHARGE" -le 20 && "$NOTIFIED_20" == false ]]; then
            notify-send -u normal -i battery-caution "Низкий заряд" "Осталось ${CHARGE}%" -t 8000
            NOTIFIED_20=true
        fi
    fi

    sleep 60
done
