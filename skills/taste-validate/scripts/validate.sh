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
#   text-hidden, off-token (colors, drawings, fonts and sizes), token-drift (the page
#   gives a token another value), unreasoned (a pattern with no decision that uses it),
#   style-lint, style-after-build
# WARN (look at it): touch targets under 44px, weak spacing consistency, spacing off the
#   handbook's scale, overlaps and cut-off content from screenshot.sh
# INFO: image and text ratio, placeholders, emoji replaced by drawn icons
#
# Anything the source already fails still fails here, marked "also in the source": a
# restyle fixes inherited problems, it doesn't keep them. Text hidden by design (a nav
# behind a mobile menu) isn't missing. Emoji are decoration, not copy: replacing one
# with a drawn icon changes no text and is reported as an improvement.
#
# Contrast reads the real stack where it's solid. Over a gradient or an image it hides
# the text, captures the page and measures the worst tenth of the pixels behind each line.
# Text filled with a gradient, blended, or covered by something else can't be measured; the report
# says how many.
#
# Build order: each run records a fingerprint of the handbook's decisions and tokens, and
# of the page and its stylesheets, in <out-dir>/build-record.json. If the handbook's
# decisions or tokens changed and the build didn't, that's style-after-build, and touching
# a file doesn't clear it. Editing only the reasons needs no rebuild. The first run has no
# record, so it compares file dates, with the stylesheets counted as the build.
#
# Mark a missing asset with data-placeholder="what's needed" and a specimen (a color
# swatch) with data-specimen.
#
# Uses Playwright, which downloads its own Chromium the first time (about 150 MB).
set -uo pipefail

