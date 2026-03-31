#!/bin/bash
# Инструкции для пуша изменений на GitHub
# Выполните эти команды вручную в терминале:

cd /home/designer/work/my-dotfiles

# 1. Проверить статус
git status

# 2. Добавить изменения
git add .config/quickshell/

# 3. Сделать коммит
git commit -m "chore: обновить файлы quickshell из ~/.config/quickshell

- Обновлены все QML компоненты (Bar, Dashboard, LauncherPanel, MusicPanel, WifiPanel, BluetoothPanel)
- Обновлены shell.qml и app_usage.json
- Синхронизированы файлы с ~/.config/quickshell/"

# 4. Запушить на GitHub
git push

# Если репозиторий my-dotfiles ещё не создан на GitHub:
# 1. Создайте репозиторий на GitHub с именем my-dotfiles
# 2. Выполните: git remote set-url origin git@github.com:designer-savage/my-dotfiles.git
# 3. Выполните: git push -u origin main
