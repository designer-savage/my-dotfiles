#!/bin/bash
# Скрипт для git операций в новой директории

cd /home/designer/work/my-dotfiles || exit 1

# Проверка статуса
echo "=== Git status ==="
git status

# Добавление изменений
echo "=== Adding changes ==="
git add .config/quickshell/

# Коммит
echo "=== Committing ==="
git commit -m "chore: обновить файлы quickshell из ~/.config/quickshell

- Обновлены все QML компоненты (Bar, Dashboard, LauncherPanel, MusicPanel, WifiPanel, BluetoothPanel)
- Обновлены shell.qml и app_usage.json
- Синхронизированы файлы с ~/.config/quickshell/"

# Пуш
echo "=== Pushing ==="
git push

echo "=== Done ==="
