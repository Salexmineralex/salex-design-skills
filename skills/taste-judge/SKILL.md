---
name: taste-judge
description: Have three independent expert judges (typography and layout, color and accessibility, and art direction, or brand fidelity for an existing brand) score a design - the style preview, a page, or a whole app - from screenshots at desktop and phone width, against reference anchors, optionally on a different model. They score alone, then read each other's reviews and give final scores. An automatic anti-slop check takes points off. Writes the reviews, the average and a fix list to style/judging/. Only judges and reports; it changes nothing. Used by /taste, or alone on any page.
disable-model-invocation: true
---

# Taste judge

Score a design with three expert judges and write down what they found. **This skill only judges.** It never edits the design, the style or the app: the notes are the output. (`/taste` and `/taste-apply` read the notes and make the fixes.)

**Changes:** only `style/judging/`: screenshots and the `round-<n>.md` or `app-round-<n>.md` notes.

## What to judge, and how

- **What:** `style/preview.html` if it exists and the user didn't name something else; otherwise the pages or URLs they name, or the app's main pages. If it's unclear, ask.
- **Brand mode:** on if `STYLE.md` has a `## Locked` section. Then the art direction judge is replaced by a brand fidelity judge, who compares the work with the brand's own pages, and originality isn't scored (`references/judges.md`).
- **Judge model:** same as the designer, a model your tool can launch sub-agents on, or a command that runs another tool. Take it from the settings or the user's message; a different model is the better test, because it doesn't share the designer's habits (`references/judges.md`, "A different model").
- **Settings:** the pass mark (default 7) and the mode: **thorough** (judges score alone, then discuss; the default) or **light** (they score alone, no discussion; faster and cheaper). Take them from the user's message or the run that called you; if the user started this skill alone and said neither, ask both in one prompt with the question tool (`AskUserQuestion` or your tool's equivalent), defaults first and marked "(Recommended)".
- **Round number:** one more than the highest existing note of that kind (`round-*.md` for the preview, `app-round-*.md` for an app).

## 1. Screenshots and the automatic check

Take screenshots of each frame (`#id`) or page at 1440px and 375px wide (pages and in-context screens at 820px too) into `style/judging/round-<n>/` (or `app-round-<n>/`), with a browser tool that saves files or this skill's `scripts/screenshot.sh` (`bash <skill folder>/scripts/screenshot.sh "style/preview.html#color" style/judging/round-1/color-1440.png 1440`; it captures only the frame with that id). Write down every warning it prints (sideways scroll, elements sticking out, cut-off content, overlaps, spilling text) and give them to the judges as facts. Don't fix them: run alone, you only report.

For an app, also note the "before" screenshots in `style/judging/before/` if they exist.

## 1b. Slop check and reference anchors

Read this skill's `references/anti-slop.md`. Run the check on every page or file you're judging:

```bash
bash <skill folder>/scripts/slop-check.sh <file-or-url> [--source <the original page>] [--locked STYLE.md] [--allow <waivers from the brief>]
```

Use `--source` whenever there's an original to compare with, `--locked` in brand mode, and `--allow` only for waivers written in the brief's `## Slop exceptions`. Keep the output: it goes to the judges as facts, and its highest `Penalty:` comes off the average. Run alone, you report it; you don't fix it.

Check that `style/references/` has anchors, and take them if it doesn't (`references/judges.md`, "Reference anchors").

## 2. The judges

Read this skill's `references/judges.md` and follow it exactly: what each judge gets, their briefs, the launch prompt, the scale and the output format.

1. Launch the three judges yourself, as independent sub-agents in one message so they run at the same time. Don't ask the user to start them.
2. **Thorough mode:** once all three have scored alone, send each one the other two reviews and get its final score ("Then they discuss").
3. Average the final scores, subtract the penalty and write the notes as "After the judges" says.

## 3. Report

Tell the user: whether the hard gate passes, the average, the penalty, the final score and whether it passes the mark, which model judged, each judge's score (first → final), any slop findings, the top problems with their fixes (agreed ones first), the disagreements, and where the notes are. Stop there. Run alone, suggest `/taste` or `/taste-apply` if they want the fixes made. Run as part of another skill, hand the notes back to it.

Screenshots are working files: if the user runs this alone and doesn't need them, offer to delete the images and keep the notes.
