---
name: taste-directions
description: Show two or three design directions with real character, each as a small real screen of my product, each with a named signature move, and ask which I like most. Works from a finished brief. Second step of /taste, or use it alone.
disable-model-invocation: true
---

# Taste directions

Offer two or three real alternatives, and let the user pick. **Changes:** only `style/directions.html` and the `Direction` line in `style/brief.md`.

Read `style/brief.md`, `style/references/moodboard.md` if there is one, and this skill’s `references/handbook.md`. In brand mode, skip this skill.

**Do not start if `style/brief.md` still has unanswered questions.** Go back to `taste-brief`.

## Directions with character

Each one is a different answer to the brief’s tension, not a variation in color. Each has:

- a **name**
- a **signature move** people will remember (one thing, visible at a glance)
- how hierarchy and scale work (what is loud, what is quiet)
- an **imagery strategy** (what pictures do, how they are cropped; never “hide overflow”)
- the trade-off it accepts

Write down the look a model would reach for first on this kind of product (SaaS: Inter, three cards, gradient headline; ecommerce: white card grid; app landing: phone mock and two store buttons). **Do not offer that default** unless the brief gives a reason to use it. Name it in your notes as the rejected default. No two directions share a type pairing or a main hue.

**Differ from the other projects in this repo.** Before drawing, read every `STYLE.md` under `examples/` and any other `STYLE.md` the run can see. Note each one’s material, color temperature and value (warm or cool, light or dark), and type family (serif, sans, mono, script). Each direction here must differ from all of those in at least two of those three, unless a recorded **owner** answer asks for that material, temperature or family and says why. An assumption, including “I don’t know, you decide”, does not count. Do not offer the shared document default — warm off-white or beige paper, monospace-led type, hairline rules, small body text, no imagery — unless an owner answer asks for that cluster. It is not banned. It is a default, and a default needs their why.

## Show them

Build `style/directions.html`: each direction as a small real screen of this product, using its real words and assets, or a marked placeholder where an asset is missing. These are sketches to choose from, not the build. The signature move must be visible in the sketch. If type character was still open, each sketch renders its own character (the same four, or the one they picked) as real type, not a font name in a caption. Show the page in the chat if your tool can, otherwise open it in the browser.

## Ask (at most one question)

Give your recommendation and its reason in a line. Then ask **one** question: which they like most, with the cost of each, with buttons in the inline view if it can send a reply, otherwise with the question tool. They can type a mix; if they do, check it still has one idea at its core.

This is the only extra question after the brief batch. Do not use it to sneak in audience or feeling — those belong at the brief.

Write the pick, their why, and the signature move into the brief. Run alone, say that `/taste` writes the handbook from here.
