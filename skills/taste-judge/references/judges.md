# Judges

Three independent experts score the style before the user sees it, and again on the real app after the restyle. Each one looks at one thing only, so their notes don't blur together, and none of them saw the design being made, so they judge what's on the page and not the intentions behind it.

The judges are usually the same kind of model that made the design, so they tend to like what it likes. Everything here pushes against that: they look before they read, they compare with real work, a different model can judge, and the anti-slop penalty isn't up to them.

## What each judge gets

Start each judge as a separate sub-agent, all three at the same time. Give each one:

- its brief from below, word for word
- **Required files:** the launch prompt lists them all, and each judge ends by listing what it opened. Anyone who skipped some is sent back before its score counts
- **Screenshots first.** They look at the work and at the reference anchors, and write down a first impression, before reading any explanation of it
- `STYLE.md`, and this skill's `references/handbook.md` (especially **Polish**) and `references/anti-slop.md`
- **Reference anchors:** the screenshots in `style/references/` with `references.md`, which says what each one is (see "Reference anchors")
- **The slop report:** the output of `scripts/slop-check.sh`, as facts
- **Preview rounds:** the screenshots of each frame of `style/preview.html` at 1440px and 375px (and the in-context screens at 820px), and the path to `preview.html` in case it wants to read the code
- **App rounds:** the screenshots of every page of the restyled app at 1440px, 820px and 375px, the "before" screenshots, and the paths to the pages and stylesheets
- **Brand mode:** the brand's own screenshots as well (`style/extract/*/page-*.png`), the `## Locked` section of `STYLE.md` and `style/audit.md`
- the **brief from the user**: what's being styled, who it's for, the idea, the why, the three feeling words, the anti-feelings, and the must-haves
- the **surface mode** of each screen from the brief: judge a dashboard as a tool and a landing page as a pitch
- the **fixed decisions**: choices the user made explicitly (a brand color, a font they insisted on, dark mode), and trade-offs settled in earlier rounds (`Settled:` lines in the brief). Judges must work within them and never ask to change them

If there's no `STYLE.md` (judging a page that has no style doc), give them the page's own stylesheet instead and skip anything that compares against `STYLE.md`.

Don't tell them the pass mark: a judge who knows the line tends to land on it. Don't give them earlier rounds' scores, your reasoning or what you changed since last round, and don't show them each other's reviews until the discussion step. Fresh eyes avoid anchoring. This holds for every judge in every round, in every mode.

### Reference anchors

A score means little in a vacuum. Judges compare the work with real, strong examples: 3 to 6 screenshots in `style/references/`, listed in `style/references/references.md` with what each one is and why it's a good example. In brand mode that's the brand's own best pages plus two or three competitors; otherwise it's the user's references and two or three strong products in the same field.

If there are none yet, take them before judging: `scripts/screenshot.sh <url> style/references/<name>-1440.png 1440`. A site that refuses the screenshot is skipped, not fought. If no anchors can be had, say so in the notes: the scores then rest on the written anchors alone.

Anchors set the bar. They're never something to copy, and a design doesn't lose points for being unlike them.

### A different model

A different model doesn't share the designer's habits, so its praise means more. The run's settings name the **judge model**:

- **Same** (the default if nothing else is available): launch the judges as usual.
- **A model your tool can launch sub-agents on** (the `model` option of the Agent tool in Claude Code): launch all three judges on it.
- **A command the user gives** that runs another tool, reading the prompt on standard input and printing its reply: run it once per judge, with the filled-in launch prompt. Check first that it can read the screenshots; a judge that can't see them can't judge.

Write the model into the notes (`Judges: <model>; designer: <model>`), so a score can be read for what it is. If the chosen model can't be reached, say so and ask; don't fall back quietly.

### Launching them

You launch the judges yourself; the user never has to. Send all three launches in the same message so they run in parallel, each one a general-purpose sub-agent (the Agent or Task tool) with this prompt, filled in:

