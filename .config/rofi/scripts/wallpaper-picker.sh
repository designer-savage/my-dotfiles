#!/bin/bash
# Wallpaper picker: shows thumbnails via rofi, applies selected wallpaper

WALL_DIR="$HOME/wallpapers"
THUMB_DIR="$HOME/.cache/wallpaper-thumbs"

# Build rofi input: "filename\0icon\x1f/thumb/path\n"
entries=""
declare -A path_map

while IFS= read -r -d '' file; do
    name=$(basename "$file")
    # Thumbnail is named by MD5 hash of the full path (matches quickshell convention)
    hash=$(echo -n "$file" | md5sum | cut -d' ' -f1)
    thumb="$THUMB_DIR/${hash}.jpg"

    if [ ! -f "$thumb" ]; then
        # Thumbnail doesn't exist yet — generate it
        if command -v vipsthumbnail &>/dev/null; then
            vipsthumbnail "$file" --size 180x120 -o "$thumb" 2>/dev/null
        elif command -v magick &>/dev/null; then
            magick "$file"[0] -thumbnail 180x120^ -gravity center -extent 180x120 "$thumb" 2>/dev/null
        else
            thumb="$file"
        fi
    fi

    [ ! -f "$thumb" ] && thumb="$file"
    entries+="${name}\x00icon\x1f${thumb}\n"
    path_map["$name"]="$file"
done < <(find "$WALL_DIR" -maxdepth 1 -type f \
    \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \
       -o -iname '*.gif' -o -iname '*.webp' \) \
    ! -name ".*" -print0 | sort -z)

selected=$(printf "%b" "$entries" | rofi -dmenu -i \
    -p "󰸉 Wallpapers" \
    -show-icons \
    -theme "$HOME/.config/rofi/themes/wallpapers.rasi")

[ -z "$selected" ] && exit 0

wall_path="$WALL_DIR/$selected"
[ -f "$wall_path" ] && ~/.local/bin/wallpaper-apply.sh "$wall_path"
