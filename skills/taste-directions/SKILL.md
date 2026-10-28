---
name: taste-directions
description: Propose three distinct design directions for a project (faithful, adjacent, and a wildcard built from random traits), show them side by side in style/directions.html, and ask me which one I like most. Works from style/brief.md, or from a short idea if there's no brief. Second step of /taste, or use it alone to explore looks.
disable-model-invocation: true
---

# Taste directions

Turn the brief into three real alternatives, show them, and let the user pick the one they like most. Real variety, not three versions of the safe default.

**Changes:** only `style/directions.html`, its screenshots in `style/judging/`, and the `## Direction` section of `style/brief.md`. Never the app.

## Before you start

Read `style/brief.md` and this skill's `references/handbook.md`. If there's no brief, take the idea from the user's message and the project itself, ask at most one round with the question tool for what's missing (the idea, why, the feeling), and write a short `style/brief.md` with those answers first. If the brief has open questions that change the directions, ask them now.

Every direction must respect the brief's must-haves and fixed decisions.

## Three directions

- **A. Faithful:** the idea done exceptionally well.
- **B. Adjacent:** the same idea from an unexpected angle. Pirates could become a ship's logbook and old sea charts instead of skulls; skateboard could become 90s zine photocopies instead of graffiti.
- **C. Wildcard:** run this skill's `scripts/roll.py` (`python3 <skill folder>/scripts/roll.py`) to get random traits (era, material, place, energy, color strategy, type voice, shape language, object). Mix two or three of them into the idea. Re-roll a trait only if it breaks a must-have, and say which traits you used.

For each one give: a name, a short paragraph that paints the picture, a 5-color palette (hex, with the main text pair checked by `scripts/contrast.py`), a type pairing, the **signature move** (the one thing people will remember), and why it fits the user's answers.

## Show them

Nobody can picture a style from a paragraph and five hex codes, so the user must **see** each direction before choosing.

Build `style/directions.html`: one section per direction, each a small real screen of this product in that style, not a swatch card. A hero or the app's main screen with the project's real name and content: heading, a paragraph, a primary and a secondary button, an input, a card or a row of data, the signature move in place, and its texture or imagery. Under it, the palette swatches with hex and the font names. Each must differ in more than color: type, shapes, density and mood. Lay them side by side on desktop and stacked on a phone, with a big label (A, B, C and the name) so the user can point.

Take screenshots at 1440px and 375px with `scripts/screenshot.sh`, fix any warning it gives, and look at them: if two directions look alike, push them apart before showing.

**Show it in the chat before asking.** The best place is inside the conversation, right above the question, so the user sees and picks in one place:

- **If your tool can render HTML or images in the chat** (an inline widget or visualization tool, or a tool that sends files the chat displays), show the three directions there: the directions page itself as an inline widget, or its 1440px screenshot.
- **Only if it can't** (a plain terminal), open the page in the browser (`open style/directions.html` on macOS, `xdg-open` on Linux) and say where it is.

Either way, say "Have a look at the three, then pick", and never ask the question with only words on screen. `style/directions.html` stays the saved copy the brief points to.

## Ask which one they like most

Never pick for the user. In the chat, give your recommendation and its reason in one or two lines.

**Shown inline with buttons:** if the inline view can send a message back when clicked (a `sendPrompt`-style function in widgets), put one pick button under the directions for each: "Pick A. <name>", and so on, each sending "I like <letter>. <name> the most". Mark your recommended one in its label. Then the user sees and picks in one place. Say in the chat that they can also type a mix ("A's keys with C's colors") or what's off. Don't open a question prompt for the direction as well: one way to answer, not two. If `/taste` needs other questions answered at this point (its settings), ask those with the question tool right after the pick arrives.

**Otherwise,** ask with the interactive question tool (`AskUserQuestion` in Claude Code, or your tool's equivalent): **"Which direction do you like most?"**, the three directions as options, each with its signature move as the description, your pick first and marked "(Recommended)". If the tool can show a preview per option (`preview` in `AskUserQuestion`), give each one a short picture of its direction: the palette hexes, the font pair and a one-line description of its screen. The user can pick one or mix them (they type the mix as their own answer). Without a question tool, ask in the chat with `➡️ <your pick>`.

If they mix, check that the mix still has one clear idea at its core; if it doesn't, say which part to drop and why. If none fits, ask what's off and propose again.

## Write it down

Add to `style/brief.md`:

```md
## Direction
Picked: <name> (<A, B, C or the mix>). Why the user picked it: <their words, if they gave any>.
<the paragraph, palette, type pairing and signature move of the picked direction>
Wildcard traits used: <list>
Not picked: <the other two, one line each>
```

## When you're done

Run alone, tell the user the pick is saved in `style/brief.md` and that `/taste-system` turns it into `STYLE.md`. Run as part of `/taste`, go straight on to the next step.
