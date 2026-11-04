# Design handbook

The rules a good designer knows by heart, condensed from the classic handbooks. Use them to make choices and to explain them: quote the rule and, when it helps, where it comes from.

**Contents:** Principles · Turning a theme into a style · Typography · Color · Space and layout · Shape, depth and texture · Components · Polish · Motion · Accessibility · Trends: when they fit · Sources

## Principles

- **A style is the rules you keep.** Few rules, applied everywhere, read as taste. Many exceptions read as a mess.
- **Hierarchy first.** Each screen has one focal point. Rank everything else below it using size, weight, color and space, in that order of strength. To make something stand out, it's often better to tone down what's around it than to make it louder (Refactoring UI).
- **Same thing, same look; different thing, different look.** If two things look alike, users assume they behave alike.
- **Gestalt:** things close together read as a group (proximity), things that look alike read as related (similarity), the eye follows lines and alignments (continuity), and a clear figure needs a calm ground (figure/ground).
- **As little design as possible** (Dieter Rams): every element should earn its place. Decoration is fine when it carries the idea; it's noise when it's only there because the space was empty.
- **Form follows use.** A dashboard used all day needs density and calm. A landing page seen once needs a strong first impression. The same idea is styled differently for each.

## Turning a theme into a style

Themes like pirates, skateboard or cyberpunk go wrong in one of two ways: costume (skull clip-art everywhere) or nothing (a default UI with one themed font). To avoid both:

- **Borrow the theme's systems, not its clichés.** Ask how things in that world are *made*: the materials, the printing methods, the lettering on its real objects, the colors of its places. Pirates: ship's logs, nautical charts, wax seals, rope, salt-faded ink. Skateboard: deck graphics, photocopied zines, grip tape, screen prints, stickers. Cyberpunk: terminal UIs, neon signage, dense info displays, glitch, rain on glass.
- **Theme at the edges, clarity at the core.** Use the theme at full strength where people look but don't work: headings, hero, illustrations, empty states, loading screens. Keep forms, tables and body text plain and easy to read, with just the palette and shape language carrying the theme.
- **One signature move.** Pick one memorable thing (a stamped label, a chart-grid background, a hard offset shadow, a ticket-stub card edge) and use it consistently. One move used well beats five used once.
- **Pick the era precisely.** "Retro" isn't a style. 1920s Art Deco, 1950s atomic, 1970s earth tones, 1980s Memphis, 1990s web and Y2K chrome are very different. Name the decade and the medium (posters, packaging, TV, software).

## Typography

Sources: Bringhurst, *The Elements of Typographic Style*; Butterick, *Practical Typography*; Lupton, *Thinking with Type*.

- **Two typefaces at most,** plus a monospace if the product shows code or data. A third starts to fight for attention. A single superfamily (sans and serif designed together) is the safest pairing.
- **Pair by contrast, not similarity.** A display face with character plus a calm text face. Two similar sans-serifs look like a mistake.
- **Body text: 16px minimum on screens,** 17 to 20px for reading-heavy products. Line height 1.4 to 1.6 for body, 1.0 to 1.2 for large headings.
- **Line length: 45 to 75 characters,** about 66 is ideal. Longer lines make the eye lose its place; shorter ones break the rhythm.
- **Use a type scale,** not random sizes. Pick the ratio by mood: 1.125 to 1.2 for dense, calm UIs; 1.25 for balanced; 1.333 to 1.5 for expressive, editorial styles. Six to eight sizes are enough.
- **Pick the body face at real size, on screen.** Set a real paragraph at the body size and look at it in a screenshot. It needs enough weight and x-height to read solidly at 16–18px. A face that looks charming in a specimen can turn thin and pale in a paragraph; if it does, pick another or go one weight up.
- **Two or three weights.** Never fake bold or italic; load the real styles.
- **Letter spacing:** tighten large display text slightly (−1% to −2%). Loosen small all-caps labels (+5% to +10%). Never letter-space lowercase body text.
- **All caps only for short labels.** Long all-caps text is hard to read.
- **Tabular numbers** in tables, prices and anything that lines up vertically.
- **Display fonts are for display.** A strong themed font (blackletter, Western slab, pixel, handwritten) belongs in headings only, never in body text, buttons or forms.
- **Check the boring things:** the font supports the project's languages and accents, has the weights you need, has an open licence (Google Fonts, Fontsource, Velvetyne, the League of Moveable Type), and isn't huge to load.
- **Defaults need a reason too.** Inter, Roboto or the system font are fine when the reason is neutrality and speed. They're a missed chance when the brief asks for character.

