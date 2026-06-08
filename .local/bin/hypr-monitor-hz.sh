#!/usr/bin/bash
HYPRLAND_INSTANCE_SIGNATURE=$(ls /run/user/1000/hypr/ 2>/dev/null | head -1)
[ -z "$HYPRLAND_INSTANCE_SIGNATURE" ] && exit 1

export HYPRLAND_INSTANCE_SIGNATURE

AC=$(cat /sys/class/power_supply/ACAD/online 2>/dev/null)
if [ "$AC" = "1" ]; then
    hyprctl keyword monitor eDP-1,2560x1600@120,0x0,1.0
else
    hyprctl keyword monitor eDP-1,2560x1600@60,0x0,1.0
fi
