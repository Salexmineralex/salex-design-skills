# Style: Harbor Tide

> A harbor master's almanac: plain, exact, trusted at dawn.

## Idea
Tide tables for working harbors.

## Principles
- Exact, not decorated.

## Signature
A bookish serif on warm paper, like a printed almanac, with one coral action.

## Decisions

### D1. Serif text on warm paper
- **Decision:** Georgia on sand #f6efe3 with navy ink #12304a.
- **Why:** the source already uses Georgia on sand, so a visitor still reads the same type while we restyle layout for the phone.
- **Instead of:** a neutral sans on white.
- **Breaks if removed:** the page stops matching the source.
- **Trade-off:** less compact than a sans.
- **Source:** brief
- **Reviewed:** kept

## Tokens
```css
:root {
  --color-ink: #12304a; /* D1 */
  --color-paper: #f6efe3; /* D1 */
  --font-text: Georgia, serif; /* D1 */
}
```
