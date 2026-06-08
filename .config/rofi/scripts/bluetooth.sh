#!/bin/bash
# Bluetooth manager via bluetoothctl + rofi

THEME="$HOME/.config/rofi/themes/launcher.rasi"
BT_POWERED=$(bluetoothctl show 2>/dev/null | grep "Powered:" | awk '{print $2}')

# ─── Build menu ────────────────────────────────────────────────────────────
entries=""

if [ "$BT_POWERED" = "yes" ]; then
    entries+="󰂲  Выключить Bluetooth\n"
else
    entries+="󰂯  Включить Bluetooth\n"
    selected=$(printf "%b" "$entries" | rofi -dmenu -i -p "󰂯 Bluetooth" \
        -theme "$THEME" -no-custom)
    [ "$selected" = "󰂯  Включить Bluetooth" ] && bluetoothctl power on
    exit 0
fi

entries+="────────────────────────\n"

# Paired devices with connection status
declare -A mac_map
while IFS=' ' read -r _ mac name_rest; do
    [ -z "$mac" ] && continue
    name="$name_rest"
    connected=$(bluetoothctl info "$mac" 2>/dev/null | grep "Connected:" | awk '{print $2}')
    if [ "$connected" = "yes" ]; then
        label="󰂱  $name  ✓ подключено"
    else
        label="󰂯  $name"
    fi
    entries+="$label\n"
    mac_map["$label"]="$mac"
done < <(bluetoothctl devices Paired 2>/dev/null)

entries+="────────────────────────\n"
entries+="󰐷  Сканировать устройства\n"

# ─── Show rofi ─────────────────────────────────────────────────────────────
selected=$(printf "%b" "$entries" | rofi -dmenu -i \
    -p "󰂱 Bluetooth" \
    -theme "$THEME" \
    -no-custom)

[ -z "$selected" ] && exit 0

# Find MAC for selected entry
mac="${mac_map[$selected]}"

case "$selected" in
    "󰂲  Выключить Bluetooth")
        bluetoothctl power off
        ;;
    "󰂯  Включить Bluetooth")
        bluetoothctl power on
        ;;
    "󰐷  Сканировать устройства")
        notify-send "Bluetooth" "Сканирование 10 секунд..." -t 3000
        bluetoothctl scan on &
        SCAN_PID=$!
        sleep 10
        kill $SCAN_PID 2>/dev/null
        bluetoothctl scan off
        # Rerun script to show new devices
        exec "$0"
        ;;
    "────────────────────────")
        ;;
    *"✓ подключено"*)
        [ -n "$mac" ] && bluetoothctl disconnect "$mac" &
        ;;
    *)
        if [ -n "$mac" ]; then
            notify-send "Bluetooth" "Подключение..." -t 2000
            bluetoothctl connect "$mac" &
        fi
        ;;
esac
