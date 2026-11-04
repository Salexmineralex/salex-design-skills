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
check "roll: prints traits" "python3 $s/roll.py --seed 1 | grep -q ."
check "screenshot: captures a page" "bash $s/screenshot.sh $f/brand.html $tmp/shot.png 375 && test -s $tmp/shot.png"

bash $s/extract.sh $f/brand.html "$tmp/x" >"$tmp/extract.log" 2>&1
check "extract: runs" "test -s $tmp/x/extract.json && test -s $tmp/x/page-1440.png && test -s $tmp/x/page-375.png"
check "extract: reads the colors" "grep -q '#c8412b' $tmp/x/extract.json"
check "extract: reads the font" "grep -q Georgia $tmp/x/extract.json"
check "extract: reads CSS variables" "grep -q harbor-coral $tmp/x/extract.json"
check "extract: finds the logo" "grep -q '\"kind\": \"logo\"' $tmp/x/assets.json"
check "extract: a photo isn't a logo" "test \$(grep -c '\"kind\": \"logo\"' $tmp/x/assets.json) = 1"
check "extract: strips scripts from SVGs" "! grep -lE '<script|onclick' $tmp/x/assets/*.svg"

bash $s/slop-check.sh $f/sloppy.html >"$tmp/sloppy.txt" 2>&1; code=$?
check "slop: sloppy page exits 1" "test $code = 1"
for rule in violet-gradient fake-visual empty-card emoji-icon invented-steps filler-copy generic-card-grid trendy-font; do
  check "slop: catches $rule" "grep -q '^$rule:' $tmp/sloppy.txt"
done
check "slop: penalty is capped at 3" "grep -q '^Penalty: 3$' $tmp/sloppy.txt"
check "slop: sloppy page fails the hard gate" "grep -q '^Hard gate: FAIL' $tmp/sloppy.txt"
check "slop: --allow can't waive the hard gate" "bash $s/slop-check.sh $f/sloppy.html --allow empty-card | grep -q '^empty-card:'"
check "slop: one soft rule alone costs nothing" "bash $s/slop-check.sh $f/one-tell.html | grep -q '^Penalty: 0$'"
bash $s/slop-check.sh $f/defaults.html >"$tmp/def.txt" 2>&1
for rule in gradient-text nested-card icon-tile all-centered default-type-scale generator-trace recipe-fingerprint; do
  check "slop: catches $rule" "grep -q '^$rule:' $tmp/def.txt"
done
check "slop: --allow removes a rule" "! bash $s/slop-check.sh $f/sloppy.html --allow trendy-font | grep -q '^trendy-font:'"

check "slop: layers and picture cards aren't flagged" "! bash $s/slop-check.sh $f/layers.html | grep -E '^(empty-card|fake-visual|generic-card-grid):'"
check "slop: a violet layer is still flagged" "bash $s/slop-check.sh $f/layers.html | grep -q '^violet-gradient:'"
check "slop: a source's own violet gradient isn't slop" "! bash $s/slop-check.sh $f/layers.html --source $f/layers.html | grep -q violet"
check "slop: real brand page is clean" "bash $s/slop-check.sh $f/brand.html"
bash $s/slop-check.sh $f/in-brand.html --source $f/brand.html --locked $f/STYLE-locked.md >"$tmp/in.txt" 2>&1; code=$?
check "slop: in-brand page lists its placeholder" "grep -q '^placeholder' $tmp/in.txt"
check "slop: in-brand page has no penalty" "grep -q '^Penalty: 0$' $tmp/in.txt"
bash $s/slop-check.sh $f/off-brand.html --source $f/brand.html --locked $f/STYLE-locked.md >"$tmp/off.txt" 2>&1
check "slop: catches off-brand color" "grep -q '^off-brand: color #0a7cff' $tmp/off.txt"
check "slop: catches off-brand font" "grep -q '^off-brand: font \"fraunces\"' $tmp/off.txt"
check "slop: catches changed content" "grep -q '^content-changed:' $tmp/off.txt"

check "sync: skill copies match shared/" "scripts/sync-shared.sh --check"

[ "$fails" = 0 ] && echo "all passed" || { echo "$fails failed"; exit 1; }
