# salex-design-skills

Design skills for AI coding agents (Claude Code, Codex and others that read `SKILL.md`). Each skill lives in `skills/<name>/`.

## Install

```bash
npx skills add Salexmineralex/salex-design-skills --skill '*'
```

`/taste` needs all of them. To pick only some, leave out `--skill '*'` and choose. Install into a project (the default) or for every project with `-g`.

Needs Python 3 and Node (the screenshot helper uses Playwright, which downloads its own Chromium the first time, about 150 MB).

## `/taste`

**`STYLE.md` is the product:** a handbook good enough to hand to a designer or another agent, so they know what to build and why.

**The one rule:** every decision needs a why, measured against your original idea. Nothing is banned for its form. A gradient that carries an illustration is fine; the same gradient because it "looks modern" isn't. If a decision conflicts with your idea, your idea wins.

**The order:** document first, design second. Nothing gets built until `STYLE.md` is finished, because a reason written after the design is an excuse.

1. **Your idea** (`/taste-brief`): short, with its tension. If it's ambiguous, it asks for a mood board, or proposes one to pick from, and records concrete traits.
2. **Two or three directions** (`/taste-directions`), shown as small real screens. You pick.
3. **The handbook** (`/taste-why`): one decision at a time, each past an anti-slop reviewer that judges the reason and never the style.
4. **The build:** one sample page, or your app if you ask, only from `STYLE.md`.
5. **Measurement** (`/taste-validate`): objective checks and captures at 1440 and 375.

Only you start it: type `/taste`, optionally with your idea.

## What's in `STYLE.md`

The idea and its tension, the principles that follow from it, then an entry per decision, then tokens as the last mechanical section:

```md
### D1. Serif text on warm paper
- **Decision:** what it is, with values.
- **Why:** the problem it solves, tied to your idea.
- **Instead of:** the obvious alternative, and why not.
- **Breaks if removed:** what goes wrong without it.
- **Trade-off:** what this costs, accepted.
- **Source:** brief | moodboard <file> | user answer Q1 | brand <file> | handbook <rule>
- **Reviewed:** kept
```

`why-lint.py` checks the form before anything is built, including that every token names its decision.

## When it asks you

If a why can't be answered from the brief, your idea or the mood board, it asks instead of inventing one: one specific question about one decision, with the options and what each costs, at most three in a project. Your answer goes into `STYLE.md` as the source of that decision. If it would need more, the brief is empty, and it goes back to that.

## How results are judged

No single score and no pass mark.

1. **Measurement disqualifies.** Contrast, type scale, typefaces, line length, touch targets, overflow, spacing, image and text, and whether the page matches `STYLE.md`. A FAIL is a FAIL.
2. **A judge on another model** can break ties, if one is available. It sees the result blind, then checks whether each written reason is honest or an excuse. It never sets a score.
3. **People decide.** For a redesign, show three people the before and after without saying which is new. The tool doesn't run or store a vote; that's yours to do.

## Brand mode: `/taste --brand`

For a product whose look you want to keep. It reads your style doc, your code and your rendered pages directly with `read-tokens.sh` (colors, greys, every border side, states, elevation, radii) and writes the handbook into your existing doc, or creates one. Problems a page already has aren't inherited: they still fail until they're fixed.

## The skills

Each works on its own. They hand over through files.

| Skill | Does | Writes |
|---|---|---|
| `/taste-brief` | The idea and its tension, a mood board if ambiguous, brand tokens in brand mode | `style/brief.md`, `style/references/`, `style/assets/` |
| `/taste-directions` | Two or three directions, and asks which you like most | `style/directions.html` |
| `/taste-why` | Writes the handbook, with the reviewer on every decision | `STYLE.md` |
| `/taste-validate` | Measures any page and captures it | `style/validate/<page>/` |

## Developing

The skills are linked into `.claude/skills/` (ignored by git) so `/taste` works inside this repo and edits show up at once. After a fresh clone, recreate the links:

```bash
mkdir -p .claude/skills && for d in skills/*/; do ln -sfn "../../$d" ".claude/skills/$(basename "$d")"; done
```

## Repo layout

```
skills/<name>/
  SKILL.md            the skill
  references/         copies of shared/references it needs
  scripts/            copies of shared/scripts it needs
  agents/             metadata for other agent tools
shared/
  references/         design handbook, assets guide
  scripts/            contrast checker, screenshots, token reader, handbook lint, page measurement
scripts/sync-shared.sh  copies shared/ into each skill
scripts/test-scripts.sh smoke-tests shared/scripts against tests/fixtures
tests/fixtures/       pages the smoke test runs on
```

Every skill installs on its own, so each carries its own copy of the shared files. Edit them in `shared/`, never in a skill, then run:

```bash
scripts/sync-shared.sh
```

`scripts/sync-shared.sh --check` fails if any copy is out of date.

After changing a script, run the smoke test:

```bash
scripts/test-scripts.sh
```
