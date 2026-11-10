# Style: Cover Board

> Tonight’s call sheet, for the person who has to name a coryphée cover at 10pm.

## Idea
Cover Board is casting and cover-planning software for ballet companies. It knows which coryphées have learned which roles, rehearsal hours per role, and who is free, and it suggests a cover. The buyer is the rehearsal director / artistic administrator of a mid-size company, at 10pm, a soloist just injured, performance tomorrow. The tension: the tool must feel like the paper they already trust — calm precision under pressure — without becoming generic SaaS calm or tutu-and-glitter. It is a lie if it claims ticketing, payroll, or choreography. The why-reviewer ran as the same writer, one decision at a time; D5 first failed SWAP (any “dashboard is the product” line) and was rewritten around a call sheet the director already reads.

## Principles
- One job (covers), not a platform.
- Paper they know, not a SaaS kit.
- Calm under pressure, not costume.
- The board is the page, not three feature cards.

## Signature
Call sheet: a strip of stage tape with the company call printed on it, then the page as a casting board — role, injured, coryphée cover, hours — in mono, on call-sheet yellow. Display is the company name; the board is dense and quiet. No Inter, no gradient headline, no tutu. If the tape and the board came off, this would be any B2B landing.

## Decisions

### D1. Call-sheet yellow and brown-black ink
- **Decision:** Paper #f6ebc9, ink #1c1408, rule the same ink, tape #c41e12, tape-type #fff8ee, muted #5c4a32.
- **Why:** At 10pm this person is holding a printed call sheet; yellow stock and brown-black type are the colours of that paper, so the tool replaces a thing they already know how to read instead of asking them to learn a dashboard palette.
- **Instead of:** Cool white and slate, which is generic SaaS calm, or a black-and-gold theatre poster, which is costume.
- **Breaks if removed:** The page stops being the artefact and starts being “software”.
- **Trade-off:** Yellow stock looks un-digital; some will not clock it as a product at first glance.
- **Source:** user answer Q2 Q3
- **Reviewed:** kept (Q3)

### D2. Grotesque for the company, mono for the board
- **Decision:** Cantarell, Liberation Sans, sans-serif for the product name and body; Liberation Mono, Cousine, monospace for the board, call times, and hours. Not Inter.
- **Why:** Call sheets are typed in a workhorse mono; the company name on the same page is a grotesque, not a display script. Inter is the SaaS default the brief forbade, so using it would undo the peculiar-in-specificity feeling.
- **Instead of:** Inter plus a gradient headline, or a ballet script for the word coryphée.
- **Breaks if removed:** The board looks like a website table, not a call sheet.
- **Trade-off:** Cantarell is homely; it will not impress a branding deck.
- **Source:** user answer Q3 Q4
- **Reviewed:** kept (Q4)

### D3. Five sizes, board smaller than the call
- **Decision:** 13px board, 16px body, 20px section, 28px product name, 40px only for the live role in trouble. Line-height 1.4 body, 1.3 board.
- **Why:** On a real call sheet the emergency is the one large name (Odile — OUT); everything else stays small so the director can scan hours without swimming in type.
- **Instead of:** A 56px gradient headline and 18px cards, the SaaS default.
- **Breaks if removed:** Tonight’s injury does not stand out from the rest of the board.
- **Trade-off:** 13px mono needs high-contrast ink; it cannot sit on tape red.
- **Source:** user answer Q1
- **Reviewed:** kept (Q1)

### D4. Stage tape as a printed strip, not a logo
- **Decision:** A 48px tape band in #c41e12 with the call printed in #fff8ee: company, date, call time. The tape contains that text (it is not an empty bar). Square ends, no gradient, no glow.
- **Why:** Stage tape is the floor mark a rehearsal director reads as “stand here”; printing the 19:30 call on a red strip puts that fact in the same material language as the mark, which is how the tool announces itself without a tutu.
- **Instead of:** A red brand gradient in the header, or clip-art pointe shoes.
- **Breaks if removed:** Nothing in the first 48px says “backstage paper”.
- **Trade-off:** A bright red band can look like an alert banner to people outside theatre.
- **Source:** user answer Q3 Q4
- **Reviewed:** kept (Q3)

### D5. The page is the casting board
- **Decision:** The main surface is a role/injured/cover/hours board. Supporting copy is extra lines on the same sheet (what the tool does, what it will not do). Not three equal rounded feature cards.
- **Why:** The director at 10pm needs to see who can cover Odile; a three-card “features” layout is the SaaS default the brief forbade, and it would hide the board behind marketing.
- **Instead of:** Inter, three cards, gradient headline.
- **Breaks if removed:** The signature is a heading without a board.
- **Trade-off:** Visitors who wanted a platform tour will not find ticketing, payroll, or choreography — those are lies.
- **Source:** user answer Q4 Q5
- **Reviewed:** kept (Q5)

### D6. Dense 8px rhythm, actions in the row
- **Decision:** Space 8, 16, 24, 32, 48, 64px. Board rows pad 8px 16px. The “Open tonight’s board” action is 48px tall in the tape/header row, min 44×44, not a pill in empty space.
- **Why:** A call sheet is a working document; large SaaS padding would slow the 10pm scan. 44px is a tap floor, not a look, so the action shares height with the tape.
- **Instead of:** Isolated 44px chrome in a sparse header.
- **Breaks if removed:** The tool looks like a marketing page with a table glued on.
- **Trade-off:** It will feel cramped on a large monitor.
- **Source:** handbook tap floor
- **Reviewed:** kept

