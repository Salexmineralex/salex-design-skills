#!/usr/bin/env bash
# Smoke-test every script in shared/scripts against tests/fixtures.
# Run from anywhere: scripts/test-scripts.sh
set -u
cd "$(dirname "$0")/.."
s=shared/scripts
f=tests/fixtures
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
fails=0

check() { # check <name> <command that must succeed>
  if eval "$2" >"$tmp/last" 2>&1; then echo "ok    $1"; else echo "FAIL  $1"; sed 's/^/      /' "$tmp/last"; fails=$((fails + 1)); fi
}

check "contrast: passing pair exits 0" "python3 $s/contrast.py '#12304a:#f6efe3'"
check "contrast: failing pair exits 1" "! python3 $s/contrast.py '#ddd:#fff'"
check "screenshot: captures a page" "bash $s/screenshot.sh $f/brand.html $tmp/shot.png 375 && test -s $tmp/shot.png"

check "why-lint: a finished handbook passes" "python3 $s/why-lint.py $f/good-STYLE.md"
python3 $s/why-lint.py $f/bad-STYLE.md >"$tmp/lint.txt" 2>&1; code=$?
check "why-lint: an unfinished one exits 1" "test $code = 1"
check "why-lint: catches a fashion reason" "grep -q 'rests on fashion' $tmp/lint.txt"
check "why-lint: catches an unresolved decision" "grep -q 'unresolved' $tmp/lint.txt"
check "why-lint: catches tokens not last" "grep -q 'must be the last' $tmp/lint.txt"
check "why-lint: catches a missing number" "grep -q 'needs a number' $tmp/lint.txt"
variant() { # variant <out> <reviewed text> [question line]: good-STYLE.md with its first Reviewed changed
  python3 - "$f/good-STYLE.md" "$1" "$2" "${3:-}" <<'PY'
import sys
src, out, reviewed, question = sys.argv[1:]
text = open(src).read().replace("- **Reviewed:** kept", "- **Reviewed:** " + reviewed, 1)
if question:
    text = text.replace("## Tokens", "## Questions asked\n" + question + "\n\n## Tokens", 1)
open(out, "w").write(text)
PY
}
variant "$tmp/history.md" "kept, after six reviews"
check "why-lint: kept with a history isn't kept" "python3 $s/why-lint.py $tmp/history.md | grep -q 'must be \"kept\"'"
variant "$tmp/onq.md" "kept (Q2)"
check "why-lint: kept on a missing answer fails" "python3 $s/why-lint.py $tmp/onq.md | grep -q 'has no Q2'"
variant "$tmp/onq-ok.md" "kept (Q2)" "- **Q2:** which lettering, rough or smooth? Answer: smooth."
check "why-lint: kept on a recorded answer passes" "python3 $s/why-lint.py $tmp/onq-ok.md"

bash $s/read-tokens.sh $f/brand.html "$tmp/x" >"$tmp/read.log" 2>&1
check "read-tokens: runs" "test -s $tmp/x/tokens.json && test -s $tmp/x/page-1440.png && test -s $tmp/x/page-375.png"
check "read-tokens: reads colors and font" "grep -q '#c8412b' $tmp/x/tokens.json && grep -q Georgia $tmp/x/tokens.json"
check "read-tokens: reads CSS variables" "grep -q harbor-coral $tmp/x/tokens.json"
check "read-tokens: reads a border on any side" "grep -q '#a8a29a' $tmp/x/tokens.json"
check "read-tokens: lists greys apart" "python3 -c \"import json;assert '#a8a29a' in json.load(open('$tmp/x/tokens.json'))['greys']\""
check "read-tokens: reads hover states" "grep -q '#9e3220' $tmp/x/tokens.json"
check "read-tokens: reads elevation and radii" "grep -q '\"elevation\"' $tmp/x/tokens.json && grep -q '2px' $tmp/x/tokens.json"
check "read-tokens: finds the logo, not the photo" "test \$(grep -c '\"kind\": \"logo\"' $tmp/x/assets.json) = 1"
check "read-tokens: strips scripts from SVGs" "! grep -lE '<script|onclick' $tmp/x/assets/*.svg"

