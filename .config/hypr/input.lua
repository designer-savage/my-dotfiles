hl.config({
    input = {
        kb_layout = "us,ru",
        kb_options = "grp:toggle",
        follow_mouse = 1,
        touchpad = {
            natural_scroll = true,
            -- This is the baseline for toolkits that take the compositor's
            -- axis delta as raw pixels: Qt, kitty, native Rust/Wayland
            -- clients. Toolkits that amplify the delta themselves (Chromium,
            -- GTK, Gecko) are scaled back down per-class in windowrules.lua.
            -- All of it is calibrated so every app scrolls at the same
            -- physical rate as Chrome — see the table there.
            scroll_factor = 1.2,
        },
    },

})

-- Three-finger workspace swipes are handled by libinput-gestures.
-- It dispatches one fixed workspace step per completed swipe, unlike
-- Hyprland's interactive workspace gesture, which reacts to swipe velocity.
