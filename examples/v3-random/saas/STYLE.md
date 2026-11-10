# Style: Overpedal

> The digester panel for the Friday a festival overfeeds the town.

## Idea
Overpedal is the screen a town digester operator reads when a tourist weekend will push the tank past what it can take. Overpedalled means the load, the digestor is the tank, touristed is the weekend that causes it. The person is on duty that Friday, not a visitor learning what biogas is. The tension is that the decision is urgent and the screen must stay calm enough to read the three marks. It is a lie if it claims to run the plant. The why-reviewer ran as the same writer, one decision at a time.

## Principles
- One tank, not a platform tour.
- The panel is the product, not a picture of the product.
- Cool tile, not warm paper.
- A time to divert, not a feature list.

## Signature
Pool tile: the first screen is the tank panel itself, three level bars on a pale cool ground, the word Overpedal in the same grotesque as the figures. The panel is large and whole. Display sits well above the sentences. If the bars came off, this would be a headline about infrastructure.

## Decisions

### D1. Changing-room tile, calm and light
- **Decision:** Ground #e7eef2, ink #102028, pool #0c3f4c, grout #c5d2d8, foam #f4f7f8.
- **Why:** The operator asked for a light, calm color from a swimming-pool changing room; glazed tile is that room, and a warm paper ground would make the tank look like a document.
- **Instead of:** Call-sheet yellow or beige paper, the ground the previous projects shared.
- **Breaks if removed:** The urgency gets dressed as an alarm banner, or as stationery.
- **Trade-off:** Calm tile can underplay a tank that is about to sour, so the load bar has to be the dark one.
- **Source:** user answer Q3
- **Reviewed:** kept (Q3)

### D2. One grotesque, figures included
- **Decision:** Helvetica Neue for the name, the sentences and the panel figures. Sizes 18px, 28px, 48px and 72px. No second family, no monospace.
- **Why:** A technical character was the ask, and a plant panel is read as figures in the same face as the labels; a mono axis would quote an instrument chart the operator did not ask for.
- **Instead of:** A serif headline over mono readouts.
- **Breaks if removed:** The panel looks typeset, and the name looks like a different product from the tank.
- **Trade-off:** Helvetica Neue has no costume, so the tile and the bars have to carry the place.
- **Source:** user answer Q2
- **Reviewed:** kept (Q2)

### D3. The panel is most of the first screen
- **Decision:** The digester panel, with three bars and the divert time, fills the hero beside the name. It is the product, drawn whole, not a screenshot in a laptop frame.
- **Why:** The operator needs the load, the gas and the sour line before the coaches arrive; a small diagram under a manifesto would hide the only numbers that matter.
- **Instead of:** Type only, or a photograph of a tank in a field.
- **Breaks if removed:** Overpedal is a verb with no instrument.
- **Trade-off:** The explanation of who it is for sits below the panel.
- **Source:** user answer Q4
- **Reviewed:** kept (Q4)

### D4. Not the SaaS kit
- **Decision:** No three equal cards, no gradient headline, no cartoon compost bin, no Inter. One panel, one act: divert.
- **Why:** Those were named as what this page must not be, because each one is the layout a model ships first for this kind of product, and none of them shows a tank.
- **Instead of:** Inter, three feature cards, a gradient wordmark.
- **Breaks if removed:** The Friday decision turns into a marketing page about biogas.
- **Trade-off:** A buyer who wanted a platform tour will not get one.
- **Source:** user answer Q5
- **Reviewed:** kept (Q5)

### D5. The Friday operator
- **Decision:** The sentences address the person on duty when the festival coaches are due, and the act is to divert before 14:00. No general “for utilities”.
- **Why:** That is the moment the three theme words meet: the tank is overpedalled because the town is touristed, and only the person on shift can divert.
- **Instead of:** A homepage for anyone curious about renewable gas.
- **Breaks if removed:** The panel has no user, so any waste dashboard would satisfy it.
- **Trade-off:** It will feel narrow to a mayor who wanted a public story.
- **Source:** user answer Q1
- **Reviewed:** kept (Q1)

### D6. Divert is a block in the hero
- **Decision:** “Divert the weekend” is a 48px pool block under the sentences, in the same column as the name. Focus is a 3px pool outline. Targets are at least 44px.
- **Why:** Diverting is the decision the panel exists to force; a text link would let the bars be admired and the act skipped.
- **Instead of:** A pill in an otherwise empty header.
- **Breaks if removed:** The screen reports a sour tank and offers nothing to do.
- **Trade-off:** The block is the darkest quiet thing on a calm ground.
- **Source:** user answer Q4
- **Reviewed:** kept (Q4)

## Assumptions
- **A1:** Theme words overpedalled, digestor, touristed, from https://random-word-api.herokuapp.com/word?number=9 on 2026-11-10, the fourth through sixth of the nine, in order. Digestor is read as the town’s digester tank.

## Questions asked
- **Q1:** Who is this for, at the moment they care? Answer: the operator on duty the Friday a festival starts, deciding whether to divert waste before the tank sours. Answered by the owner's assistant at the owner's request. Why: the words are a load, a tank and a tourist crush, which meet on that shift.
- **Q2:** Type character? Options: editorial serif, technical grotesque, warm book face, loud condensed grotesque, or you decide. Answer: technical and precise. Answered by the owner's assistant at the owner's request. Why: the page is a panel of figures, and a poster face or a book face would decorate the reading.
- **Q3:** Color vibe? Light or dark, calm or intense, and a place that evokes it. Answer: light and calm, a swimming-pool changing room. Answered by the owner's assistant at the owner's request. Why: the decision is urgent, so the ground should not shout; tile keeps the urgency in the bars.
- **Q4:** Imagery? Photos, illustration, type only, or a big product. Answer: big product, the tank panel whole. Answered by the owner's assistant at the owner's request. Why: the product is the panel the operator acts on, not a story about it.
- **Q5:** What would you hate to see? Answer: Inter, three feature cards, a gradient headline, and a cartoon compost bin. Answered by the owner's assistant at the owner's request. Why: that is the default for this product type, and it hides the tank.
- **Q6:** Which direction? Answer: Pool tile, the panel at hero scale. Answered by the owner's assistant at the owner's request. Why: the alarm-red direction made the ground do the shouting, and the field-photo direction hid the figures.

## Tokens
```css
:root {
  --color-tile: #e7eef2; /* D1 */
  --color-ink: #102028; /* D1 */
  --color-pool: #0c3f4c; /* D1 */
  --color-grout: #c5d2d8; /* D1 */
  --color-foam: #f4f7f8; /* D1 */
  --font-body: "Helvetica Neue", Helvetica, Arial, sans-serif; /* D2 */
  --text-body: 18px; /* D2 */
  --text-label: 28px; /* D2 */
  --text-read: 48px; /* D2 */
  --text-display: 72px; /* D2 */
  --space-2: 16px; /* D6 */
  --space-3: 24px; /* D6 */
  --space-4: 40px; /* D6 */
  --space-5: 64px; /* D6 */
}
```
