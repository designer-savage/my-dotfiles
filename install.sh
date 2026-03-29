#!/bin/bash

# Hyprland config installation script

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"

echo "==> Installing configs from $DOTFILES_DIR"

# Create backups of existing configs
backup_if_exists() {
    local target=$1
    if [ -e "$target" ]; then
        echo "Creating backup: $target -> $target.backup.$(date +%Y%m%d_%H%M%S)"
        mv "$target" "$target.backup.$(date +%Y%m%d_%H%M%S)"
    fi
}

# Create symlinks
create_symlink() {
    local source=$1
    local target=$2

    backup_if_exists "$target"

    echo "Creating symlink: $target -> $source"
    ln -sf "$source" "$target"
}

# Install configs
mkdir -p "$CONFIG_DIR"

create_symlink "$DOTFILES_DIR/.config/hypr" "$CONFIG_DIR/hypr"
create_symlink "$DOTFILES_DIR/.config/quickshell" "$CONFIG_DIR/quickshell"
create_symlink "$DOTFILES_DIR/.config/kitty" "$CONFIG_DIR/kitty"
create_symlink "$DOTFILES_DIR/.config/waybar" "$CONFIG_DIR/waybar"

echo ""
echo "==> Done!"
echo ""
echo "To install packages from packages.txt:"
echo "  yay -S --needed \$(cat packages.txt | awk '{print \$1}')"