bash $s/validate.sh $f/sloppy.html "$tmp/v1" >"$tmp/sloppy.txt" 2>&1; code=$?
check "validate: sloppy page exits 1" "test $code = 1"
check "validate: writes captures and a report" "test -s $tmp/v1/page-1440.png && test -s $tmp/v1/page-375.png && test -s $tmp/v1/report.md"
for rule in contrast typefaces line-length touch-target sideways-scroll empty-box focus; do
  check "validate: catches $rule" "grep -q '^FAIL $rule:' $tmp/sloppy.txt"
done
check "validate: gives no score" "! grep -qiE 'penalty|score' $tmp/sloppy.txt"

touch $f/good-page.html
bash $s/validate.sh $f/good-page.html "$tmp/v2" --style $f/good-STYLE.md >"$tmp/good.txt" 2>&1; code=$?
check "validate: a page built from its handbook passes" "test $code = 0"
check "validate: the brand's own border isn't off-token" "! grep -q 'off-token' $tmp/good.txt"

bash $s/validate.sh $f/good-page.html "$tmp/v3" --source $f/source-menu.html >"$tmp/menu.txt" 2>&1
check "bug: a nav behind a mobile menu isn't missing" "! grep -qE '^FAIL text-(removed|hidden)' $tmp/menu.txt"
check "bug: replacing an emoji isn't a text change" "! grep -qE '^FAIL text-' $tmp/menu.txt"
check "bug: replacing an emoji is an improvement" "grep -q '^INFO better:.*emoji replaced by drawn icons' $tmp/menu.txt"

bash $s/validate.sh $f/sloppy.html "$tmp/v4" --source $f/sloppy.html >"$tmp/inherit.txt" 2>&1; code=$?
check "bug: a sloppy source's problems still fail" "test $code = 1 && grep -q 'also in the source' $tmp/inherit.txt"

bash $s/validate.sh $f/sloppy.html "$tmp/v5" --style $f/good-STYLE.md >"$tmp/off.txt" 2>&1
check "validate: catches an off-token color" "grep -q '^FAIL off-token: color' $tmp/off.txt"
check "validate: a pattern with no decision is unreasoned" "grep -q '^FAIL unreasoned:.*gradient' $tmp/off.txt"
check "validate: refuses an unfinished handbook" "bash $s/validate.sh $f/good-page.html $tmp/v6 --style $f/bad-STYLE.md | grep -q '^FAIL style-lint'"
cp $f/good-page.html $f/brand-logo.svg $f/brand-photo.svg "$tmp/"; touch -t 200001010000 "$tmp/good-page.html"
check "validate: refuses a handbook newer than the build" "bash $s/validate.sh $tmp/good-page.html $tmp/v7 --style $f/good-STYLE.md | grep -q '^FAIL style-after-build'"

bash $s/validate.sh $f/over-pictures.html "$tmp/v8" >"$tmp/pics.txt" 2>&1
check "contrast: catches pale text on a gradient" "grep -q '^FAIL contrast: p.pale-text.*over a gradient' $tmp/pics.txt"
check "contrast: passes white text on a deep gradient" "! grep -q 'deep-text' $tmp/pics.txt"
check "contrast: says what it couldn't measure" "grep -q '^INFO contrast:.*1 not measured' $tmp/pics.txt"

# Build order: a project with its own stylesheet, so the page file can stay untouched.
b="$tmp/build"; mkdir -p "$b"
cat >"$b/STYLE.md" <<'EOF'
# Style: Test

> A test.

## Idea
A small page for testing the build order, with a dark ink on a pale ground.

## Principles
- Plain, not decorated.

## Decisions

### D1. Ink on a pale ground
- **Decision:** ink #111111 on paper #fefefe, text at 16px, 32px and 48px, space at 8px, 16px and 32px.
- **Why:** this test page has to read at once, so the darkest ink on the palest ground leaves nothing to check by eye.
- **Instead of:** grey on white, which would need a contrast check of its own.
- **Breaks if removed:** the test page has no style to compare against.
- **Trade-off:** it looks severe.
- **Source:** brief
- **Reviewed:** kept

