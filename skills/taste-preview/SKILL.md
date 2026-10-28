---
name: taste-preview
description: Build style/preview.html from STYLE.md - a Figma-style page with labelled frames showing every color, type size, spacing, shape and component in all its states, plus typical screens at desktop and phone width, using only the style's tokens. Checks it with screenshots before anyone sees it. Fourth step of /taste, or use it alone after editing STYLE.md.
disable-model-invocation: true
---

# Taste preview

Build `style/preview.html`, the proof that the style works: if a component can't be built from the tokens, the style isn't finished.

**Changes:** only `style/preview.html` and its screenshots in `style/judging/`. If a component needs a value `STYLE.md` doesn't have, add it to `STYLE.md` first, with its why. Never the app.

## Before you start

Read `STYLE.md` (or the style doc `style/brief.md` names) and this skill's `references/handbook.md`, especially **Polish**. If there's no style doc, stop and say that `/taste-system` (or `/taste`) writes one first. If `style/preview.html` already exists, rebuild it from the current `STYLE.md` rather than patching around old values.

## Build it

One self-contained file, laid out like a Figma page, with labelled frames on a neutral canvas. Every color, font, size, radius and shadow in the components comes from the tokens: paste the `:root` block from `## Tokens` in and use `var(--…)`. Literal values are fine only for the canvas around the frames (frame labels, the canvas background).

Give each frame an `id` and keep each one under about 2000px tall, so it can be screenshotted and judged on its own.

Show, each in its own frame:

- **Cover:** the name, the one-liner, the DNA and a few moodboard images.
- **Color:** every swatch with its token name, hex and contrast ratio on its usual background.
- **Typography:** the whole scale with sizes, a paragraph at the real line length, and the families' specimens.
- **Space, shape and depth:** the spacing scale, radii, borders and shadows.
- **Components:** everything listed in `## Components`, each one in all its states side by side.
- **In context:** one or two typical screens of this kind of product (a landing hero, a dashboard, a form; whatever fits) built from the components, at desktop and phone width. Use the app's real screens if it has them; otherwise make up plausible content, without asking the user for it, and label it as placeholder. This is where the style either holds together or doesn't.
- **Light and dark**, if both exist.

Make the page itself feel like the style, not a generic template. The phone frames must lay out like a real phone, not a squeezed desktop: container queries on the frame work well.

## Check it before anyone sees it

1. **Polish pass.** Go through the handbook's Polish rules yourself: controls in a row share one height and line up, text sits where its box says it does, badges and labels sit in a clear spot instead of floating over artwork, disabled states look disabled, not broken, and focus rings fit the shape.
2. **Screenshots.** Take one per frame at 1440px and 375px wide with this skill's `scripts/screenshot.sh` (`bash <skill folder>/scripts/screenshot.sh "style/preview.html#color" style/judging/check/color-1440.png 1440`). It warns when the page scrolls sideways, an element sticks out of its box, content is cut off, neighbours overlap or text spills. Fix every warning.
3. **Look at the screenshots** and fix anything plainly broken: missing fonts, overlapping text, a frame that didn't render. A 2px overflow a judge catches caps the whole score at 5, so it's far cheaper to catch it here.

## When you're done

Run alone, open the preview (`open style/preview.html` on macOS, `xdg-open` on Linux), tell the user where it is, and say that `/taste-judge` scores it. Run as part of `/taste`, go straight on to judging.
