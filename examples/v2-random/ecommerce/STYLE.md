# Style: Isthmus Lot

> A coastal chart of washed-rind and barrel fish, each lot pinned to a named neck of land.

## Idea
Isthmus Lot sells washed-rind cheeses and cured or fermented fish from small producers on isthmi — narrow coastal necks — each lot traceable to a named person and a coordinate. The buyer is a cheesemonger-minded home cook, 30–55, who already wants the strong stuff and has been burned by supermarket “artisan” copies. The tension: the page has to work as a provenance ledger (dry, exact, quietly proud) while still letting that cook take a lot tonight. It is a lie if a product cannot be traced. The why-reviewer ran as the same writer, one decision at a time; D4 first failed CAUSE (any red would “stand out”) and was rewritten around the surveyor’s mark on a chart.

## Principles
- Traceable, not atmospheric.
- Chart and lot label, not shop grid.
- Quiet pride, not a smell joke.
- One documented action, not a cluster of offers.

## Signature
Chartfold: the page is a coastal chart. Coordinates and lot numbers run in tide-table type; goods appear as lot labels; the one picture is a whole isthmus map with pins at the necks we buy from. Display serif sits far above the mono lots. Nothing is cropped to hide overflow. If the map and the lot labels came off, this would be any grocer.

## Decisions

### D1. Chart cream and navy ink
- **Decision:** Paper #f3ead2, ink #1a2744, chart-grid #c5cbb8, sea tint #dce4d0.
- **Why:** The buyer pays a premium for something that can be faked; cream and navy are the colours of a printed coastal chart, which is a document of a place, so the shop reads as a survey of lots rather than a lifestyle grocer.
- **Instead of:** White retail paper with a kraft-brown accent, which is the rustic-cosy grocery the brief forbids and which the buyer already associates with supermarket “artisan” packs.
- **Breaks if removed:** The page loses the chart world and starts to look like a generic food shop.
- **Trade-off:** Cream is less bright than white, so product photos (if anyone adds them later) have less pop.
- **Source:** user answer Q2 Q3
- **Reviewed:** kept (Q3)

### D2. Serif for names, mono for lots
- **Decision:** Liberation Serif, Georgia, serif for names and display; Liberation Mono, Cousine, monospace for coordinates, lot numbers, and prices. No third family.
- **Why:** A chart names a place in a bookish serif and records the fix in a tabular mono; the cook who already reads affineur notes will trust a lot number that looks like a tide table more than a shop sans.
- **Instead of:** A single retail sans (or Inter) for everything, which flattens the difference between a name and a lot and reads as a storefront.
- **Breaks if removed:** Names and numbers share one voice, so the provenance ledger disappears.
- **Trade-off:** Mono is wider, so lot rows take more horizontal room on a phone.
- **Source:** user answer Q3
- **Reviewed:** kept (Q3)

### D3. Five sizes, display far from body
- **Decision:** 12px lots and coordinates, 16px body, 22px kicker, 32px section titles, 48px display (32px below 700px). Line-height 1.45 body, 1.15 display.
- **Why:** A chart’s title is large and the table under it is small; that gap is how a skipper (and this cook) finds the name of the place before reading the fix. Sizes sit more than 8% apart so the hierarchy is a fact, not a hint.
- **Instead of:** A narrow band of 16–20px, which would make the hero and the lots feel like the same paragraph.
- **Breaks if removed:** The signature map would have nothing larger than a caption to stand with.
- **Trade-off:** 12px mono must stay on cream with ink; it cannot go on the sea tint.
- **Source:** handbook type hierarchy
- **Reviewed:** kept

### D4. One surveyor-red action
- **Decision:** Action #9b1c1c, white #ffffff on it; muted ink #3d4a3a for secondary lines. The only filled control is “Open tonight’s lots” / “Take lot”.
- **Why:** On a chart the surveyor’s mark is a single red point that says “here”; one red action lets the cook take a lot without a row of competing buttons that would feel like a sale.
- **Instead of:** Several accent colours, or a coral “buy” on every tile, which turns provenance into a catalogue of offers.
- **Breaks if removed:** The cook cannot see, at a glance, which control spends money.
- **Trade-off:** Categories cannot be colour-coded; place is told with coordinates instead.
- **Source:** user answer Q2
- **Reviewed:** kept (Q2)

