hl.config({
    general = {
        gaps_in = 3,
        -- Одинаковый отступ со всех четырёх сторон. Верхний раньше был 0,
        -- из-за чего окна упирались прямо в waybar; теперь бар отделён такой
        -- же щелью, как и края экрана. Отсчитывается от занятой баром зоны,
        -- а не от края монитора.
        gaps_out = 5,
        border_size = 1,
        col = {
            active_border = "rgb(585b70)",
            inactive_border = "rgb(2a2b36)",
        },
        layout = "dwindle",
    },

    decoration = {
        rounding = 16,
        active_opacity = 1.0,
        inactive_opacity = 0.9,
        dim_inactive = false,
        dim_strength = 0.04,

        shadow = {
            enabled = true,
            range = 35,
            render_power = 4,
            color = "rgba(00000050)",
            offset = { 0, 8 },
        },

        blur = {
            enabled = true,
            size = 6,
            passes = 2,
            noise = 0.006,
            brightness = 1.03,
            contrast = 1.02,
            vibrancy = 0.25,
            vibrancy_darkness = 0.6,
            new_optimizations = true,
            xray = false,
            popups = true,
            special = true,
        },
    },
})