## Color

Sources: Albers, *Interaction of Color*; WCAG 2.2; Refactoring UI.

- **Color is relative** (Albers). The same color looks different next to different colors, so judge the palette in context, on the preview page, never as isolated swatches.
- **Define colors by role,** not by name: background, surface, text, muted text, border, primary, accent, and the states (success, warning, danger, info). Components use roles, so the palette can change without touching them.
- **Build each hue as a scale** (for example 50 to 900) with even lightness steps. OKLCH makes even steps easy; plain HSL doesn't, because yellow and blue at the same "lightness" look very different.
- **Tint the neutrals.** Pure grays look dead next to a colored brand. Push the grays slightly toward the brand hue (warm or cool).
- **Avoid pure black on pure white** for long reading; it glares. Use a near-black and an off-white. Pure black is fine as a deliberate graphic choice (posters, brutalism).
- **60/30/10:** about 60% dominant (usually the neutral background), 30% secondary, 10% accent. A scarce accent means something; an accent everywhere means nothing.
- **Strong saturated colors side by side vibrate.** Separate them with a neutral or change one's lightness.
- **Never use color alone to carry meaning.** Add an icon, a label or a pattern. About 1 in 12 men can't tell red from green.
- **Dark mode is not inverted light mode.** Lower the saturation, show elevation with lighter surfaces instead of shadows, avoid pure black backgrounds, and recheck every contrast pair.
- **Contrast minimums (WCAG 2.2 AA):** 4.5:1 for normal text, 3:1 for large text (24px and up, or 18.66px bold), 3:1 for UI boundaries, icons and focus rings. AAA is 7:1 for normal text. Check with `scripts/contrast.py`.

## Space and layout

Sources: Müller-Brockmann, *Grid Systems in Graphic Design*; Refactoring UI.

- **One base unit,** 4px or 8px, and a spacing scale built from it (4, 8, 12, 16, 24, 32, 48, 64, 96). Every gap uses the scale.
- **Space shows relationships:** the gap inside a group is smaller than the gap between groups. If everything is evenly spaced, nothing is grouped.
- **Start with too much space, then remove it.** Cramped layouts are the most common amateur mistake.
- **A grid makes things look intentional.** Twelve columns are flexible on the web. Fewer alignment lines read as calmer.
- **Density follows use:** tools used for hours can be dense, marketing pages should breathe.
- **Touch targets:** at least 44×44px (Apple HIG) or 48×48dp (Material). WCAG 2.2's minimum is 24×24px.
- **Design mobile first** when the product is used on phones, and check the style holds at 375px wide.

## Shape, depth and texture

- **One radius family.** Sharp (0 to 2px) reads technical or editorial, medium (6 to 12px) friendly, pill reads playful. When one rounded shape sits inside another, the inner radius equals the outer radius minus the padding between them, or the corners look off.
- **One depth language:** shadows, borders or background shifts. Mixing all three looks noisy.
- **Shadows imitate one light source.** Realistic shadows combine a tight dark one with a wide soft one. Hard offset shadows with no blur are a stylistic choice (retro, neubrutalism) and should be used everywhere or nowhere.
- **Two to four elevation levels** are enough: flat, raised (cards), floating (menus, popovers), overlay (modals).
- **Textures (grain, halftone, paper) stay subtle** and never sit under body text where they lower contrast.
- **One icon set,** with a stroke width that matches the text weight and sizes that align to the type.
- **Imagery has rules too:** photo or illustration, color or duotone, cropped how. Write them down.

## Components

- **Every interactive component has states:** default, hover, focus-visible, active (pressed), disabled, loading, and for inputs, error and success. Missing states are what make a style feel unfinished.
- **Button hierarchy:** one primary action per view, then secondary, tertiary (text or ghost) and destructive. If everything is primary, nothing is.
- **Inputs keep a visible label.** A placeholder is not a label; it disappears when the user types. Errors appear under the field, in words, with an icon, not only in red.
- **Focus must always be visible,** with at least 3:1 contrast. Style it to match the theme, but never remove it.
- **Empty, loading and error states** are where a style shows its personality, and the ones most often forgotten.

## Polish

The small things people notice before they notice the palette. A style with great colors and one misaligned button looks unfinished. Check these on the real screens, with real content, at desktop and phone width.

