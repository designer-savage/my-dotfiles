#!/usr/bin/env bash
# Auto-switch to a known Wi-Fi network if its signal is significantly better.
# Requires all target networks to already be saved in NetworkManager.

THRESHOLD=15   # minimum signal advantage (%) to trigger a switch
INTERVAL=20    # seconds between scans

while true; do
    # Get current connection: SSID and signal
    current_line=$(nmcli -t -f IN-USE,SSID,SIGNAL dev wifi 2>/dev/null | grep '^\*')
    current_ssid=$(echo "$current_line" | cut -d: -f2)
    current_signal=$(echo "$current_line" | cut -d: -f3)

    # Only act when connected to something
    if [[ -n "$current_ssid" && -n "$current_signal" ]]; then
        # Scan visible networks, find known ones with better signal
        best_ssid=""
        best_signal=$current_signal

        while IFS=: read -r ssid signal _rest; do
            [[ -z "$ssid" || "$ssid" == "$current_ssid" ]] && continue

            # Check if this SSID has a saved profile in NetworkManager
            if nmcli -t -f NAME con show | grep -qxF "$ssid"; then
                if (( signal - best_signal >= THRESHOLD )); then
                    best_signal=$signal
                    best_ssid=$ssid
                fi
            fi
        done < <(nmcli -t -f SSID,SIGNAL dev wifi list --rescan yes 2>/dev/null)

        if [[ -n "$best_ssid" ]]; then
            logger -t wifi-autoswitch "Switching from '$current_ssid' (${current_signal}%) to '$best_ssid' (${best_signal}%)"
            nmcli con up "$best_ssid" >/dev/null 2>&1
        fi
    fi

    sleep "$INTERVAL"
done
