#!/bin/bash

# Dotfiles installation script.
# Symlinks configs from the repo into ~/.config and ~/.local/bin.
# Existing files are backed up with a timestamp suffix.

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
BIN_DIR="$HOME/.local/bin"
STAMP="$(date +%Y%m%d_%H%M%S)"

echo "==> Installing configs from $DOTFILES_DIR"

backup_if_exists() {
    local target=$1
    if [ -e "$target" ] || [ -L "$target" ]; then
        echo "Backup:  $target -> $target.backup.$STAMP"
        mv "$target" "$target.backup.$STAMP"
    fi
}

create_symlink() {
    local source=$1
    local target=$2
    backup_if_exists "$target"
    echo "Symlink: $target -> $source"
    ln -s "$source" "$target"
}

mkdir -p "$CONFIG_DIR" "$BIN_DIR" "$CONFIG_DIR/wal" "$CONFIG_DIR/fish"

# --- ~/.config directories ---
for dir in hypr waybar rofi quickshell swaync kitty scripts fastfetch; do
    create_symlink "$DOTFILES_DIR/.config/$dir" "$CONFIG_DIR/$dir"
done

# --- single files and partial directories ---
# wal and fish also hold machine-local state (cache, fish_variables, plugins),
# so only the tracked parts are linked, not the whole directory.
create_symlink "$DOTFILES_DIR/.config/wal/templates" "$CONFIG_DIR/wal/templates"
for file in config.fish fish_plugins; do
    create_symlink "$DOTFILES_DIR/.config/fish/$file" "$CONFIG_DIR/fish/$file"
done
for file in starship.toml libinput-gestures.conf; do
    create_symlink "$DOTFILES_DIR/.config/$file" "$CONFIG_DIR/$file"
done

# --- ~/.local/bin helpers ---
for script in "$DOTFILES_DIR"/.local/bin/*; do
    create_symlink "$script" "$BIN_DIR/$(basename "$script")"
done

echo ""
echo "==> Done."
echo ""
echo "Next steps:"
echo "  1. Install packages:  grep -v '^#' packages.txt | paru -S --needed -"
echo "  2. Put some images into ~/wallpapers"
echo "  3. Log into Hyprland and pick a wallpaper with Super+W."
echo "     That generates the colour scheme every panel imports."
