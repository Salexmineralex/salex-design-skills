---
name: taste
description: Give a project its own taste. Interview me about the idea and the why behind it, ask for a moodboard when the idea is unclear, propose three directions (one deliberately random) and ask which I like most, then write STYLE.md (idea, moodboard, palette, typography, components, rules grounded in design handbooks) and a Figma-style preview page. Three expert judges score it; it learns from their notes and redesigns until they reach my pass mark (default 7, up to 5 rounds, or one quick round in light mode). Once I approve, the whole app is restyled to match. If STYLE.md or DESIGN.md already exists, redesign from it. For a product with a brand worth keeping, /taste --brand <url or files> locks the existing design system instead, then audits it, fixes it and builds new screens in-brand, scored on brand fidelity.
disable-model-invocation: true
---

# Taste

Turn a loose idea ("retro", "pirates", "skateboard", "calm and natural") into a style with a reason behind every choice: a `STYLE.md` that other agents build from, a preview page where the user sees it first, and then the whole app restyled to match.

This skill conducts seven step skills, each of which also works on its own. It runs them in order, carries the user's answers from one to the next through `style/brief.md`, and owns the loop between judging and fixing: the judges only write notes, and this skill learns from them and makes the changes.

| Step | Skill | Writes |
|---|---|---|
| 0. Extract (brand mode) | `taste-extract` | the `## Locked` section of `STYLE.md`, `style/assets/`, `style/audit.md` |
| 1. Brief | `taste-brief` | `style/brief.md`, `style/options.html`, `style/assets/`, `style/references/` |
| 2. Directions | `taste-directions` | `style/directions.html`, the pick in the brief |
| 3. Style | `taste-system` | `STYLE.md` |
| 4. Preview | `taste-preview` | `style/preview.html` |
| 5. Judging | `taste-judge` | `style/judging/round-<n>.md` |
| 6. App | `taste-apply` | the app's styling, `style/judging/app-round-<n>.md` |

**Changes:** `STYLE.md` at the repo root, the `style/` folder and, once the user approves the style, the app's styling. Never the app's behavior, text or structure.

## Three things every run does

- **Real assets.** Everything is built with the product's real logo, images and words, collected into `style/assets/`. What's missing becomes a marked placeholder on an asset list for the user. Never an empty card, never a gradient faking an image.
- **Anti-slop.** `slop-check.sh` looks for the marks of generic AI design, and its penalty comes off the judges' average. The pass mark applies to what's left.
- **Judges who aren't just agreeing with themselves.** They look before they read, compare with real strong examples in `style/references/`, and can run on a different model.

## Brand mode

Use it when the user says `--brand`, passes a URL or files with "keep our brand", or chooses it when `taste-brief` recommends it. A polished brand doesn't need a new identity: a redesign usually comes out worse, with less product and more decoration. So the deliverable changes from a new style to an audit, fixes and extensions, and the run changes like this:

| Step | In brand mode |
|---|---|
| 0. Extract | **Runs first.** `taste-extract` writes `## Locked`, collects the assets and writes `style/audit.md`. |
| 1. Brief | One short round: the job, the new screens, what's off limits. No options page or moodboard. |
| 2. Directions | **Skipped.** There's no identity to choose. Ask the settings in their own prompt, and show the audit: ask which items to fix, with multi-select. |
| 3. Style | Adds to `## Extensions` only. Locked values never change. |
| 4. Preview | Shows the brand's inventory, the audit as before and after, extensions and the new screens. |
| 5. Judging | A brand fidelity judge replaces art direction; originality isn't scored. Colors and fonts outside `## Locked` and `## Extensions` cost a penalty. Anything worse than the brand's own page is capped at 5. |
| 6. Show the user | The same. Before and after, side by side. |
| 7. App | Only the approved fixes and new screens. No restyle. |

Write `Brand mode: yes` in `## Settings`. If a judge or the audit wants a locked value changed, that's a question for the user, never a fix you make.

## Running a step

The step skills are installed next to this one: `<skills folder>/taste-brief/SKILL.md` and so on, where `<skills folder>` is the folder that holds this skill's folder. For each step, read that step's `SKILL.md` and follow it, with these differences:

- **Don't stop between steps.** Where a step says "run alone, tell the user…", go straight on to the next step instead. `taste-apply`'s clean-point check counts only the app's own files: `STYLE.md`, `style/` and `AGENTS.md` from this run don't count as uncommitted changes. Questions a step asks along the way still get asked: the interview, which direction, which audit items, and the check after the first piece of a big restyle.
- **Use each step's own `references/` and `scripts/`.** They are the same files in every step.
- **Carry the settings** (below) into every step that judges.

If a step skill is missing, tell the user and give the install command, then stop: `npx skills add Salexmineralex/salex-design-skills --skill '*'`.

## Keep a progress log

A full run can stop halfway: a usage limit, a closed session, a crash. So the run writes down where it is as it goes. After each step, and after each judging round, update `## Progress` at the end of `style/brief.md`:

