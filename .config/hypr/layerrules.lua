hl.layer_rule({ match = { namespace = "waybar" }, blur = true })
hl.layer_rule({ match = { namespace = "waybar" }, ignore_alpha = 0 })

hl.layer_rule({ match = { namespace = "swaync-notification-window" }, blur = true })
-- 0.3 leaves headroom: the panel glass sits at 0.74, and anything above
-- the threshold still gets blurred if that alpha is ever lowered.
hl.layer_rule({ match = { namespace = "swaync-notification-window" }, ignore_alpha = 0.3 })

-- swaync uses a SECOND namespace for the control centre, and it was never
-- covered here — the panel spent its whole life unblurred. Its layer spans
-- the full screen (the blank window behind the panel), which is exactly why
-- ignore_alpha matters: the transparent part must stay untouched.
hl.layer_rule({ match = { namespace = "swaync-control-center" }, blur = true })
hl.layer_rule({ match = { namespace = "swaync-control-center" }, ignore_alpha = 0.3 })

hl.layer_rule({ match = { namespace = "quickshell" }, blur = true })
hl.layer_rule({ match = { namespace = "quickshell" }, ignore_alpha = 0 })

-- No animation for slurp's selection overlay so it cannot appear in screenshots.
hl.layer_rule({ match = { namespace = "selection" }, animation = "none" })

-- rofi (launcher + wallpaper picker): the panel itself is translucent, the
-- frosted-glass look comes from blurring the desktop behind it. ignore_alpha
-- keeps the rounded corners from being blurred into a rectangle.
hl.layer_rule({ match = { namespace = "rofi" }, blur = true })
hl.layer_rule({ match = { namespace = "rofi" }, ignore_alpha = 0.15 })
-- macOS-style appearance: scale up from 92% instead of sliding in.
hl.layer_rule({ match = { namespace = "rofi" }, animation = "popin 92%" })
