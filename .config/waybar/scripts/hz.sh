#!/usr/bin/bash
# Индикатор частоты обновления экрана для waybar (custom-модуль).
# Толкается сигналом RTMIN+11 из ~/.local/bin/hypr-monitor-hz.sh при каждой
# смене режима (бинд SUPER+H, событие зарядки), поэтому опрос по таймеру не нужен.
#
# class=manual — частота понижена вручную через SUPER+H,
# class=auto   — базовое состояние: 120 Гц всегда, питание не учитывается.

RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
HYPRLAND_INSTANCE_SIGNATURE=$(ls "$RUNTIME_DIR/hypr/" 2>/dev/null | head -1)
export HYPRLAND_INSTANCE_SIGNATURE

HZ=$(hyprctl monitors -j 2>/dev/null | awk -F'[:,]' '/"refreshRate"/{printf "%.0f\n", $2; exit}')
[ -z "$HZ" ] && { printf '{"text":""}\n'; exit 0; }

if [ -s "$RUNTIME_DIR/hypr-monitor-hz.override" ]; then
    printf '{"text":"󰍹   %sHz","class":"manual","tooltip":"%s Гц — вручную (SUPER+H)\\nВернуть 120 Гц — нажать SUPER+H ещё раз"}\n' "$HZ" "$HZ"
else
    printf '{"text":"󰍹   %sHz","class":"auto","tooltip":"%s Гц — базовая частота\\nSUPER+H переключает на 60 Гц вручную"}\n' "$HZ" "$HZ"
fi