### D7. Square paper, dashed row rules
- **Decision:** Radius 0. Solid 1px ink around the sheet; dashed 1px ink between board rows. No shadow. No cards, panels, or tiles.
- **Why:** Printed call sheets are ruled, not rounded; rounding plus shadow is the card pattern that would make this a default SaaS landing even on yellow paper.
- **Instead of:** 16px-radius feature panels.
- **Breaks if removed:** The board becomes a set of tiles.
- **Trade-off:** Dashed rules look old-fashioned on a retina screen.
- **Source:** user answer Q3 Q4
- **Reviewed:** kept (Q3)

### D8. Backstage voice, one job
- **Decision:** Copy uses role, cover, hours, learned, free, out. It names coryphées. It states it does not do ticketing, payroll, or choreography. No glitter, no “unleash your company”.
- **Why:** The user is an expert commissioning a cover under pressure; decoration and platform language would insult that expertise and would lie about scope.
- **Instead of:** Lifestyle ballet copy, or a suite of modules.
- **Breaks if removed:** The peculiar job (covers) blurs into “arts admin software”.
- **Trade-off:** A generalist buyer will bounce.
- **Source:** user answer Q2 Q5
- **Reviewed:** kept (Q5)

### D9. States on paper, no motion
- **Decision:** Hover: dashed rule goes solid. Focus-visible: 2px ink outline, 2px offset. Active: tape-red fill with tape-type. Disabled: 40% ink. Loading: “Checking hours…”. Error: a board line in tape-red (“Okoye — conflict 21:00”). No animation; flipping a sheet is instant.
- **Why:** At 10pm motion is noise; the director needs to see which name is selected and whether a cover conflicts.
- **Instead of:** Skeleton loaders and fade-in heroes.
- **Breaks if removed:** Focus disappears on yellow, or a spinner burns minutes they do not have.
- **Trade-off:** The page feels still, almost printed.
- **Source:** user answer Q2
- **Reviewed:** kept (Q2)

## Assumptions
- **A1:** The owner asked for a SaaS landing, built from scratch.
- **A2:** Theme words from the random-word API: peculiar, commissioners, coryphees.
- **A3:** Cantarell and Liberation Mono are the families this environment will paint.

## Questions asked
- **Q1:** Who is this product for? Answered by the owner's assistant at the owner's request: the rehearsal director / artistic administrator of a mid-size ballet company, at 10pm the night before a performance when a soloist is injured and they must find which coryphée can cover the role. Why: coryphées are exactly the dancers who cover soloist parts; the buyer is the person who commissions casting under pressure.
- **Q2:** What one feeling, and what it must never feel like? Answered by the owner's assistant at the owner's request: calm precision under pressure, a backstage professional's tool — peculiar in being made for a very specific world. Never generic SaaS calm, never tutu-and-glitter. Why: the user is an expert in a niche; specificity earns trust, and decoration would insult them.
- **Q3:** What world to borrow? Answered by the owner's assistant at the owner's request: printed backstage call sheets and casting boards, stage-tape floor marks, rehearsal schedules pinned on cork. Why: it's the artefact this person already reads every day; the software replaces paper they know.
- **Q4:** What must it never borrow? Answered by the owner's assistant at the owner's request: no Inter + three feature cards + gradient headline; no tutus, pointe shoes, or gavels as clip-art. Why: the first is the category default; the second turns the words into costume.
- **Q5:** What must be true of the product? Answered by the owner's assistant at the owner's request: casting and cover planning software for ballet companies: which coryphées have learned which roles, rehearsal hours per role, who's available, suggested covers. It's a lie if it claims ticketing, payroll, or choreography. Why: one sharp job beats a vague platform.
- **Q6:** Which direction? Answered by the owner's assistant at the owner's request: Call sheet, because it is closest to the call-sheet/casting-board world.

## Tokens
```css
:root {
  --color-ink: #1c1408; /* D1 */
  --color-paper: #f6ebc9; /* D1 */
  --color-tape: #c41e12; /* D1 */
  --color-tape-type: #fff8ee; /* D1 */
  --color-muted: #5c4a32; /* D1 */
  --font-display: Cantarell, Liberation Sans, sans-serif; /* D2 */
  --font-board: Liberation Mono, Cousine, monospace; /* D2 */
  --font-size-board: 13px; /* D3 */
  --font-size-body: 16px; /* D3 */
  --font-size-section: 20px; /* D3 */
  --font-size-name: 28px; /* D3 */
  --font-size-alert: 40px; /* D3 */
  --space-1: 8px; /* D6 */
  --space-2: 16px; /* D6 */
  --space-3: 24px; /* D6 */
  --space-4: 32px; /* D6 */
  --space-5: 48px; /* D6 */
  --space-6: 64px; /* D6 */
  --radius: 0px; /* D7 */
  --row-height: 48px; /* D6 */
  --focus-width: 2px; /* D9 */
}
```
