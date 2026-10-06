-- Обновление воркспейсов в waybar.
-- Кнопки воркспейсов — свои custom-модули (~/.config/waybar/scripts/ws.sh),
-- потому что нативный hyprland/workspaces не переключает по клику на Lua-конфиге.
-- Вместо опроса по таймеру дёргаем их сигналом на события Hyprland.
local function refresh_waybar()
    hl.exec_cmd("pkill -RTMIN+9 waybar")
end

hl.on("workspace.active", refresh_waybar)
hl.on("workspace.created", refresh_waybar)
hl.on("workspace.removed", refresh_waybar)
