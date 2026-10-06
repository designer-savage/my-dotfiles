#!/usr/bin/bash
# Частота монитора eDP-1: всегда 120 Гц, независимо от питания.
#
# Раньше здесь было правило AC -> 120, батарея -> 60, и отдельный демон
# hypr-monitor-hz-watch.sh дёргал --reset на каждое подключение зарядки.
# Из-за этого 120 Гц сбрасывались сами, без спроса. Автопереключение убрано:
# 120 Гц — базовое состояние, снизить можно только руками через --toggle.
#
#   (без аргументов) — применить override, если он есть, иначе 120
#   --toggle         — переключить 60 <-> 120 вручную и поставить override
#   --reset          — снять override и вернуться к 120

RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
OVERRIDE="$RUNTIME_DIR/hypr-monitor-hz.override"

HYPRLAND_INSTANCE_SIGNATURE=$(ls "$RUNTIME_DIR/hypr/" 2>/dev/null | head -1)
[ -z "$HYPRLAND_INSTANCE_SIGNATURE" ] && exit 1
export HYPRLAND_INSTANCE_SIGNATURE

current_hz() {
    hyprctl monitors -j 2>/dev/null | awk -F'[:,]' '/"refreshRate"/{printf "%.0f\n", $2; exit}'
}

# Базовая частота. Питание больше не учитывается.
auto_hz() {
    echo 120
}

apply() {
    # Уже на нужной частоте — не дёргаем режим (переключение гасит экран),
    # но индикатор в баре всё равно обновляем: мог смениться режим auto/manual.
    if [ "$(current_hz)" != "$1" ]; then
        # Конфиг Hyprland на Lua: hyprctl keyword здесь не работает, только eval.
        hyprctl eval "hl.monitor({ output = \"eDP-1\", mode = \"2560x1600@${1}\", position = \"0x0\", scale = 1.0 })" >/dev/null
        sleep 0.3  # режим применяется не мгновенно — иначе бар прочитает старую частоту
    fi
    pkill -RTMIN+11 waybar 2>/dev/null
}

case "$1" in
    --toggle)
        if [ "$(current_hz)" = "120" ]; then HZ=60; else HZ=120; fi
        echo "$HZ" > "$OVERRIDE"
        apply "$HZ"
        notify-send -h string:x-canonical-private-synchronous:hz \
            "Монитор: ${HZ} Гц" "Ручной режим — держится до следующего SUPER+H"
        ;;
    --reset)
        rm -f "$OVERRIDE"
        apply "$(auto_hz)"
        ;;
    *)
        if [ -s "$OVERRIDE" ]; then apply "$(cat "$OVERRIDE")"; else apply "$(auto_hz)"; fi
        ;;
esac
