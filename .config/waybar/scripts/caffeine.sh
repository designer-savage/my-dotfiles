#!/usr/bin/bash
# Индикатор caffeine-режима для waybar (custom-модуль).
# Caffeine = hypridle убит, экран не гаснет. Толкается сигналом RTMIN+10
# из ~/.config/scripts/caffeine.sh, поэтому опрос по таймеру не нужен.
#
# Пустой text прячет модуль: в обычном режиме капсулы в баре нет,
# иконка появляется только когда автогашение отключено.

if pgrep -x hypridle >/dev/null; then
    printf '{"text":"","class":"off","tooltip":"Автогашение экрана активно"}\n'
else
    printf '{"text":"󰅶","class":"on","tooltip":"Caffeine: экран не гаснет"}\n'
fi
