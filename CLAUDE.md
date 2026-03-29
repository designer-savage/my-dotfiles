# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Personal Arch Linux desktop configuration. Built around Hyprland (Wayland compositor) + Quickshell (QML-based UI shell). Not a software project — it's a dotfiles/config repo deployed via symlinks.

## Installation

```bash
bash install.sh   # Creates symlinks from repo into ~/.config/, backs up existing configs
```

After running, install packages manually:
```bash
paru -S - < packages.txt
```

## Architecture

### Config Deployment Model

`install.sh` symlinks `.config/{hypr,quickshell,kitty,waybar}` from the repo into `~/.config/`. So editing files here is editing live config.

### Hyprland Config (`~/.config/hypr/`)

Modular — `hyprland.conf` sources all other files:
- `monitor.conf` — display layout (1920x1080@60)
- `input.conf` — keyboard (us/ru), touchpad
- `binds.conf` — all keybindings
- `decoration.conf` — gaps, rounding, blur, shadows
- `animations.conf` — bezier curves, window/workspace animations
- `autostart.conf` — launches: swww, wal, quickshell, swaync, mpd-mpris, kdeconnect
- `windowrules.conf` / `layerrules.conf` — per-app rules

### Quickshell (`~/.config/quickshell/`)

QML shell. Root is `shell.qml` (646 lines) — holds all global state (panel visibility toggles, IPC). Components in `components/`:
- `Bar.qml` — top bar: workspaces, media, volume, battery, RAM, Wi-Fi, Bluetooth
- `Dashboard.qml` — right-side panel: CPU/RAM/disk, sliders, avatar picker
- `LauncherPanel.qml` — left-side panel: app launcher + wallpaper picker
- `MusicPanel.qml` — MPRIS music player
- `WifiPanel.qml` / `BluetoothPanel.qml` — network/BT via nmcli

**Color scheme:** Catppuccin Mocha, dynamically loaded from `~/.cache/wal/colors.json` (set by pywal on wallpaper change).

**State:** persisted in `~/.config/quickshell/state/`. Wallpaper thumbnails cached in `~/.cache/wallpaper-thumbs/`.

**Assets:** GIF animations and profile pictures live in `quickshell/assets/`.

### Key Integrations

| Tool | Purpose |
|------|---------|
| `swww` | Wallpaper daemon |
| `pywal` | Generates color scheme from wallpaper |
| `swaync` | Notification center |
| MPRIS | Music player control protocol |
| `wpctl` | Volume control (PipeWire) |
| `brightnessctl` | Brightness control |
| `hyprlock` / `hypridle` | Lock screen / idle management |

## Key Bindings (Super = Windows key)

| Binding | Action |
|---------|--------|
| `Super+Return` | Open terminal (kitty) |
| `Super+Q` | Kill window |
| `Super+R` | Toggle launcher panel |
| `Super+A` | Toggle dashboard |
| `Super+M` | Toggle music panel |
| `Super+W` | Toggle wallpaper selector |
| `Super+N` | Toggle notification center |
| `Super+L` | Lock screen |
| `Super+Space` | Switch keyboard layout (us/ru) |
| `Super+[1-5]` | Switch workspace |
| `Print` | Screenshot (area selection) |
