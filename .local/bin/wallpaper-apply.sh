#!/bin/bash
# Apply wallpaper: transition → wal → postprocess
# Usage: wallpaper-apply.sh /path/to/image

if [ -z "$1" ] || [ ! -f "$1" ]; then
    echo "Usage: wallpaper-apply.sh /path/to/image" >&2
    exit 1
fi

wall="$1"

ln -sf "$wall" "$HOME/wallpapers/current"
awww img "$wall" --transition-type any --transition-duration 2 &
wal -i "$wall" -n -q
sleep 0.3
~/.local/bin/wal-postprocess.sh
