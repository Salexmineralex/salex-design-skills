# Anti-slop checklist

Generic AI design has a look: a violet gradient, a serif headline, three rounded cards, "Step 01". It appears because the model reaches for what it has seen most, and it survives because the same model then judges it. This checklist is the counterweight. It applies to everything these skills produce: options, directions, previews and restyled pages.

## Rules with an automatic penalty

`scripts/slop-check.sh` looks for these on the rendered page. Each rule costs its penalty once per page, and the total is capped at 3. **Final score = the judges' average − the penalty.** The pass mark applies to the final score, so a page can't argue its way past a violet gradient.

| Rule | Penalty | What it is | What to do instead |
|---|---|---|---|
| `fake-visual` | 1 | A gradient box standing in for a photo, product shot or illustration | A real asset, or a marked placeholder (`references/assets.md`) |
| `empty-card` | 1 | A box with nothing in it | Fill it with real content, or remove it |
| `violet-gradient` | 1 | Any purple or violet gradient | A color from the idea, flat unless there's a reason |
| `emoji-icon` | 1 | Emoji acting as interface icons | One icon set, drawn in the style's own line and weight |
| `invented-steps` | 1 | "Step 01 / 02 / 03" or bare 01, 02, 03 labels the source doesn't have | Show the steps only if the product truly has an order |
| `content-changed` | 1 | Text added to or removed from the source (needs `--source`) | Restyling changes the look, not the words |
| `off-brand` | 1 | Colors or fonts outside the locked brand (needs `--locked`) | Use a locked token, or propose an extension |
| `generic-card-grid` | 0.5 | Three or more identical rounded cards with only text | Vary by importance, use real media, or use a plain list |
| `filler-copy` | 0.5 | Stock phrases ("seamless", "unlock", "elevate") and lorem ipsum | Say what the product does, in its own words |
| `trendy-font` | 0.5 | A fashionable default (Inter, Fraunces, Space Grotesk, Instrument Serif, Playfair, DM Sans, Geist…) with no stated reason | A font picked for this idea, or a written reason |

## Exceptions

A rule can be waived only for a reason tied to this product, written in `style/brief.md` under `## Slop exceptions`: `trendy-font (font:Fraunces): its soft, wonky letters match the hand-drawn map; picked over Recoleta for licensing`. "It looks good" isn't a reason. Pass the waivers to the script with `--allow trendy-font` or `--allow font:Fraunces`.

The brand's own values are never slop. If Stripe's gradients are violet, they're Stripe's. Pass `--locked STYLE.md` and `--source <the original page>`, and waive `violet-gradient` in the brief when the extract shows the gradient is the brand's own.

Mark deliberate exceptions in the HTML, so the check reads them correctly:

- `data-placeholder="what's needed"`: an asset still to come. Listed, not penalized.
- `data-specimen`: this element and its contents are a specimen, like a color swatch or a radius sample in the preview.
- `data-canvas`: this element alone is the canvas around the preview's frames.

Using these to hide a real problem is itself slop: the judges see the page, not the attributes.

## What only eyes can catch

The script can't see these, so the art direction (or brand fidelity) judge goes through them and lists any it finds as problems:

- **Invented proof:** made-up statistics, testimonials, customer logos, awards or team photos.
- **Borrowed filler:** sections lifted from another page because they looked good there, like a home page's stats or book of the week on an unrelated landing page.
- **Invented structure:** sections, features or claims the source doesn't have ("How it works", "Why choose us").
- **The default page:** a centered hero, a subtitle, two buttons, three cards, a logo strip and a big footer, with nothing specific to this product.
- **Decoration in place of content:** glowing blobs, dot grids, floating shapes, grain or glass with nothing behind them, filling room the real content should have filled.
- **The default pairing:** a high-contrast serif headline with a neutral sans and one saturated accent, chosen because it reads as "designed".
- **Swap test:** replace the name with a competitor's. If nothing else has to change, it isn't a style.

These are guides for the judge, not a list to design around: avoiding every item doesn't make a design good.

## While you design

Before showing anything, ask of each choice: did this come from the brief, the brand or the handbook, or is it just what came to mind first? When it's the second, try one more option. Write the real reason down, or change it.