```md
## Progress
- [x] Extract (brand mode only): 12 values locked, 9 audit items, 3 assets needed
- [x] Brief (while waiting: `- [ ] Brief: round 1 sent, waiting for answers`)
- [x] Directions: B. Logbook (brand mode: skipped; audit items chosen)
- [x] Settings: thorough, pass mark 7, 5 preview rounds, 3 app rounds, judges on another model
- [x] Style: STYLE.md
- [x] Preview: style/preview.html
- [ ] Judging: round 1 6.2 − 1 = 5.2, round 2 6.8 − 0 = 6.8 (started 14:05, about 9 min a round)
- [ ] Approved by the user
- [ ] App: restyled pieces: tokens, components (pages left: settings, billing)
- [ ] Clean up
```

Write it the moment a step finishes, not at the end: if the run stops between two steps, the log is the only thing that remembers the first one finished.

## Resume a stopped run

Before anything else, check whether a run is already under way: `style/brief.md` with a `## Progress` section whose last box isn't ticked. If there is one:

1. **Check the log against the files.** The files win: a ticked step whose file is missing isn't done, and a round folder with screenshots but no `round-<n>.md` is a round that stopped halfway; redo that round from the screenshots, fresh judges.
2. **Sum it up for the user in three lines:** the idea and the picked direction, the last step finished, and the scores so far.
3. **Ask with the question tool:** "Continue from <next step>" (Recommended), or "Start over" (the old brief moves to `style/history/<date>/`, with the notes, so nothing is lost).
4. **Continuing, skip everything finished.** Don't re-interview, don't re-propose directions, don't ask the settings again: they're in the brief. Re-read the brief, `STYLE.md` and every round's notes first, since you don't remember them; the files are the whole memory of the run. Then go on from the next unticked step.

With no run under way but a `STYLE.md` already there, it's a redesign, not a resume: start at step 1, which handles it.

## Your role

You know more about design than the user: lead with a recommendation, explain the rule behind it in one line, and push back when a request breaks a rule. Always ask why for every big choice, and never follow a trend without one. The user still decides; the step skills say how.

## Settings

Four settings shape the cost of a run and how far to trust it:

