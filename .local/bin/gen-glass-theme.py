#!/usr/bin/env python3
"""Generate the shared "liquid glass" design tokens from the current pywal palette.

Outputs
  ~/.config/rofi/glass.rasi          tokens for every rofi theme
  ~/.config/waybar/glass.css         tokens for the bar
  ~/.config/swaync/glass.css         tokens for the notification centre
  ~/.cache/wal/glass.json            tokens for the quickshell panels
  ~/.cache/wal/glass-hyprlock.conf   accent + glass vars for hyprlock

The glass surfaces stay deliberately neutral (macOS reads the wallpaper through
the compositor blur, it does not paint the wallpaper's colour onto the panel).
Only the accent follows pywal, and it gets normalised so a muddy palette still
produces a lively selection colour.
"""
import colorsys
import json
import os
import sys

HOME = os.path.expanduser("~")
COLORS = os.path.join(HOME, ".cache/wal/colors.json")

# Neutral base of the glass, before the wallpaper tint is mixed in.
NEUTRAL = (0x16, 0x16, 0x1A)
TINT = 0.30          # how much of the wallpaper's own background bleeds in
GLASS_ALPHA = 0.58   # panel translucency; the compositor supplies the blur


def hex2rgb(h):
    h = h.lstrip("#")
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))


def rgb2hex(r, g, b):
    return "#%02X%02X%02X" % (round(r), round(g), round(b))


def rgba(hexcolor, alpha):
    """rofi/CSS #RRGGBBAA — rasi cannot do alpha maths on a variable."""
    return "%s%02X" % (hexcolor.upper(), round(max(0.0, min(1.0, alpha)) * 255))


def mix(a, b, t):
    return tuple(a[i] + (b[i] - a[i]) * t for i in range(3))


def normalise_accent(palette):
    """Pick the most chromatic pywal colour, then force it to a usable
    saturation and lightness so the accent always reads as an accent."""
    best, best_chroma = None, -1.0
    for key in ("color1", "color2", "color3", "color4", "color5", "color6",
                "color9", "color10", "color11", "color12", "color13", "color14"):
        if key not in palette:
            continue
        r, g, b = (c / 255 for c in hex2rgb(palette[key]))
        h, l, s = colorsys.rgb_to_hls(r, g, b)
        chroma = s * (1 - abs(2 * l - 1))
        if chroma > best_chroma:
            best_chroma, best = chroma, (h, l, s)
    if best is None:
        best = (0.58, 0.55, 0.9)  # macOS system blue as the fallback
    h, l, s = best
    s = max(s, 0.62)
    l = min(max(l, 0.56), 0.68)
    r, g, b = colorsys.hls_to_rgb(h, l, s)
    return rgb2hex(r * 255, g * 255, b * 255)


def _hls(hexcolor):
    r, g, b = (c / 255 for c in hex2rgb(hexcolor))
    return colorsys.rgb_to_hls(r, g, b)


def _chroma(l, s):
    return s * (1 - abs(2 * l - 1))


def _lightness_weight(l):
    """How usable a colour is as an accent on dark glass.

    Chroma alone is a bad selector: a deep saturated navy sky scores higher
    than the dusty rose of a sunset, even though the navy IS the background
    and the rose is what the picture reads as. Weighting by lightness fixes
    that — near-black and near-white are useless as accents no matter how
    saturated they measure.
    """
    if l < 0.14 or l > 0.92:
        return 0.0
    # peak around L 0.55, falling off both ways
    return max(0.0, 1.0 - abs(l - 0.55) / 0.45)