```
You are the <judge name> for a design review. Work alone and only judge.

Your brief:
<the judge's brief from below, word for word>

Scale, anchors and output format:
<the "Scale" section, your own pair from "Anchors", the paragraph after the pairs, and the "Output format" section, all word for word>

Look first, in this order, before reading anything else:
1. Screenshots of the work: <list of PNG paths, each with its width and what it shows>
2. Reference anchors: <list of PNG paths, each with what it is>
3. In brand mode, the brand's own pages: <list of PNG paths>
Write down your first impression in one line: would you put this next to those anchors?

You must open every screenshot listed, phone and tablet included. End your reply with `Opened:` and the files you opened.

Then read:
- <path to STYLE.md>
- <path to this skill's references/handbook.md>
- <path to this skill's references/anti-slop.md>
- Code, if you need it: <paths to preview.html, or the app's pages and stylesheets>

The automatic slop report, as facts: <the output of slop-check.sh>
The penalty is applied separately. Don't lower your score for what it lists; do list what only eyes can catch.

Bold choices (protected; say if one has no visible job, but don't flatten it for being unusual): <the `## Bold choices` section, or "none">
If this is a restyle, the words and structure can't change: fixes may not add or remove text. Propose a visual fix instead.

The user's brief: <what's styled, who for, the idea, the why, feeling words, anti-feelings, must-haves>
Fixed decisions (don't ask to change these): <list, or "none">

Reply with your review in the output format and nothing else.
```

Each judge's reply comes back to you; you average and save them (see "After the judges").

Only if your tool truly can't start sub-agents, run the three judgements one after another yourself, reading only the brief for that judge each time, and say in the report that the judges weren't independent. A judge failing to start (an error, a usage limit) isn't that case: wait and launch it again.

## Scale (shared by all three)

Tell every judge to be strict. A 7 is not a polite default. Compare against what a strong senior designer would ship for this brief, not against the "before" version.

**Caps:** whatever else is good, a judge scores no more than 5 if:

- any page scrolls sideways or breaks at 375px wide, or controls that sit together are visibly misaligned. These are the first things a user notices.
- **it's worse than what it replaces.** If there's a "before" or a brand's own page and you'd rather ship that, the redesign failed, however tidy it is.

**An 8 or more must hold up next to the reference anchors.** If it would look like the weak one on that page, it's a 7 at most.

- **9–10:** exceptional; a senior designer would put it in their portfolio. Rare.
- **7–8:** good and shippable; small fixes only.
- **5–6:** works, but a trained eye spots clear problems or it feels generic.
- **3–4:** real problems: it breaks core rules or misses the brief.
- **1–2:** doesn't work.

## Anchors: what a 5 and an 8 look like

The judges are the same kind of model that made the design, so left alone they drift: too kind to work that looks like their own, or a point up or down from one round to the next. These anchors pin the scale. Each judge gets the pair for its own area, and must say which one the work is closer to before scoring.

**Typography and layout**
- **A 5:** a sensible pairing used without care. The scale has steps that are too close (16, 18, 20) so headings barely stand out; body lines run 90+ characters on desktop; buttons in a row are 40, 44 and 48px tall; the phone view is the desktop squeezed, with a cramped table and a hero heading breaking into one word per line.
- **An 8:** the pairing has a clear job each (one for voice, one for reading); the scale has a steady ratio and every frame has one obvious focal point; body text sits at 60–70 characters with a line height that reads easily; everything aligns to one spacing scale; the phone view is designed, not shrunk. A trained eye finds only one or two small things (a label 2px off its baseline, one cramped gap).

**Color and accessibility**
- **A 5:** every text pair passes 4.5:1, but the palette is a default with a hue swapped in: pure grays, the accent used on half the page so it means nothing, a focus ring that's the browser default or barely visible on one surface, dark mode that's the light mode inverted with the accent glaring.
- **An 8:** roles are clear and the accent is scarce enough to point at the one thing to do; neutrals are tinted toward the palette; every state (hover, focus, disabled, error) is distinguishable without color alone; dark mode is designed (its own surfaces, the accent toned down, contrast rechecked). One or two pairs are just above the line where a shade more margin would be safer.

**Art direction**
- **A 5:** the idea is visible on the cover and nowhere else: a themed font in the hero, then generic rounded cards and a default dashboard. It leans on clichés of the theme (skulls for pirates, neon glow for cyberpunk) rather than its systems. With the logo removed, it could be anyone's product.
- **An 8:** the DNA shows in every frame, down to the form fields and the empty state; it borrows the theme's systems (a logbook's ruled lines, a chart's grid, a print's registration marks) and keeps the core clean; one signature move is used consistently and with restraint. With the logo removed, you'd still know whose it is. What keeps it from a 9: one component that feels from a different world, or a move overused once.

**Brand fidelity** (replaces art direction in brand mode)
- **A 5:** it uses the brand's colors and fonts, but the page is somebody else's: new proportions, a new kind of card, stock imagery or gradients where the brand shows its product, a new tone of voice. Next to the brand's own pages, it looks like a competitor's imitation.
- **An 8:** put it next to the brand's own pages and it's hard to tell which one is new: the same type rhythm, spacing, image treatment and component shapes, and real assets throughout. The fixes are visibly improvements. What keeps it from a 9: one extension that's correct but a little less sure of itself than the original.

Scores between and beyond the anchors follow from them: a 6 is a 5 with one or two of its problems fixed, a 7 is close to the 8 but with a clear problem left, a 9 beats the 8 in a way you can name.

## Output format (shared by all three)

```md
## <Judge name>
Anchor: <closer to the 5 or the 8, and the one thing that decides it>
Score: <1–10>

What works:
- …

Problems, worst first (at most 5):
1. <problem> → <concrete fix, with exact values where possible> (<rule from the handbook, or the part of the brief it misses>)

Verdict: <one sentence>
```

A problem without a concrete fix isn't useful. "The colors feel off" isn't feedback. "The accent #E84A27 on the cream surface is 3.1:1, so small links fail; darken it to #C23A1B" is.

## The three judges

### 1. Typography and layout judge

> You're a senior typographer and layout designer, trained on Bringhurst, Butterick, Lupton and Müller-Brockmann. Judge only typography, hierarchy, spacing and layout; ignore color and the concept unless they break readability. Check: the pairing (two families at most, real contrast between them, fits the idea), the type scale (consistent ratio, enough steps, not too many), body size and line height, line length (45–75 characters), letter spacing, the use of all caps, display fonts kept out of body text and forms, a clear focal point and hierarchy on each frame, a consistent spacing scale, grouping by proximity, alignment to a grid, whether the in-context screens and the phone view still read well, and the **Polish** rules from the handbook: controls in a row share one height and line up, text fills its box, badges sit in a clear spot, disabled looks disabled, edges line up. Look at the phone screenshots as carefully as the desktop ones, and at the focus states: the ring fits the component's shape and shadow. Score it from 1 to 10 using the shared scale and format.

### 2. Color and accessibility judge

> You're a senior color and accessibility specialist, trained on Albers, WCAG 2.2 and Refactoring UI. Judge only color, contrast and accessibility. Check: the palette defined by roles, tinted neutrals, the 60/30/10 balance and a scarce, meaningful accent, saturated colors vibrating against each other, every text and background pair (4.5:1 for normal text, 3:1 for large text, UI borders, icons and focus rings), meaning never carried by color alone, visible focus states, touch targets, every component state present and distinguishable, and dark mode if there is one (not just inverted, contrast rechecked). Run the contrast script on any pair you doubt: `python3 <skill folder>/scripts/contrast.py "#text:#bg"`. Score it from 1 to 10 using the shared scale and format.

### 3. Art direction judge

> You're a senior art director. Judge only the concept: does this look like the idea in the brief, for these users, with these feelings? Check: the DNA is visible on every frame, not only the cover; it borrows the theme's systems (materials, printing, lettering, places) instead of its clichés; it puts the theme at the edges and keeps the core clear; it has one memorable signature move used consistently; every component looks like it belongs to the same world; it avoids the anti-feelings; and it doesn't look like the generic default (Inter, rounded gray cards, purple gradients) unless the brief asked for that. Go through "What only eyes can catch" in the anti-slop checklist, and list what you find as problems. Ask yourself: if you saw this with the logo removed, would you know whose product it is? **Then answer: what would you remember about this tomorrow? Name it in your review. If the honest answer is nothing, score no more than 6, however clean it is.** Check that the work matches the energy, rhythm and motion dials in `STYLE.md`. Score it from 1 to 10 using the shared scale and format.

### In brand mode

The brief is to serve an existing brand, not to invent one, so **nobody scores originality**. Replace the art direction judge with this one, and tell the other two: locked tokens are given; a problem with one goes in as a proposed extension, never as a change to the token.

### Brand fidelity judge

> You're the brand's senior design director, and you've looked after this identity for years. Judge only whether this belongs to the brand. Compare it side by side with the brand's own pages. Check: type rhythm, spacing and proportions match the originals, not just the fonts and hex values; components have the brand's shapes and states; imagery is the brand's real assets, with placeholders clearly marked and no gradients or stock standing in; the voice is unchanged and no content was invented; extensions look as if the brand's own team made them; audit fixes solve the problem without changing the character. On a new screen, check every section, number and example against the brief: content lifted from the brand's other pages that has nothing to do with this screen is a fault. Originality earns nothing here: a new idea that isn't the brand's is a fault, however good it is. Go through "What only eyes can catch" in the anti-slop checklist too. Score it from 1 to 10 using the shared scale and format.

## Then they discuss

(Thorough mode only. In light mode, a single round, the judges score alone and you go straight to "After the judges".)

Each round has two steps. **First, alone:** the three judges score in parallel, without seeing each other's reviews, so each view is formed independently and nobody anchors on someone else's number. **Then, together:** once all three reviews are in, every judge reads the other two and can respond.

Start **a new sub-agent for each discussion**, and wait for its result before going on; don't message the earlier judges, because replies that arrive in the background stop runs partway. Launch all three in one message, in the foreground if your tool lets you choose. Give each one its brief, its own review and the other two reviews **in full, not summarized**, and the same screenshots. Ask:

```
Here are the other two judges' reviews. Reply in this format:

Agree: <problems from the others you also see, and would add to your own list>
Disagree: <anything you think is wrong or doesn't matter for this brief, and why>
Missed: <anything you now notice that nobody raised, if any>
Final score: <1–10> (<"unchanged" or one sentence on why it moved>)
```

The rules for this step, to give to each judge with the reviews:

- **Stay in your own lane.** Your final score is still about your area only. Another judge's problem can move your score only if it hurts your area too (a contrast problem that also breaks the hierarchy, say).
- **Move only for a reason you can point to on the screen.** Changing your score to match the others, or to land on the pass line, isn't a reason.
- **Disagreeing is useful.** If you think another judge is wrong, say so and why; the designer settles it with the brief.

## After the judges

Average the three **final** scores (one decimal place; in light mode, the first scores). Then subtract the slop penalty: the highest `Penalty:` that `slop-check.sh` gave on any page of this round. The judges don't decide the penalty, and a discussion can't remove it. Save everything to `style/judging/round-<n>.md` (app rounds: `style/judging/app-round-<n>.md`):

- `Judges: <model>; designer: <model>`, which anchors they saw, and what each judge actually opened. A judge who skipped the phone views or `STYLE.md` hasn't finished: send it back before counting its score
- each judge's first impression, review and discussion reply, with the first and final scores
- `Average: <x> − penalty <y> = final <z> (pass mark <p>: passed | not passed)`, and `Hard gate: PASS | FAIL`. A hard-gate failure means not passed, whatever the score
- the slop report, with waivers and their reasons
- **Fix list:** every problem with its fix, problems two or more judges agree on first, then the lowest-scoring judge's
- **Disagreements:** where the judges pulled in opposite directions, and which way the brief points
- **Blocked:** fixes that would break a fixed decision, so they're not made

The pass mark is 7 unless the user chose another one (the run's settings say which). Scoring exactly on the mark is a **borderline pass**: say so in the notes and to the user, and don't describe it as a clear pass.

What happens next depends on who ran the judges. `/taste-judge` on its own stops here and reports the notes; it changes nothing. `/taste` and `/taste-apply` read the notes and act on them, as their own instructions say.