- **Pass mark:** what the final score must reach: the judges' average minus the slop penalty. Default **7**.
- **Most rounds:** how many judging rounds on the preview before stopping. Default **5**. The app gets at most 3 (or this number, if it's lower).
- **Mode:** **thorough** (judges score alone, then discuss) or **light** (one round, no discussion, the user sees it whatever the score). One round means light mode.
- **Judge model:** who judges. The same model as the designer shares its habits and tends to like its own work; a different one is a harder test. Light mode doesn't change this.

### What it costs

Most of the cost is judging: every round starts 3 judge agents, and in thorough mode each one also reads the other two reviews and answers. Building the brief, style and preview takes about 20 minutes; each judging round, with its fixes, about 10 more. (Measured: one test run took 44 minutes for the style, the preview and 2 rounds; another took 55 minutes for everything, with 2 preview rounds, 2 app rounds and the restyle, where the judging itself was about 4 minutes a round and the fixes took the rest.) Many runs pass in 2 rounds; a hard brief uses them all.

| Rounds | Judges at most (preview + app) | Time at most |
|---|---|---|
| 5 (thorough) | 15 + 9 = 24, each also discussing | about 1½–2 hours |
| 3 (thorough) | 9 + 9 = 18, each also discussing | about 1¼ hours |
| 1 (light) | 3 + 3 = 6, no discussion | about 40 minutes |

These are worst cases, without the app restyle itself (which depends on the app's size) or time spent waiting for the user. Tell the user they're estimates. After the first judging round, time it and correct the estimate for what's left ("Round 1 took 12 minutes; at most 4 more rounds, so up to 50 more minutes"), and write the time per round into `## Progress`.

### Asking

At the start, say in one line which mode you're running and its worst case, and that you'll confirm it later ("Running thorough mode: pass mark 7, up to 5 judging rounds, up to about 2 hours. Say 'light' for about 40 minutes; I'll confirm the settings when you pick a direction."). If the user said "light", "quick", "fast" or "cheap", or gave a mark or a number of rounds, use what they said.

Otherwise ask, but don't add a prompt for it: put three questions into the same prompt as step 2's "Which direction do you like most?", right before the expensive part starts. If the direction was picked with an inline button instead of the prompt, ask these three in a prompt of their own right after the pick. In brand mode there's no direction question, so they get their own prompt after the brief. Put the cost in the descriptions, so it's a real choice:

- **"Pass mark"**: 7 (Recommended, "good and shippable"), 8 ("strict: usually needs more rounds"), 6 ("works, with visible problems; fewer rounds").
- **"Judging rounds"**: 5 (Recommended, "best result; up to 24 judges and about 2 hours at worst"), 3 ("up to 18 judges, about 1¼ hours at worst"), 1 ("light mode: 6 judges, no discussion, about 40 minutes").
- **"Judge model"**: a different model (Recommended when your tool can launch one, naming it and saying what it costs compared with the current one, "a harder, more independent test"), the same model ("simplest; it shares the designer's taste"), or a command for another tool, typed as their own answer.

Write them into `style/brief.md`:

```md
## Settings
Mode: <thorough | light>. Brand mode: <yes | no>. Pass mark: <p>. Most rounds: <n> on the preview, <m> on the app. Judge model: <same | model | command>.
```

## The run

0. **Resume?** Check for a stopped run first (above). **Brand mode?** Follow `taste-extract`.
1. **Brief.** Follow `taste-brief`. If it recommends brand mode and the user agrees, follow `taste-extract` now, and go on as "Brand mode" says.
2. **Directions.** Follow `taste-directions` (not in brand mode). Its last question asks which direction the user likes most; add the settings questions to that same prompt. Never pick the direction for them.
3. **Style.** Follow `taste-system`.
4. **Preview.** Follow `taste-preview`.
5. **Judge, learn, redesign.** Follow `taste-judge` with the settings, then act on its notes as "Learn from the judges" says. Repeat until the final score reaches the pass mark or the most rounds are used. Don't ask the user between rounds: judging and redesigning are part of this skill.
6. **Show the user and iterate.** Open the preview (`open style/preview.html` on macOS, `xdg-open` on Linux) and tell the user where it is, with every round's scores, penalties and what changed because of the judges, plus the assets still needed (`## Needed` in `style/assets/assets.md`). Ask what feels off. Translate vague feedback into design terms before changing anything: "too boring" might mean too little contrast, too even a type scale or no signature move. Say which one you think it is, change `STYLE.md` through `taste-system`, rebuild through `taste-preview`, and judge again (step 5), so the user never sees a version below the pass mark. Repeat until the user approves the style.
7. **Restyle the app** (in brand mode, make the approved fixes and new screens). Once the user approves, follow `taste-apply` with the settings. If there's no app yet, skip this and say so: the style is the foundation every later page follows.

## Learn from the judges

`taste-judge` only writes notes. After each round, you read them and make the changes:

1. **Read every round's notes, not just the last one** (`style/judging/round-*.md`).
2. **Make the fixes**, through `taste-system` ("Fixing after the judges") and then `taste-preview`: problems two or more judges agree on first, then the lowest-scoring judge's. Where judges disagree, the brief decides; note the trade-off for the user.
3. **Settle a trade-off once.** Fresh judges don't know what earlier rounds decided, so a settled question comes back every round (in one test the red X on book covers flip-flopped for three rounds). When you settle one, add it to `## Fixed decisions` in `style/brief.md` as "Settled: <the choice>, because <the brief's reason>". Judges get the fixed decisions, so later rounds work within it instead of reopening it.
4. **A problem that comes back in a later round means the fix didn't work.** Don't nudge the same value again: find the cause and change the approach (in one run, the dark keys' travel kept showing a ghost line for three rounds until the two layers became one slab with one outline). Write the lesson into `STYLE.md`'s `## Do and don't`, so the app restyle and every later page follow it.
5. **Slop findings are fixes like any other,** unless the brief waives them with a reason. Don't waive a rule to reach the pass mark: a waiver needs a reason tied to the product, and you tell the user about each one.
6. **Passing doesn't end the round's work, and doesn't restart the loop either.** After a passing round, make the fixes the judges listed without a new round when each one adjusts a value, a token or a component, or repairs a bug (a misaligned button, a missing state, a contrast pair a shade too light, a color used in one place too many). Only a change to the idea itself means judging again: a new font, a new palette, or a new signature move. After those fixes, rerun the screenshot and slop checks, and tell the user the score is for the version before them. Otherwise a passing run never stops, because judges always list something.
7. **Never let the judges overrule the user.** A fix that breaks a fixed decision or a locked value isn't made; find another one, or tell the user at the end.
8. **Light mode:** one round only. Make the quick fixes, then show the user the scores, with the bigger changes as options.
9. **Out of rounds and still below the mark:** stop and show the user every round's scores and the problems that keep coming back. Usually that means the brief has a conflict only the user can settle.

## Clean up

Screenshots are working files, not deliverables, and they add up fast (a thorough run easily leaves 10 MB or more). Once the user has approved the style (and the app restyle, if there was one) and has seen the before and after screenshots, delete every image in `style/judging/` and its subfolders, including the options and directions shots, and the screenshots and raw downloads in `style/extract/`. Keep `style/assets/`, `style/references/`, `extract.json`, the `*.md` notes and `style/brief.md`: they're small and they record why each choice was made. Tick the last box in `## Progress`, so a later `/taste` sees the run as finished.

## Finish

Say: "Style saved to `STYLE.md`, preview at `style/preview.html`, judged <final score> on the preview and <final score> on the app, and the app restyled (<pages>)." In brand mode, say what was fixed and which screens were added instead. List any assets still needed, and which model judged. Then make sure future work follows it: offer to add one line to `AGENTS.md` (or to create `AGENTS.md` with it, if there isn't one): "UI work follows `STYLE.md`: use its tokens, don't invent new values." Without that line, the next agent that builds a page won't know the style exists.
