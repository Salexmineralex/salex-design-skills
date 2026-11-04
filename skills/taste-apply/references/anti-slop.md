# Anti-slop checklist

Generic AI design has a look: a violet gradient, a serif headline, three rounded cards, "Step 01". It appears because the model reaches for what it has seen most, and it survives because the same model then judges it. This checklist is the counterweight. It applies to everything these skills produce: options, directions, previews and restyled pages.

## Three kinds of rule

**Slop is a choice made by default, not by decision.** So most techniques aren't banned: they need a job. But some things are never acceptable, and no score can buy them back.

### 1. Hard gate: blocks delivery, no waivers

A failure here means the work isn't shown to the user as finished, whatever the judges scored.

| Rule | Checked by |
|---|---|
| Invented proof: made-up numbers, testimonials, customer logos, awards, security or speed claims | Judges and you |
| Controls you added or broke, dead navigation you added (a labelled preview is exempt). Already dead before a looks-only restyle: note it as `FOUND, not caused` for the user; it doesn't block | You, by clicking |
| Sideways scroll or broken layout at 375px and 820px | `sideways-scroll`, `screenshot.sh` |
| Text below WCAG AA contrast (locked brand values go to the user as a question) | `contrast.py` |
| No visible keyboard focus | You, by pressing Tab |
| `empty-card`: a box with nothing in it | `slop-check.sh` |
| `fake-visual`: a gradient standing in for a photo, product shot or illustration | `slop-check.sh` |
| `content-changed`: text changed from the source in a restyle (needs `--source`) | `slop-check.sh` |
| `off-brand`: colors, fonts or weights outside the locked brand (needs `--locked`) | `slop-check.sh` |

### 2. Needs a reason: allowed with a job, in a small dose

These are fine when the brief gives them a job and they're used sparingly. Without a written reason they cost points. **Final score = the judges' average − the penalty** (at most 3); the judges can't remove it.

| Rule | Penalty | Instead, if there's no reason |
|---|---|---|
| `violet-gradient` | 1 | A color from the idea, flat by default |
| `emoji-icon` | 1 | One icon set in the style's own line and weight |
| `invented-steps` | 1 | Show steps only if the product truly has an order |
| `generic-card-grid` | 0.5 | Vary by importance, use real media, or a plain list |
| `filler-copy` | 0.5 | Say what the product does, in its own words |
| `trendy-font` | 0.5 | A font picked for this idea, or a written reason |
| `left-stripe` | 0.5 | A heading, a rule, or nothing |
| `gradient-text` | 0.5 | Solid color and real hierarchy |
| `nested-card` | 0.5 | One container; use space or a rule inside it |
| `icon-tile` | 0.5 | The icon alone, or a real picture |
| `all-centered` | 0.5 | A layout that follows the content |
| `default-type-scale` | 0.5 | Sizes chosen for this design |
| `generator-trace` | 0.5 | Your own title, description and clean code |
| `recipe-fingerprint` | 0.5 | Your own values and your own example data |

**Look for clusters.** One 0.5 rule alone is noted but costs nothing; two or more kinds mean a pattern. Glass, glow, bento grids, badges and heavy shadows aren't checked by script: judges ask only whether each has a job.

### 3. Quality: what judges weigh

Layout that follows the content, one focal point, specific button words, and everything in "What only eyes can catch" below. These move the score, not the gate.

### Never hand over a recipe

Replacing one default with another fixed value just makes a new default, and thousands of agents following the same exact values share a fingerprint. So values in these skills are examples, never ingredients: every font, radius, shadow and color is chosen for this project and written in `STYLE.md`. Keep prohibitions; don't turn them into a house look. The strongest sign of slop is often no single tell, but never having touched a default: make deliberate breaks where the content asks for them.

### A clean page isn't enough

Removing slop can leave something bland, and bland fails too. A bland result usually means the direction was missing, so go back to the dials and the signature move, not the filter. Don't flatten a bold choice that has a job just because it's unusual: `STYLE.md`'s `## Bold choices` lists them, with their reasons, and they're protected like fixed decisions.

## Exceptions

Only "needs a reason" rules can be waived; `--allow` has no effect on the hard gate. A rule can be waived only for a reason tied to this product, written in `style/brief.md` under `## Slop exceptions`: `trendy-font (font:Fraunces): its soft, wonky letters match the hand-drawn map; picked over Recoleta for licensing`. "It looks good" isn't a reason. Pass the waivers to the script with `--allow trendy-font` or `--allow font:Fraunces`.

The brand's own values are never slop. If Stripe's gradients are violet, they're Stripe's. Pass `--locked STYLE.md` and `--source <the original page>`, and waive `violet-gradient` in the brief when the extract shows the gradient is the brand's own.

Mark deliberate exceptions in the HTML, so the check reads them correctly:

- `data-placeholder="what's needed"`: an asset still to come. Listed, not penalized.
- `data-specimen`: this element and its contents are a specimen, like a color swatch or a radius sample in the preview.
- `data-canvas`: this element alone is the canvas around the preview's frames.

Using these to hide a real problem is itself slop: the judges see the page, not the attributes.

## What only eyes can catch

The script can't see these, so the art direction (or brand fidelity) judge goes through them and lists any it finds as problems:

- **Invented proof** (a hard-gate failure): made-up statistics, testimonials, customer logos, awards or team photos.
- **Borrowed filler:** sections lifted from another page because they looked good there, like a home page's stats or book of the week on an unrelated landing page.
- **Invented structure:** sections, features or claims the source doesn't have ("How it works", "Why choose us").
- **The default page:** a centered hero, a subtitle, two buttons, three cards, a logo strip and a big footer, with nothing specific to this product.
- **Decoration in place of content:** glowing blobs, dot grids, floating shapes, grain or glass with nothing behind them, filling room the real content should have filled.
- **The default pairing:** a high-contrast serif headline with a neutral sans and one saturated accent, chosen because it reads as "designed".
- **Stock tells:** an eyebrow badge above the heading, sparkle or robot icons, fake terminal windows, wide-tracked monospace labels, three pricing columns, "John Doe" data, "It's not just X, it's Y".
- **Swap test:** replace the name with a competitor's. If nothing else has to change, it isn't a style.

These are guides for the judge, not a list to design around: avoiding every item doesn't make a design good.

## While you design

Before showing anything, ask of each choice: did this come from the brief, the brand or the handbook, or is it just what came to mind first? When it's the second, try one more option. Write the real reason down, or change it.