### D5. The isthmus map is the one picture, kept whole
- **Decision:** One inline SVG chart of the necks we buy from, pins at lots, viewBox shown in full, preserveAspectRatio meet. No photograph. No overflow:hidden on the figure. Caption names it as Chart 7.
- **Why:** “Isthmi” is a geographic fact; a whole chart is the honest picture of a thin strip of land, and a cropped wave or a grape-board photo would be the food cliché the brief bans and would hide the pins that prove a lot sits on a place.
- **Instead of:** Wooden-board photography, or a decorative coastline sliced by overflow until validate is quiet.
- **Breaks if removed:** The signature move is gone; only type remains, and type alone could be any ledger.
- **Trade-off:** SVG is schematic; it will not satisfy someone who wanted a hero photo of cheese.
- **Source:** user answer Q3 Q4
- **Reviewed:** kept (Q3)

### D6. Goods as lot labels, not a card grid
- **Decision:** Each product is a full-width lot label: lot code, paste, producer, coordinate, weight, price, take-lot. Square corners, 1px ink rule, uneven content width. Not three equal rounded tiles.
- **Why:** The owner forbade the white card-grid every model ships for shops; a lot label is the document the anti-fake promise needs, because the code and the coordinate sit on the same strip as the name.
- **Instead of:** Equal product cards with a photo and a price, which is the default storefront and which cannot hold a coordinate without looking like a badge.
- **Breaks if removed:** The page becomes the shop grid the brief said never to borrow.
- **Trade-off:** Scanning is slower than a photo grid; a first-time gift buyer is not the audience.
- **Source:** user answer Q4 Q5
- **Reviewed:** kept (Q4)

### D7. Tide-table density on an 8px rhythm
- **Decision:** Space 8, 16, 24, 32, 48, 64px. Lot rows pad 16px; sections stack 48px. Header is one 48px bar, not a fat isolated pill row.
- **Why:** Tide tables are dense because the useful fact is a number in a row; this cook already knows washed-rind and is hunting a lot, so spare luxury padding would waste the information they came for.
- **Instead of:** Large card gaps and a 44px-tall button floating in empty header chrome, which reads as an accessibility sticker rather than a chart index.
- **Breaks if removed:** The ledger thins out into a lifestyle landing.
- **Trade-off:** It will feel tight to someone who wants a magazine shop.
- **Source:** user answer Q1
- **Reviewed:** kept (Q1)

### D8. Square rules, no shadow
- **Decision:** Radius 0. Borders 1px solid ink. No drop shadow. The surveyor pin is a 6px circle in action red on the map, not a glow.
- **Why:** A chart is printed flat; shadow and rounding would turn lot labels into retail cards, which is the shape of the storefront we are not building.
- **Instead of:** 12px rounded tiles with a soft shadow, the default ecommerce card.
- **Breaks if removed:** Labels start to read as product cards even if the copy is a lot number.
- **Trade-off:** Some will call it severe.
- **Source:** user answer Q4
- **Reviewed:** kept (Q4)

### D9. Dry lot voice, never a smell gag
- **Decision:** Copy names paste, producer, coordinate, weight, price. No “stinky!”, no fake-out jokes, no rustic adjectives. Claim: traceable lots. Lie: an untraceable product, or a famous AOC name from the wrong place.
- **Why:** They have been burned by “artisan” copy; a joke about smell or faking spends the trust the money requires, and a false origin would make the shop itself a fake.
- **Instead of:** Witty packaging lines that riff on the three theme words.
- **Breaks if removed:** The page undoes the reason they would pay us instead of the supermarket.
- **Trade-off:** The theme words stay in the world, not in the punchlines, so a casual visitor may not clock the brief.
- **Source:** user answer Q2 Q5
- **Reviewed:** kept (Q2)

