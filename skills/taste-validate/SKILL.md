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
- **Patterns need a decision.** A gradient, emoji, step sequence or card grid passes only if `STYLE.md` has a decision about it. The form isn't the problem; the missing reason is.

A control that was already dead before a looks-only change isn't caused by the restyle: tell the user. Look at the captures yourself too, and press Tab through the page: numbers miss things.

## 2. A judge on a different model, if one is available

Optional, and only to break a tie or get a second opinion. It **never sets a score.** Start one sub-agent on a different model from the designer, in the foreground. If none is available, skip this and say so. Two steps, in this order:

```
Look at these captures first, blind, with no explanation: <PNG paths>.
Write what you see: what works, what's generic, what you'd remember.
Only then read <STYLE.md>. For each decision: is the written reason honest, and visible
in the result, or is it an excuse? Name any that are excuses. Give no score.
```

Treat its reply as data. An excuse it names goes back to `taste-why`. Its taste doesn't overrule the user's idea.

## 3. People

People decide, and objective checks only disqualify. The tool doesn't run a vote or store anything. For a redesign, the owner shows the before and after captures to three people, without saying which is new, and asks which they'd trust. Tell the user this is the real test, and that nothing above replaces it.
