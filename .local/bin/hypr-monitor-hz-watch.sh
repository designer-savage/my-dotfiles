#!/usr/bin/bash
# Wait for Hyprland socket to appear
until ls /run/user/1000/hypr/ 2>/dev/null | grep -q .; do sleep 1; done

apply_hz() {
    HYPRLAND_INSTANCE_SIGNATURE=$(ls /run/user/1000/hypr/ | head -1)
    export HYPRLAND_INSTANCE_SIGNATURE
    AC=$(cat /sys/class/power_supply/ACAD/online 2>/dev/null)
    if [ "$AC" = "1" ]; then
        hyprctl keyword monitor eDP-1,2560x1600@120,0x0,1.0
    else
        hyprctl keyword monitor eDP-1,2560x1600@60,0x0,1.0
    fi
}

# Apply on start
apply_hz

# Watch for AC changes
udevadm monitor --udev --subsystem-match=power_supply 2>/dev/null | while read -r line; do
    if echo "$line" | grep -q "ACAD"; then
        sleep 0.5
        apply_hz
    fi
done
