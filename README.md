# salex-design-skills

Design skills for AI coding agents (Claude Code, Codex and others that read `SKILL.md`). Each skill lives in `skills/<name>/`.

## Install

```bash
npx skills add Salexmineralex/salex-design-skills --skill '*'
```

`/taste` needs all of them. To pick only some, leave out `--skill '*'` and choose. Install into a project (the default) or for every project with `-g`.

Needs Python 3 and Node (the screenshot helper uses Playwright, which downloads its own Chromium the first time, about 150 MB).

## `/taste`

Gives a project its own taste, with a reason behind every choice. It runs the six step skills below in order and owns the loop between judging and fixing.

1. **Interviews you about the design only** (`/taste-brief`): which version of the idea, why, the feeling, references. Questions come as clickable prompts, and a vague idea ("retro", "cyberpunk") gets a visual menu of readings and a moodboard request.
2. **Proposes three directions** (`/taste-directions`), one of them a wildcard built from random traits, each shown as a small real screen of your product, and **asks which one you like most**. The same prompt asks your pass mark (default 7) and how many judging rounds (default 5; 1 is light mode), with what each costs at worst (from about 40 minutes to about 2 hours).
3. **Writes `STYLE.md`** (`/taste-system`): idea, DNA, moodboard, palette (contrast checked), typography, spacing, shape, motion, every component with its states, voice and CSS tokens, grounded in a design handbook (Refactoring UI, Bringhurst, Butterick, Albers, Müller-Brockmann, WCAG).
4. **Builds `style/preview.html`** (`/taste-preview`), a Figma-like page with every token, component and state, plus typical screens at desktop and phone width.
5. **Has three expert judges score it** (`/taste-judge`): typography and layout, color and accessibility, art direction. Each is calibrated against a described 5 and 8 for its area. They score alone, then read each other's reviews and give a final score. A screenshot check catches broken phone layouts, overflowing text and overlapping elements first.
6. **Learns from the judges' notes and redesigns** until they reach your pass mark. It reads every round, fixes what they agree on first, changes the approach when a problem keeps coming back, and writes each lesson into `STYLE.md` so later pages follow it.
7. **Restyles your app** (`/taste-apply`) once you approve, and judges the real pages too. A big app goes in pieces: tokens and shared components first, a check with you, then groups of pages. With no app yet, the style becomes the foundation every later page follows.

Only you start it: type `/taste`, optionally with your idea. Say "light" for one quick judging round.

**If a run stops** (a usage limit, a closed session), type `/taste` again: it keeps a progress log in `style/brief.md`, checks it against the files, and offers to continue from the next step.

## The step skills

Each one also works on its own. They hand over through files, so you can stop after any step and pick up later.

| Skill | Does | Reads | Writes |
|---|---|---|---|
| `/taste-brief` | Interview, options page, moodboard | the project | `style/brief.md`, `style/options.html` |
| `/taste-directions` | Three directions, asks which you like most | `style/brief.md` | `style/directions.html`, the pick in the brief |
| `/taste-system` | The style guide | the brief | `STYLE.md` |
| `/taste-preview` | The preview page, checked with screenshots | `STYLE.md` | `style/preview.html` |
| `/taste-judge` | Three judges score any design and write a fix list. Only reports, changes nothing | any page, the preview or the app | `style/judging/round-<n>.md` |
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
  references/         design handbook, judges guide
  scripts/            contrast checker, random traits, screenshots
scripts/sync-shared.sh  copies shared/ into each skill
```

Every skill installs on its own, so each carries its own copy of the shared files. Edit them in `shared/`, never in a skill, then run:

```bash
scripts/sync-shared.sh
```

`scripts/sync-shared.sh --check` fails if any copy is out of date.
