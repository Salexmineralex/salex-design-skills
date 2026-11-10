# Style: Night Trace

> Your own seismograph: nights scribed on drum paper, overlaid until a pattern shows.

## Idea
Night Trace is a phone-on-the-nightstand recorder. It listens on-device overnight, detects grinding, draws each night as a scribed trace, overlays a weekly composite, and lets you tag triggers (coffee, stress, alcohol). The person wakes with a sore jaw, suspects bruxism, and wants when and why before a dentist. The tension: calm clinical clarity, like reading an instrument chart, while the subject is an anxious body thing. It is a lie if it diagnoses or cures, or uploads audio. The why-reviewer ran as the same writer, one decision at a time; D5 first failed CAUSE (any “hero illustration” would “show the product”) and was rewritten around a whole drum-paper trace.

## Principles
- Evidence, not therapy.
- Instrument paper, not wellness pastel.
- A scribed trace, not a phone mock with store badges.
- Honest scope: record, overlay, tag — nothing clinical as a claim.

## Signature
Drum paper: the hero is a whole seismograph strip — gridded drum paper, a needle’s trace for last night, fainter traces composited under it. Time runs along the top in mono. Display sits above a quiet clinical sans. No centred phone, no jaw gag, no crop. If the strip came off, this would be any app landing.

## Decisions

### D1. Drum paper and trace ink
- **Decision:** Paper #f3efe4, ink #1a1a1a, grid #c9c2b0, needle #0b5c5c, muted #4a4a42, paper-white #fffcf6.
- **Why:** They are anxious about a body thing; seismograph paper is the look of a measurement, which reduces anxiety by being a record, whereas wellness pastels would soothe without showing evidence and horror-black would raise it.
- **Instead of:** Mint-and-lilac wellness, or a black “sleep” UI with a tooth icon.
- **Breaks if removed:** The page stops being an instrument chart.
- **Trade-off:** Warm paper can still be mistaken for a journal app until the traces show.
- **Source:** user answer Q2 Q3
- **Reviewed:** kept (Q3)

### D2. Technical sans and mono axis
- **Decision:** Noto Sans, Liberation Sans, sans-serif for body and display; JetBrains Mono, Liberation Mono, monospace for the time axis, night labels, and Hz marks. Two families only.
- **Why:** Instrument charts pair a plain sans with tabular marks; a rounded wellness sans would soften a grinding record, and a novelty “ECG” font would turn scribing into costume.
- **Instead of:** A single geometric sans, or a handwritten journal face.
- **Breaks if removed:** Axis numbers stop lining up with the traces they name.
- **Trade-off:** Noto is plain; it will not feel like a branded consumer app.
- **Source:** user answer Q3
- **Reviewed:** kept (Q3)

### D3. Five sizes, the trace louder than the type
- **Decision:** 12px axis, 16px body, 20px section, 28px product name, 44px only if a night needs a numeral (e.g. “18 events”). Line-height 1.45 body.
- **Why:** On drum paper the drawing is the loud thing; type is a legend. A huge marketing headline would cover the trace, which is the evidence they woke up wanting.
- **Instead of:** A 64px headline and a small phone mock, the app-landing default.
- **Breaks if removed:** The seismograph becomes a banner under an ad.
- **Trade-off:** The name Night Trace is quieter than most app heroes.
- **Source:** user answer Q2
- **Reviewed:** kept (Q2)

### D4. Needle teal only on the live trace
- **Decision:** Last night’s trace is #0b5c5c; older nights in the composite are ink at 40% via a second path coloured #4a4a42. Paper-white #fffcf6 on needle teal for the one filled control (“Take last night to the dentist”).
- **Why:** A polygraph needle is one colour; extra accents would turn events into a dashboard. Teal is the instrument’s ink, not a wellness mint — it sits on paper at 6.7:1 so the live night can be told from the composite.
- **Instead of:** A rainbow of sleep stages, or pastel pills for coffee/stress/alcohol.
- **Breaks if removed:** Composite nights cannot be told from the night in question.
- **Trade-off:** Tags are words, not coloured chips, so they are slower to filter.
- **Source:** user answer Q3
- **Reviewed:** kept (Q3)

### D5. Hero is a whole drum strip
- **Decision:** One inline SVG: grid, time axis, composite paths, live path, needle. viewBox shown in full with meet, not slice. Figure overflow visible. No photograph of a jaw, no phone bezel as the composition.
- **Why:** “Scribing” and “composite” are what a seismograph does; a centred phone mock with two store badges is the default the brief forbade, and a cropped waveform would hide the night’s shape, which is the evidence.
- **Instead of:** Phone plus badges, or a tooth illustration.
- **Breaks if removed:** The signature move is gone.
- **Trade-off:** Some will not clock it as an app until the nightstand sentence.
- **Source:** user answer Q3 Q4
- **Reviewed:** kept (Q4)

### D6. Nights as overlaid traces, not cards
- **Decision:** Each night is a labelled trace on the same strip, plus a weekly composite. Supporting facts (on-device, no upload, not a diagnosis) are legend lines under the strip. Not three rounded tiles, not two store badges as the idea.
- **Why:** Overlay is how a composite is made; putting each night in a card would separate what the product exists to combine, and store badges as the hero would make it a generic download page.
- **Instead of:** Feature cards and badge buttons as the layout.
- **Breaks if removed:** “Composite” is a word with no picture.
- **Trade-off:** The download is a legend line, quieter than a store button.
- **Source:** user answer Q4 Q5
- **Reviewed:** kept (Q5)

