---
name: taste-why
description: Write STYLE.md as a handbook, one decision at a time - the idea and its tension, the principles, each decision with its reason and accepted trade-off, then the tokens. An anti-slop why-reviewer checks every decision as it's written, judging the reason and never the style. If a why can't be answered, it asks me one specific question. Third step of /taste, or use it alone on a style doc.
disable-model-invocation: true
---

# Taste why

Write the handbook, with each decision reviewed before it's kept. **Changes:** only `STYLE.md` (or the user's existing style doc, keeping its name), and nothing gets built here.

Read `style/brief.md`, `style/references/moodboard.md` and this skill's `references/handbook.md`. The handbook tells you what the craft rules are. It doesn't choose for you.

## The handbook

Values in these instructions are examples, never ingredients: thousands of agents copying the same recipe is its own slop. Choose every value for this project.

~~~md
# Style: <name>

> <one line that captures it>

## Idea
What this is, for whom, and the tension, in a few lines. Self-sufficient: the reader never saw the brief.

## Principles
3 to 5 rules that follow from the idea, each as "<this>, not <that>". Use them to settle what this file doesn't cover.

## Decisions

### D1. <decision>
- **Decision:** what it is, exactly, with values.
- **Why:** the problem it solves, tied to the idea.
- **Instead of:** the obvious alternative, and why not.
- **Breaks if removed:** what goes wrong without it.
- **Trade-off:** what this costs, accepted.
- **Source:** brief | moodboard <file> | user answer Q1 | brand <file> | handbook <rule>
- **Reviewed:** kept

## Questions asked
- **Q1:** the question, the options, the answer. Authoritative; cited as Source.

## Tokens
```css
:root {
  --color-ink: <value>; /* D1 */
}
```
~~~

Cover what someone needs in order to build: type, color by role, space and density, shape and depth, imagery, motion, voice, and how each component looks in all its states (hover, focus, active, disabled, loading, error). Group small choices into one decision when they share one reason. Check color pairs with `scripts/contrast.py`. Tokens come last and are mechanical: each one names its decision.

## The why-reviewer

**Before a decision is kept, it goes past the reviewer.** Start a short-lived sub-agent on your cheapest model, in the foreground, one per decision or small group. If your tool can't, ask the same questions yourself, one at a time, and say so in the file's Idea section. Give it only the brief, the mood board notes and the entry:

```
You're an anti-slop reviewer. Most reasons are written to sound good, so assume this one
is filler until its own words prove otherwise. You judge the reason, never the style: any
form is allowed if its reason serves the idea.

The idea: <from the brief>
The decision: <the entry>

Run these four tests on the Why, in order. A reason doesn't have to rule out every option
in the world. It has to make this option better than the one in "Instead of".
1. SWAP: take out the names and put a different product of the same kind in its place.
   Is the Why still true, word for word? Then it says nothing about this one: fail. Naming
   this product's users or the user's own idea, and depending on them, passes.
2. CAUSE: would the option in "Instead of" produce the effect the Why claims just as well?
   Fail. Also fail a reference given as the whole reason ("like Tintin"): that's where it
   came from, not what it does for the user.
3. CHOICE: if you delete every "it was asked for", "by instruction", "out of scope" and
   "nothing requires changing it", does a reason remain? If not, nobody chose: fail. The
   user's own idea is a fine reason when the Why says what the decision does for it.
4. OPEN: does the Why admit that something is undecided, or need a fact the idea, brief
   and mood board don't give, where a different answer would change the decision? Fail.
   A reasonable reading of the brief isn't open.

Reply in exactly this form:
SWAP: pass or fail, in a few words
CAUSE: pass or fail, in a few words
CHOICE: pass or fail, in a few words
OPEN: pass or fail, in a few words
WEAKEST: "<the weakest phrase in the Why, quoted>"
VERDICT: KEEP, BACK or ASK: one line. KEEP only if all four pass. If 1, 2 or 3 fails,
BACK and say what's missing. If 4 fails, ASK and say what only the user can answer.
```

- **KEEP:** read its WEAKEST line first. If that phrase isn't doing any work, cut it or back it up, then write `Reviewed: kept`. If every decision comes back KEEP, or none does, the reviewer isn't working: say so in your notes.
- **BACK:** find the real reason, or change the decision. Often there was no reason, and that was the slop. A rewrite goes past a fresh reviewer.
- **ASK:** go to "Asking the user".

**Brand mode:** "the owner asked to keep it" is a source, not a reason. One question covers every kept value: ask why the owner wants this look, and cite the answer. What you changed or added still needs its own why.

## Asking the user

If the brief, the idea and the mood board can't answer a why, **ask rather than invent or guess. An invented why is worse than an unanswered one:** mark it `Reviewed: unresolved` until you have the answer.

Ask with the question tool: one specific question about one decision, with the plausible options and what each one costs. Never "what do you prefer?". Record the answer under `## Questions asked`, and cite it as the Source: it's authoritative.

**At most three questions in a project.** If you need more, the brief is empty: go back to `taste-brief` instead of interrogating the user.

## Finished means

`python3 <skill folder>/scripts/why-lint.py STYLE.md` passes. It checks the form: sections in order, every field present, no fashion words in a Why, nothing unresolved, no more than three questions, every token tracing to a decision. Passing doesn't make the reasons good. The reviewer tests the argument before anything exists; only someone looking at the result can tell whether it shows.

Read it once as a stranger. Could you build from this without asking anything? Fix what you'd have to ask.
