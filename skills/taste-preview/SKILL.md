---
name: taste-preview
description: Build style/preview.html from STYLE.md - a Figma-style page with labelled frames showing every color, type size, spacing, shape and component in all its states, plus typical screens at desktop and phone width, using only the style's tokens. Checks it with screenshots before anyone sees it. Fourth step of /taste, or use it alone after editing STYLE.md.
disable-model-invocation: true
---

# Taste preview

Build `style/preview.html`, the proof that the style works: if a component can't be built from the tokens, the style isn't finished.

**Changes:** only `style/preview.html` and its screenshots in `style/judging/`. If a component needs a value `STYLE.md` doesn't have, add it to `STYLE.md` first, with its why. Never the app.

## Before you start

Read `STYLE.md` (or the style doc `style/brief.md` names) and this skill's `references/handbook.md`, especially **Polish**, `references/anti-slop.md` and `references/assets.md`. If there's no style doc, stop and say that `/taste-system` (or `/taste`) writes one first. If `style/preview.html` already exists, rebuild it from the current `STYLE.md` rather than patching around old values. Locked values and real assets from `style/assets/` are used as they are.

## Build it

One self-contained file, laid out like a Figma page, with labelled frames on a neutral canvas. Every color, font, size, radius and shadow in the components comes from the tokens: paste the `:root` block from `## Tokens` in and use `var(--…)`. Literal values are fine only for the canvas around the frames (frame labels, the canvas background).

Give each frame an `id` and keep each one under about 2000px tall, so it can be screenshotted and judged on its own.

Show, each in its own frame:

- **Cover:** the name, the one-liner, the DNA and a few moodboard images.
- **Color:** every swatch with its token name, hex and contrast ratio on its usual background.
- **Typography:** the whole scale with sizes, a paragraph at the real line length, and the families' specimens.
- **Space, shape and depth:** the spacing scale, radii, borders and shadows.
- **Components:** everything listed in `## Components`, each one in all its states side by side.
- **In context:** one or two typical screens of this kind of product (a landing hero, a dashboard, a form; whatever fits) built from the components, at desktop and phone width. Use the app's real screens, words and assets if it has them. Otherwise write plain, plausible content, without asking the user for it, and label it as placeholder. **Don't invent proof or structure:** no made-up statistics, testimonials, customer logos or "Step 01" sequences. Every image comes from `style/assets/`, or is a marked placeholder listed in `## Needed` (`references/assets.md`): never an empty card, never a gradient standing in for an image. This is where the style either holds together or doesn't.
- **Light and dark**, if both exist.

**Every section of a new screen must trace to the brief or to a marked placeholder.** Don't fill it with sections borrowed from the brand's other pages. Screens shown inside iframes aren't seen by the slop check, so run it on each of those files too. Check external masks and images really render: a broken one vanishes silently, on `file://` especially.

**In brand mode** (`STYLE.md` has `## Locked`), the page shows a brand being looked after, not a new one. Replace the cover and specimens with these frames: **Brand:** the locked values and real assets, as the brand's inventory. **Audit:** each fix from `style/audit.md` as before and after, side by side. **Extensions:** every new value next to the locked one it derives from. **New screens:** the screens the brief asked for, built only from locked values and extensions, with real assets and the brand's real words, shown next to one of the brand's own pages.

Make the page itself feel like the style, not a generic template. The phone frames must lay out like a real phone, not a squeezed desktop: container queries on the frame work well.

## Check it before anyone sees it

1. **Polish pass.** Go through the handbook's Polish rules yourself: controls in a row share one height and line up, text sits where its box says it does, badges and labels sit in a clear spot instead of floating over artwork, disabled states look disabled, not broken, and focus rings fit the shape.
2. **Screenshots.** Take one per frame at 1440px and 375px wide with this skill's `scripts/screenshot.sh` (`bash <skill folder>/scripts/screenshot.sh "style/preview.html#color" style/judging/check/color-1440.png 1440`). It warns when the page scrolls sideways, an element sticks out of its box, content is cut off, neighbours overlap or text spills. Fix every warning.
3. **Look at the screenshots** and fix anything plainly broken: missing fonts, overlapping text, a frame that didn't render. A 2px overflow a judge catches caps the whole score at 5, so it's far cheaper to catch it here.
4. **Slop check.** Mark swatches and other specimens with `data-specimen`, canvas around the frames with `data-canvas` and missing assets with `data-placeholder`. Run `bash <skill folder>/scripts/slop-check.sh style/preview.html` (in brand mode, add `--locked STYLE.md`; add `--allow` for waivers in the brief). Fix what it finds: each rule takes points straight off the final score (`references/anti-slop.md`).

## When you're done

Run alone, open the preview (`open style/preview.html` on macOS, `xdg-open` on Linux), tell the user where it is, and say that `/taste-judge` scores it. Run as part of `/taste`, go straight on to judging.
