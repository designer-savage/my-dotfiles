hl.window_rule({ match = { class = "Lorien" }, opacity = "0.8 1" })
hl.window_rule({ match = { class = "sublime_text" }, opacity = "0.88 1" })
hl.window_rule({ match = { class = "thunar" }, opacity = "0.9 1" })
hl.window_rule({ match = { class = "Thunar" }, opacity = "0.9 1" })
hl.window_rule({ match = { class = "org.pwmt.zathura" }, opacity = "0.9 1" })
hl.window_rule({ match = { class = "firefox" }, opacity = "1.0 1.0" })

hl.window_rule({ match = { class = "mpv" }, float = true })
hl.window_rule({ match = { class = "mpv" }, size = { 640, 360 } })
hl.window_rule({ match = { class = "mpv" }, center = true })
hl.window_rule({ match = { class = "mpv" }, opacity = "1.0 1.0" })

hl.window_rule({ match = { float = true }, center = true })

hl.window_rule({ match = { class = "scratchterm" }, float = true })
hl.window_rule({ match = { class = "scratchterm" }, size = { "85%", "70%" } })
hl.window_rule({ match = { class = "scratchterm" }, center = true })

-- ─── Per-window touchpad scroll ────────────────────────────────────────────
-- Toolkits do not agree on what one unit of the compositor's axis delta is
-- worth, so the same scroll_factor scrolls a wildly different distance
-- depending on what drew the window. The conversions, read off each toolkit's
-- own Wayland input code:
--
--   Qt      delta += wl_fixed_to_double(value)            ->    1.0 px/unit
--   kitty   y_offset * touch_scroll_multiplier (1.0)      ->    1.0 px/unit
--   Gecko   (value/10) * apz.gtk.pangesture
--                        .pixel_delta_mode_multiplier(40) ->    4.0 px/unit
--   Chromium (value/10) * MouseWheelEvent::kWheelDelta(120) ->  12.0 px/unit
--   GTK3    (value/10) * min(page_size^(2/3), page_size/2) -> ~12.5 px/unit
--
-- Chrome is the reference: at factor 0.1 it moves 12 * 0.1 = 1.2 px per unit.
-- Every factor below is that target divided by the toolkit's own rate, so all
-- of them land on the same physical scroll distance per finger travel.
--
--   Qt / kitty / native   1.2    <- input.lua global, no rule needed
--   Gecko                 0.3
--   Chromium              0.1
--   GTK3                  0.096  (rounded to 0.1; it varies with viewport)
--
-- These REPLACE the global factor, they do not multiply with it
-- (InputManager.cpp: factor = PWINDOW->getScrollTouchpad()).
-- To find a window's class: hyprctl clients | grep class
local CHROMIUM = 0.1
local GTK      = 0.096
local GECKO    = 0.3

local scroll_touchpad = {
    -- Chromium / Electron — one engine, one number
    ["google-chrome"]        = CHROMIUM,
    ["com.anthropic.Claude"] = CHROMIUM,
    ["vesktop"]              = CHROMIUM,
    ["code"]                 = CHROMIUM,
    ["Code"]                 = CHROMIUM,
    ["obsidian"]             = CHROMIUM,
    ["md.obsidian.Obsidian"] = CHROMIUM,

    -- Gecko
    ["zen"]                  = GECKO,
    ["zen-alpha"]            = GECKO,
    ["zen-browser"]          = GECKO,
    ["firefox"]              = GECKO,

    -- GTK3
    ["thunar"]               = GTK,
    ["Thunar"]               = GTK,
    ["org.pwmt.zathura"]     = GTK,
    ["libreoffice-writer"]   = GTK,
    ["libreoffice-calc"]     = GTK,
    ["libreoffice-impress"]  = GTK,
    ["libreoffice-draw"]     = GTK,
    ["libreoffice-startcenter"] = GTK,
    ["soffice"]              = GTK,
}

-- Qt (Telegram, SASM, AmneziaVPN), kitty and Spotifast take the delta as raw
-- pixels, so they are already correct on the global factor and get no rule.
-- Spotifast is native Rust: /proc/<pid>/maps shows smithay-client-toolkit.

for cls, factor in pairs(scroll_touchpad) do
    hl.window_rule({ match = { class = cls }, scroll_touchpad = factor })
end
