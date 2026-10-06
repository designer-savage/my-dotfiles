#!/usr/bin/env bash
# Toggle hypridle: caffeine mode keeps the screen awake (reading PDFs, watching video).

if pgrep -x hypridle >/dev/null; then
    pkill -x hypridle
    # hypridle's on-resume hooks never fire when it's killed, so restore state by hand.
    brightnessctl -r >/dev/null 2>&1
    notify-send -a caffeine -i preferences-desktop-screensaver "Caffeine ON" "Экран не будет гаснуть"
    pkill -RTMIN+10 waybar
else
    hypridle >/dev/null 2>&1 &
    notify-send -a caffeine -i preferences-desktop-screensaver "Caffeine OFF" "Автогашение экрана снова активно"
    pkill -RTMIN+10 waybar
fi