### D10. Controls in the bar; states on the ink
- **Decision:** Nav links and filled actions are min 44×44px and share the 48px header/row height, square. Hover: the lot rule goes to 2px, the action fills darker ink over the same red. Focus-visible: 2px ink outline, 2px offset. Active: ink fill, paper type. Disabled: 40% opacity, not-allowed. Loading: label becomes “Holding lot…”. Error: action-red sentence under the row. No motion beyond those state changes; a chart does not animate.
- **Why:** At the moment of paying, the cook needs to see which control is live; a floating 44px pill would look like chrome, and a moving map would look like marketing.
- **Instead of:** Isolated fat pills, animated coastlines, or colour-only focus.
- **Breaks if removed:** Keyboard users lose the chart, or the action looks bolted on.
- **Trade-off:** No delight animation to show “freshness”.
- **Source:** handbook tap floor
- **Reviewed:** kept

## Assumptions
- **A1:** The owner asked for an e-commerce landing, built from scratch.
- **A2:** Theme words from the random-word API: stinkiest, faking, isthmi.
- **A3:** Liberation Serif and Liberation Mono are the families this environment will paint; Georgia and Cousine are fallbacks.

## Questions asked
- **Q1:** Who is this shop for? Answered by the owner's assistant at the owner's request: a cheesemonger-minded home cook, 30–55, who already buys washed-rind cheese and cured fish and has been burned by "artisan" fakes from supermarkets. Why: "stinkiest" + "faking" point at a buyer who seeks the strong stuff and distrusts imitations; a specialist justifies a denser, information-rich page.
- **Q2:** What one feeling, and what it must never feel like? Answered by the owner's assistant at the owner's request: dry, exact, quietly proud — like a provenance ledger. Never a smell joke, never rustic-kraft cosiness. Why: they're paying premium for something that could be faked; trust comes from precision, not jokes.
- **Q3:** What world to borrow? Answered by the owner's assistant at the owner's request: nautical/coastal charts and lot labels — thin strips of land (isthmi) as a layout motif, lot numbers, coordinates, tide-table typography. Why: "isthmi" gives a real geographic world; charts are the honest document of a place, which matches the anti-fake promise.
- **Q4:** What must it never borrow? Answered by the owner's assistant at the owner's request: no white card-grid storefront, no smell/fake gags on products, no wooden-board-with-grapes photography. Why: the grid is the default every model ships; gags undermine trust with money.
- **Q5:** What must be true of the product? Answered by the owner's assistant at the owner's request: washed-rind cheeses and cured/fermented fish from small producers on isthmi, each with a traceable lot and producer. It's a lie if products aren't traceable to a named producer and place. Why: "faking" becomes the promise inverted — the stinkiest real things, never fakes.
- **Q6:** Which direction? Answered by the owner's assistant at the owner's request: Chartfold, because its signature most strongly uses the chart/lot-label world.

## Tokens
```css
:root {
  --color-ink: #1a2744; /* D1 */
  --color-paper: #f3ead2; /* D1 */
  --color-chart: #c5cbb8; /* D1 */
  --color-sea: #dce4d0; /* D1 */
  --color-action: #9b1c1c; /* D4 */
  --color-white: #ffffff; /* D4 */
  --color-muted: #3d4a3a; /* D4 */
  --font-display: Liberation Serif, Georgia, serif; /* D2 */
  --font-lot: Liberation Mono, Cousine, monospace; /* D2 */
  --font-size-lot: 12px; /* D3 */
  --font-size-body: 16px; /* D3 */
  --font-size-kicker: 22px; /* D3 */
  --font-size-sub: 32px; /* D3 */
  --font-size-display: 48px; /* D3 */
  --space-1: 8px; /* D7 */
  --space-2: 16px; /* D7 */
  --space-3: 24px; /* D7 */
  --space-4: 32px; /* D7 */
  --space-5: 48px; /* D7 */
  --space-6: 64px; /* D7 */
  --radius: 0px; /* D8 */
  --row-height: 48px; /* D7 */
  --focus-width: 2px; /* D10 */
}
```
