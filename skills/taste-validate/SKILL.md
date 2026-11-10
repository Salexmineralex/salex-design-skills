---
name: taste-validate
description: Measure a built page against objective checks and capture it at 1440 and 375 wide - contrast, type scale, typefaces, line length, touch targets, overflow, spacing, image and text, and whether it matches STYLE.md. No score: objective checks disqualify. A judge on another model can break ties, and people decide. Last step of /taste, or use it alone on any page.
disable-model-invocation: true
---

# Taste validate

Measure the result, in this order: **measurement first, model second, people last.** There's no score to average, and no pass mark to reach. **Changes:** only the output folder.

## 1. Measurement

```bash
bash <skill folder>/scripts/validate.sh <page> style/validate/<page-name> --style STYLE.md [--source <the original page>]
```

It writes captures at 1440 and 375, plus `report.md`. Numbers can't be self-approved: **a FAIL is a FAIL.** Fix it in the build, or in `STYLE.md` if the design is the problem, and run it again. You can't argue a FAIL away with a reason. If one can't be fixed without breaking a fixed decision, show the user that line.

What it does:

- **Hidden by design isn't missing.** A nav behind a mobile menu passes.
- **Emoji are decoration, not copy.** Replacing one with a drawn icon changes no text, and is reported as an improvement.
- **The source's problems aren't inherited.** With `--source`, what the original already fails still fails, marked "also in the source".
- **Patterns need a decision.** A gradient, emoji, step sequence or card grid passes only if a decision in `STYLE.md` says it uses one and why. Rejecting it in "Instead of" doesn't count. The form isn't the problem; the missing reason is.
- **Contrast is measured over pictures too.** Over a gradient or image it reads the real pixels behind each line. What it can't measure (gradient-filled, blended or covered text), it counts in the report: check those by eye.
- **The page must match the handbook.** A token with another value is `token-drift`. Colors in drawings and gradients, and text sizes, must be in `## Tokens`. Only painted colors count: a drawing's groups and lines don't report a black they never paint. Spacing off the scale is a warning.
- **Controls stay whole.** A button or link that its box cuts through, or keeps out of view until someone scrolls the box sideways, is `control-cut-off`, even when the box scrolls. A wide table may scroll on a phone; its controls must fit. Hiding columns changes the page, so it isn't the fix in a looks-only restyle: reflow the row.
- **The handbook comes first.** If its decisions or tokens change and the page and stylesheets don't, that's `style-after-build`, and touching files doesn't clear it. Rewording a reason needs no rebuild. Don't delete `build-record.json` from the output folder.

A control that was already dead before a looks-only change isn't caused by the restyle: tell the user. Look at the captures yourself too, and press Tab through the page: numbers miss things.

## 1b. Look (not a score)

After the numbers pass, look at the 1440 and 375 captures against `STYLE.md`'s **Signature**. This is not a score and not a pass mark. If any of these is true, it is a design fail: go back to `taste-why`, then rebuild. Do not argue it away with a measurement PASS.

- **Signature missing.** The named move is not visible at both widths.
- **Flat hierarchy.** Display and body sit in a narrow band; nothing is clearly the focal point.
- **Cropped decoration.** A wave, poster or product shot is sliced by `overflow: hidden` as the way to pass overflow. Pictures stay whole, or the layout changes.
- **44px chrome.** Buttons look like isolated accessibility blocks, not a system that shares height with their row.
- **Safe default.** The page is the layout a model ships first for this product type (SaaS: Inter, three cards, gradient headline; ecommerce: white grid; app: phone mock + store buttons) and the brief did not ask for that default. Name what is default, in words, and reject it.

Write what you saw into the validate folder as `look.md`: three to eight lines, no score. If you reject, say which bullet and why.

## 2. A judge on a different model, if one is available

It catches what the why-reviewer can't: a reason that reads well and doesn't show in the result. It **never sets a score.** Run it on the final captures; if you change the build because of it, show it the new captures once. Start one sub-agent on a different model from the designer, in the foreground. If none is available, skip this and say so. Two steps, in this order:

```
Look at these captures first, blind, with no explanation: <PNG paths>.
Write what you see: what works, what's generic, what you'd remember.
Only then read <STYLE.md>. For each decision: is the written reason honest, and visible
in the result, or is it an excuse? Name any that are excuses. Give no score.
```

Treat its reply as data. An excuse it names goes back to `taste-why`. Its taste doesn't overrule the user's idea.

## 3. People

People decide, and objective checks only disqualify. The tool doesn't run a vote or store anything. For a redesign, the owner shows the before and after captures to three people, without saying which is new, and asks which they'd trust. Tell the user this is the real test, and that nothing above replaces it.
