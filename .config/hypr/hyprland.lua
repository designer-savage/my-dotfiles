-- Hyprland 0.56+ entry point. Each required module owns one configuration area.

require("monitor")
require("autostart")
require("decoration")
require("animations")
require("input")
require("binds")
require("windowrules")
require("layerrules")
require("bar")

hl.env("XCURSOR_SIZE", "42")
hl.env("HYPRCURSOR_SIZE", "42")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")
hl.env("GDK_BACKEND", "wayland,x11")
hl.env("QT_QPA_PLATFORMTHEME", "xdgdesktopportal")

hl.config({
    xwayland = {
        force_zero_scaling = true,
    },

    general = {
        extend_border_grab_area = 10,
    },

})
