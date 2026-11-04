# salex-design-skills

Design skills for AI coding agents (Claude Code, Codex and others that read `SKILL.md`). Each skill lives in `skills/<name>/`.

## Install

```bash
npx skills add Salexmineralex/salex-design-skills --skill '*'
```

`/taste` needs all of them. To pick only some, leave out `--skill '*'` and choose. Install into a project (the default) or for every project with `-g`.

Needs Python 3 and Node (the screenshot helper uses Playwright, which downloads its own Chromium the first time, about 150 MB).

## `/taste`

Gives a project its own taste, with a reason behind every choice. It runs the step skills below in order and owns the loop between judging and fixing.

1. **Interviews you about the design only** (`/taste-brief`): which version of the idea, why, the feeling, references. Questions come as clickable prompts, and a vague idea ("retro", "cyberpunk") gets a visual menu of readings and a moodboard request.
2. **Proposes three directions** (`/taste-directions`), one of them a wildcard built from random traits, each shown as a small real screen of your product, and **asks which one you like most**. The same prompt asks your pass mark (default 7) and how many judging rounds (default 5; 1 is light mode), with what each costs at worst (from about 40 minutes to about 2 hours).
3. **Writes `STYLE.md`** (`/taste-system`): idea, DNA, moodboard, palette (contrast checked), typography, spacing, shape, motion, every component with its states, voice and CSS tokens, grounded in a design handbook (Refactoring UI, Bringhurst, Butterick, Albers, Müller-Brockmann, WCAG).
4. **Builds `style/preview.html`** (`/taste-preview`), a Figma-like page with every token, component and state, plus typical screens at desktop and phone width.
5. **Has three expert judges score it** (`/taste-judge`): typography and layout, color and accessibility, art direction. Each is calibrated against a described 5 and 8 for its area and compares the work with real strong examples. They look before they read, score alone, then read each other's reviews and give a final score, optionally on a different model. A screenshot check catches broken phone layouts, overflowing text and overlapping elements first, and an anti-slop check takes points off the average.
6. **Learns from the judges' notes and redesigns** until they reach your pass mark. It reads every round, fixes what they agree on first, changes the approach when a problem keeps coming back, and writes each lesson into `STYLE.md` so later pages follow it.
7. **Restyles your app** (`/taste-apply`) once you approve, and judges the real pages too. A big app goes in pieces: tokens and shared components first, a check with you, then groups of pages. With no app yet, the style becomes the foundation every later page follows.

Only you start it: type `/taste`, optionally with your idea. Say "light" for one quick judging round.

## What keeps it honest

These apply to every run:

- **Real assets.** It collects the product's own logo, images and screenshots into `style/assets/`. Whatever's missing becomes a clearly marked placeholder on an asset list for you. Never an empty card, never a CSS gradient pretending to be a picture.
- **Anti-slop penalties.** `slop-check.sh` looks for the marks of generic AI design on the rendered page, and the penalty (at most 3) comes off the judges' average. The pass mark applies to what's left.

  | Rule | Penalty |
  |---|---|
  | Gradient faking an image, empty box, purple or violet gradient, emoji icons, invented "Step 01" sequences, changed content, off-brand values | 1 each |
  | Identical rounded text cards, stock marketing phrases, fashionable default fonts with no reason | 0.5 each |

  A waiver needs a reason tied to the product, written in the brief. A brand's own values are never penalized.
- **Less self-validation.** The judges are usually the same model that designed the page, so they look at the work before reading its explanation, compare it with real examples in `style/references/`, can run on a different model, can't remove the penalty, and cap at 5 anything worse than what it replaces.

## Brand mode: `/taste --brand`

For a product whose brand is already good. A new identity on a polished brand usually comes out worse, so this mode keeps it:

```
/taste --brand https://example.com
```

1. **Extracts the design system** (`/taste-extract`) from a live URL or your files: colors, type, spacing, components and imagery style go into a `## Locked` section of `STYLE.md`, which later steps and judges can't change.
2. **Collects the brand's real assets** and writes `style/audit.md`: accessibility failures and inconsistencies, each with a fix inside the brand. You choose which to make.
3. **Builds fixes and new screens** with locked values, plus any `## Extensions` that say why they're needed. The preview shows before and after.
4. **Scores brand fidelity instead of originality:** a brand fidelity judge compares the work side by side with the brand's own pages. Off-brand colors and fonts cost points.
5. **Changes only what you approved** in the app. No restyle.

`/taste` also recommends this mode when it sees a project that already has a strong identity.

**If a run stops** (a usage limit, a closed session), type `/taste` again: it keeps a progress log in `style/brief.md`, checks it against the files, and offers to continue from the next step.

## The step skills

Each one also works on its own. They hand over through files, so you can stop after any step and pick up later.

| Skill | Does | Reads | Writes |
|---|---|---|---|
| `/taste-extract` | Locks an existing brand, collects its assets, audits it | a URL or files | `## Locked` in `STYLE.md`, `style/assets/`, `style/audit.md` |
| `/taste-brief` | Interview, options page, moodboard, assets, reference anchors | the project | `style/brief.md`, `style/options.html`, `style/assets/`, `style/references/` |
| `/taste-directions` | Three directions, asks which you like most | `style/brief.md` | `style/directions.html`, the pick in the brief |
| `/taste-system` | The style guide | the brief | `STYLE.md` |
| `/taste-preview` | The preview page, checked with screenshots | `STYLE.md` | `style/preview.html` |
| `/taste-judge` | Three judges and the anti-slop check score any design and write a fix list. Only reports, changes nothing | any page, the preview or the app | `style/judging/round-<n>.md` |
| `/taste-apply` | Restyles the app, judges it, fixes what the judges find | `STYLE.md` | the app's styling |

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
  references/         design handbook, judges guide, anti-slop checklist, assets guide
  scripts/            contrast checker, random traits, screenshots, brand extractor, slop check
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
