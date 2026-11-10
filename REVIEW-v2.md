# Review: why `feature/style-md-handbook` looked worse

Written after re-reading every skill on the branch and the four live runs in `/opt/cursor/artifacts/handbook-live` (stripe-brand, stripe-free, google, flowai).

The owner is right. The handbook pipeline made pages that pass the script and still look like cautious clones of the sources, flatter and more “accessibility chrome” than designed. That is not a scoring miss. It is the skills asking the wrong things, and then filling the rest.

## What the live runs actually did

- **Same page, same bones.** The job was “restyle only: keep the text, language and structure.” The skills have no step that is allowed to invent a visual idea bigger than CSS on the existing DOM. The after pages are the sources with more padding, clamped type, a hamburger, and 44px min-height. Google at 1440 is almost a screenshot of Google. That is obedience to a restyle constraint, not a design.
- **Validate only disqualifies numbers.** Contrast, overflow, 24px taps, token-drift, unreasoned patterns. It cannot say “this is generic.” The runs were steered to PASS: crop the Stripe wave until overflow stops, bump every control to 44px, lock Inter and the FlowAI glow because the source had them. WARNs (wave cut off, spacing off the scale) were left as WARNs. Nothing asks whether the page looks designed.
- **Whys that are copies.** Stripe-brand D1–D4 and D7 are “the rendered page already uses this.” FlowAI D2 is “the source already sets Inter.” Google D2 is “the source ships Arial.” The why-reviewer tests SWAP/CAUSE/CHOICE/OPEN. It does not fail a reason whose only fact is “the source did it.” Off brand-lock (stripe-free, google, flowai) that is not a why. It is a refusal to choose, dressed as a reason.
- **Questions were skipped, then faked.** The brief was thin (“modernise… accessible; mobile-first”). taste-brief allows at most three questions and says if the message already answers them, ask nothing. The runs invented audience, feeling and product truth, wrote them into the brief, and marked Q1/Q2 as “test stand-in, not a user answer.” The pipeline acted as if it knew why Stripe’s violet, why Inter, why a night studio. It did not. It guessed.
- **No signature, weak hierarchy.** STYLE.md has Idea, Principles, Decisions, Tokens. There is no named move the page must show. Display type was clamped down so Spanish would fit, so the hero got quieter than the source, not louder in the right place. Scale contrast went the wrong way.
- **Imagery strategy was “hide overflow.”** Stripe’s wave is the one picture the homepage is remembered by. Both restyles `overflow: hidden` and `max-width: ~50vw` so validate would shut up. The captures show it sliced. That is not an imagery decision. It is a gate workaround.
- **44px became the look.** The brief said accessible. The skills treat 44px as a floor. The builds treated it as a style: isolated fat pills in the header, language links as 44×44 blocks, a hamburger whose only job is to satisfy tap-size. The source’s compact chrome was more designed than the “fixed” one.
- **The look-judge is optional and after the fact.** taste-validate’s different-model judge “if one is available,” never a score, and the live runs skipped it. There is no required step that rejects a safe default (SaaS: dark + Inter + three cards + gradient headline; restyle: same grid, bigger taps).

## What the skills get wrong

1. **Ask too late, and too little.** Questions live in taste-why, one at a time, cap three, “last resort.” A thin theme never reaches that gate because the brief step infers a tension and a “for” line from nothing. Last resort got implemented as “don’t bother the user.”
2. **Assumptions are written as Whys.** There is no Assumptions list. Anything not asked is invented and then reviewed until it sounds like a reason.
3. **Brand-lock leaks into free runs.** “Keep it recognisable” was read as “copy the source tokens and type.” Only `/taste --brand` should lock rendered tokens. Free runs still cited the source as the why.
4. **Document-first without a look.** Writing STYLE.md before paint is right. Writing it without a signature move, a hierarchy, and an imagery strategy just documents a default layout in advance.
5. **Measurement is the only hard gate.** Agents optimise for `Result: PASS`. Cropped waves, isolated buttons, and flat type all pass.

## What v2 has to change (this branch)

- A **question gate at the brief**, before directions and before any Why: up to five questions in one batch (audience, one feeling, what to borrow, what to avoid, what must be true of the product). At most one more at the direction pick. Do not answer them for the user. Stop.
- **Assumptions** are listed as assumptions. They are never a Why.
- A **signature / hierarchy / imagery** block in the handbook, and a look reviewer that rejects the default layout for that kind of product, with reasons, and no score.
- The why-reviewer **fails** a Why whose only source is “the source/brand already did it” unless the run is brand-locked.
- Validate still has no score. After the numbers, someone has to look: is the signature visible, is the picture whole, are the buttons a system or just 44px chrome.
