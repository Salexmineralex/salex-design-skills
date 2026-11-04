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
You're an anti-slop reviewer. You judge the reason, never the style: any form is
allowed if its reason serves the idea. Answer one question: why this, and does that
why serve the user's original idea?

The idea: <from the brief>
The decision: <the entry>

Reply with one word and one line:
KEEP: the why names a real problem and serves the idea.
BACK: the why is fashion or filler ("it's what everyone does", "it looks clean",
"modern"), or would be true of any product. Say what's missing.
ASK: nothing in the idea, brief or mood board can answer this.
```

- **KEEP:** write `Reviewed: kept`.
- **BACK:** find the real reason, or change the decision. Often there was no reason, and that was the slop.
- **ASK:** go to "Asking the user".

## Asking the user

If the brief, the idea and the mood board can't answer a why, **ask rather than invent or guess. An invented why is worse than an unanswered one:** mark it `Reviewed: unresolved` until you have the answer.

Ask with the question tool: one specific question about one decision, with the plausible options and what each one costs. Never "what do you prefer?". Record the answer under `## Questions asked`, and cite it as the Source: it's authoritative.

**At most three questions in a project.** If you need more, the brief is empty: go back to `taste-brief` instead of interrogating the user.

## Finished means

`python3 <skill folder>/scripts/why-lint.py STYLE.md` passes. It checks the form: sections in order, every field present, no fashion words in a Why, nothing unresolved, no more than three questions, every token tracing to a decision. Passing doesn't make the reasons good; the reviewer does that.

Read it once as a stranger. Could you build from this without asking anything? Fix what you'd have to ask.