## Tokens
```css
:root {
  --color-ink: #111111; /* D1 */
  --color-paper: #fefefe; /* D1 */
  --text-body: 16px; /* D1 */
  --text-title: 32px; /* D1 */
  --text-big: 48px; /* D1 */
  --space-s: 8px; /* D1 */
  --space-m: 16px; /* D1 */
  --space-l: 32px; /* D1 */
}
```
EOF
cat >"$b/page.html" <<'EOF'
<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Test</title><link rel="stylesheet" href="styles.css"></head><body><h1>Tide tables</h1><p>Daily tide times.</p></body></html>
EOF
css() { printf ':root{--color-ink:#111111;--color-paper:#fefefe;--text-body:16px;--text-title:32px;--text-big:48px;--space-s:8px;--space-m:16px;--space-l:32px}body{margin:0;padding:var(--space-l);color:var(--color-ink);background:var(--color-paper);font:var(--text-body)/1.5 Georgia,serif}h1{font-size:var(--text-title);margin:0 0 var(--space-m)}p{margin:0}%s\n' "$1" >"$b/styles.css"; }
vb() { bash $s/validate.sh "$b/page.html" "$b/out" --style "$b/STYLE.md" 2>&1; }
css ""; touch -t 200001010000 "$b/STYLE.md"
vb >"$tmp/b1.txt"
check "build: a page built from its handbook passes" "grep -q '^Result: PASS' $tmp/b1.txt"
sed -i.bak 's/this test page has to read at once/this test page must read straight away/' "$b/STYLE.md"
vb >"$tmp/b2.txt"
check "build: rewording a reason needs no rebuild" "grep -q '^Result: PASS' $tmp/b2.txt"
sed -i.bak 's/--color-ink: #111111/--color-ink: #222222/' "$b/STYLE.md"
touch "$b/page.html" "$b/styles.css"
vb >"$tmp/b3.txt"
check "build: touching files doesn't clear a changed handbook" "grep -q '^FAIL style-after-build' $tmp/b3.txt"
check "build: a token with another value is drift" "grep -q '^FAIL token-drift: --color-ink' $tmp/b3.txt"
sed -i.bak 's/--color-ink:#111111/--color-ink:#222222/' "$b/styles.css"
vb >"$tmp/b4.txt"
check "build: changing only the stylesheet counts as a rebuild" "grep -q '^Result: PASS' $tmp/b4.txt"
css "h1{font-size:37px}"; sed -i.bak 's/--color-ink:#111111/--color-ink:#222222/' "$b/styles.css"
vb >"$tmp/b5.txt"
check "tokens: catches a text size off the scale" "grep -q '^FAIL off-token: text size 37px' $tmp/b5.txt"
css ""; sed -i.bak 's/--color-ink:#111111/--color-ink:#222222/' "$b/styles.css"
sed -i.bak 's#<h1>#<svg width="40" height="40" aria-hidden="true"><circle cx="20" cy="20" r="18" fill="\#ff00aa"/></svg><h1>#' "$b/page.html"
vb >"$tmp/b6.txt"
check "tokens: catches a drawing color off the handbook" "grep -q '^FAIL off-token: color #ff00aa in a drawing' $tmp/b6.txt"
sed -i.bak 's#<svg.*</svg>##' "$b/page.html"
css "main{padding:13px 27px;margin:19px 23px}section{padding:11px;margin:29px}"
sed -i.bak 's/--color-ink:#111111/--color-ink:#222222/' "$b/styles.css"
css2="$(cat "$b/styles.css")"
sed -i.bak 's/<h1>/<main><section><h1>/; s#</p>#</p></section></main>#' "$b/page.html"
sed -i.bak 's/ink #111111 on paper #fefefe/a gradient, ink #111111 on paper #fefefe/; s/\*\*Instead of:\*\* grey on white/**Instead of:** grey on white/' "$b/STYLE.md"
printf '%s\nbody{background-image:linear-gradient(#fefefe,#fefefe)}\n' "$css2" >"$b/styles.css"
vb >"$tmp/b7.txt"
check "patterns: a decision that uses the pattern reasons it" "! grep -q '^FAIL unreasoned' $tmp/b7.txt"
sed -i.bak 's/a gradient, ink #111111/never a gradient; ink #111111/' "$b/STYLE.md"
vb >"$tmp/b8.txt"
check "patterns: a decision that rejects it doesn't" "grep -q '^FAIL unreasoned:.*gradient' $tmp/b8.txt"

check "sync: skill copies match shared/" "scripts/sync-shared.sh --check"

[ "$fails" = 0 ] && echo "all passed" || { echo "$fails failed"; exit 1; }
