#!/usr/bin/env bash
set -e

DIR="$HOME/screenshots"

# если папки нет — создаём
mkdir -p "$DIR"

# считаем кол-во PNG
COUNT=$(find "$DIR" -maxdepth 1 -type f -name "*.png" | wc -l)

if [ "$COUNT" -eq 0 ]; then
    notify-send "Screenshots" "Папка уже пустая"
    exit 0
fi

# удаление
find "$DIR" -maxdepth 1 -type f -name "*.png" -delete

notify-send "Screenshots" "Удалено $COUNT скриншотов"