def salient_colour(wallpaper, palette):
    """The colour the wallpaper actually reads as.

    Sampled from the image rather than picked out of pywal's palette: area
    matters. A hue covering a visible part of the picture beats one that only
    survives as a palette slot. Falls back to the palette if the file is gone.
    """
    try:
        from PIL import Image
    except ImportError:
        return palette_colour(palette)
    try:
        im = Image.open(wallpaper).convert("RGB").resize((160, 100))
    except Exception:
        return palette_colour(palette)

    quant = im.quantize(colors=24, method=Image.Quantize.FASTOCTREE).convert("RGB")
    total = 160 * 100
    best, best_score = None, 0.0
    for count, rgb in quant.getcolors(total) or []:
        h, l, s = colorsys.rgb_to_hls(*(c / 255 for c in rgb))
        # sqrt on area: presence should count, but a huge flat background
        # must not simply outvote everything colourful.
        score = (count / total) ** 0.5 * _chroma(l, s) * _lightness_weight(l)
        if score > best_score:
            best_score, best = score, (h, l, s)
    if best is None:
        return palette_colour(palette)
    return best


def palette_colour(palette):
    best, best_score = None, 0.0
    for key in ("color1", "color2", "color3", "color4", "color5", "color6",
                "color7", "color9", "color10", "color11", "color12", "color13",
                "color14"):
        if key not in palette:
            continue
        h, l, s = _hls(palette[key])
        score = _chroma(l, s) * _lightness_weight(l)
        if score > best_score:
            best_score, best = score, (h, l, s)
    return best or (0.58, 0.60, 0.70)


def make_accent(hls):
    """Lift a colour just enough to read on dark glass — no further.

    The old version forced every accent to S >= 0.62 and L in [0.56, 0.68],
    which manufactured colours that were nowhere in the wallpaper: a deep
    navy came out a vivid sky blue. Hue is never touched, saturation is only
    raised if the colour is close to grey, and lightness only up to the
    minimum that stays legible.
    """
    h, l, s = hls
    s = max(s, 0.32)          # keep muted palettes muted, just not grey
    s = min(s, 0.80)          # and never push into neon
    l = min(max(l, 0.56), 0.74)
    r, g, b = colorsys.hls_to_rgb(h, l, s)
    return rgb2hex(r * 255, g * 255, b * 255)


def second_hue(palette, accent_hex, min_sep=40):
    """A real second hue from the palette, or nothing.

    Previously this rotated the accent by a fixed 42 degrees, which invents a
    colour the wallpaper never contained. If the palette has no genuinely
    different hue with usable chroma, the accent is reused — one honest
    colour beats two, one of which is fictional.
    """
    ah = _hls(accent_hex)[0] * 360
    best, best_score = None, 0.0
    for key in ("color1", "color2", "color3", "color4", "color5", "color6",
                "color7", "color9", "color10", "color11", "color12", "color13",
                "color14"):
        if key not in palette:
            continue
        h, l, s = _hls(palette[key])
        deg = h * 360
        dist = min(abs(deg - ah), 360 - abs(deg - ah))
        if dist < min_sep:
            continue
        score = _chroma(l, s) * _lightness_weight(l)
        if score > best_score:
            best_score, best = score, (h, l, s)
    return make_accent(best) if best else accent_hex


def warning_colour(palette, accent_hex):
    """A red for the one state that must be unmistakable.

    Nearest-hue-to-red over the palette, but without the old Apple fallback:
    #FF453A on a navy wallpaper was a foreign object. When the palette has no
    warm hue at all, the accent's own hue is pushed toward red only as far as
    it takes to separate it from the accent.
    """
    best, best_dist = None, 361.0
    for key in ("color1", "color2", "color3", "color4", "color5", "color6",
                "color9", "color10", "color11", "color12", "color13", "color14"):
        if key not in palette:
            continue
        h, l, s = _hls(palette[key])
        if s < 0.12:
            continue
        deg = h * 360
        dist = min(abs(deg - 5), 360 - abs(deg - 5))
        if dist < best_dist:
            best_dist, best = dist, (h, l, s)
    if best is not None and best_dist <= 55:
        h, l, s = best
        return make_accent((h, l, max(s, 0.45)))
    return make_accent((5 / 360.0, 0.60, 0.58))


