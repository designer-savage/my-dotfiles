hl.monitor({
    output = "eDP-1",
    mode = "2560x1600@120",
    position = "0x0",
    scale = 1.0,
})

-- 120 Гц — базовое состояние независимо от питания. Хук нужен только чтобы
-- reload не затирал ручное понижение до 60 Гц (SUPER+H): hz.sh знает про
-- override и переприменит выбранное значение.
hl.on("config.reloaded", function()
    hl.exec_cmd("~/.local/bin/hypr-monitor-hz.sh")
end)
