#!/usr/bin/bash
# Одна кнопка воркспейса для waybar (custom-модуль).
# Нативный hyprland/workspaces не переключает по клику: он шлёт Hyprland
# старый IPC "dispatch workspace N", который Lua-конфиг больше не понимает
# (Waybar issue #5008). Здесь клик идёт через hl.dsp.focus.
#
# Пустой text прячет модуль — так ряд выглядит как раньше:
# видны только существующие воркспейсы.
N="$1"
[ -z "$N" ] && exit 1

active=$(hyprctl activeworkspace -j 2>/dev/null | jq -r '.id // empty')
exists=$(hyprctl workspaces -j 2>/dev/null | jq -r --argjson n "$N" 'any(.[]; .id == $n)')

if [ "$active" = "$N" ]; then
    printf '{"text":"%s","class":"active"}\n' "$N"
elif [ "$exists" = "true" ]; then
    printf '{"text":"%s","class":"occupied"}\n' "$N"
else
    printf '{"text":"","class":"empty"}\n'
fi
