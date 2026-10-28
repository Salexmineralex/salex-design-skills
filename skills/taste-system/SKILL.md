---
name: taste-system
description: Write STYLE.md, the style guide other agents build from - idea, why, DNA, moodboard, palette (contrast checked), typography, spacing, shape, motion, every component with its states, voice and CSS tokens, with a reason behind every rule, grounded in design handbooks. Works from style/brief.md and the picked direction, or from an existing STYLE.md or DESIGN.md to redesign. Third step of /taste, or use it alone.
disable-model-invocation: true
---

# Taste system

Write `STYLE.md`: exact values another agent can build from without guessing, and a reason for every rule.

**Changes:** only `STYLE.md` (or the existing style doc the brief names, keeping its file name). Never the app.

## Before you start

- Read this skill's `references/handbook.md`. Every rule in `STYLE.md` should trace back to it, or to a reason the user gave.
- Read `style/brief.md`, especially `## Direction` and `## Fixed decisions`. If there's no brief or no direction yet, ask one short round with the question tool (`AskUserQuestion` or your tool's equivalent) for the idea, why, the feeling and the must-haves, and say that `/taste-directions` would give them three to choose from first.
- If a style doc already exists, this is a **redesign**: keep what the brief says to keep, and move the old direction into `## History` with the reason it changed.
- If `style/judging/round-*.md` notes exist and you were asked to fix them, read every round, not just the last (see "Fixing after the judges").

## Write it

Check every text and background pair with this skill's `scripts/contrast.py` (`python3 <skill folder>/scripts/contrast.py "#text:#bg" …`; stacked translucent layers as `"#fff:rgba(0,0,0,.6)@#1a1a1a"`) and only keep pairs that pass. Use this structure:

~~~md
# Style: <name>

> <one line that captures it>

## Idea
What this is, who it's for, and the feeling. The context: where the idea comes from and which part of it we use.

## Why
The reasons behind the big choices, from the brief.

## DNA
3 to 5 traits everything else follows, each as "<this>, not <that>" (e.g. "Hand-printed, not digital-perfect").

## Moodboard
References (images in style/moodboard/, the option picked from options.html, places, objects, eras, artists) and what we take from each. Always filled in, even without images: then it's the references in words.
Anti-references: what this must not look like.

## Color
Palette as tokens by role (background, surface, text, muted text, border, primary, accent, success, warning, danger), with hex values.
Proportions (e.g. 60/30/10), contrast pairs checked, light and dark if both exist.

## Typography
Families (with source and fallbacks), the scale, weights, line heights, letter spacing, rules (e.g. "all caps only for labels under 14px").

## Space and layout
Base unit, spacing scale, grid, line length, density, phone breakpoints.

## Shape, depth and texture
Corner radius, borders, shadows or elevation, textures, icon style, imagery and illustration.

## Motion
Durations, easing, what moves and why.

## Components
For each one: how it looks and its states (hover, focus, active, disabled, loading, error).
Buttons, inputs, selects, checkboxes, radios, toggles, cards, navigation, tabs, badges, alerts, toasts, tables, modals, avatars, progress, empty states.

## Voice
How the UI text talks, in two or three lines with examples.

## Do and don't
- Do …  /  Don't …

## Tokens
```css
:root { /* every value above, as custom properties, including shared component sizes: control height, icon sizes */ }
```

## History
(Redesigns only.) Previous direction, and why it changed.
~~~

Every rule needs a why, from the handbook or the brief. Values should be exact (hex, px, ms). Load fonts from Google Fonts or another open source, never paid fonts without a licence.

## Fixing after the judges

When `/taste` sends you back here with judges' notes, the notes are the input:

- Make every fix in the fix list that doesn't break a fixed decision, worst first.
- Fix the cause, not the symptom: a contrast problem in one component usually means a token is wrong for everything that uses it.
- When a problem has come back in two or more rounds, the earlier fix didn't work. Don't nudge the same value again; change the approach, and say what you changed.
- Write each lesson into `## Do and don't` ("Don't let a pressed key's travel show a second line in dark mode: one slab, one outline"), so the app restyle and every later page follow it too.

## When you're done

Run alone, tell the user `STYLE.md` is written and that `/taste-preview` shows it as a page. Run as part of `/taste`, go straight on to the next step.
