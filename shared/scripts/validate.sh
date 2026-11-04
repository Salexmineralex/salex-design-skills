#!/usr/bin/env bash
# Measure a built page. Numbers only, no score and no opinion.
#
# Usage: validate.sh <file-or-url> <out-dir> [--source <file-or-url>] [--style <STYLE.md>]
#   --source  the original page: report text added or removed, and what it already fails
#   --style   the handbook the page was built from: check it first with why-lint.py, and
#             report colors, fonts and patterns the handbook doesn't account for
#
# Writes <out-dir>/page-1440.png, page-375.png and report.md.
#
# FAIL (disqualifies; exit 1):
#   contrast, typefaces (more than 3), type-scale (near-duplicate sizes, more than 10
#   sizes), line-length (over 85 characters), touch-target (under 24px), sideways-scroll,
#   empty-box, broken-image, focus (no visible ring), text-removed, text-added,
#   text-hidden, off-token, unreasoned (a pattern with no decision in the handbook),
#   style-lint, style-after-build
# WARN (look at it): touch targets under 44px, weak spacing consistency, overlaps and
#   cut-off content from screenshot.sh
# INFO: image and text ratio, placeholders, emoji replaced by drawn icons
#
# Anything the source already fails still fails here, marked "also in the source": a
# restyle fixes inherited problems, it doesn't keep them. Text hidden by design (a nav
# behind a mobile menu) isn't missing. Emoji are decoration, not copy: replacing one
# with a drawn icon changes no text and is reported as an improvement.
#
# Mark a missing asset with data-placeholder="what's needed" and a specimen (a color
# swatch) with data-specimen.
#
# Uses Playwright, which downloads its own Chromium the first time (about 150 MB).
set -uo pipefail

if [ $# -lt 2 ]; then
  sed -n '2,29p' "$0"
  exit 2
fi

target="$1"; out="$2"; shift 2
source_page="" style=""
while [ $# -gt 0 ]; do
  case "$1" in
    --source) source_page="$2"; shift 2 ;;
    --style) style="$2"; shift 2 ;;
    *) echo "unknown option: $1" >&2; exit 2 ;;
  esac
done

here="$(cd "$(dirname "$0")" && pwd)"
to_url() {
  case "$1" in
    "") echo "" ;;
    http://*|https://*|file://*) echo "$1" ;;
    *) echo "file://$(cd "$(dirname "$1")" && pwd)/$(basename "$1")" ;;
  esac
}
url="$(to_url "$target")"
source_url="$(to_url "$source_page")"
mkdir -p "$out"
out="$(cd "$out" && pwd)"
if [ -n "$style" ] && [ ! -f "$style" ]; then
  echo "no such file: $style" >&2
  exit 2
fi

pre=""
if [ -n "$style" ]; then
  if ! lint="$(python3 "$here/why-lint.py" "$style" 2>&1)"; then
    pre="FAIL style-lint: the handbook isn't finished, so nothing should be built from it
$(echo "$lint" | sed 's/^/  /')"
  fi
  # The handbook comes first. If it's newer than the page, the page wasn't built from it.
  if [ -f "$target" ] && [ "$style" -nt "$target" ]; then
    pre="$pre
FAIL style-after-build: STYLE.md changed after this page was built; rebuild the page from it"
  fi
fi

warnings=""
for w in 1440 375; do
  shot="$(bash "$here/screenshot.sh" "$target" "$out/page-$w.png" "$w" 2>&1 >/dev/null)" || { echo "$shot" >&2; exit 2; }
  warnings="$warnings$(echo "$shot" | grep '^warning:' | grep -v 'wider than the window' | sed "s/^warning: /WARN overflow at $w: /")
"
done

version="1.49.1"
modules="$(npx -y -p "playwright@$version" -c 'cd "$(dirname "$(command -v playwright)")/.." && pwd')"

