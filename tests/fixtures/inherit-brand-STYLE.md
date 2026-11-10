# Style: Harbor Tide

> A harbor master's almanac: plain, exact, trusted at dawn.

## Idea
Tide tables for working harbors, in brand mode: keep the rendered look.

## Principles
- Exact, not decorated.

## Signature
A bookish serif on warm paper, like a printed almanac, with one coral action.

## Decisions

### D1. Serif text on warm paper
- **Decision:** Georgia on sand #f6efe3 with navy ink #12304a.
- **Why:** the source already uses Georgia on sand, so a visitor who knows this almanac still reads the same type while layout is what we change.
- **Instead of:** a neutral sans on white, which would throw away the look we were asked to keep.
- **Breaks if removed:** the page stops matching the brand we were asked to keep.
- **Trade-off:** less compact than a sans.
- **Source:** brand style/references/tokens/source/tokens.json
- **Reviewed:** kept

## Tokens
```css
:root {
  --color-ink: #12304a; /* brand */
  --color-paper: #f6efe3; /* brand */
  --font-text: Georgia, serif; /* brand */
}
```
