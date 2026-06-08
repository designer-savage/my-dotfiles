# My Dotfiles

Personal Arch Linux desktop configuration built around Hyprland. 🐧

Mostly native, lightweight tooling: **Waybar** for the bar, **Rofi** for launchers/menus,
**pywal** for wallpaper-driven theming. A trimmed-down **Quickshell** instance survives only
for the Wi-Fi and Bluetooth slide-out panels.

## Screenshots

![Desktop 1](screenshots/screen-1.png)
![Desktop 2](screenshots/screen-2.png)
![Desktop 3](screenshots/screen-3.png)
![Desktop 4](screenshots/screen-4.png)
![Desktop 5](screenshots/screen-5.png)

## Main Components

### Hyprland Ecosystem
- **hyprland** — tiling Wayland compositor 🖼️
- **hyprlock** — lock screen 🔒
- **hypridle** — idle management 😴

### UI & Shell
- **waybar** — top bar: workspaces, clock, battery, volume, RAM, keyboard layout, network, Bluetooth 📊
- **rofi** — app launcher, wallpaper picker, Wi-Fi and Bluetooth menus 🚀
- **quickshell** — minimal QML instance, only the Wi-Fi/Bluetooth panels (toggled from Waybar) 📶
- **swaync** — notification center 🔔
- **pywal** — generates the color scheme from the current wallpaper 🎨
- **awww** — wallpaper daemon 🖼️

### Applications
- **kitty** — GPU-accelerated terminal 🐱
- **thunar** — file manager 📁
- **neovim** — text editor ✏️
- **mpv / celluloid** — video players 🎬

## Project Structure

```
.
├── .config/
│   ├── hypr/        # Modular Hyprland configs (sourced from hyprland.conf)
│   ├── waybar/      # Bar config, style, generated colors, custom scripts
│   ├── rofi/        # Launcher/menu themes and scripts
│   ├── quickshell/  # Minimal QML shell — Wi-Fi/Bluetooth panels only
│   ├── kitty/       # Terminal config
│   └── scripts/     # Hyprland helper scripts (screenshot, nightlight, battery, …)
├── .local/bin/      # Wallpaper + monitor refresh-rate helpers, quickshell launcher
├── install.sh       # Symlinks configs into ~/.config and ~/.local/bin
├── packages.txt     # Explicitly installed packages
└── README.md
```

## Installation

### 1. Clone

```bash
git clone https://github.com/designer-savage/my-dotfiles.git
cd my-dotfiles
```

### 2. Install packages

```bash
paru -S --needed - < packages.txt
```

Or install only the components you actually want.

### 3. Link configs

Creates symlinks into `~/.config` and `~/.local/bin`; existing files are backed up first.

```bash
chmod +x install.sh
./install.sh
```

### 4. Restart Hyprland

Re-login or restart Hyprland to pick everything up.

## Theming

Wallpaper changes drive the whole color scheme. Picking a wallpaper (rofi, `Super+W`) runs
`~/.local/bin/wallpaper-apply.sh`, which sets the wallpaper via `awww`, regenerates colors with
`pywal`, then `wal-postprocess.sh` propagates them to Waybar, Rofi, swaync and GTK and hot-reloads
Waybar. Quickshell reads the same `~/.cache/wal/colors.json` for its panels.

## Key Bindings

Full list in `.config/hypr/binds.conf`. Highlights (Super = Windows key):

| Binding | Action |
|---------|--------|
| `Super + Return` | Terminal (kitty) |
| `Super + Q` | Close window |
| `Super + R` | App launcher (rofi) |
| `Super + W` | Wallpaper picker (rofi) |
| `Super + Shift + W` | Random wallpaper |
| `Super + E` | File manager (thunar) |
| `Super + L` | Lock screen |
| `Super + F` | Fullscreen |
| `Super + N` | Toggle night light |
| `Super + Space` | Switch keyboard layout (us/ru) |
| `Super + [1-5]` | Switch workspace |
| `Print` | Screenshot (area) |

> Note: some bindings point at personal paths (e.g. `Super+B`, `Super+T`) — adjust them in
> `binds.conf` to your own setup.
