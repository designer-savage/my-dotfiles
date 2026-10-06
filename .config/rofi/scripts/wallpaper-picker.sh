#!/usr/bin/env bash
# Wallpaper picker (SUPER+W)
#
# Renders ~/wallpapers as a thumbnail grid in rofi and applies the pick.
#
# Two things matter for how it looks:
#   * thumbnails are cropped to the screen's own 16:10 ratio and rendered at
#     2x the on-screen tile size, so the grid is even and the tiles are sharp;
#   * the visible label is the file name cleaned up (no extension, no
#     separators, title-cased) — selection travels back by row index, so the
#     pretty label never has to round-trip to a path.

set -uo pipefail

WALL_DIR="$HOME/wallpapers"
THUMB_DIR="$HOME/.cache/wallpaper-thumbs"
THEME="$HOME/.config/rofi/themes/wallpapers.rasi"
# 3x the tile the theme draws (335x209), cropped to fill. Rofi downscales the
# icon itself, and giving it more to work with is what keeps the grid crisp —
# at 2x the tiles were visibly soft.
THUMB_W=1005
THUMB_H=628
JOBS=8

mkdir -p "$THUMB_DIR"

mapfile -d '' -t files < <(
    find "$WALL_DIR" -maxdepth 1 -type f \
        \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \
           -o -iname '*.gif' -o -iname '*.webp' \) \
        ! -name '.*' -print0 | sort -z
)

if [ ${#files[@]} -eq 0 ]; then
    notify-send "Wallpapers" "No images in $WALL_DIR"
    exit 0
fi

# Cache key covers the geometry too, so changing THUMB_W/H rebuilds cleanly
# instead of silently reusing thumbnails made for a different tile size.
thumb_path() {
    local key
    key=$(printf '%s|%sx%s' "$1" "$THUMB_W" "$THUMB_H" | md5sum | cut -d' ' -f1)
    printf '%s/%s.jpg' "$THUMB_DIR" "$key"
}

make_thumb() {
    local src="$1" dst="$2"
    if command -v vipsthumbnail &>/dev/null; then
        vipsthumbnail "$src" --size "${THUMB_W}x${THUMB_H}" --smartcrop attention \
            -o "$dst[Q=93,strip]" 2>/dev/null && return 0
    fi
    if command -v magick &>/dev/null; then
        magick "$src[0]" -thumbnail "${THUMB_W}x${THUMB_H}^" -gravity center \
            -extent "${THUMB_W}x${THUMB_H}" -quality 93 -strip "$dst" 2>/dev/null && return 0
    fi
    return 1
}
export -f make_thumb
export THUMB_W THUMB_H

# Build the missing-thumbnail worklist, then render it in parallel — a cold
# cache over ~80 wallpapers is otherwise a visible stall before rofi appears.
todo=()
thumbs=()
for f in "${files[@]}"; do
    t=$(thumb_path "$f")
    thumbs+=("$t")
    [ -f "$t" ] || todo+=("$f" "$t")
done

if [ ${#todo[@]} -gt 0 ]; then
    printf '%s\0' "${todo[@]}" |
        xargs -0 -n2 -P "$JOBS" bash -c 'make_thumb "$0" "$1"' 2>/dev/null
fi

# Drop thumbnails that no longer belong to anything: wallpapers that were
# deleted, and the smaller tiles left behind by an earlier THUMB_W/H.
keep=$(printf '%s\n' "${thumbs[@]}")
while IFS= read -r stale; do
    grep -qxF "$stale" <<< "$keep" || rm -f "$stale"
done < <(find "$THUMB_DIR" -maxdepth 1 -type f -name '*.jpg')

# "anime_girl_plus_rockets.png" → "Anime Girl Plus Rockets"
pretty() {
    local n="${1%.*}"
    n="${n//[_-]/ }"
    printf '%s' "$n" | sed -E 's/\s+/ /g; s/\b(.)/\u\1/g'
}

# Open the grid on the wallpaper that is currently applied, the way macOS
# shows the active one already selected.
current=$(readlink -f "$WALL_DIR/current" 2>/dev/null || true)
selected_row=0

entries=""
for i in "${!files[@]}"; do
    [ -n "$current" ] && [ "$(readlink -f "${files[$i]}")" = "$current" ] && selected_row=$i
    label=$(pretty "$(basename "${files[$i]}")")
    icon="${thumbs[$i]}"
    [ -f "$icon" ] || icon="${files[$i]}"
    entries+="${label}\x00icon\x1f${icon}\n"
done

# -format i returns the row's index in the input list, so the displayed label
# stays free-form and never has to be mapped back onto a file name.
index=$(printf "%b" "$entries" | rofi -dmenu -i -format i -p "" -show-icons \
    -selected-row "$selected_row" -theme "$THEME")

[[ "$index" =~ ^[0-9]+$ ]] || exit 0
[ "$index" -lt "${#files[@]}" ] || exit 0

"$HOME/.local/bin/wallpaper-apply.sh" "${files[$index]}"
