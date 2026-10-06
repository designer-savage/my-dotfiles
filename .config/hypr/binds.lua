local mod = "SUPER"

hl.bind("SUPER + SPACE", hl.dsp.exec_cmd("hyprctl switchxkblayout at-translated-set-2-keyboard next; pkill -RTMIN+8 waybar"))

hl.bind(mod .. " + Return", hl.dsp.exec_cmd("kitty"))
hl.bind(mod .. " + SHIFT + Return", hl.dsp.exec_cmd("kitty", { float = true, size = { 1050, 700 } }))
hl.bind(mod .. " + R", hl.dsp.exec_cmd("~/.config/rofi/scripts/launcher.sh"))
hl.bind(mod .. " + E", hl.dsp.exec_cmd("thunar"))
hl.bind(mod .. " + Q", hl.dsp.window.close())
hl.bind(mod .. " + C", hl.dsp.window.float({ action = "toggle" }))

-- Режим "поверх всех столов": pin держит парящее окно на каждом воркспейсе.
-- Плиточное окно сначала становится парящим 16:9 в правом нижнем углу
-- (как картинка-в-картинке); уже парящее остаётся где было. Повторное
-- нажатие снимает pin и возвращает в плитку только то, что мы сами подняли.
local pip_floated_by_us = {}

hl.bind(mod .. " + SHIFT + C", function()
    local win = hl.get_active_window()
    if not win then return end

    if win.pinned then
        hl.dispatch(hl.dsp.window.pin({ action = "disable" }))
        if pip_floated_by_us[win.stable_id] then
            hl.dispatch(hl.dsp.window.float({ action = "disable" }))
            pip_floated_by_us[win.stable_id] = nil
        end
        return
    end

    if not win.floating then
        local mon = hl.get_active_monitor()
        local mw, mh = mon.width / mon.scale, mon.height / mon.scale
        local w = math.floor(mw * 0.3)
        local h = math.floor(w * 9 / 16)
        local margin = 20
        hl.dispatch(hl.dsp.window.float({ action = "enable" }))
        hl.dispatch(hl.dsp.window.resize({ x = w, y = h }))
        hl.dispatch(hl.dsp.window.move({ x = mon.x + mw - w - margin, y = mon.y + mh - h - margin }))
        pip_floated_by_us[win.stable_id] = true
    end
    hl.dispatch(hl.dsp.window.pin({ action = "enable" }))
end)
hl.bind(mod .. " + W", hl.dsp.exec_cmd("~/.config/rofi/scripts/wallpaper-picker.sh"))
hl.bind(mod .. " + SHIFT + W", hl.dsp.exec_cmd("~/.local/bin/random-wallpaper.sh"))
hl.bind(mod .. " + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mod .. " + G", hl.dsp.exec_cmd("claude-desktop"))
hl.bind(mod .. " + B", hl.dsp.exec_cmd("google-chrome-stable"))

hl.bind(mod .. " + Left", hl.dsp.focus({ direction = "l" }))
hl.bind(mod .. " + Down", hl.dsp.focus({ direction = "d" }))
hl.bind(mod .. " + Up", hl.dsp.focus({ direction = "u" }))
hl.bind(mod .. " + Right", hl.dsp.focus({ direction = "r" }))

hl.bind(mod .. " + SHIFT + Left", hl.dsp.window.move({ direction = "l" }))
hl.bind(mod .. " + SHIFT + Down", hl.dsp.window.move({ direction = "d" }))
hl.bind(mod .. " + SHIFT + Up", hl.dsp.window.move({ direction = "u" }))
hl.bind(mod .. " + SHIFT + Right", hl.dsp.window.move({ direction = "r" }))

hl.bind(mod .. " + CTRL + Left", hl.dsp.window.resize({ x = -20, y = 0, relative = true }), { repeating = true })
hl.bind(mod .. " + CTRL + Right", hl.dsp.window.resize({ x = 20, y = 0, relative = true }), { repeating = true })
hl.bind(mod .. " + CTRL + Up", hl.dsp.window.resize({ x = 0, y = -20, relative = true }), { repeating = true })
hl.bind(mod .. " + CTRL + Down", hl.dsp.window.resize({ x = 0, y = 20, relative = true }), { repeating = true })

hl.bind(mod .. " + Tab", hl.dsp.window.cycle_next())
hl.bind(mod .. " + SHIFT + Tab", hl.dsp.window.cycle_next({ next = false }))

for workspace = 1, 9 do
    hl.bind(mod .. " + " .. workspace, hl.dsp.focus({ workspace = workspace }))
    hl.bind(mod .. " + SHIFT + " .. workspace, hl.dsp.window.move({ workspace = workspace }))
end

-- Десятый воркспейс висит на нуле: "SUPER + 10" клавиши не существует.
hl.bind(mod .. " + 0", hl.dsp.focus({ workspace = 10 }))
hl.bind(mod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))

hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Keep the legacy unnamed special workspace, using Lua dispatchers directly.
hl.bind(mod .. " + S", hl.dsp.workspace.toggle_special(""))
hl.bind(mod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special" }))

hl.bind(mod .. " + P", hl.dsp.window.pseudo())
hl.bind(mod .. " + J", hl.dsp.layout("togglesplit"))

hl.bind("SUPER + SHIFT + N", hl.dsp.exec_cmd("swaync-client -C"))
hl.bind(mod .. " + N", hl.dsp.exec_cmd("~/.config/scripts/nightlight.sh"))
hl.bind(mod .. " + I", hl.dsp.exec_cmd("~/.config/scripts/caffeine.sh"))
hl.bind(mod .. " + H", hl.dsp.exec_cmd("~/.local/bin/hypr-monitor-hz.sh --toggle"))

hl.bind("Print", hl.dsp.exec_cmd("~/.config/scripts/screenshot.sh area"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("~/.config/scripts/screenshot.sh full"))
hl.bind("Sys_Req", hl.dsp.exec_cmd("~/.config/scripts/screenshot.sh full"))
hl.bind(mod .. " + M", hl.dsp.exec_cmd("~/.config/scripts/screenshot.sh full"))
hl.bind("SUPER + SHIFT + Delete", hl.dsp.exec_cmd("~/.config/scripts/clear-screenshots.sh"))

hl.bind("Menu", hl.dsp.exec_cmd("~/.config/scripts/define.sh"))
hl.bind(mod .. " + SHIFT + R", hl.dsp.exec_cmd("killall -SIGINT gpu-screen-recorder && notify-send 'Recording Stopped'"))

hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("ALT + mouse:272", hl.dsp.window.resize(), { mouse = true })

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%-"))
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"))
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 5%+"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"))
