---
name: taste-why
description: Write STYLE.md as a handbook, one decision at a time - the idea, a named signature move, the principles, each decision with its reason and accepted trade-off, then the tokens. An anti-slop why-reviewer checks every decision as it's written, judging the reason and never the style, and rejects "the source already did it" unless the run is brand-locked. If a why can't be answered, it does not invent one. Third step of /taste, or use it alone on a style doc.
disable-model-invocation: true
---

# Taste why

Write the handbook, with each decision reviewed before it’s kept. **Changes:** only `STYLE.md` (or the user’s existing style doc, keeping its name), and nothing gets built here.

Read `style/brief.md`, `style/references/moodboard.md` and this skill’s `references/handbook.md`. The handbook tells you what the craft rules are. It doesn’t choose for you.

**Do not start if the brief still has unanswered questions.** An invented why is worse than an unanswered one.

## The handbook

Values in these instructions are examples, never ingredients: thousands of agents copying the same recipe is its own slop. Choose every value for this project.

~~~md
# Style: <name>

> <one line that captures it>

## Idea
What this is, for whom, and the tension, in a few lines. Self-sufficient: the reader never saw the brief.

## Principles
3 to 5 rules that follow from the idea, each as "<this>, not <that>". Use them to settle what this file doesn't cover.

## Signature
The one named move the page must show. Hierarchy: what is loud, what is quiet, and how far display sits from body. Imagery: what pictures do, and how they stay whole. If this block could be deleted and the page would still "work", it is not a signature.

## Decisions

### D1. <decision>
- **Decision:** what it is, exactly, with values.
- **Why:** the problem it solves, tied to the idea.
- **Instead of:** the obvious alternative, and why not.
- **Breaks if removed:** what goes wrong without it.
- **Trade-off:** what this costs, accepted.
- **Source:** brief | moodboard <file> | user answer Q1 | brand <file> | handbook <rule> | assumption A1
- **Reviewed:** kept, or kept (Q1) when it rests on an answer

## Assumptions
- **A1:** a fact from a file or a measurement, not a taste guess. Never used as a Why.

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

**44px is a floor for tapping, not a look.** Actions share height with the row they sit in. Isolated fat pills in a sparse header are chrome, not a system.

**Do not crop a decorative asset to silence overflow.** If a picture is the signature (a wave, a product, a poster), it stays whole, or you change the layout. `overflow: hidden` until validate shuts up is not an imagery strategy.

## The why-reviewer

**Before a decision is kept, it goes past the reviewer.** Start a short-lived sub-agent on your cheapest model, in the foreground, one per decision or small group. If your tool can’t, ask the same questions yourself, one at a time, and say so in the file’s Idea section. Give it only the brief, the mood board notes, the entry, and the settled facts the entry leans on: the recorded answer to any question it cites, values it takes from other decisions (quote those lines), and measurements you made (a contrast ratio, a width). Nothing else: not your own case for the decision.

```
You're an anti-slop reviewer. Most reasons are written to sound good, so assume this one
is filler until its own words prove otherwise. You judge the reason, never the style: any
form is allowed if its reason serves the idea.

The idea: <from the brief>
Brand-locked: <yes or no>
Settled facts: <recorded answers, lines from other decisions and measurements the entry
relies on, or "none">. These are decided: don't test them, and don't ask about them again.
The decision: <the entry>

Run these five tests on the Why, in order. A reason doesn't have to rule out every option
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
4. INHERIT: is the Why only "the source / the brand / the rendered page already did this"?
   If the run is not brand-locked, fail. Copying a look is not a reason. If the run is
   brand-locked, pass only when the Why still says what keeping it does for the user,
   not merely that it was there.
5. OPEN: does the Why admit that something is undecided, or need a fact the idea, brief
   and mood board don't give, where a different answer would change the decision? Fail.
   A reasonable reading of the brief isn't open, and neither is a settled fact.
   An assumption in ## Assumptions is not a Why: if the decision needs a taste fact
   that was never asked, OPEN fails.

Reply in exactly this form:
SWAP: pass or fail, in a few words
CAUSE: pass or fail, in a few words
CHOICE: pass or fail, in a few words
INHERIT: pass or fail, in a few words
OPEN: pass or fail, in a few words
WEAKEST: "<the weakest phrase in the Why, quoted>"
VERDICT: KEEP, BACK or ASK: one line. KEEP only if all five pass. If 1, 2, 3 or 4 fails,
BACK and say what's missing. If 5 fails, ASK and say what only the user can answer.
If the brief already used its five questions and this would be a new one, BACK to the
brief instead of asking again.
```

- **KEEP:** read its WEAKEST line first. If that phrase isn’t doing any work, cut it or back it up, then write `Reviewed: kept`. If every decision comes back KEEP, or none does, the reviewer isn’t working: say so in your notes.
- **BACK:** find the real reason, or change the decision. Often there was no reason, and that was the slop. A rewrite goes past a fresh reviewer.
- **ASK:** first check whether the fact is already settled: in another decision, a recorded answer, or something you can measure. If it is, write it into the Why, give it to a fresh reviewer as a settled fact, and don’t ask. Otherwise: if the brief still has question budget (five at the brief were the batch; do not start a sixth there), you missed the gate — go back to `taste-brief`. If the budget is spent, mark `Reviewed: unresolved` and stop. Do **not** invent a stand-in answer.
- **ASK about something already answered:** never ask the user twice. The answer stands: write `Reviewed: kept (Q1)`, naming the answer. If the reviewer still fails SWAP, CAUSE, CHOICE or INHERIT with the answer in front of it, that’s a BACK: the Why doesn’t say what the answer does for the idea.

**Brand mode:** “the owner asked to keep it” is a source, not a reason. One question covers every kept value: ask why the owner wants this look, and cite the answer. What you changed or added still needs its own why. INHERIT may pass here; SWAP, CAUSE, CHOICE and OPEN still apply.

## Look, before lint (not a score)

Re-read the decisions as a stranger looking at a page that does not exist yet. **Reject and rewrite** if any of these is true. Give a reason, not a number.

- There is no named signature, or it could be removed and the page would still work.
- Type sits in a narrow band: display is not clearly not-body.
- Imagery is “crop until overflow stops.”
- Actions read as isolated 44px chrome, not a system.
- The layout is the default for this product type, and the brief did not ask for that default.

## Asking the user

The brief already had up to five questions in one batch, plus at most one at the direction pick. This skill does not open a new interview. If a Why is still OPEN, the brief was empty: go back.

If you somehow still need a fact, mark the decision `Reviewed: unresolved` and stop. **An invented why is worse than an unanswered one.**

## Finished means

`python3 <skill folder>/scripts/why-lint.py STYLE.md` passes. It checks the form: sections in order (Idea, Principles, Signature, Decisions, Tokens), every field present, no fashion words in a Why, no inherit-only Why unless Source is brand, nothing unresolved, `Reviewed` exactly `kept` or `kept (Qn)` with Qn recorded, no more than six questions, every token tracing to a decision. Passing doesn’t make the reasons good. The reviewer tests the argument before anything exists; the Look pass tests whether a page from this file would be designed; only someone looking at the result can tell whether it shows.

Read it once as a stranger. Could you build from this without asking anything? Fix what you’d have to ask.
