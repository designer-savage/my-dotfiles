#!/bin/bash
WALL_DIR="$HOME/wallpapers"

selected=$(find "$WALL_DIR" -maxdepth 1 -type f \
    \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.gif' \
       -o -iname '*.png' -o -iname '*.webp' \) \
    ! -name ".*" | shuf -n1)

[ -f "$selected" ] && ~/.local/bin/wallpaper-apply.sh "$selected"
