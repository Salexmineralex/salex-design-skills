# Style: Harbor Tide

> A harbor master's almanac: plain, exact, trusted at dawn.

## Idea
Tide tables for working harbors, read by skippers at dawn. The tension: it must feel as old and trusted as an almanac, yet be fast on a phone in the rain.

## Principles
- Exact, not decorated.

## Decisions

### D1. Serif text on warm paper
- **Decision:** Georgia on sand #f6efe3 with navy ink #12304a.
- **Why:** skippers trust printed almanacs, and a bookish serif on paper carries that trust while staying legible in low dawn light.
- **Instead of:** a neutral sans on white, which would read as one more weather app and lose the almanac's trust.
- **Breaks if removed:** the page stops feeling like a reference skippers already rely on.
- **Trade-off:** less compact than a sans, so tables take more room.
- **Source:** brief
- **Reviewed:** kept

### D2. One coral action, with quiet greys
- **Decision:** coral #c8412b for the one action; muted text #6b5f4c; white on coral.
- **Why:** coral matches harbor buoys, so the single action stands out at a glance when hands are busy on deck.
- **Instead of:** several accent colors, which would make skippers hunt for the action.
- **Breaks if removed:** the main action blends into the table.
- **Trade-off:** no color left for categories.
- **Source:** brief
- **Reviewed:** kept

## Tokens
```css
:root {
  --color-ink: #12304a; /* D1 */
  --color-paper: #f6efe3; /* D1 */
  --color-action: #c8412b; /* D2 */
  --color-muted: #6b5f4c; /* D2 */
  --color-white: #ffffff; /* D2 */
  --color-rule: #d9cdb6; /* D2 */
  --font-text: Georgia, serif; /* D1 */
}
```