if [ $# -lt 2 ]; then
  sed -n '2,41p' "$0"
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
const crypto = require("crypto");
const { fileURLToPath } = require("url");
const [url, sourceUrl, stylePath, out] = process.argv.slice(2);

const measure = () => {
  const cs = (el) => getComputedStyle(el);
  const name = (el) => el.tagName.toLowerCase() + (el.id ? "#" + el.id : "") + [...el.classList].slice(0, 2).map((c) => "." + c).join("");
  const seen = (el) => el.checkVisibility({ checkOpacity: false, checkVisibilityCSS: true }) && el.getBoundingClientRect().width > 0;
  const color = (c) => { const p = (c.match(/[\d.]+/g) || [0, 0, 0, 0]).map(Number); return { r: p[0], g: p[1], b: p[2], a: p.length > 3 ? p[3] : 1 }; };
  const hex = (c) => "#" + [c.r, c.g, c.b].map((v) => Math.round(v).toString(16).padStart(2, "0")).join("");
  const lum = (c) => { const f = (v) => { v /= 255; return v <= 0.03928 ? v / 12.92 : ((v + 0.055) / 1.055) ** 2.4; }; return 0.2126 * f(c.r) + 0.7152 * f(c.g) + 0.0722 * f(c.b); };
  const blend = (top, under) => ({ r: top.r * top.a + under.r * (1 - top.a), g: top.g * top.a + under.g * (1 - top.a), b: top.b * top.a + under.b * (1 - top.a), a: 1 });
  // The solid color behind an element, "pixels" when an image or gradient is in the way,
  // "covered" when something else sits on top. Read the real stack at the text's position,
  // because what's behind it may be a sibling layer rather than an ancestor.
  const behind = (el) => {
    const range = document.createRange();
    range.selectNodeContents(el);
    el.scrollIntoView({ block: "center", behavior: "instant" });
    const box = range.getBoundingClientRect();
    const stack = document.elementsFromPoint(box.left + box.width / 2, box.top + box.height / 2);
    const start = stack.indexOf(el);
    if (start < 0) return "covered";
    const layers = [];
    for (const e of stack.slice(start)) {
      const s = cs(e);
      if (s.backgroundImage !== "none" || e.matches("img, video, canvas, svg, svg *, picture, iframe") || +s.opacity < 1 || s.mixBlendMode !== "normal") return "pixels";
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

  const contrast = new Map(), fonts = {}, sizes = {}, colors = {}, placeholders = [], overPixels = [];
  let solid = 0, unmeasured = 0;
  for (const el of texted) {
    const s = cs(el), px = parseFloat(s.fontSize);
    fonts[s.fontFamily.split(",")[0].replace(/["']/g, "").trim()] = 1;
    sizes[px] = (sizes[px] || 0) + 1;
    const under = behind(el), fg = color(s.color);
    if (fg.a === 1) colors[hex(fg)] = 1;
    if (under === "covered" || fg.a === 0 || /text/.test(s.webkitBackgroundClip || "")) { unmeasured++; continue; }
    if (under === "pixels") { overPixels.push(el); continue; }
    solid++;
    const f = lum(blend(fg, under)), b = lum(under), ratio = (Math.max(f, b) + 0.05) / (Math.min(f, b) + 0.05);
    const large = px >= 24 || (px >= 18.66 && +s.fontWeight >= 700);
    if (ratio < (large ? 3 : 4.5)) contrast.set(hex(blend(fg, under)) + " on " + hex(under), ratio.toFixed(2) + ":1 at " + px + "px");
  }

  // Where each line over a picture sits on the page, for sampling the capture.
  window.scrollTo({ top: 0, left: 0, behavior: "instant" });
  const pixelTexts = [];
  for (const el of overPixels) {
    let opacity = 1, blended = false;
    for (let e = el; e; e = e.parentElement) { opacity *= +cs(e).opacity; blended = blended || cs(e).mixBlendMode !== "normal"; }
    // Blended text has no color of its own to compare, and invisible text isn't read.
    if (blended || opacity < 0.05) { unmeasured++; continue; }
    const rects = [];
    for (const n of el.childNodes) {
      if (n.nodeType !== 3 || !n.textContent.trim()) continue;
      const r = document.createRange();
      r.selectNode(n);
      for (const b of r.getClientRects()) if (b.width >= 1 && b.height >= 1) rects.push({ x: b.left + scrollX, y: b.top + scrollY, w: b.width, h: b.height });
    }
    const s = cs(el), fg = color(s.color);
    if (rects.length) pixelTexts.push({ name: name(el), fg, hex: hex(fg), alpha: fg.a * opacity, px: parseFloat(s.fontSize), weight: +s.fontWeight, rects: rects.slice(0, 8) });
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

  // Colors in drawings and gradients, which the color check above doesn't see. A logo keeps
  // its own colors.
  const drawnColors = {};
  const solidColor = (v) => { if (/^rgb\(/.test(v)) { const c = color(v); if (c.a === 1) drawnColors[hex(c)] = 1; } };
  for (const el of document.querySelectorAll("svg *")) {
    if (el.closest('[data-specimen], [data-placeholder], [class*="logo" i], [id*="logo" i], [aria-label*="logo" i]') || !el.checkVisibility({ checkVisibilityCSS: true })) continue;
    const s = cs(el);
    solidColor(s.fill); solidColor(s.stroke); solidColor(s.stopColor);
  }
  for (const el of all) {
    if (specimen(el)) continue;
    for (const m of cs(el).backgroundImage.matchAll(/rgb\([^)]*\)/g)) solidColor(m[0]);
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
    contrast: [...contrast].map(([k, v]) => k + " is " + v), pixelTexts, solid, unmeasured, fonts: Object.keys(fonts), sizes: Object.keys(sizes).map(Number).sort((a, b) => a - b),
    longLines, small, tight: tight.length, base: bases[0][0], onBase: bases[0][1], spacingCount: spacing.length,
    empties: [...new Set(empties)], broken, placeholders, patterns: [...patterns], colors: Object.keys(colors), drawnColors: Object.keys(drawnColors), spacing,
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

const px = (v) => { const m = v.trim().match(/^([\d.]+)(px|rem)$/); return m ? +m[1] * (m[2] === "rem" ? 16 : 1) : null; };
const normValue = (v) => v.toLowerCase().replace(/["']/g, "").replace(/\s*,\s*/g, ",").replace(/\s+/g, " ").trim().replace(/#([0-9a-f])([0-9a-f])([0-9a-f])\b/g, "#$1$1$2$2$3$3");

const tokensOf = () => {
  const raw = fs.readFileSync(stylePath, "utf8");
  const lines = raw.split("\n");
  const start = lines.findIndex((l) => /^## tokens/i.test(l));
  const body = start < 0 ? "" : lines.slice(start + 1).join("\n");
  const colors = [...body.matchAll(/#[0-9a-f]{3,8}\b/gi)].map((m) => {
    let v = m[0].slice(1).toLowerCase();
    if (v.length <= 4) v = [...v].map((c) => c + c).join("");
    return [0, 2, 4].map((i) => parseInt(v.slice(i, i + 2), 16));
  });
  const fonts = new Set();
  for (const m of body.matchAll(/--font[\w-]*\s*:\s*([^;\n]+)/gi)) m[1].split(",").forEach((f) => fonts.add(f.trim().replace(/["']/g, "").toLowerCase()));
  const vars = new Map();
  for (const m of body.matchAll(/(--[\w-]+)\s*:\s*([^;]+);/g)) {
    if (!vars.has(m[1])) vars.set(m[1], new Set());
    vars.get(m[1]).add(m[2].trim());
  }
  const named = (re) => [...vars].filter(([n]) => re.test(n)).flatMap(([, vs]) => [...vs]);
  const scale = (re) => { const vs = named(re); return { fluid: vs.some((v) => /clamp|calc|vw|var\(/.test(v)), values: vs.map(px).filter((v) => v !== null) }; };
  // What a decision says it does: its title, Decision and Why, without what it rejects.
  const decisions = [...raw.matchAll(/^(### .*|- \*\*(?:Decision|Why):\*\*.*)$/gm)].map((m) => m[1]).join("\n");
  const said = decisions.split(/[.;\n]/).map((s) => s.toLowerCase()).filter((s) => !/\b(no|not|never|without|avoid\w*|ban\w*|don't|instead of|rather than)\b/.test(s));
  return {
    colors, fonts, vars, said,
    sizes: scale(/^--(font-size|fs|text|size|type)\b/), spacing: scale(/^--(space|spacing|gap|sp|pad|padding|margin)\b/),
    print: crypto.createHash("sha256").update(decisions.split("\n").filter((l) => /Decision:/.test(l)).join("\n") + body).digest("hex"),
  };
};

// The page, its own stylesheets and its style tags, as loaded.
const buildOf = async (page, target) => {
  const read = async (u) => {
    if (u.startsWith("file:")) { const file = fileURLToPath(u); return { file, text: fs.readFileSync(file, "utf8") }; }
    const r = await page.request.get(u);
    return { file: null, text: await r.text() };
  };
  const clean = target.split(/[#?]/)[0];
  const hrefs = await page.evaluate(() => ({ links: [...document.querySelectorAll('link[rel~="stylesheet"]')].map((l) => l.href), styles: [...document.querySelectorAll("style")].map((s) => s.textContent).join("\n") }));
  const origin = new URL(clean).origin;
  const parts = [], files = [];
  for (const u of [clean, ...hrefs.links.filter((h) => h.startsWith("file:") || new URL(h).origin === origin)]) {
    try { const got = await read(u.split(/[#?]/)[0]); parts.push(got.text); if (got.file) files.push(got.file); } catch (e) { /* a missing stylesheet is its own problem */ }
  }
  parts.push(hrefs.styles);
  return { print: crypto.createHash("sha256").update(parts.join("\n")).digest("hex"), files };
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
  const contrast = [...new Map(wide.contrast.concat(phone.contrast).map((c) => [c.split(" is ")[0], c])).values()];
  const pair = (c) => c.split(" is ")[0];
  for (const c of contrast) fail("contrast", c, source && source.contrast.concat(sourcePhone.contrast).map(pair).includes(pair(c)));
  if (wide.fonts.length > 3) fail("typefaces", wide.fonts.length + " (" + wide.fonts.join(", ") + ")", was((s) => s.fonts.length > 3));
  const near = wide.sizes.filter((v, i) => i && v / wide.sizes[i - 1] < 1.08);
  if (near.length >= 3 || wide.sizes.length > 10) fail("type-scale", wide.sizes.length + " sizes: " + wide.sizes.join(", "), was((s) => s.sizes.length > 10));
  for (const l of [...new Set(wide.longLines)].slice(0, 5)) fail("line-length", l);
  for (const l of [...new Set(phone.small)].slice(0, 8)) fail("touch-target", l + " at 375", was((s, p) => p.small.includes(l)));
  for (const e of wide.empties.concat(phone.empties).filter((v, i, a) => a.indexOf(v) === i)) fail("empty-box", e + " has nothing in it");
  for (const b of wide.broken) fail("broken-image", b);
  const focusPage = await open(browser, url, 1440);
  const handbook = stylePath ? tokensOf() : null;
  if (handbook) {
    // A token the page gives another value: it wasn't built from this handbook.
    const names = [...handbook.vars.keys()];
    const declared = await focusPage.evaluate((names) => names.map((n) => getComputedStyle(document.documentElement).getPropertyValue(n).trim()), names);
    let found = 0;
    names.forEach((n, i) => {
      if (!declared[i]) return;
      found++;
      const wanted = [...handbook.vars.get(n)];
      if (wanted.some((v) => /var\(|calc\(/.test(v))) return;
      if (!wanted.map(normValue).includes(normValue(declared[i]))) fail("token-drift", n + " is " + declared[i] + " in the page, " + wanted.join(" or ") + " in the handbook");
    });
    if (names.length && !found) lines.push("WARN tokens: the page declares none of the handbook's tokens, so only its colors and sizes can be compared");

    const label = path.basename(stylePath);
    const build = await buildOf(focusPage, url);
    const recordPath = path.join(out, "build-record.json");
    let record = null;
    try { record = JSON.parse(fs.readFileSync(recordPath, "utf8")); } catch (e) { /* first run */ }
    let late = false;
    if (record) {
      late = record.handbook !== handbook.print && record.build === build.print;
      if (late) fail("style-after-build", "the decisions or tokens in " + label + " changed and the page and its stylesheets didn't; rebuild from it");
    } else if (build.files.length) {
      const newest = Math.max(...build.files.map((f) => fs.statSync(f).mtimeMs));
      late = fs.statSync(stylePath).mtimeMs > newest;
      if (late) fail("style-after-build", label + " is newer than the page and its stylesheets; build from it");
    }
    if (!late) fs.writeFileSync(recordPath, JSON.stringify({ handbook: handbook.print, build: build.print }, null, 2) + "\n");
  }
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
    const t = handbook;
    const near_ = (hexv) => { const v = [1, 3, 5].map((i) => parseInt(hexv.slice(i, i + 2), 16)); return t.colors.some((c) => Math.hypot(v[0] - c[0], v[1] - c[1], v[2] - c[2]) < 6); };
    for (const c of [...new Set(wide.colors.concat(phone.colors))].filter((c) => !near_(c)).slice(0, 8)) fail("off-token", "color " + c + " isn't in ## Tokens");
    const generic = new Set(["serif", "sans-serif", "monospace", "system-ui", "-apple-system", "ui-sans-serif", "ui-monospace", "ui-serif", "cursive", "fantasy"]);
    if (t.fonts.size) for (const f of wide.fonts) if (!t.fonts.has(f.toLowerCase()) && !generic.has(f.toLowerCase())) fail("off-token", 'font "' + f + "\" isn't in ## Tokens");
    for (const c of [...new Set(wide.drawnColors.concat(phone.drawnColors))].filter((c) => !near_(c)).slice(0, 8)) fail("off-token", "color " + c + " in a drawing or gradient isn't in ## Tokens");
    if (t.sizes.values.length >= 3 && !t.sizes.fluid) {
      const onScale = (v, scale) => scale.some((s) => Math.abs(s - v) <= 0.5);
      for (const v of [...new Set(wide.sizes.concat(phone.sizes))].filter((v) => !onScale(v, t.sizes.values)).slice(0, 8)) fail("off-token", "text size " + v + "px isn't in ## Tokens");
    } else lines.push("INFO tokens: text sizes not compared, ## Tokens has no fixed size scale");
    if (t.spacing.values.length >= 3 && !t.spacing.fluid) {
      const used = wide.spacing, on = used.filter((v) => t.spacing.values.some((s) => Math.abs(s - v) <= 0.5)).length;
      const share = on / (used.length || 1);
      if (used.length >= 20 && share < 0.7) lines.push("WARN spacing: only " + Math.round(share * 100) + "% of spacing values are on the scale in ## Tokens");
    } else lines.push("INFO tokens: spacing not compared, ## Tokens has no fixed spacing scale");
    const words = { gradient: /gradient|ombr[eé]/, emoji: /emoji/, step: /numbered|sequence|\bstep (number|label)/, card: /\bcards?\b|\bpanels?\b|\btiles?\b/ };
    for (const p of wide.patterns) if (!t.said.some((s) => words[p].test(s))) fail("unreasoned", "the page uses a " + p + " pattern, and no decision says it does and why");
  }

  for (const w of process.env.WARNINGS.split("\n").filter((l) => l.trim())) lines.push(w);
  if (phone.tight) lines.push("WARN touch-target: " + phone.tight + " controls are between 24 and 44px at 375");
  if (wide.spacingCount >= 20 && wide.onBase < 0.6) lines.push("WARN spacing: only " + Math.round(wide.onBase * 100) + "% of spacing values sit on a " + wide.base + "px base");
  lines.push("INFO contrast: " + (wide.solid + wide.overPixels) + " text elements measured at 1440, " + wide.overPixels + " of them from pixels" + (wide.unmeasured ? "; " + wide.unmeasured + " not measured (gradient-filled, blended or covered text): check those by eye" : ""));
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

// Text over a picture: hide the glyphs (only their fill, so currentColor keeps working),
// capture, then measure each line of text against the worst tenth of the pixels behind it.
async function sampleContrast(browser, page, texts) {
  await page.addStyleTag({ content: "*,*::before,*::after{-webkit-text-fill-color:transparent!important;-webkit-text-stroke:0!important;text-shadow:none!important;text-decoration-color:transparent!important;transition:none!important;animation:none!important;caret-color:transparent!important}" });
  await page.waitForTimeout(100);
  const data = (await page.screenshot({ fullPage: true })).toString("base64");
  const blank = await browser.newPage();
  const found = await blank.evaluate(async ({ data, texts }) => {
    const img = new Image();
    img.src = "data:image/png;base64," + data;
    await img.decode();
    const lin = (v) => { v /= 255; return v <= 0.03928 ? v / 12.92 : ((v + 0.055) / 1.055) ** 2.4; };
    const lum = (r, g, b) => 0.2126 * lin(r) + 0.7152 * lin(g) + 0.0722 * lin(b);
    const worst = new Map();
    for (const t of texts) {
      const ratios = [];
      for (const r of t.rects) {
        // Inset, so the sample stays behind the glyphs and off the edges of the line box.
        const y = Math.round(r.y + r.h * 0.15), x = Math.round(r.x), w = Math.round(r.w), h = Math.round(r.h * 0.7);
        if (w < 1 || h < 1 || x >= img.width || y >= img.height) continue;
        const c = document.createElement("canvas");
        c.width = w; c.height = h;
        const g = c.getContext("2d", { willReadFrequently: true });
        g.drawImage(img, -x, -y);
        const d = g.getImageData(0, 0, w, h).data;
        const stride = Math.max(1, Math.floor(Math.sqrt((w * h) / 1500)));
        for (let py = 0; py < h; py += stride) for (let px = 0; px < w; px += stride) {
          const i = (py * w + px) * 4;
          const mix = (fg, bg) => fg * t.alpha + bg * (1 - t.alpha);
          const b = lum(d[i], d[i + 1], d[i + 2]), f = lum(mix(t.fg.r, d[i]), mix(t.fg.g, d[i + 1]), mix(t.fg.b, d[i + 2]));
          ratios.push((Math.max(f, b) + 0.05) / (Math.min(f, b) + 0.05));
        }
      }
      if (!ratios.length) continue;
      ratios.sort((a, b) => a - b);
      const ratio = ratios[Math.floor(ratios.length * 0.1)];
      const large = t.px >= 24 || (t.px >= 18.66 && t.weight >= 700);
      const key = t.name + " " + t.hex;
      if (ratio < (large ? 3 : 4.5) && (!worst.has(key) || worst.get(key).ratio > ratio)) worst.set(key, { ratio, px: t.px });
    }
    return [...worst].map(([k, v]) => k + " over a gradient or image is " + v.ratio.toFixed(2) + ":1 at " + v.px + "px, in the worst tenth of the pixels behind it");
  }, { data, texts: texts.map((t) => ({ fg: t.fg, alpha: t.alpha, hex: t.hex, name: t.name, px: t.px, weight: t.weight, rects: t.rects })) });
  await blank.close();
  return found;
}

async function measure_(browser, target, width) {
  const page = await open(browser, target, width);
  const result = await page.evaluate(measure);
  result.overPixels = result.pixelTexts.length;
  if (result.overPixels) result.contrast.push(...await sampleContrast(browser, page, result.pixelTexts));
  await page.close();
  return result;
}
JS
