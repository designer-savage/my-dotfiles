#!/bin/bash
if command -v rofi &>/dev/null; then
    rofi -show drun -theme ~/.config/rofi/themes/hyprland-menu.rasi
elif command -v wofi &>/dev/null; then
    wofi --show drun --prompt "" --insensitive
else
    notify-send "Launcher" "Install rofi: sudo pacman -S rofi"
fi
