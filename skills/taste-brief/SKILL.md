---
name: taste-brief
description: Interview me about the design of a project, only the look and the why behind it (which version of the idea, the feeling, references, must-haves), with clickable questions. For a vague idea like "retro" or "cyberpunk" it builds a visual menu of readings (style/options.html) and asks for a moodboard. Writes the answers to style/brief.md. First step of /taste, or use it alone to pin down a design brief.
disable-model-invocation: true
---

# Taste brief

Find out what the user means by their idea and why they want it, and write it down in `style/brief.md`, so every later design step builds on the user's own words instead of guesses.

**Changes:** only the `style/` folder: `brief.md`, `options.html`, `moodboard/` and screenshots in `judging/`. Never the app.

## Your role

You know more about design than the user. Act like it: lead with a recommendation, explain the rule behind it in one line ("two typefaces at most, a third one starts to fight for attention"), and push back when a request breaks a rule. The user still decides; your job is to make sure they decide knowing the trade-off.

Read this skill's `references/handbook.md` before proposing anything.

## Always ask why

Every big choice needs a reason tied to the product, its users or the feeling it should give. Ask "why?" for each one the user makes, once, in plain words: "Why pirates? Is it the adventure, the hand-made maps, the rebel attitude?" The answer tells you which part of the idea to build on.

- **"It's trendy", "it looks modern" or "everyone does it" isn't a reason.** Ask what the user should feel or do because of it. If there's no answer, recommend against it. The handbook has the usual trends and when each one actually fits.
- **"I just love it" is a valid reason** for a personal project. Write it down as the reason.

## Before you start

- **Look for an existing style doc:** `STYLE.md`, `DESIGN.md` or `design.md` at the root or in `docs/`. If one exists, this is a **redesign**: read it, sum up its current direction in three lines, and make the first round "What's not working, what do we keep, and why?". Write its name in the brief, so the later steps rewrite that file instead of creating a new one.
- **See the current UI, if there is one.** Take screenshots of each main page at 1440px and 375px wide into `style/judging/before/` with this skill's `scripts/screenshot.sh` (`bash <skill folder>/scripts/screenshot.sh index.html style/judging/before/home-1440.png 1440`) and look at them. Check its contrast with `scripts/contrast.py`. Show the user what's actually broken (unreadable text, a layout that spills off a phone screen), not just what's unfashionable; it's the strongest argument for or against a direction.
- **Read the project:** what it is, who uses it, and any UI that already exists (CSS variables, Tailwind config, theme files, logos in assets). These are facts, so look them up instead of asking. An existing brand color or logo is a constraint to design around, not something to replace silently.
- **No app yet is fine.** Then the brief is the start of the style every later page follows.
- If `AGENTS.md` exists, follow its rules.
- **A brief already exists** (`style/brief.md`) and you were started alone: show what it says in three lines and ask with the question tool whether to update it (Recommended) or start a new one. Updating keeps every section you don't change, including `## Direction`, `## Settings` and `## Progress`.

## Ask in rounds

Each round asks every question that can be answered now, then waits. Write in the language the user writes to you in, even if the product is in another one.

**Ask through the interactive question tool** (`AskUserQuestion` in Claude Code, or your tool's equivalent), not as a block of text the user has to answer by typing. Before calling it, write one or two lines in the chat with anything they need to see first (the options page, what's broken now, the moodboard request), because the prompt itself only holds short text.

- **Up to 4 questions per call**, each with a short header, 2 to 4 options and a one-line description per option. The user can always type their own answer instead, so options are examples, not a cage.
- **Decisions** (light or dark mode, which era, how loud) get your pick as the first option, marked "(Recommended)", with the reason in its description.
- **Questions only the user can answer** (why they want this idea, who their users are, what they love) get example options and no "(Recommended)": a suggested answer there puts words in their mouth.
- **Use multi-select** when several answers can be true at once (which feelings fit).
- **Don't ask for images through the tool:** ask for the moodboard in the chat lines before the call, and say where to put them.

If your tool has no interactive question tool, write the questions in the chat instead, one per line as `**Q1. <title>**: <question>`, with `➡️ <your pick>` under decisions only.

**Only ask about the design.** This decides how things look, not what the product contains. Never ask which pages, sections, features or copy there are (a footer, a pricing table, an FAQ): that's product work. If there's an app, its screens are facts you read.

