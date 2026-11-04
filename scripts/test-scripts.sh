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

check "sync: skill copies match shared/" "scripts/sync-shared.sh --check"

[ "$fails" = 0 ] && echo "all passed" || { echo "$fails failed"; exit 1; }
