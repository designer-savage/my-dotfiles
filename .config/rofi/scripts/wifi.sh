#!/bin/bash
# Wi-Fi manager via nmcli + rofi

THEME="$HOME/.config/rofi/themes/launcher.rasi"
WIFI_ON=$(nmcli radio wifi)

# ─── Build menu ────────────────────────────────────────────────────────────
entries=""

# Toggle header
if [ "$WIFI_ON" = "enabled" ]; then
    entries+="󰤭  Выключить Wi-Fi\n"
else
    entries+="󰤨  Включить Wi-Fi\n"
    selected=$(printf "%b" "$entries" | rofi -dmenu -i -p "󰤨 Wi-Fi" \
        -theme "$THEME" -no-custom)
    [ "$selected" = "󰤨  Включить Wi-Fi" ] && nmcli radio wifi on
    exit 0
fi

# Separator
entries+="────────────────────────\n"

# Connected SSID
CONNECTED=$(nmcli -t -f active,ssid dev wifi 2>/dev/null | grep '^yes:' | cut -d: -f2)
[ -n "$CONNECTED" ] && entries+="󰤨  $CONNECTED  ✓ подключено\n────────────────────────\n"

# Scan and list networks (deduplicate by SSID, sort by signal)
while IFS=: read -r ssid security signal; do
    [ -z "$ssid" ] && continue
    [ "$ssid" = "$CONNECTED" ] && continue

    icon="󰤟"
    [ "$signal" -ge 25 ] 2>/dev/null && icon="󰤢"
    [ "$signal" -ge 50 ] 2>/dev/null && icon="󰤥"
    [ "$signal" -ge 75 ] 2>/dev/null && icon="󰤨"

    lock=""
    [ "$security" != "--" ] && [ -n "$security" ] && lock="  󰌾"

    entries+="$icon  $ssid$lock  [${signal}%]\n"
done < <(nmcli -t -f ssid,security,signal dev wifi list 2>/dev/null \
    | sort -t: -k3 -rn \
    | awk -F: '!seen[$1]++ && $1 != ""')

# ─── Show rofi ─────────────────────────────────────────────────────────────
selected=$(printf "%b" "$entries" | rofi -dmenu -i \
    -p "󰤨 Wi-Fi" \
    -theme "$THEME" \
    -no-custom)

[ -z "$selected" ] && exit 0

case "$selected" in
    "󰤭  Выключить Wi-Fi")
        nmcli radio wifi off
        ;;
    "󰤨  Включить Wi-Fi")
        nmcli radio wifi on
        ;;
    *"✓ подключено"*)
        # Disconnect
        nmcli dev disconnect "$(nmcli -t -f device,type dev | grep ':wifi' | cut -d: -f1 | head -1)"
        ;;
    "────────────────────────")
        ;;
    *)
        # Extract SSID from "icon  SSID  [signal%]" or "icon  SSID 󰌾  [signal%]"
        ssid=$(echo "$selected" \
            | sed 's/^[^ ]*  //' \
            | sed 's/  󰌾.*//' \
            | sed 's/  \[.*//' \
            | xargs)

        if nmcli connection show "$ssid" &>/dev/null; then
            nmcli connection up "$ssid" &
        else
            password=$(rofi -dmenu \
                -p "󰌾 Пароль для $ssid" \
                -theme "$THEME" \
                -password \
                -l 0)
            [ -n "$password" ] && nmcli dev wifi connect "$ssid" password "$password" &
        fi
        ;;
esac
