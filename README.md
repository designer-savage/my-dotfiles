# Hyprland Setup

Персональная конфигурация Arch Linux с Hyprland и Quickshell для Lenovo ThinkBook 15 G3 ACL.

## Железо и система

- **Ноутбук**: Lenovo ThinkBook 15 G3 ACL
- **CPU**: AMD Ryzen 7 5700U @ 4.37GHz (16 потоков)
- **RAM**: ~13.5 GB
- **OS**: Arch Linux (kernel 6.19.9)
- **WM**: Hyprland 0.54.2
- **Terminal**: Kitty 0.46.2
- **Shell**: Bash + Starship prompt

## Основные компоненты

### Hyprland экосистема
- **hyprland** — тайловый Wayland-композитор
- **hyprlock** — экран блокировки
- **hypridle** — управление idle-состоянием
- **hyprpaper** — менеджер обоев
- **hyprpicker** — пипетка для выбора цветов
- **hyprshot** — утилита для скриншотов

### UI и бары
- **quickshell** — статус-бар на QML (основной)
- **waybar** — альтернативный бар (резервный)
- **swaync** — центр уведомлений
- **rofi/wofi** — лаунчеры приложений

### Приложения
- **kitty** — GPU-ускоренный терминал
- **firefox** — браузер
- **dolphin/thunar** — файловые менеджеры
- **neovim/vim** — редакторы
- **visual-studio-code** — IDE
- **obs-studio** — запись экрана
- **mpv/celluloid** — видеоплеер

### Утилиты
- **paru/yay** — AUR-хелперы
- **lazygit** — TUI для Git
- **bottom/htop** — мониторинг системы
- **fastfetch** — системная информация
- **eza** — современная замена ls
- **brightnessctl** — управление яркостью
- **blueman** — Bluetooth-менеджер

## Структура проекта

```
.
├── .config/
│   ├── hypr/           # Модульные конфиги Hyprland
│   ├── quickshell/     # QML-конфиг статус-бара
│   ├── kitty/          # Конфиг терминала
│   └── waybar/         # Альтернативный бар
├── install.sh          # Скрипт установки конфигов
├── packages.txt        # Список установленных пакетов
└── README.md
```

## Установка

### 1. Клонирование репозитория

```bash
git clone https://github.com/designer-savage/hyprland-setup.git
cd hyprland-setup
```

### 2. Установка пакетов

Установить все пакеты из `packages.txt`:

```bash
yay -S --needed $(cat packages.txt | awk '{print $1}')
```

Или выборочно установить только нужные компоненты.

### 3. Установка конфигов

Скрипт создаст симлинки на конфиги (существующие будут сохранены в бэкапы):

```bash
chmod +x install.sh
./install.sh
```

### 4. Перезапуск Hyprland

После установки перезапусти Hyprland или перелогинься.

## Особенности

- Модульная структура конфигов Hyprland (разделены по файлам)
- Quickshell на QML для гибкой настройки статус-бара
- Поддержка AMD GPU (драйверы AMDGPU, Vulkan)
- Настроенный power management (TLP, cpupower)
- Pipewire для аудио
- NetworkManager + iwd для сети
- Автоматические бэкапы при установке конфигов

## Полезные биндинги

Основные биндинги настроены в `.config/hypr/binds.conf`. Примеры:

- `Super + Q` — закрыть окно
- `Super + Return` — открыть терминал
- `Super + D` — лаунчер приложений
- `Super + F` — фуллскрин
- `Super + [1-9]` — переключение воркспейсов

Полный список смотри в конфиге.

## Лицензия

MIT
