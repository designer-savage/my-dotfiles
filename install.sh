#!/bin/bash

# Скрипт установки конфигов Hyprland

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"

echo "==> Установка конфигов из $DOTFILES_DIR"

# Создаём бэкапы существующих конфигов
backup_if_exists() {
    local target=$1
    if [ -e "$target" ]; then
        echo "Создаю бэкап: $target -> $target.backup.$(date +%Y%m%d_%H%M%S)"
        mv "$target" "$target.backup.$(date +%Y%m%d_%H%M%S)"
    fi
}

# Создаём симлинки
create_symlink() {
    local source=$1
    local target=$2
    
    backup_if_exists "$target"
    
    echo "Создаю симлинк: $target -> $source"
    ln -sf "$source" "$target"
}

# Устанавливаем конфиги
mkdir -p "$CONFIG_DIR"

create_symlink "$DOTFILES_DIR/.config/hypr" "$CONFIG_DIR/hypr"
create_symlink "$DOTFILES_DIR/.config/quickshell" "$CONFIG_DIR/quickshell"
create_symlink "$DOTFILES_DIR/.config/kitty" "$CONFIG_DIR/kitty"
create_symlink "$DOTFILES_DIR/.config/waybar" "$CONFIG_DIR/waybar"

echo ""
echo "==> Готово!"
echo ""
echo "Для установки пакетов из packages.txt:"
echo "  yay -S --needed \$(cat packages.txt | awk '{print \$1}')"