### D7. 8px rhythm, actions in the legend
- **Decision:** Space 8, 16, 24, 32, 48, 64px. The get-app / export action is 48px tall in the legend row, min 44×44, square, sharing height with that row.
- **Why:** 44px is a tap floor, not a look; an isolated download pill under a phone mock is the default this page is not. The action belongs in the instrument’s legend, where “export the trace” would sit on paper.
- **Instead of:** Two store badges under a device.
- **Breaks if removed:** The page grows a marketing footer that fights the chart.
- **Trade-off:** Store identity is not shown.
- **Source:** user answer Q4
- **Reviewed:** kept (Q4)

### D8. Square paper, printed grid, no shadow
- **Decision:** Radius 0. Grid lines are drawn in the SVG in #c9c2b0, not a CSS gradient and not a drop shadow. No cards, panels, or tiles.
- **Why:** Drum paper is a printed grid; CSS rounding and shadow would turn traces into app widgets, and a CSS gradient grid would be a decoration instead of the instrument.
- **Instead of:** Soft cards on a lilac wash.
- **Breaks if removed:** The seismograph reads as a rounded chart widget.
- **Trade-off:** The page is flat, like paper.
- **Source:** user answer Q3
- **Reviewed:** kept (Q3)

### D9. Clinical voice, honest lie-line
- **Decision:** Copy says what it does (listen on-device, draw a trace, overlay, tag). It says it does not diagnose or cure bruxism and does not upload audio. No horror, no “smile again”, no jaw puns.
- **Why:** They need evidence for a dentist; a diagnostic claim would be a lie, and a teeth gag would make an anxious record feel unserious.
- **Instead of:** Wellness promises or jump-scare dentistry.
- **Breaks if removed:** The product overclaims, which is the one thing this person cannot afford.
- **Trade-off:** No cure story, so conversion is slower.
- **Source:** user answer Q2 Q5
- **Reviewed:** kept (Q5)

### D10. States on the needle, no motion
- **Decision:** Hover: live trace stroke 2px. Focus-visible: 2px ink outline, 2px offset. Active: needle fill, paper-white type. Disabled: 40%. Loading: “Scribing…”. Error: “Mic permission off — nothing was recorded.” The strip does not animate; a printed drum is still.
- **Why:** A moving waveform would feel like an equaliser toy; they need a still record they can screenshot for a dentist.
- **Instead of:** Looping “live” animation in the hero.
- **Breaks if removed:** The evidence looks performed instead of kept.
- **Trade-off:** No demo motion to prove the needle works.
- **Source:** user answer Q2
- **Reviewed:** kept (Q2)

## Assumptions
- **A1:** The owner asked for a mobile-app landing, built from scratch.
- **A2:** Theme words from the random-word API: gnash, composite, scribing.
- **A3:** Noto Sans and JetBrains Mono are the families this environment will paint.

## Questions asked
- **Q1:** Who is this app for? Answered by the owner's assistant at the owner's request: someone who wakes with a sore jaw and suspects they grind their teeth at night (bruxism), wanting to know when and why before seeing a dentist. Why: "gnash" names the act; the person needs evidence, not therapy.
- **Q2:** What one feeling, and what it must never feel like? Answered by the owner's assistant at the owner's request: calm, clinical clarity — like reading your own instrument chart. Never wellness pastel softness, never horror-teeth. Why: they're anxious about a body thing; clarity reduces anxiety more than soothing visuals.
- **Q3:** What world to borrow? Answered by the owner's assistant at the owner's request: seismograph and polygraph paper — needles scribing waveforms on gridded drum paper, composite overlays of many nights. Why: "scribing" + "composite" map directly onto instruments that draw a record over time; it's the honest look of measurement.
- **Q4:** What must it never borrow? Answered by the owner's assistant at the owner's request: no centred phone mock + two store badges as the whole idea; no literal jaw/teeth gags. Why: default app-landing layout and gags both make it feel unserious.
- **Q5:** What must be true of the app? Answered by the owner's assistant at the owner's request: the phone, on the nightstand, listens on-device overnight, detects grinding sounds, and draws each night as a scribed trace; a weekly composite overlays nights so patterns show, and you tag triggers (coffee, stress, alcohol). It's a lie if it claims to diagnose or cure bruxism, or uploads audio. Why: honest scope; it's a record you bring to a dentist.
- **Q6:** Which direction? Answered by the owner's assistant at the owner's request: Drum paper, because it is closest to the seismograph-paper world.

## Tokens
```css
:root {
  --color-ink: #1a1a1a; /* D1 */
  --color-paper: #f3efe4; /* D1 */
  --color-grid: #c9c2b0; /* D1 */
  --color-needle: #0b5c5c; /* D1 */
  --color-muted: #4a4a42; /* D1 */
  --color-white: #fffcf6; /* D1 */
  --font-display: Noto Sans, Liberation Sans, sans-serif; /* D2 */
  --font-axis: JetBrains Mono, Liberation Mono, monospace; /* D2 */
  --font-size-axis: 12px; /* D3 */
  --font-size-body: 16px; /* D3 */
  --font-size-section: 20px; /* D3 */
  --font-size-name: 28px; /* D3 */
  --font-size-numeral: 44px; /* D3 */
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
