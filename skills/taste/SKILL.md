---
name: taste
description: Give a project its own style, written down as STYLE.md - a handbook with the idea, a named signature move, principles and every design decision with its reason, good enough to hand to a designer or another agent. Takes my idea (stopping to ask if the idea is thin), offers two or three directions, writes STYLE.md with every decision checked for a reason that serves my idea, and only then builds a sample page or my app and measures the result. For a product with a brand to keep, /taste --brand reads the existing tokens instead.
disable-model-invocation: true
---

# Taste

**`STYLE.md` is the product.** It's a handbook: someone who never saw the brief can build in-brand from it, and knows what to build and why. Everything else exists to make it good, or to prove the build follows it.

## The one rule

**Every decision needs a why, measured against the user's original idea.** The user's idea (intent, vibe, references) is the highest authority. Nothing is banned for its form: a gradient that carries an illustration is fine, and the same gradient because it looks modern isn't. A serif, a mono label, "Step 01", an emoji, a rounded card grid: each is allowed with a reason that serves the idea. If a decision conflicts with the idea, the idea wins.

## The order

**Document first, design second.** No page, stylesheet or screen gets built until `STYLE.md` is finished. A rationale written after the design exists is an excuse, not a reason.

1. **Idea.** Follow `taste-brief`. If the idea is thin, **stop at the question gate** and wait. Do not invent answers.
2. **Directions.** Follow `taste-directions`. The user picks one. (Their cards are sketches to choose from, not a build.) At most one question: which they like.
3. **Handbook.** Follow `taste-why`: write `STYLE.md` one decision at a time, including a **Signature**, each one reviewed before it's kept. It must pass `why-lint.py`. A Why that is only “the source already did it” fails unless this run is brand-locked.
4. **Build.** Only now, and only from `STYLE.md`'s tokens and decisions:
   - **No app:** one page, `style/sample.html`, of the kind this product really needs, with real content and the assets in `style/assets/`, or marked placeholders, at desktop and phone width. One page is enough. The signature move must be visible at 1440 and at 375. Pictures stay whole. 44px is a tap floor, not the look of the buttons.
   - **An app, if the user asked for it to change:** start from a clean `git status` in the app's files. Put the tokens in one place, then shared components, then pages. Change looks only: behavior, words and structure stay. On a big app, show the user the first page before going on.
   - If the build needs a value `STYLE.md` doesn't have, stop and add the decision first. Don't invent it in the CSS.
   - A restyle that keeps structure is still a design: do not ship a clone of the source with more padding.
5. **Validate.** Follow `taste-validate`. Fix every FAIL. Then look: signature, hierarchy, imagery, chrome-as-system. A problem in the design goes back to `STYLE.md`, and the build follows from it.
6. **Show the user** the page, the report, and `STYLE.md`'s open trade-offs. Their feedback changes a decision in `STYLE.md` first. Then offer one line for `AGENTS.md`: "UI work follows `STYLE.md`: use its decisions and tokens, don't invent new values."

## Brand mode

Use it for `/taste --brand`, when the user says to keep their brand, or when they accept `taste-brief`'s recommendation. The brand is the idea. There's no new identity to choose, so skip directions.

`taste-brief` reads the existing tokens directly with `scripts/read-tokens.sh`: colors, greys, borders, states, elevation and radii. Keep the user's existing `STYLE.md` or `DESIGN.md` and write the handbook into it, or create one if there's none. Tokens from the brand are marked `/* brand */`. Decisions then cover what the brand does and why, plus each fix or new value, and a change to a look the brand has chosen goes to the user as a question. “It was already there” is a source, not a why.

## Asking the user

Asking is the last resort, and a legitimate one: **last resort means only what cannot be inferred from files and their words.** A thin idea cannot be inferred. `taste-brief` asks up to five questions in one batch. `taste-directions` asks at most one more (the pick). Do not invent stand-in answers. An invented why is worse than an unanswered one.

## If a run stops

`STYLE.md` and `style/brief.md` are the memory. On `/taste`, if they exist and `why-lint.py` or `validate.sh` doesn't pass, say where things stand in three lines and offer to continue from there. If the brief has unanswered questions, that is the stop: list them and wait. A finished `STYLE.md` means the user wants a change: ask what isn't working, and why.

If a step skill is missing, give the install command and stop: `npx skills add Salexmineralex/salex-design-skills --skill '*'`.
