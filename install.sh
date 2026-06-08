#!/bin/bash

# Dotfiles installation script.
# Symlinks configs from the repo into ~/.config and ~/.local/bin.
# Existing files are backed up with a timestamp suffix.

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
BIN_DIR="$HOME/.local/bin"

echo "==> Installing configs from $DOTFILES_DIR"

backup_if_exists() {
    local target=$1
    if [ -e "$target" ] || [ -L "$target" ]; then
        echo "Backup: $target -> $target.backup.$(date +%Y%m%d_%H%M%S)"
        mv "$target" "$target.backup.$(date +%Y%m%d_%H%M%S)"
    fi
}

create_symlink() {
    local source=$1
    local target=$2
    backup_if_exists "$target"
    echo "Symlink: $target -> $source"
    ln -sf "$source" "$target"
}

mkdir -p "$CONFIG_DIR" "$BIN_DIR"

# --- ~/.config directories ---
for dir in hypr quickshell kitty waybar rofi scripts; do
    create_symlink "$DOTFILES_DIR/.config/$dir" "$CONFIG_DIR/$dir"
done

# --- ~/.local/bin helper scripts (symlinked individually) ---
for script in "$DOTFILES_DIR"/.local/bin/*.sh; do
    create_symlink "$script" "$BIN_DIR/$(basename "$script")"
done

echo ""
echo "==> Done!"
echo ""
echo "Install packages from packages.txt (AUR helper required):"
echo "  paru -S --needed - < packages.txt"
echo ""
echo "Then restart Hyprland or re-login."
