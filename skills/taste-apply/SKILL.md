---
name: taste-apply
description: Restyle a whole app to match STYLE.md - tokens in one place, shared components with every state, then each page, at desktop and phone width - changing only the looks, never behavior, text or structure. Then three expert judges score the real pages, and it fixes what they find until they pass. Last step of /taste, or use it alone once STYLE.md is approved.
disable-model-invocation: true
---

# Taste apply

Make the real app look like `STYLE.md`, then have it judged on the real pages, because the user lives in the app, not the preview.

**Changes:** the app's styling: CSS, theme and token files, fonts and the look of components; `style/judging/` for screenshots and notes; `STYLE.md` only when a judge finds a problem in the style itself. Never the app's behavior, text, routes or structure.

## Before you start

- Read `STYLE.md` (or the style doc `style/brief.md` names) and this skill's `references/handbook.md`. No style doc: stop and say that `/taste` (or `/taste-system`) writes one first. If the repo has no UI yet, say so and stop.
- **Settings:** the pass mark (default 7), the most app rounds (default 3) and the mode (thorough or light). Take them from `style/brief.md`'s `## Settings` or the run that called you. If the user started this skill alone and said nothing, ask in one prompt with the question tool (`AskUserQuestion` or your tool's equivalent), defaults first and marked "(Recommended)".
- **Start from a clean point.** If `git status` shows uncommitted changes in the app's files, ask the user to commit or stash first (the style's own files, `STYLE.md`, `style/` and `AGENTS.md`, don't count), so the restyle can be reviewed and undone on its own.

## Restyle

- **Look before you change.** Find every page and screen and how styling is done (plain CSS, CSS modules, Tailwind, CSS-in-JS, a component library, native themes). If there are no screenshots of each main page in `style/judging/before/` yet, take them now at 1440px and 375px with this skill's `scripts/screenshot.sh`.
- **Put the tokens in one place,** the way this app does it: a CSS variables file, the Tailwind theme, the theme object or the native theme. Names and values come straight from `STYLE.md`'s `## Tokens`.
- **Shared components first,** then pages: buttons, inputs, cards, navigation and the rest, each with every state from `STYLE.md`. Then each page's layout, spacing and type.
- **Replace hard-coded values** (colors, fonts, sizes, radii, shadows) with tokens, and remove old style values nothing uses anymore. When you're done, search for leftover hex colors and pixel values outside the tokens file. A size that belongs to one component (a cover's width, a progress route's height) can stay as a value in that component's rule; give it a token only if two components share it.
- **Change looks only.** Keep the behavior, text, routes, structure, and accessibility attributes like labels and roles. If a component can't match the style without changing behavior, leave it and tell the user.
- **Phone is not optional.** At 375px wide no page scrolls sideways, tables and card grids reflow or scroll inside their own box (and show that they scroll), and rows of controls stack cleanly.
- **Follow `## Do and don't`,** including the lessons earlier judging rounds wrote there.

## Big apps: go in pieces

A small app (up to about 5 pages, no shared component library) is restyled in one go. A bigger one is restyled in pieces, because one huge change is hard to review, hard to undo and breaks in too many places at once. Say which way you're going and why, in one line.

1. **Plan the pieces** and show the list: first the tokens and the shared components, then the pages in groups of 3 to 5 that belong together (the dashboard pages, the settings pages, the marketing pages), the most-used group first.
2. **Piece 1: tokens and shared components.** Restyle them, run the build and tests, and take screenshots of the one or two most-used pages, which now show the new components on old layouts. **Show the user and ask with the question tool** whether to go on (Recommended), change something first, or stop here. This is the cheapest moment to catch a style that doesn't fit the real app.
3. **Then one group of pages at a time.** For each: restyle, run the build and tests, take its screenshots and fix the `screenshot.sh` warnings, and tick it in `style/brief.md`'s `## Progress` (or a `## Restyle` list there when run alone), so a stopped run can continue from the next group. Offer to commit each piece on its own; commit only when the user says yes.
4. **Judge once all pieces are done,** on the whole app (below): judging each piece would multiply the cost, and the judges need to see the pages together.

If the user stops after any piece, the app is left consistent at that point: restyled pieces use the tokens, the rest keeps its old look. Tell them which pages are still old.

## Check it

Run the app's build, linters and tests. Take screenshots of every page at 1440px and 375px into `style/judging/app-round-<n>/` and fix every warning `screenshot.sh` gives. Compare them with the preview, and go through the handbook's Polish rules again on the real pages: real content breaks things the preview didn't. Press Tab through each page once and look at every focused element: the preview shows focus as a drawing, the real page shows what keyboard users actually get.

## Judge it, learn from the notes, fix

1. **Judge the real pages** as this skill's `references/judges.md` says for app rounds (three independent judges; a discussion in thorough mode; light mode is one round with no discussion). The notes go to `style/judging/app-round-<n>.md`.
2. **Read the notes, and every earlier `app-round-*.md`.** Make the fixes, agreed problems first. A problem in the pages gets fixed in the pages; a problem in the style itself (a token that fails everywhere) gets fixed in `STYLE.md` first, then in the app. A problem that keeps coming back means the earlier fix didn't work: change the approach, and write the lesson into `STYLE.md`'s `## Do and don't`.
3. **Below the pass mark, judge again** with fresh judges, up to the most app rounds. Passing, still make the cheap fixes they listed. A fix that would break a fixed decision isn't made; tell the user at the end.
4. If the last round still doesn't pass, stop and show the user every round's scores and the problems that keep coming back: usually the brief has a conflict only they can settle.

Show the user before and after screenshots of the main pages, with the scores.

## When you're done

Say which pages changed and the app's score. Run alone, offer to delete the screenshots in `style/judging/` (keep the `*.md` notes). Run as part of `/taste`, hand back to it.
