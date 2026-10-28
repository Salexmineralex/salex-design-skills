#!/usr/bin/env python3
"""Roll random style traits for the wildcard direction.

Language models are bad at picking at random: left alone they reach for the
same safe choices every time. This picks one value per axis with real
randomness, so the wildcard direction starts somewhere unexpected.

Usage:
  python3 roll.py                 # one trait per axis
  python3 roll.py --seed 42       # repeatable roll
  python3 roll.py --only era,material
"""
import argparse
import random

AXES = {
    "era": [
        "1920s Art Deco", "1930s streamline", "1950s atomic age", "1960s Swiss modernism",
        "1960s psychedelia", "1970s earth tones", "1980s Memphis", "1980s arcade",
        "1990s early web", "1990s rave flyers", "Y2K chrome", "Victorian print",
        "Bauhaus", "Soviet constructivism", "medieval manuscript", "far future",
    ],
    "material": [
        "risograph paper", "raw concrete", "oiled wood", "brushed aluminium", "felt",
        "frosted glass", "corrugated cardboard", "chrome", "glazed ceramic", "neon tube",
        "chalkboard", "linen", "rubber", "terrazzo", "tracing paper", "enamel pins",
    ],
    "place": [
        "Tokyo train station signage", "Mexican loteria cards", "Scandinavian kitchen",
        "Brazilian modernism", "Moroccan tiles", "New York subway", "Italian 1970s design",
        "Indian hand-painted trucks", "California surf shop", "Swiss railway clock",
        "Berlin techno club", "Seoul convenience store", "Cuban vintage cars",
        "Icelandic landscape", "Parisian bistro menu", "Hong Kong neon street",
    ],
    "energy": [
        "calm", "loud", "playful", "serious", "eerie", "cozy", "rebellious",
        "luxurious", "nerdy", "dreamy", "industrious", "mischievous",
    ],
    "color strategy": [
        "monochrome plus one accent", "complementary pair", "analogous warm",
        "analogous cool", "triad", "duotone", "earth tones", "neon on dark",
        "muted pastels", "black and white plus one primary", "sun-faded print",
        "jewel tones",
    ],
    "type voice": [
        "neo-grotesk sans", "geometric sans", "humanist sans", "slab serif",
        "high-contrast didone", "old-style serif", "monospace", "condensed display",
        "rounded sans", "blackletter accent", "handwritten accent", "stencil",
        "wide extended sans", "pixel font accent",
    ],
    "shape language": [
        "sharp corners", "pill shapes", "soft rounded", "hand-drawn irregular",
        "chamfered corners", "circles", "torn edges", "thick outlines",
    ],
    "object": [
        "ticket stub", "vinyl record sleeve", "field guide", "arcade cabinet",
        "ship's manifest", "skate deck graphic", "botanical plate", "old terminal",
        "folded road map", "comic panel", "tin can label", "seed packet",
        "boarding pass", "museum placard", "matchbox", "trading card",
    ],
}


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--seed", type=int, help="seed for a repeatable roll")
    parser.add_argument("--only", help="comma-separated axes to roll")
    args = parser.parse_args()

    rng = random.Random(args.seed)
    axes = AXES
    if args.only:
        wanted = [a.strip() for a in args.only.split(",")]
        unknown = [a for a in wanted if a not in AXES]
        if unknown:
            parser.error("unknown axes: %s (choose from: %s)" % (", ".join(unknown), ", ".join(AXES)))
        axes = {a: AXES[a] for a in wanted}

    width = max(len(a) for a in axes)
    for axis, values in axes.items():
        print("%s  %s" % (axis.ljust(width), rng.choice(values)))


if __name__ == "__main__":
    main()
