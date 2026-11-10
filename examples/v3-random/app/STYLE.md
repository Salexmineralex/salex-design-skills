# Style: Home rota

> A workshop sign for the swan pen and the pig pen you still share.

## Idea
Home rota is the feeding rota you still keep with the friend who stayed: a swannery, and the grumphies, the Scots word you use for the pigs. You are on a train. They are at the pen. The app confirms today’s mark. It does not stream the birds. The tension is affection for a place you left, against the need for a plain yes-or-no about the sow and the swan. It is a lie if it pretends to doctor an animal. The why-reviewer ran as the same writer, one decision at a time.

## Principles
- A rota, not a postcard.
- The cut-paper pair is the picture.
- Workshop primer, not instrument paper.
- The friend who stayed is a person, not a brand voice.

## Signature
Bench: the first screen is a cut-paper swan and a pig on a pale primer ground, with Home rota set in a book serif large enough to be the sign over the bench. The drawing is whole. Display is far above the rota sentences. If the cut paper came off, this would be a note about chores.

## Decisions

### D1. Primer green and enamel ochre
- **Decision:** Ground #d7e6d4, ink #14241a, enamel #1f6b45, ochre #c45c12, sign-white #f6f1e6. Ochre is for the large section titles and the pig, not for body sentences.
- **Why:** The color asked for was light and intense, from a 1970s workshop; primer on the bench is the light, and the ochre enamel of a tool board is the intense note, which a beige sheet would flatten.
- **Instead of:** Warm off-white paper with a mono axis, the instrument look of the earlier night-trace page.
- **Breaks if removed:** The rota looks like a clinical chart for a body, which these animals are not.
- **Trade-off:** Ochre on primer is too weak for small type, so ochre stays at 48px and in the drawing.
- **Source:** user answer Q3
- **Reviewed:** kept (Q3)

### D2. A book serif, used large
- **Decision:** Palatino for everything. Sizes 19px, 28px, 48px and 72px. No grotesque, no monospace.
- **Why:** Warm and handmade was the character asked for, and a book serif is the lettering of a bench sign someone painted, whereas a grotesque would turn the same rota into a utility app.
- **Instead of:** Helvetica Neue, or a script face pretending to be a farmer’s hand.
- **Breaks if removed:** The cut paper sits next to system type and the handmade claim is only in the picture.
- **Trade-off:** Palatino at 19px is wider than a grotesque, so the sentences stay short.
- **Source:** user answer Q2
- **Reviewed:** kept (Q2)

### D3. Swan and pig, cut paper, filling the hero
- **Decision:** One illustration, the swan and the grumphie as cut paper, large in the first screen, not a phone frame and not a photograph of a sanctuary.
- **Why:** Illustration was the ask, and these two animals are the whole product; a photo would sell the place, and type alone would leave “grumphie” as a word the reader has to trust.
- **Instead of:** A centred phone mock with store badges, or type only.
- **Breaks if removed:** The rota has no flock, so it could be any shared checklist.
- **Trade-off:** The drawing is specific to this pen, and a second species would not fit the same sheet.
- **Source:** user answer Q4
- **Reviewed:** kept (Q4)

### D4. Not a phone advert and not a chart
- **Decision:** No device mock, no store buttons, no pastel wellness gradient, no beige drum-paper grid. The page is the sign and the rota.
- **Why:** Those were named as what this must not become: the default app landing, and the document default of paper, mono and hairlines.
- **Instead of:** A phone in the centre, two store badges, and a feature row.
- **Breaks if removed:** The friend and the animals turn into an acquisition page.
- **Trade-off:** Someone who wanted to install from a badge has to use the link in the sign.
- **Source:** user answer Q5
- **Reviewed:** kept (Q5)

### D5. The friend who stayed
- **Decision:** The copy is to the person who left, about the homeboy who still does the pen. It names the swannery and the pigs, and it says grumphie is their word.
- **Why:** The three words are a place, an animal and a person; dropping the person makes it a sanctuary brochure, which is not the rota they share.
- **Instead of:** “For animal lovers”, which any shelter could use.
- **Breaks if removed:** The app has an audience of everyone and a job of none.
- **Trade-off:** A stranger opening it will feel they walked into someone else’s chore.
- **Source:** user answer Q1
- **Reviewed:** kept (Q1)

### D6. Open today’s pen, on the sign
- **Decision:** The action is a 48px enamel block, sign-white type, in the hero with the name. Focus is a 3px ochre outline. Targets are at least 44px.
- **Why:** Opening today’s pen is the only act; the block shares the sign with the name so the rota starts where the animals are drawn.
- **Instead of:** A text link under a long explanation.
- **Breaks if removed:** The drawing is a picture with no way into the day.
- **Trade-off:** Enamel on primer is heavy for a single link.
- **Source:** user answer Q1
- **Reviewed:** kept (Q1)

## Assumptions
- **A1:** Theme words swanneries, grumphies, homeboy, from https://random-word-api.herokuapp.com/word?number=9 on 2026-11-10, the last three of the nine, in order.
- **A2:** Grumphie is the Scots familiar name for a pig, from the Dictionaries of the Scots Language. A swannery is a place where swans are kept.

## Questions asked
- **Q1:** Who is this for, at the moment they care? Answer: someone on the way home who still shares the feeding rota with the friend who stayed at the pen. Answered by the owner's assistant at the owner's request. Why: homeboy is a person, not a theme, so the product is a shared chore.
- **Q2:** Type character? Options: editorial serif, technical grotesque, warm book face, loud condensed grotesque, or you decide. Answer: warm and handmade. Answered by the owner's assistant at the owner's request. Why: the rota is a sign over a bench, and a technical grotesque would make the pigs into a dashboard.
- **Q3:** Color vibe? Light or dark, calm or intense, and a place that evokes it. Answer: light and intense, a 1970s workshop, primer on the bench and ochre enamel on the tool board. Answered by the owner's assistant at the owner's request. Why: the news can be “the sow is out”, so the ground stays light and the enamel carries the heat.
- **Q4:** Imagery? Photos, illustration, type only, or a big product. Answer: illustration, cut paper of the swan and the pig. Answered by the owner's assistant at the owner's request. Why: a photo would advertise the place, and the animals need to be seen for the Scots word to land.
- **Q5:** What would you hate to see? Answer: a phone mock with two store buttons, pastel wellness, and a beige instrument chart. Answered by the owner's assistant at the owner's request. Why: the first is the app-landing default, and the chart is the document default this round is not supposed to repeat.
- **Q6:** Which direction? Answer: Bench, cut paper on primer. Answered by the owner's assistant at the owner's request. Why: the night-pen direction went dark and clinical, and the postcard direction became a photograph of water.

## Tokens
```css
:root {
  --color-primer: #d7e6d4; /* D1 */
  --color-ink: #14241a; /* D1 */
  --color-enamel: #1f6b45; /* D1 */
  --color-ochre: #c45c12; /* D1 */
  --color-sign: #f6f1e6; /* D1 */
  --font-body: Palatino, "Palatino Linotype", Georgia, serif; /* D2 */
  --text-body: 19px; /* D2 */
  --text-label: 28px; /* D2 */
  --text-section: 48px; /* D2 */
  --text-display: 72px; /* D2 */
  --space-2: 16px; /* D6 */
  --space-3: 24px; /* D6 */
  --space-4: 40px; /* D6 */
  --space-5: 64px; /* D6 */
}
```
