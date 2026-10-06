hl.config({
    animations = {
        enabled = true,
    },
})

hl.curve("bounce", { type = "bezier", points = { { 0.0, 1.25 }, { 0.15, 1.0 } } })
hl.curve("buttery", { type = "bezier", points = { { 0.1, 1.15 }, { 0.15, 1.02 } } })
hl.curve("smooth", { type = "bezier", points = { { 0.0, 0.0 }, { 0.12, 1.0 } } })
hl.curve("linear", { type = "bezier", points = { { 0.0, 0.0 }, { 1.0, 1.0 } } })
hl.curve("easeOutExpo", { type = "bezier", points = { { 0.16, 1 }, { 0.3, 1 } } })
hl.curve("easeOutCubic", { type = "bezier", points = { { 0.33, 1 }, { 0.68, 1 } } })

hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.5, bezier = "bounce", style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3.5, bezier = "smooth", style = "slide" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 4, bezier = "buttery", style = "slide" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 3.5, bezier = "smooth" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 3, bezier = "smooth" })
hl.animation({ leaf = "fadeDim", enabled = true, speed = 4, bezier = "smooth" })
hl.animation({ leaf = "fadeShadow", enabled = true, speed = 4, bezier = "smooth" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 4, bezier = "easeOutCubic", style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 6, bezier = "easeOutExpo", style = "slidefadevert -100%" })
hl.animation({ leaf = "border", enabled = true, speed = 7, bezier = "smooth" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "bounce", style = "slide" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 3, bezier = "smooth", style = "slide" })