- **Controls in a row share one height.** Buttons, inputs, selects and toggles that sit side by side use the same height token (for example 48px) and the same vertical center. Their labels line up on the same baseline.
- **Depth effects apply to the whole row.** If buttons have an offset shadow that makes them look raised, a select or input next to them must match it, or sit on a separate line. Otherwise the row looks uneven even when the boxes are aligned.
- **Text fills its box the way the box suggests.** If the text has a maximum line length, the box around it gets that width too, or the text is centered in it. A narrow column of text on the left of a wide card looks like a bug.
- **Badges and labels have a home.** Put them inside the content (next to the title) or pinned cleanly to a card's corner or edge. Never half over an illustration, where they look dropped there.
- **The focus ring fits the shape.** It follows the component's corner radius (radius plus the offset), and it wraps everything that looks like part of the component, including an offset or hard shadow; or the shadow goes away while focused. It's the same style on every focusable thing, and it doesn't change the component's own shape. A ring that sits inside a shadow, or has different corners from its button, looks broken.
- **Disabled looks disabled.** Lower contrast (still 3:1 for the outline), no shadow and no hover. Not dashed, striped or "broken" looking, which reads as an error.
- **Edges line up.** Headings, cards and text in one column share the same left edge. Count the different alignment lines on a screen; fewer is calmer.
- **Spacing is consistent between siblings.** The same kind of gap is the same size everywhere: between cards, between form fields, under headings.
- **Real content, not ideal content.** Long titles, a 5-digit number, an empty list, a name with an accent. The layout should survive all of them.
- **Phone first-class.** At 375px wide: no sideways scroll, grids collapse to one or two columns, tables scroll inside their own box or turn into stacked rows, rows of buttons stack full-width, nothing is cut off and touch targets stay at least 44px. A layout that falls apart on a phone fails, however good it looks on a laptop.

## Motion

- **Motion explains:** where something came from, what changed, what's connected. Motion that only decorates gets tiring on the tenth view.
- **Durations:** 100 to 200ms for small changes (hover, toggles), 200 to 400ms for larger ones (panels, modals). Anything slower feels sluggish in a tool.
- **Easing:** ease-out for things entering, ease-in for things leaving. Linear only for continuous loops.
- **Respect `prefers-reduced-motion`:** swap movement for fades or nothing.

## Accessibility

Good design is usable design; these aren't optional extras.

- Contrast as above. Check every pair, including text on colored buttons and on images.
- Never color-only meaning. Visible focus. Big enough targets.
- Text must stay readable at 200% zoom without breaking the layout.
- Body text in a readable face. Decorative fonts never carry essential information.

## Trends: when they fit

A trend is allowed only when you can state the reason without the words "popular" or "modern". Ask the user what it should do for *their* users.

- **Glassmorphism (frosted glass):** needs a rich, colorful background to have anything to blur, and often fails contrast. Fits overlays on photos or video. Doesn't fit text-heavy tools.
- **Neumorphism (soft extruded shapes):** buttons barely stand out from the background, so it fails contrast almost by design. Recommend against it.
- **Neubrutalism (thick borders, hard shadows, flat bright colors):** fits playful, indie, rebellious products. Can feel like a costume on serious or premium ones.
- **Bento grids:** good for showing several features at a glance. Not a layout for real app screens.
- **Purple-to-blue gradients, glowing blobs:** today's default "AI startup" look. Signals generic, not a brand. Avoid unless the user has a reason.
- **Dark mode by default:** fits tools used at night, media, developer tools. Light usually reads better for long text and in daylight.
- **Huge hero type:** strong for editorial and brand pages, wasteful on tools.
- **Everything Inter, rounded 8px cards, soft gray shadows:** a perfectly fine default that says nothing. Choose it on purpose or not at all.

## Sources

Point the user to these when a rule needs backing:

- Adam Wathan and Steve Schoger, *Refactoring UI*: hierarchy, spacing, color for interfaces.
- Matthew Butterick, *Practical Typography* (free online): typography rules for screens.
- Robert Bringhurst, *The Elements of Typographic Style*: line length, scale, rhythm.
- Ellen Lupton, *Thinking with Type*: type pairing and expression.
- Josef Albers, *Interaction of Color*: why color is relative.
- Josef Müller-Brockmann, *Grid Systems in Graphic Design*: grids and order.
- Don Norman, *The Design of Everyday Things*: affordances, feedback, consistency.
- Dieter Rams, ten principles of good design.
- WCAG 2.2, Apple Human Interface Guidelines, Material Design 3: accessibility and platform rules.