def main():
    try:
        data = json.load(open(COLORS))
    except (OSError, ValueError) as exc:
        print("gen-glass-theme: %s" % exc, file=sys.stderr)
        return 1

    wal_bg = hex2rgb(data["special"]["background"])
    accent = make_accent(salient_colour(data.get("wallpaper", ""), data["colors"]))
    glass_rgb = mix(NEUTRAL, wal_bg, TINT)
    glass = rgb2hex(*glass_rgb)
    # One step darker for the surface the search field sits on.
    deep = rgb2hex(*mix(glass_rgb, (0, 0, 0), 0.35))

    rasi = """/* Generated by gen-glass-theme.py — do not edit, edit the generator. */
* {{
    /* ── Materials ───────────────────────────────────────────────
       The panel is translucent; the blur comes from Hyprland's
       `layer_rule({{ namespace = "rofi" }}, blur)`. Alpha here only
       controls how much of the blurred wallpaper reads through.    */
    glass:          {glass_a};
    glass-deep:     {deep_a};
    glass-well:     #FFFFFF12;
    glass-raised:   #FFFFFF0F;

    /* ── Edges ─────────────────────────────────────────────────── */
    hairline:       #FFFFFF26;
    divider:        #FFFFFF14;

    /* ── Text (Apple's dark-mode label ramp) ───────────────────── */
    text:           #F5F5F7;
    text-secondary: #EBEBF599;
    text-tertiary:  #EBEBF54D;

    /* ── Accent, normalised from the wallpaper ─────────────────── */
    accent:         {accent};
    accent-soft:    {accent_soft};
    accent-fill:    {accent_fill};
    accent-line:    {accent_line};
    accent-glow:    {accent_glow};

    background-color: transparent;
    text-color:       @text;
}}

/* rofi's `highlight` property only accepts a literal colour, never a
   variable — so the fuzzy-match emphasis is baked in here. */
element-text {{
    highlight: bold #F5F5F7;
}}
""".format(
        glass_a=rgba(glass, GLASS_ALPHA),
        deep_a=rgba(deep, 0.55),
        accent=accent,
        accent_soft=rgba(accent, 0.20),
        accent_fill=rgba(accent, 0.32),
        accent_line=rgba(accent, 0.55),
        accent_glow=rgba(accent, 0.10),
    )

    rofi_dir = os.path.join(HOME, ".config/rofi")
    os.makedirs(rofi_dir, exist_ok=True)
    with open(os.path.join(rofi_dir, "glass.rasi"), "w") as fh:
        fh.write(rasi)

    # ── waybar ──────────────────────────────────────────────────────────
    # Same material and accent as the rofi panels, in GTK3 CSS. The static
    # half (label ramp, system reds/greens) is Apple's dark-mode semantic
    # set; only the accent and the glass tint follow the wallpaper.
    ar_, ag_, ab_ = hex2rgb(accent)
    gr_, gg_, gb_ = (round(c) for c in glass_rgb)
    accent_alt = second_hue(data["colors"], accent)
    # Only one semantic colour survives: a critical battery has to be
    # unmistakable. Charging and warning are expressed by brightness in the
    # label ramp instead, so the bar never grows a second and third hue that
    # the wallpaper does not contain.
    themed_red = warning_colour(data["colors"], accent)
    themed_yellow = themed_red
    themed_green = accent

    waybar_css = """/* Generated by gen-glass-theme.py — do not edit, edit the generator. */

/* Material — the blur itself comes from Hyprland's layer_rule on waybar */
@define-color bar-glass       rgba({gr}, {gg}, {gb}, {ga});
@define-color hairline        rgba(255, 255, 255, 0.15);
@define-color hover           rgba(255, 255, 255, 0.12);

/* Island surfaces — the raised groups the modules sit in */
@define-color island          rgba(255, 255, 255, 0.07);
@define-color island-line     rgba(255, 255, 255, 0.11);
@define-color divider         rgba(255, 255, 255, 0.13);

/* Text — Apple's dark-mode label ramp */
@define-color label           #F5F5F7;
@define-color label-secondary rgba(235, 235, 245, 0.62);
@define-color label-tertiary  rgba(235, 235, 245, 0.32);

/* Themed from the wallpaper, normalised so they always read on the glass */
@define-color accent          {accent};
@define-color accent-alt      {accent_alt};

/* Semantics: the palette's own nearest hue, or Apple's system colour when the
   palette has nothing close enough to carry the meaning. */
@define-color sys-red         {red};
@define-color sys-yellow      {yellow};
@define-color sys-green       {green};
""".format(gr=gr_, gg=gg_, gb=gb_, ga=GLASS_ALPHA, accent=accent,
           accent_alt=accent_alt, red=themed_red, yellow=themed_yellow,
           green=themed_green)

    waybar_dir = os.path.join(HOME, ".config/waybar")
    if os.path.isdir(waybar_dir):
        with open(os.path.join(waybar_dir, "glass.css"), "w") as fh:
            fh.write(waybar_css)

    # ── swaync ──────────────────────────────────────────────────────────
    swaync_css = """/* Generated by gen-glass-theme.py — do not edit, edit the generator. */
@define-color glass           rgba({gr}, {gg}, {gb}, 0.74);
@define-color glass-raised    rgba(255, 255, 255, 0.07);
@define-color hairline        rgba(255, 255, 255, 0.15);
@define-color island-line     rgba(255, 255, 255, 0.11);
@define-color divider         rgba(255, 255, 255, 0.10);
@define-color hover           rgba(255, 255, 255, 0.12);

@define-color label           #F5F5F7;
@define-color label-secondary rgba(235, 235, 245, 0.62);
@define-color label-tertiary  rgba(235, 235, 245, 0.32);

@define-color accent          {accent};
@define-color accent-alt      {accent_alt};
@define-color sys-red         {red};
@define-color sys-yellow      {yellow};
@define-color sys-green       {green};
""".format(gr=gr_, gg=gg_, gb=gb_, accent=accent, accent_alt=accent_alt,
           red=themed_red, yellow=themed_yellow, green=themed_green)

    swaync_dir = os.path.join(HOME, ".config/swaync")
    if os.path.isdir(swaync_dir):
        with open(os.path.join(swaync_dir, "glass.css"), "w") as fh:
            fh.write(swaync_css)

    # ── quickshell ──────────────────────────────────────────────────────
    # QML reads this instead of colors.json directly, so the panels use the
    # same normalised accent as every other surface.
    glass_json = {
        "glass": glass,
        "glassAlpha": 0.60,
        "label": "#F5F5F7",
        "labelTint": "#EBEBF5",
        "accent": accent,
        "accentAlt": accent_alt,
        "red": themed_red,
        "yellow": themed_yellow,
        "green": themed_green,
    }
    with open(os.path.join(HOME, ".cache/wal/glass.json"), "w") as fh:
        json.dump(glass_json, fh, indent=2)

    ar, ag, ab = hex2rgb(accent)
    gr, gg, gb = (round(c) for c in glass_rgb)
    hypr = (
        "# Generated by gen-glass-theme.py — do not edit.\n"
        "$accent = rgb({ar:02x}{ag:02x}{ab:02x})\n"
        "$accent_soft = rgba({ar:02x}{ag:02x}{ab:02x}59)\n"
        "$glass = rgba({gr:02x}{gg:02x}{gb:02x}99)\n"
        "$glass_line = rgba(ffffff26)\n"
        "$label = rgb(f5f5f7)\n"
        "$label_secondary = rgba(ebebf5b3)\n"
    ).format(ar=ar, ag=ag, ab=ab, gr=gr, gg=gg, gb=gb)
    with open(os.path.join(HOME, ".cache/wal/glass-hyprlock.conf"), "w") as fh:
        fh.write(hypr)
    return 0


if __name__ == "__main__":
    sys.exit(main())