NODE_PATH="$modules" PRE="$pre" WARNINGS="$warnings" node - "$url" "$source_url" "$style" "$out" <<'JS'
const { chromium } = require("playwright");
const fs = require("fs");
const path = require("path");
const [url, sourceUrl, stylePath, out] = process.argv.slice(2);

const measure = () => {
  const cs = (el) => getComputedStyle(el);
  const name = (el) => el.tagName.toLowerCase() + (el.id ? "#" + el.id : "") + [...el.classList].slice(0, 2).map((c) => "." + c).join("");
  const seen = (el) => el.checkVisibility({ checkOpacity: false, checkVisibilityCSS: true }) && el.getBoundingClientRect().width > 0;
  const color = (c) => { const p = (c.match(/[\d.]+/g) || [0, 0, 0, 0]).map(Number); return { r: p[0], g: p[1], b: p[2], a: p.length > 3 ? p[3] : 1 }; };
  const hex = (c) => "#" + [c.r, c.g, c.b].map((v) => Math.round(v).toString(16).padStart(2, "0")).join("");
  const lum = (c) => { const f = (v) => { v /= 255; return v <= 0.03928 ? v / 12.92 : ((v + 0.055) / 1.055) ** 2.4; }; return 0.2126 * f(c.r) + 0.7152 * f(c.g) + 0.0722 * f(c.b); };
  const blend = (top, under) => ({ r: top.r * top.a + under.r * (1 - top.a), g: top.g * top.a + under.g * (1 - top.a), b: top.b * top.a + under.b * (1 - top.a), a: 1 });
  // The solid color behind an element, or null when an image or gradient is in the way.
  // Read the real stack at the text's position, because what's behind it may be a sibling
  // layer rather than an ancestor. Not sure means not measured: never a guessed failure.
  const behind = (el) => {
    const range = document.createRange();
    range.selectNodeContents(el);
    el.scrollIntoView({ block: "center" });
    const box = range.getBoundingClientRect();
    const stack = document.elementsFromPoint(box.left + box.width / 2, box.top + box.height / 2);
    const start = stack.indexOf(el);
    if (start < 0) return null;
    const layers = [];
    for (const e of stack.slice(start)) {
      const s = cs(e);
      if (s.backgroundImage !== "none" || e.matches("img, video, canvas, svg, svg *, picture, iframe") || +s.opacity < 1 || s.mixBlendMode !== "normal") return null;
      const c = color(s.backgroundColor);
      if (c.a > 0) { layers.push(c); if (c.a === 1) break; }
    }
    let base = { r: 255, g: 255, b: 255, a: 1 };
    for (const l of layers.reverse()) base = blend(l, base);
    return base;
  };
  const all = [...document.querySelectorAll("body, body *")].filter((el) => !el.closest("svg, script, style, noscript, template") && seen(el));
  const specimen = (el) => !!el.closest("[data-specimen]") || !!el.parentElement?.closest("[data-placeholder]");
  const texted = all.filter((el) => !specimen(el) && [...el.childNodes].some((n) => n.nodeType === 3 && n.textContent.trim()));

  const contrast = new Map(), fonts = {}, sizes = {}, colors = {}, placeholders = [];
  for (const el of texted) {
    const s = cs(el), px = parseFloat(s.fontSize);
    fonts[s.fontFamily.split(",")[0].replace(/["']/g, "").trim()] = 1;
    sizes[px] = (sizes[px] || 0) + 1;
    const under = behind(el), fg = color(s.color);
    if (fg.a === 1) colors[hex(fg)] = 1;
    if (!under || fg.a === 0 || /text/.test(s.webkitBackgroundClip || "")) continue;
    const f = lum(blend(fg, under)), b = lum(under), ratio = (Math.max(f, b) + 0.05) / (Math.min(f, b) + 0.05);
    const large = px >= 24 || (px >= 18.66 && +s.fontWeight >= 700);
    if (ratio < (large ? 3 : 4.5)) contrast.set(hex(blend(fg, under)) + " on " + hex(under), ratio.toFixed(2) + ":1 at " + px + "px");
  }

  const longLines = [];
  const range = document.createRange();
  for (const el of texted.filter((e) => e.matches("p, li, blockquote, dd"))) {
    range.selectNodeContents(el);
    const tops = new Set([...range.getClientRects()].map((r) => Math.round(r.top)));
    const chars = el.textContent.trim().length;
    if (tops.size >= 3 && chars / tops.size > 85) longLines.push(name(el) + " about " + Math.round(chars / tops.size) + " characters a line");
  }

  const small = [], tight = [];
  for (const el of document.querySelectorAll('a[href], button, input:not([type="hidden"]), select, textarea, [role="button"]')) {
    if (!seen(el) || (el.matches("a") && el.closest("p, li") && !el.matches("nav a, nav *"))) continue;
    const r = el.getBoundingClientRect(), side = Math.min(r.width, r.height);
    if (side < 24) small.push(name(el) + " " + Math.round(r.width) + "x" + Math.round(r.height));
    else if (side < 44) tight.push(name(el));
  }

  const spacing = [];
  for (const el of all) {
    const s = cs(el);
    for (const p of ["paddingTop", "paddingLeft", "marginTop", "marginBottom", "rowGap", "columnGap"]) { const v = parseFloat(s[p]); if (v > 0) spacing.push(v); }
  }
  const onBase = (b) => spacing.filter((v) => v % b === 0).length / (spacing.length || 1);
  const bases = [4, 5, 6, 8].map((b) => [b, onBase(b)]).sort((x, y) => y[1] - x[1]);

  const empties = [], broken = [];
  let picture = 0;
  for (const el of document.querySelectorAll("img, svg, video, canvas, picture")) {
    if (!seen(el) || el.parentElement?.closest("svg")) continue;
    const r = el.getBoundingClientRect();
    picture += r.width * r.height;
    if (el.matches("img") && el.complete && el.naturalWidth === 0) broken.push(el.getAttribute("src") || name(el));
  }
  for (const el of all) {
    if (/url\(/.test(cs(el).backgroundImage)) { const r = el.getBoundingClientRect(); picture += r.width * r.height; }
  }
  const media = "img, picture, video, canvas, svg, iframe, object, input, select, textarea, button, [data-placeholder]";
  for (const el of all) {
    if (el.hasAttribute("data-placeholder")) placeholders.push(el.getAttribute("data-placeholder") || el.textContent.trim().slice(0, 80));
    if (specimen(el) || el.matches("html, body, input, select, textarea, button, hr, progress, meter, pre, code, " + media)) continue;
    const s = cs(el), r = el.getBoundingClientRect();
    if (r.width < 100 || r.height < 60 || /absolute|fixed/.test(s.position) || el.closest('[aria-hidden="true"]')) continue;
    const drawn = color(s.backgroundColor).a > 0 || s.boxShadow !== "none" || (parseFloat(s.borderLeftWidth) > 0 && parseFloat(s.borderRightWidth) > 0 && parseFloat(s.borderTopWidth) > 0);
    if (drawn && s.backgroundImage === "none" && !el.textContent.trim() && !el.querySelector(media)) empties.push(name(el));
  }

  // Patterns aren't banned. Each one needs a decision in the handbook.
  const patterns = new Set();
  for (const el of all) if (!specimen(el) && /gradient/.test(cs(el).backgroundImage) && el.getBoundingClientRect().width >= 80) patterns.add("gradient");
  const emoji = /\p{Emoji_Presentation}|\p{Extended_Pictographic}️/u;
  if (texted.some((el) => [...el.childNodes].some((n) => n.nodeType === 3 && emoji.test(n.textContent)))) patterns.add("emoji");
  const labels = texted.map((el) => el.textContent.trim());
  if (labels.some((t) => /^step\s*0?\d+\b/i.test(t)) || labels.filter((t) => /^0[1-9][.)]?$/.test(t)).length >= 2) patterns.add("step");
  for (const el of all) {
    if (specimen(el) || !/flex|grid/.test(cs(el).display)) continue;
    const kids = [...el.children].filter(seen);
    const rounded = kids.filter((k) => parseFloat(cs(k).borderTopLeftRadius) >= 8);
    if (kids.length >= 3 && rounded.length === kids.length && Math.max(...kids.map((k) => k.getBoundingClientRect().width)) - Math.min(...kids.map((k) => k.getBoundingClientRect().width)) < 4) patterns.add("card");
  }

  // Every color drawn, on every side, for the handbook check.
  for (const el of all) {
    if (specimen(el)) continue;
    const s = cs(el), bg = color(s.backgroundColor);
    if (bg.a === 1) colors[hex(bg)] = 1;
    for (const side of ["Top", "Right", "Bottom", "Left"]) {
      if (parseFloat(s["border" + side + "Width"]) > 0 && s["border" + side + "Style"] !== "none") { const c = color(s["border" + side + "Color"]); if (c.a === 1) colors[hex(c)] = 1; }
    }
  }

  // All text in the page, hidden or not, with whether a reader can get to it.
  const blocks = {};
  const walker = document.createTreeWalker(document.body, NodeFilter.SHOW_TEXT);
  for (let n = walker.nextNode(); n; n = walker.nextNode()) {
    const p = n.parentElement;
    if (!n.textContent.trim() || p.closest("script, style, noscript, template, svg, [data-placeholder]")) continue;
    // A mobile menu's own toggle is part of the pattern, not new copy.
    const toggle = p.closest("button, [role=button]");
    if (toggle && (toggle.hasAttribute("aria-expanded") || toggle.hasAttribute("aria-controls") || /menu|navigation/i.test(toggle.getAttribute("aria-label") || ""))) continue;
    const text = n.textContent;
    const reachable = seen(p) || !!p.closest('nav, header, menu, details, dialog, [role="menu"], [role="dialog"], [role="navigation"], [popover], [class*="menu" i], [class*="drawer" i]');
    blocks[text] = (blocks[text] || false) || reachable;
  }
  return {
    sideways: document.documentElement.scrollWidth - innerWidth,
    contrast: [...contrast].map(([k, v]) => k + " is " + v), fonts: Object.keys(fonts), sizes: Object.keys(sizes).map(Number).sort((a, b) => a - b),
    longLines, small, tight: tight.length, base: bases[0][0], onBase: bases[0][1], spacingCount: spacing.length,
    empties: [...new Set(empties)], broken, placeholders, patterns: [...patterns], colors: Object.keys(colors),
    picture: picture / Math.max(1, document.documentElement.scrollWidth * document.documentElement.scrollHeight),
    words: document.body.innerText.trim().split(/\s+/).length, blocks,
    drawn: document.querySelectorAll("svg, img").length,
    emoji: (document.body.textContent.match(/\p{Emoji_Presentation}|\p{Extended_Pictographic}️/gu) || []).length,
  };
};

const open = async (browser, target, width) => {
  const page = await browser.newPage({ viewport: { width, height: 900 } });
  await page.goto(target, { waitUntil: "load", timeout: 45000 });
  await page.evaluate(() => document.fonts.ready);
  await page.evaluate(async () => {
    for (let y = 0; y < document.body.scrollHeight; y += 600) { window.scrollTo(0, y); await new Promise((r) => setTimeout(r, 100)); }
    window.scrollTo(0, 0);
  });
  await page.waitForTimeout(600);
  return page;
};

const focusGaps = async (page) => {
  const missing = [];
  for (let i = 0; i < 15; i++) {
    await page.keyboard.press("Tab");
    const r = await page.evaluate(() => {
      const el = document.activeElement;
      if (!el || el === document.body) return null;
      const s = getComputedStyle(el);
      return { name: el.tagName.toLowerCase() + (el.id ? "#" + el.id : ""), shown: (s.outlineStyle !== "none" && parseFloat(s.outlineWidth) > 0) || s.boxShadow !== "none" };
    });
    if (!r) break;
    if (!r.shown) missing.push(r.name);
  }
  return [...new Set(missing)];
};

const stripEmoji = (t) => t.replace(/\p{Emoji_Presentation}|\p{Extended_Pictographic}️?|️|‍/gu, "");
const norm = (t) => stripEmoji(t).toLowerCase().replace(/\s+/g, " ").trim();

const tokensOf = () => {
  const lines = fs.readFileSync(stylePath, "utf8").split("\n");
  const start = lines.findIndex((l) => /^## tokens/i.test(l));
  const body = start < 0 ? "" : lines.slice(start + 1).join("\n");
  const colors = [...body.matchAll(/#[0-9a-f]{3,8}\b/gi)].map((m) => {
    let v = m[0].slice(1).toLowerCase();
    if (v.length <= 4) v = [...v].map((c) => c + c).join("");
    return [0, 2, 4].map((i) => parseInt(v.slice(i, i + 2), 16));
  });
  const fonts = new Set();
  for (const m of body.matchAll(/--font[\w-]*\s*:\s*([^;\n]+)/gi)) m[1].split(",").forEach((f) => fonts.add(f.trim().replace(/["']/g, "").toLowerCase()));
  return { colors, fonts, text: lines.join("\n").toLowerCase() };
};

(async () => {
  const browser = await chromium.launch();
  const lines = [];
  const fail = (rule, text, inherited) => lines.push("FAIL " + rule + ": " + text + (inherited ? " (also in the source)" : ""));

  const wide = await measure_(browser, url, 1440);
  const phone = await measure_(browser, url, 375);
  let source = null, sourcePhone = null;
  if (sourceUrl) { source = await measure_(browser, sourceUrl, 1440); sourcePhone = await measure_(browser, sourceUrl, 375); }
  const was = (rule) => source && rule(source, sourcePhone);

  if (process.env.PRE.trim()) lines.push(process.env.PRE.trim());
  for (const [w, m, s] of [[1440, wide, source], [375, phone, sourcePhone]]) {
    if (m.sideways > 0) fail("sideways-scroll", m.sideways + "px at " + w, s && s.sideways > 0);
  }
  const contrast = [...new Set(wide.contrast.concat(phone.contrast))];
  for (const c of contrast) fail("contrast", c, source && source.contrast.concat(sourcePhone.contrast).includes(c));
  if (wide.fonts.length > 3) fail("typefaces", wide.fonts.length + " (" + wide.fonts.join(", ") + ")", was((s) => s.fonts.length > 3));
  const near = wide.sizes.filter((v, i) => i && v / wide.sizes[i - 1] < 1.08);
  if (near.length >= 3 || wide.sizes.length > 10) fail("type-scale", wide.sizes.length + " sizes: " + wide.sizes.join(", "), was((s) => s.sizes.length > 10));
  for (const l of [...new Set(wide.longLines)].slice(0, 5)) fail("line-length", l);
  for (const l of [...new Set(phone.small)].slice(0, 8)) fail("touch-target", l + " at 375", was((s, p) => p.small.includes(l)));
  for (const e of wide.empties.concat(phone.empties).filter((v, i, a) => a.indexOf(v) === i)) fail("empty-box", e + " has nothing in it");
  for (const b of wide.broken) fail("broken-image", b);
  const focusPage = await open(browser, url, 1440);
  const gaps = await focusGaps(focusPage);
  if (gaps.length) fail("focus", "no visible ring on " + gaps.join(", "));

  if (source) {
    const here = {}, there = {};
    for (const [k, v] of Object.entries(wide.blocks)) if (norm(k)) here[norm(k)] = v || phone.blocks[k] || false;
    for (const [k, v] of Object.entries(phone.blocks)) if (norm(k)) here[norm(k)] = here[norm(k)] || v;
    for (const [k, v] of Object.entries(source.blocks)) if (norm(k)) there[norm(k)] = v;
    const joinedHere = Object.keys(here).join(" | "), joinedThere = Object.keys(there).join(" | ");
    for (const t of Object.keys(there).filter((t) => there[t] && !joinedHere.includes(t)).slice(0, 8)) fail("text-removed", '"' + t.slice(0, 80) + '"');
    for (const t of Object.keys(here).filter((t) => !joinedThere.includes(t)).slice(0, 8)) fail("text-added", '"' + t.slice(0, 80) + '"');
    for (const t of Object.keys(there).filter((t) => there[t] && here[t] === false).slice(0, 8)) fail("text-hidden", '"' + t.slice(0, 80) + '" can\'t be reached at either width');
    if (source.emoji > wide.emoji) lines.push("INFO better: " + (source.emoji - wide.emoji) + " emoji " + (wide.drawn > source.drawn ? "replaced by drawn icons" : "removed") + "; no text changed by this");
  }

  if (stylePath) {
    const t = tokensOf();
    const near_ = (hexv) => { const v = [1, 3, 5].map((i) => parseInt(hexv.slice(i, i + 2), 16)); return t.colors.some((c) => Math.hypot(v[0] - c[0], v[1] - c[1], v[2] - c[2]) < 6); };
    for (const c of [...new Set(wide.colors.concat(phone.colors))].filter((c) => !near_(c)).slice(0, 8)) fail("off-token", "color " + c + " isn't in ## Tokens");
    const generic = new Set(["serif", "sans-serif", "monospace", "system-ui", "-apple-system", "ui-sans-serif", "ui-monospace", "ui-serif", "cursive", "fantasy"]);
    if (t.fonts.size) for (const f of wide.fonts) if (!t.fonts.has(f.toLowerCase()) && !generic.has(f.toLowerCase())) fail("off-token", 'font "' + f + "\" isn't in ## Tokens");
    const words = { gradient: "gradient", emoji: "emoji", step: "step", card: "card" };
    for (const p of wide.patterns) if (!t.text.includes(words[p])) fail("unreasoned", "the page uses a " + p + " pattern, and no decision in STYLE.md gives its reason");
  }

  for (const w of process.env.WARNINGS.split("\n").filter((l) => l.trim())) lines.push(w);
  if (phone.tight) lines.push("WARN touch-target: " + phone.tight + " controls are between 24 and 44px at 375");
  if (wide.spacingCount >= 20 && wide.onBase < 0.6) lines.push("WARN spacing: only " + Math.round(wide.onBase * 100) + "% of spacing values sit on a " + wide.base + "px base");
  lines.push("INFO spacing: " + Math.round(wide.onBase * 100) + "% of " + wide.spacingCount + " values on a " + wide.base + "px base");
  lines.push("INFO type: " + wide.fonts.length + " typefaces (" + wide.fonts.join(", ") + "), sizes " + wide.sizes.join(", "));
  lines.push("INFO image and text: pictures cover " + Math.round(wide.picture * 100) + "% of the page, " + wide.words + " words");
  for (const p of [...new Set(wide.placeholders)]) lines.push('INFO placeholder: "' + p + '" must be in the asset list');
  if (wide.patterns.length) lines.push("INFO patterns: " + wide.patterns.join(", "));

  const fails = lines.join("\n").split("\n").filter((l) => l.startsWith("FAIL")).length;
  lines.push("Result: " + (fails ? "FAIL (" + fails + ")" : "PASS"));
  fs.writeFileSync(path.join(out, "report.md"), lines.join("\n") + "\n");
  console.log(lines.join("\n"));
  await browser.close();
  process.exit(fails ? 1 : 0);
})().catch((e) => { console.error(e.message); process.exit(2); });

async function measure_(browser, target, width) {
  const page = await open(browser, target, width);
  const result = await page.evaluate(measure);
  await page.close();
  return result;
}
JS
