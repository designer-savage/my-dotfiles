hl.on("hyprland.start", function()
    hl.exec_cmd("xrdb -merge ~/.Xresources")
    hl.exec_cmd("~/.config/scripts/battery_notify.sh")
    hl.exec_cmd("~/.config/scripts/wifi-autoswitch.sh")

    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("wal -R -n")
    hl.exec_cmd("~/.local/bin/restore-wallpaper.sh")
    hl.exec_cmd("waybar")
    hl.exec_cmd("~/.local/bin/start-quickshell.sh")
    hl.exec_cmd("swaync")
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("systemctl --user start hyprland-session.target")
    hl.exec_cmd("mpd-mpris")
    -- libinput-gestures.service handles the three-finger fixed-step swipe.
    -- Do not register Hyprland's interactive workspace gesture as well.
    hl.exec_cmd("bash -c 'sleep 3 && nmcli networking connectivity check | grep -q full && kdeconnect-indicator'")
    hl.exec_cmd("hypridle")
    -- hypr-monitor-hz-watch.sh отсюда убран: он сбрасывал частоту на 60 Гц
    -- при отключении зарядки. Теперь 120 Гц держатся всегда, снизить можно
    -- только вручную через SUPER+H.
end)