**Keep the first round short:** 4 questions, the ones everything else depends on. A one-line request answered with nine questions feels like homework. Ask the rest in the next round, once the answers show what still matters. When more than four topics compete for round 1, take them in this order and move the rest to round 2:

1. **Why**, if the only reason given is a trend.
2. **Which reading**, if the idea is a vague genre (with the options page).
3. **Keep and change**, in a redesign.
4. **Why**, otherwise.
5. **The feeling.**
6. **How strong** the idea should be (everywhere, or at the edges with a plain core).

The moodboard request goes in the chat lines before the prompt, never as a question, so it doesn't take a slot.

"Which reading is closest?" is a taste question: no "(Recommended)" on it, since the options page is a menu, not a proposal.

If the user's message gives a trend as the only reason ("it's trendy", "everyone's doing it"), the first round starts with why.

The answers must cover:

- **Who it's for:** who will look at it (age, context, in a hurry or relaxed), only as much as it changes the look.
- **The idea:** the generic idea in a few words (retro, steampunk, cyberpunk, minimalist…) and **why** that idea.
- **The feeling:** three words for how it should feel, and three for how it must *not* feel.
- **References:** things they love (sites, apps, posters, places, objects, films) and what exactly they love in each.
- **Must-haves:** existing brand colors or logo, light and/or dark mode, platforms (web, mobile), accessibility needs.

## Moodboard and options, when the idea isn't clear

If you can't picture the style yet (the idea is a single vague word, the answers contradict each other, or the words could mean very different things, like "retro" meaning the 50s or the 90s), say so and ask for a moodboard: 3 to 10 images, saved in `style/moodboard/` or pasted into the chat, with a line on what they like in each. If the idea is a single vague word from the start (including a genre that covers very different looks, like retro, cyberpunk or minimalist), ask for it in the first round. Their images are the input; don't make your own moodboard in their place.

**Show the options, too.** People react to pictures far better than to questions, so in that same first round build `style/options.html`: 4 genuinely different readings of the word (for "retro": a 1950s cafetería, 1970s earth tones, coffee-sack print, 90s web), so each one fits as an option in the "which is closest?" question. Each gets a small card with a name, a one-line picture, five color swatches, its type pairing as a real heading and paragraph, and one sample button. Use the project's real name and a line of its real content in each card. Label the page plainly as a menu, not a design: "Which of these is closest to what you mean? Mix them, or none of them." Each card must be different in more than color: different type, shapes and density. Take a screenshot of it and check it works at phone width too. Then show it in the chat just before the question prompt, if your tool can render HTML or images there (an inline widget or visualization tool, or a tool that sends files the chat displays); only if it can't, open it in the browser (`open style/options.html` on macOS, `xdg-open` on Linux) and say where it is. They must see the options, not read about them.

If they can't or won't send images, go on with their words and their pick from the options, and say so in the brief.

Look at every image. Write down what they share: the palette, contrast, textures, type, shapes, density and era. Tell the user what you see ("All five are warm, grainy and hand-printed, but three are busy and two are very calm. Which way?") so they can correct you.

## Write style/brief.md

Write it as soon as round 1 is sent, with the facts you know and the questions still open, and fill it in as answers arrive. A brief that only exists at the end is lost if the run stops while waiting for the user, and `/taste` keeps its progress log in this file.

```md
# Brief: <project>

## Project
What it is and who looks at it. Existing style doc (redesign): <file name, or "none">. Existing app: <yes, with its main pages | no>.

## Idea
<the idea in a few words>. Why: <their reason, in their words>.

## Feeling
Should feel: <three words>. Must not feel: <three words>.

## References
- <reference>: what they love in it
Options page pick: <which card, and what to change, or "not shown">
Moodboard: <what the images share, or "no images">

## Must-haves
Brand colors, logo, light/dark, platforms, accessibility.

## Fixed decisions
Choices the user made explicitly. Later steps and the judges never change these.

## Open questions
Anything still unclear, for the next step to settle.
```

In a redesign, add `## Keep` and `## Change` from the first round.

## When you're done

Run alone, tell the user the brief is in `style/brief.md` and that `/taste-directions` turns it into three directions to choose from (or `/taste` runs the whole thing). Run as part of `/taste`, go straight on to the next step.
