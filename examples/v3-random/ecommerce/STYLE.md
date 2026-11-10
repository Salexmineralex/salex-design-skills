# Style: Cusp

> A cut-steel poster for one hypocycloid plate, still chalky with plaster.

## Idea
Cusp sells a single machine plate whose opening is a hypocycloid, pulled from a demolishment on Rope Walk, the pale bloom on it the poof of plaster rather than a finish. It is for someone furnishing one room who has already been sold new metal with a rust wash. The tension is that the object is heavy and specific, while a shop page wants to become a catalogue. The page is a lie if the plate could be any industrial fragment. The why-reviewer ran as the same writer, one decision at a time.

## Principles
- One plate, not a line.
- The curve is the picture, not a texture behind type.
- Torch-light on a yard, not a paper ledger.
- Poster type, not a lot number.

## Signature
Night yard: the first screen is the plate itself, a steel disc with a torch-orange hypocycloid, beside the word Cusp set in a condensed grotesque at poster scale. Display is far above body. The plate is whole; it is not cropped to fit a column. If the disc came off, this would be a headline on a black page.

## Decisions

### D1. Yard black and a cutting torch
- **Decision:** Ground #14110e, type #f3eee6, torch #ff5a1f, steel #b7c0c8, dust note #8a8178.
- **Why:** The plate was cut and pulled at night in a demolition yard; a torch is the light that job actually uses, so the page is that yard instead of a daytime catalogue.
- **Instead of:** Warm off-white paper and brown ink, which is the ledger the brief refused.
- **Breaks if removed:** The plate reads as a product photo on a shop template.
- **Trade-off:** A black page hides the plaster bloom unless the steel is drawn light enough to show it.
- **Source:** user answer Q3
- **Reviewed:** kept (Q3)

### D2. Condensed grotesque, poster scale
- **Decision:** Avenir Next Condensed for the name and the action, Helvetica Neue for the sentences. Sizes 18px, 28px, 48px and 72px. Not a monospace.
- **Why:** A plate cut on a machine curve is a graphic object; a condensed grotesque at poster size treats it as a poster, which is the character asked for, while a mono ledger would turn the same object into a stock line.
- **Instead of:** Liberation Mono for lot numbers on cream paper.
- **Breaks if removed:** Cusp sits at body size and the plate becomes an illustration beside an article.
- **Trade-off:** Condensed capitals are hard to read in a long sentence, so only the name and the action use them.
- **Source:** user answer Q2
- **Reviewed:** kept (Q2)

### D3. The plate fills the first screen
- **Decision:** A whole steel disc, at least half the first viewport, with the hypocycloid cut out in torch orange. No second product, no lifestyle crop.
- **Why:** The buyer was burned by fragments that could have been anything; showing the actual curve, whole, is how they can see this is the Rope Walk plate and not a category.
- **Instead of:** Type only, or a small thumbnail beside a description.
- **Breaks if removed:** The word Cusp has no object, and the hypocycloid is a vocabulary word.
- **Trade-off:** The disc pushes the explanation below the first screen.
- **Source:** user answer Q4
- **Reviewed:** kept (Q4)

### D4. No ledger and no rust wash
- **Decision:** No table of lots, no hairline rules, no beige ground, no photograph graded to look rusty. Facts sit in three lines under a thick steel rule.
- **Why:** The buyer named that ledger, and the rust wash, as the thing they hate, because both are how a new part pretends to have come out of a wall.
- **Instead of:** A beige mono catalogue with 1px rules and no picture.
- **Breaks if removed:** The page becomes the shop they already refused.
- **Trade-off:** There is no way to compare three plates, because there is one plate.
- **Source:** user answer Q5
- **Reviewed:** kept (Q5)

### D5. One buyer, one address
- **Decision:** The copy names one person furnishing one room, and one address, Rope Walk. It does not speak to collectors as a class.
- **Why:** That person has already been fooled by a general claim of age; a single address is the check they can make, and a class of collectors cannot.
- **Instead of:** “For design lovers”, which fits any object shop.
- **Breaks if removed:** The plate could be from anywhere, which is the lie.
- **Trade-off:** Someone wanting a set of three will not find one.
- **Source:** user answer Q1
- **Reviewed:** kept (Q1)

### D6. The action sits in the poster, not in empty chrome
- **Decision:** “Take this plate” is a 48px torch block in the hero, sharing the column with the name. Minimum target 44px. Focus is a 3px torch outline.
- **Why:** The only act is to take this plate; a small text link would hide the act under the disc, and a lone pill in a bare header would be chrome.
- **Instead of:** A 44px pill floating in the black with nothing else in the row.
- **Breaks if removed:** The poster has no way to take the object it shows.
- **Trade-off:** The torch block is louder than the steel.
- **Source:** user answer Q4
- **Reviewed:** kept (Q4)

## Assumptions
- **A1:** Theme words hypocycloids, poofs, demolishments, from https://random-word-api.herokuapp.com/word?number=9 on 2026-11-10, first three of the nine, in order. Poofs is the puff of plaster dust, not a name for a person.
- **A2:** A hypocycloid is the curve of a point on a circle rolling inside a fixed circle. The four-cusp plate is that curve, not a logo mark invented after the fact.

## Questions asked
- **Q1:** Who is this for, at the moment they care? Answer: someone furnishing one room, who has already bought new metal sold as old. Answered by the owner's assistant at the owner's request. Why: the words are a single salvaged object, so the buyer is one person checking one claim.
- **Q2:** Type character? Options: editorial serif, technical grotesque, warm book face, loud condensed grotesque, or you decide. Answer: loud and graphic. Answered by the owner's assistant at the owner's request. Why: a cut plate is a poster object, and the other three characters would quiet it into an article.
- **Q3:** Color vibe? Light or dark, calm or intense, and a place that evokes it. Answer: dark and intense, a cutting torch in a demolition yard at night. Answered by the owner's assistant at the owner's request. Why: demolishment is the source of the object, and a torch is the light of that work.
- **Q4:** Imagery? Photos, illustration, type only, or a big product. Answer: big product, the plate whole. Answered by the owner's assistant at the owner's request. Why: the hypocycloid is the thing being sold, so a description without the disc fails the claim.
- **Q5:** What would you hate to see? Answer: a beige lot ledger, monospace stock codes, hairline tables, and rust-filter photographs. Answered by the owner's assistant at the owner's request. Why: that is the shared default, and it is also how fake salvage is dressed.
- **Q6:** Which direction? Answer: Night yard, the disc and the condensed word. Answered by the owner's assistant at the owner's request. Why: the other two either shrank the plate or put the curve in a caption.

## Tokens
```css
:root {
  --color-yard: #14110e; /* D1 */
  --color-ink: #f3eee6; /* D1 */
  --color-spark: #ff5a1f; /* D1 */
  --color-steel: #b7c0c8; /* D1 */
  --color-mute: #8a8178; /* D1 */
  --font-display: "Avenir Next Condensed", "Avenir Next", Avenir, sans-serif; /* D2 */
  --font-body: "Helvetica Neue", Helvetica, Arial, sans-serif; /* D2 */
  --text-body: 18px; /* D2 */
  --text-kicker: 28px; /* D2 */
  --text-plate: 48px; /* D2 */
  --text-display: 72px; /* D2 */
  --space-2: 16px; /* D6 */
  --space-3: 24px; /* D6 */
  --space-4: 40px; /* D6 */
  --space-5: 64px; /* D6 */
}
```
