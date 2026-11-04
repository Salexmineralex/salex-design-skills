#!/usr/bin/env python3
"""Check WCAG 2.2 contrast between color pairs.

Usage:
  python3 contrast.py "#1a1a1a" "#f5f0e8"              # one pair: text, background
  python3 contrast.py "#1a1a1a:#f5f0e8" "#fff:#c0392b"  # several text:background pairs

Colors can be #rgb, #rrggbb, #rrggbbaa or rgba(r, g, b, a). A see-through text
color is blended over its background. A see-through background needs the solid
color under it, after an @:
  python3 contrast.py "rgba(255,255,255,.6):rgba(255,255,255,.15)@#2575fc"
  python3 contrast.py "#fff:rgba(255,255,255,.2)@rgba(255,255,255,.15)@#2575fc"   # stacked layers

Prints the ratio and whether it passes for normal text (4.5:1), large text and
UI parts like borders, icons and focus rings (3:1), and AAA normal text (7:1).
Exits with 1 if any pair fails 3:1, the lowest bar any pair should clear.
"""
import re
import sys


def parse(value):
    """Return (r, g, b, alpha), each from 0 to 1."""
    v = value.strip()
    m = re.fullmatch(r"rgba?\(\s*([\d.]+)\s*,\s*([\d.]+)\s*,\s*([\d.]+)\s*(?:,\s*([\d.]+%?)\s*)?\)", v)
    if m:
        r, g, b = (float(x) / 255 for x in m.group(1, 2, 3))
        a = m.group(4) or "1"
        a = float(a[:-1]) / 100 if a.endswith("%") else float(a)
        return r, g, b, a
    h = v.lstrip("#")
    if len(h) in (3, 4):
        h = "".join(c * 2 for c in h)
    if len(h) not in (6, 8) or not re.fullmatch(r"[0-9a-fA-F]+", h):
        raise ValueError("not a color: %s" % value)
    r, g, b = (int(h[i:i + 2], 16) / 255 for i in (0, 2, 4))
    a = int(h[6:8], 16) / 255 if len(h) == 8 else 1.0
    return r, g, b, a


def over(top, base):
    """Blend a possibly see-through color over a solid one."""
    r, g, b, a = top
    return tuple(a * c + (1 - a) * u for c, u in zip((r, g, b), base[:3])) + (1.0,)


def solid_background(value):
    if "@" in value:
        # Layers from top to bottom, e.g. button@card@page; the last one must be solid.
        layers = value.split("@")
        result = parse(layers[-1])
        if result[3] < 1:
            raise ValueError("the last color after @ must be solid: %s" % value)
        for layer in reversed(layers[:-1]):
            result = over(parse(layer), result)
        return result
    bg = parse(value)
    if bg[3] < 1:
        raise ValueError("see-through background %s: add the solid color under it, like %s@#ffffff" % (value, value))
    return bg


def luminance(rgb):
    def channel(c):
        return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4
    r, g, b = (channel(c) for c in rgb[:3])
    return 0.2126 * r + 0.7152 * g + 0.0722 * b


def ratio(fg, bg):
    back = solid_background(bg)
    front = over(parse(fg), back)
    a, b = luminance(front), luminance(back)
    return (max(a, b) + 0.05) / (min(a, b) + 0.05)


def split_pair(arg):
    # Split on the colon that separates the two colors, not one inside rgba(...).
    depth = 0
    for i, c in enumerate(arg):
        depth += c == "("
        depth -= c == ")"
        if c == ":" and depth == 0:
            return arg[:i], arg[i + 1:]
    return None


def main(args):
    if not args:
        print(__doc__)
        return 2
    if len(args) == 2 and split_pair(args[0]) is None:
        pairs = [(args[0], args[1])]
    else:
        pairs = []
        for arg in args:
            pair = split_pair(arg)
            if pair is None:
                print("expected text:background, got %s" % arg)
                return 2
            pairs.append(pair)

    failed = False
    for fg, bg in pairs:
        try:
            r = ratio(fg, bg)
        except ValueError as e:
            print(e)
            return 2
        mark = lambda ok: "pass" if ok else "FAIL"
        print("%s on %s  %5.2f:1  text %s  large/UI %s  AAA %s" % (
            fg, bg, r, mark(r >= 4.5), mark(r >= 3), mark(r >= 7)))
        failed = failed or r < 3
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
