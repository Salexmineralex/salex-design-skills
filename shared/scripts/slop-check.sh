#!/usr/bin/env bash
# Catch the marks of generic AI design on a rendered page, and work out the penalty.
#
# Usage: slop-check.sh <file-or-url> [options]
#   --source <file-or-url>  the original page: report text added or removed compared
#                           with it, and don't flag steps or stock phrases it already has
#   --locked <STYLE.md>     report colors and fonts outside its "## Locked" and
#                           "## Extensions" sections and the --source page; those
#                           values are never slop
#   --allow <a,b,...>       exceptions with a reason written in the brief: a rule id
#                           (violet-gradient, ...) or a font (font:Inter)
#   --width <px>            viewport width, 1440 by default
#
# Hard-gate rules (*) can't be waived and block delivery, whatever the score. A 0.5
# rule costs points only when two or more kinds fire: one alone is noted, a cluster is slop.
#
# Rule                 Penalty   What it catches
# sideways-scroll *    1         the page scrolls sideways at this width
# fake-visual *        1         a gradient box standing in for an image
# empty-card *         1         a box with nothing in it
# violet-gradient      1         a purple or violet gradient
# emoji-icon           1         emoji used as interface icons
# invented-steps       1         "Step 01", "01 02 03" sequences the source doesn't have
# content-changed *    1         text added or removed compared with --source
# off-brand *          1         colors, fonts or weights outside --locked
# generic-card-grid    0.5       3+ identical rounded cards with no media
# filler-copy          0.5       stock marketing phrases and lorem ipsum
# trendy-font          0.5       a fashionable default font with no stated reason
#
# left-stripe          0.5       a colored stripe down one side of a box
# gradient-text        0.5       a gradient clipped to text
# nested-card          0.5       a rounded box inside a rounded box
# icon-tile            0.5       3+ icons sitting in small colored squares
# all-centered         0.5       nearly every block of text is centered
# default-type-scale   0.5       every font size sits on Tailwind's default scale
# generator-trace      0.5       a site builder's title or attributes left in the code
# recipe-fingerprint   0.5       values copied from popular design skills (picsum.photos...)
#
# Prints one line per finding, then "Hard gate: PASS|FAIL" and "Penalty: <x>" (at most 3). Exits 1 if it found
# anything, 0 if clean. Mark deliberate exceptions in the page's HTML:
#   data-placeholder   an asset still to come; counted and listed, not penalized
#   data-specimen      this element and its contents are a specimen (swatches, radii)
#   data-canvas        this element alone is canvas around the frames
#
# Uses Playwright, which downloads its own Chromium the first time (about 150 MB).
set -euo pipefail

if [ $# -lt 1 ]; then
  sed -n '2,43p' "$0"
  exit 2
fi

target="$1"; shift
source_page="" locked="" allow="" width="1440"
while [ $# -gt 0 ]; do
  case "$1" in
    --source) source_page="$2"; shift 2 ;;
    --locked) locked="$2"; shift 2 ;;
    --allow) allow="$2"; shift 2 ;;
    --width) width="$2"; shift 2 ;;
    *) echo "unknown option: $1" >&2; exit 2 ;;
  esac
done

to_url() {
  case "$1" in
    "") echo "" ;;
    http://*|https://*|file://*) echo "$1" ;;
    *) echo "file://$(cd "$(dirname "$1")" && pwd)/$(basename "$1")" ;;
  esac
}
url="$(to_url "$target")"
source_url="$(to_url "$source_page")"
if [ -n "$locked" ] && [ ! -f "$locked" ]; then
  echo "no such file: $locked" >&2
  exit 2
fi

version="1.49.1"
npx -y "playwright@$version" install chromium >/dev/null 2>&1
# The folder npx put Playwright in, so node can load it as a library.
modules="$(npx -y -p "playwright@$version" -c 'cd "$(dirname "$(command -v playwright)")/.." && pwd')"

NODE_PATH="$modules" node - "$url" "$source_url" "$locked" "$allow" "$width" <<'JS'
const { chromium } = require("playwright");
const fs = require("fs");
const [url, sourceUrl, lockedPath, allowArg, width] = process.argv.slice(2);
const allow = new Set(allowArg.split(",").map((s) => s.trim().toLowerCase()).filter(Boolean));

const PENALTY = { "fake-visual": 1, "empty-card": 1, "violet-gradient": 1, "emoji-icon": 1, "invented-steps": 1, "content-changed": 1, "off-brand": 1, "generic-card-grid": 0.5, "filler-copy": 0.5, "trendy-font": 0.5, "left-stripe": 0.5, "gradient-text": 0.5, "nested-card": 0.5, "icon-tile": 0.5, "all-centered": 0.5, "default-type-scale": 0.5, "generator-trace": 0.5, "recipe-fingerprint": 0.5, "sideways-scroll": 1 };
const HARD = new Set(["sideways-scroll", "fake-visual", "empty-card", "content-changed", "off-brand"]);
const MAX_PENALTY = 3;
const TRENDY = ["inter", "space grotesk", "instrument serif", "fraunces", "playfair display", "dm sans", "dm serif display", "poppins", "plus jakarta sans", "geist", "sora", "outfit", "manrope", "newsreader", "syne", "bricolage grotesque", "cormorant garamond"];
const FILLER = /lorem ipsum|dolor sit amet|\bseamless(ly)?\b|\bunlock\b|\belevate\b|\bempower(s|ing)?\b|\bsupercharge\b|next[- ]generation|game[- ]chang|world[- ]class|cutting[- ]edge|\brevolutioni[sz]e|next level|built for the modern|trusted by (teams|thousands|millions)|effortless(ly)?|at the speed of|reimagine[ds]?\b/gi;

const lockedValues = () => {
  if (!lockedPath) return null;
  const lines = fs.readFileSync(lockedPath, "utf8").split("\n");
  const section = (name) => {
    const start = lines.findIndex((l) => l.toLowerCase().startsWith("## " + name.toLowerCase()));
    if (start < 0) return "";
    const rest = lines.slice(start + 1);
    const end = rest.findIndex((l) => l.startsWith("## "));
    return (end < 0 ? rest : rest.slice(0, end)).join("\n");
  };
  const text = section("Locked") + "\n" + section("Extensions");
  if (!section("Locked").trim()) { console.error('warning: no "## Locked" section in ' + lockedPath); return null; }
  const colors = [...text.matchAll(/#[0-9a-f]{3,8}\b/gi)].map((m) => m[0].toLowerCase());
  const fonts = new Set();
  for (const m of text.matchAll(/--font[\w-]*\s*:\s*([^;\n]+)/gi)) m[1].split(",").forEach((f) => fonts.add(f.trim().replace(/["']/g, "").toLowerCase()));
  const weights = new Set([...text.matchAll(/--[\w-]*(?:weight|w)(?:-[\w-]+)?\s*:\s*(\d{3})\b/gi)].map((m) => m[1]));
  return { colors, fonts, weights };
};

const rgb = (h) => {
  let v = h.slice(1);
  if (v.length === 3 || v.length === 4) v = [...v].map((c) => c + c).join("");
  return [0, 2, 4].map((i) => parseInt(v.slice(i, i + 2), 16));
};

const inspect = () => {
  const cs = (el) => getComputedStyle(el);
  const name = (el) => el.tagName.toLowerCase() + (el.id ? "#" + el.id : "") + [...el.classList].slice(0, 2).map((c) => "." + c).join("");
  const specimen = (el) => !!el.closest("[data-specimen]") || !!el.parentElement?.closest("[data-placeholder]");
  const visible = (el) => { const r = el.getBoundingClientRect(), s = cs(el); return r.width > 0 && r.height > 0 && s.visibility !== "hidden" && s.display !== "none" && +s.opacity > 0; };
  const parseColor = (c) => { const p = c.match(/[\d.]+/g).map(Number); return { r: p[0], g: p[1], b: p[2], a: p.length > 3 ? p[3] : 1 }; };
  const hex = (c) => { const p = parseColor(c); return p.a < 1 ? null : "#" + [p.r, p.g, p.b].map((v) => Math.round(v).toString(16).padStart(2, "0")).join(""); };
  const hsl = ({ r, g, b }) => {
    r /= 255; g /= 255; b /= 255;
    const max = Math.max(r, g, b), min = Math.min(r, g, b), d = max - min, l = (max + min) / 2;
    const s = d === 0 ? 0 : d / (1 - Math.abs(2 * l - 1));
    const h = d === 0 ? 0 : max === r ? 60 * (((g - b) / d) % 6) : max === g ? 60 * ((b - r) / d + 2) : 60 * ((r - g) / d + 4);
    return { h: (h + 360) % 360, s, l };
  };
  const stops = (bg) => (bg.match(/rgba?\([^)]+\)/g) || []).map(parseColor);
  const violet = (p) => { const c = hsl(p); return p.a > 0.2 && c.h >= 245 && c.h <= 310 && c.s > 0.3 && c.l > 0.15 && c.l < 0.85; };
  // A layer stacked on top of or behind real content is decoration, not an empty box:
  // climb out of absolutely placed elements and see whether their host has anything in it.
  const decoration = (el) => {
    if (el.closest('[aria-hidden="true"]')) return true;
    let host = el;
    while (host && /absolute|fixed/.test(cs(host).position)) host = host.parentElement;
    return host !== el && !!host && (ownText(host).length > 0 || hasMedia(host));
  };
  // Enough picture to count as real media in a card: not just a small icon.
  const hasPicture = (el) => !!el.querySelector("img, picture, video, canvas, [data-placeholder]") ||
    [...el.querySelectorAll("svg")].some((v) => v.getBoundingClientRect().width >= 96) ||
    [...el.querySelectorAll("*")].some((d) => /url\(/.test(cs(d).backgroundImage) && d.getBoundingClientRect().width >= 96);
  const hasMedia = (el) => !!el.querySelector("img, picture, video, canvas, svg, iframe, object, [data-placeholder]") || ["IMG", "VIDEO", "CANVAS", "SVG", "IFRAME"].includes(el.tagName.toUpperCase());
  const ownText = (el) => (el.innerText || "").trim();
  const boxed = (s) => {
    const bw = parseFloat(s.borderTopWidth) > 0 && s.borderTopStyle !== "none" && parseColor(s.borderTopColor).a > 0;
    const sides = parseFloat(s.borderLeftWidth) > 0 && parseFloat(s.borderRightWidth) > 0;
    const bg = parseColor(s.backgroundColor).a > 0;
    return (bw && sides) || bg || s.boxShadow !== "none";
  };
  const found = [], placeholders = [], tiles = [];
  const all = [...document.querySelectorAll("body, body *")].filter((el) => !el.closest("svg, script, style, noscript, head") && visible(el));

  for (const el of all) {
    const s = cs(el), r = el.getBoundingClientRect();
    if (el.hasAttribute("data-placeholder")) { placeholders.push((el.getAttribute("data-placeholder") || ownText(el)).slice(0, 80)); continue; }
    if (specimen(el) || el.hasAttribute("data-canvas")) continue;
    const gradient = /gradient/.test(s.backgroundImage);
    if (gradient && r.width >= 80 && r.height >= 24 && stops(s.backgroundImage).some(violet)) found.push(["violet-gradient", name(el) + " has a purple or violet gradient"]);
    if (gradient && r.width >= 160 && r.height >= 100 && !decoration(el) && !hasMedia(el) && ownText(el).length < 20) found.push(["fake-visual", name(el) + " (" + Math.round(r.width) + "x" + Math.round(r.height) + ") is a gradient standing in for an image; use a real asset or a marked placeholder"]);
    if (!gradient && r.width >= 100 && r.height >= 60 && boxed(s) && !decoration(el) && !hasMedia(el) && !ownText(el) && el.tagName !== "BODY" && el.tagName !== "HTML" && !el.matches("input, select, textarea, button, hr, progress, meter, pre, code") && !/url\(/.test(s.backgroundImage) && !el.querySelector("input, select, textarea, button")) found.push(["empty-card", name(el) + " (" + Math.round(r.width) + "x" + Math.round(r.height) + ") is an empty box"]);
    if (parseFloat(s.borderLeftWidth) >= 3 && parseFloat(s.borderRightWidth) === 0 && parseFloat(s.borderTopWidth) === 0 && r.height >= 40) found.push(["left-stripe", name(el) + " has a colored stripe down one side"]);
    if (gradient && /text/.test(s.webkitBackgroundClip || s.backgroundClip) && ownText(el)) found.push(["gradient-text", name(el) + " has gradient text"]);
    const framed = (c) => parseFloat(c.borderTopLeftRadius) >= 8 && parseFloat(c.borderLeftWidth) > 0 && parseFloat(c.borderRightWidth) > 0 || (parseFloat(c.borderTopLeftRadius) >= 8 && c.boxShadow !== "none");
    if (r.width >= 160 && r.height >= 80 && framed(s) && el.parentElement) {
      for (let a = el.parentElement; a && a !== document.body; a = a.parentElement) {
        if (framed(cs(a)) && !specimen(a)) { found.push(["nested-card", name(el) + " is a card inside " + name(a)]); break; }
      }
    }
    if (r.width >= 28 && r.width <= 72 && Math.abs(r.width - r.height) < 3 && parseColor(s.backgroundColor).a > 0 && el.querySelector("svg, i") && !ownText(el)) tiles.push(name(el));
    // Rows of the same rounded box with only text in it: the default feature grid.
    if (/flex|grid/.test(s.display)) {
      const kids = [...el.children].filter(visible);
      if (kids.length >= 3) {
        const cards = kids.filter((k) => { const c = cs(k); return parseFloat(c.borderTopLeftRadius) >= 8 && boxed(c) && !hasPicture(k) && ownText(k).length > 0; });
        const w = cards.map((k) => k.getBoundingClientRect().width);
        if (cards.length >= 3 && cards.length === kids.length && Math.max(...w) - Math.min(...w) < 4 && !specimen(el)) found.push(["generic-card-grid", name(el) + " is " + cards.length + " identical rounded text cards with no media"]);
      }
    }
  }

  if (tiles.length >= 3) found.push(["icon-tile", tiles.length + " icons sit in small colored squares"]);
  const reading = all.filter((el) => el.matches("h1, h2, h3, p") && !specimen(el) && ownText(el));
  const centered = reading.filter((el) => /center/.test(cs(el).textAlign));
  if (reading.length >= 6 && centered.length / reading.length >= 0.8) found.push(["all-centered", centered.length + " of " + reading.length + " text blocks are centered"]);
  const TW = new Set([12, 14, 16, 18, 20, 24, 30, 36, 48, 60, 72, 96, 128]);
  const typeSizes = new Set(all.filter((el) => !specimen(el) && [...el.childNodes].some((n) => n.nodeType === 3 && n.textContent.trim())).map((el) => parseFloat(cs(el).fontSize)));
  if (typeSizes.size >= 4 && [...typeSizes].every((v) => TW.has(v))) found.push(["default-type-scale", "all " + typeSizes.size + " font sizes sit on Tailwind's default scale; choose the sizes for this design"]);
  const html = document.documentElement.outerHTML;
  if (/data-lov-id|gptengineer|lovable-tagger/i.test(html) || /^(vite \+ react|react app|untitled|document|lovable.*|v0 app)$/i.test(document.title.trim())) found.push(["generator-trace", "a builder's default title or attributes are still here"]);
  for (const m of new Set(html.match(/picsum\.photos|rounded-\[2rem\]|rounded-\[2\.5rem\]|0_20px_40px_-15px|47\.2%|\(312\) 847-1928/g) || [])) found.push(["recipe-fingerprint", '"' + m + '" is copied from popular design skills']);

  // Emoji inside controls and headings, or leading a block of text, are acting as icons.
  const emoji = /\p{Emoji_Presentation}|\p{Extended_Pictographic}️/u;
  for (const el of all) {
    if (specimen(el)) continue;
    for (const n of el.childNodes) {
      if (n.nodeType === 3 && emoji.test(n.textContent)) { found.push(["emoji-icon", name(el) + ' uses an emoji: "' + n.textContent.trim().slice(0, 40) + '"']); break; }
    }
  }

  const blocks = [];
  for (const el of all) {
    if (specimen(el)) continue;
    const direct = [...el.childNodes].some((n) => n.nodeType === 3 && n.textContent.trim());
    if (direct && !el.hasAttribute("data-canvas") && !el.hasAttribute("data-placeholder")) blocks.push(ownText(el));
  }
  const fonts = {};
  const weights = {};
  const colors = {};
  for (const el of all) {
    if (specimen(el) || el.hasAttribute("data-canvas") || el.hasAttribute("data-placeholder")) continue;
    const s = cs(el);
    if ([...el.childNodes].some((n) => n.nodeType === 3 && n.textContent.trim())) {
      const f = s.fontFamily.split(",")[0].replace(/["']/g, "").trim().toLowerCase();
      fonts[f] = (fonts[f] || 0) + 1;
      weights[s.fontWeight] = (weights[s.fontWeight] || 0) + 1;
      const c = hex(s.color);
      if (c) colors[c] = (colors[c] || 0) + 1;
    }
    const b = hex(s.backgroundColor);
    if (b) colors[b] = (colors[b] || 0) + 1;
    if (parseFloat(s.borderTopWidth) > 0 && s.borderTopStyle !== "none") { const bc = hex(s.borderTopColor); if (bc) colors[bc] = (colors[bc] || 0) + 1; }
  }
  return { found, placeholders, blocks: [...new Set(blocks)], fonts, weights, colors };
};

const textOf = async (browser, target) => {
  const page = await browser.newPage({ viewport: { width: Number(width), height: 900 } });
  await page.goto(target, { waitUntil: "load", timeout: 45000 });
  await page.evaluate(() => document.fonts.ready);
  // Scroll through the page so lazy images and scroll-triggered content load, then back up.
  await page.evaluate(async () => {
    for (let y = 0; y < document.body.scrollHeight; y += 600) { window.scrollTo(0, y); await new Promise((r) => setTimeout(r, 120)); }
    window.scrollTo(0, 0);
  });
  await page.waitForTimeout(800);
  return page;
};

(async () => {
  const browser = await chromium.launch();
  const page = await textOf(browser, url);
  const seen = await page.evaluate(inspect);
  const findings = [...seen.found];
  const wider = await page.evaluate(() => document.documentElement.scrollWidth - window.innerWidth);
  if (wider > 0) findings.push(["sideways-scroll", "the page is " + wider + "px wider than the window"]);
  const norm = (s) => s.toLowerCase().replace(/\s+/g, " ").trim();

  let sourceBlocks = null, sourceAll = "", sourceColors = {};
  if (sourceUrl) {
    const sp = await textOf(browser, sourceUrl);
    const original = await sp.evaluate(inspect);
    sourceBlocks = original.blocks.map(norm);
    sourceColors = original.colors;
    // What the original already does is the brand's, not slop.
    for (const [rule] of original.found) if (!HARD.has(rule)) allow.add(rule);
    sourceAll = sourceBlocks.join(" | ");
    const mine = seen.blocks.map(norm);
    const whole = mine.join(" | ");
    const added = seen.blocks.filter((b) => !sourceAll.includes(norm(b)));
    const removed = sourceBlocks.filter((b) => !whole.includes(b));
    for (const t of added.slice(0, 8)) findings.push(["content-changed", 'text not in the source: "' + t.slice(0, 80) + '"']);
    for (const t of removed.slice(0, 8)) findings.push(["content-changed", 'source text missing: "' + t.slice(0, 80) + '"']);
  }

  // Steps: "Step 1", "Step 02", or a run of bare 01, 02, 03 labels.
  const stepWord = seen.blocks.filter((b) => /^step\s*0?\d+\b/i.test(b.trim()));
  const bare = seen.blocks.filter((b) => /^0[1-9][.)]?$/.test(b.trim()));
  for (const b of stepWord.concat(bare.length >= 2 ? bare : [])) {
    if (!sourceAll.includes(norm(b))) findings.push(["invented-steps", 'numbered step label not in the source: "' + b.slice(0, 40) + '"']);
  }

  const phrases = new Set();
  for (const b of seen.blocks) for (const m of b.matchAll(FILLER)) if (!sourceAll.includes(m[0].toLowerCase())) phrases.add(m[0].toLowerCase());
  for (const p of phrases) findings.push(["filler-copy", 'stock phrase: "' + p + '"']);

  const locked = lockedValues();
  const fontsAllowed = (f) => allow.has("font:" + f) || (locked && locked.fonts.has(f));
  for (const f of Object.keys(seen.fonts)) if (TRENDY.includes(f) && !fontsAllowed(f)) findings.push(["trendy-font", '"' + f + '" is a fashionable default; write down why it fits, or change it']);

  if (locked) {
    const brand = locked.colors.filter((c) => c.length !== 5 && c.length !== 9).map(rgb);
    const close = (c) => { const v = rgb(c); return brand.some((b) => Math.hypot(v[0] - b[0], v[1] - b[1], v[2] - b[2]) < 14); };
    const off = Object.entries(seen.colors).filter(([c]) => !close(c) && !sourceColors[c]).sort((a, b) => b[1] - a[1]);
    for (const [c, n] of off.slice(0, 6)) findings.push(["off-brand", "color " + c + " (used " + n + " times) is not in Locked or Extensions"]);
    if (locked.weights.size) for (const w of Object.keys(seen.weights)) if (!locked.weights.has(w)) findings.push(["off-brand", "font weight " + w + " is not in Locked or Extensions"]);
    const generic = new Set(["serif", "sans-serif", "monospace", "system-ui", "-apple-system", "ui-sans-serif", "ui-monospace", "ui-serif", "cursive", "fantasy"]);
    for (const f of Object.keys(seen.fonts)) if (!locked.fonts.has(f) && !generic.has(f) && locked.fonts.size) findings.push(["off-brand", 'font "' + f + '" is not in Locked or Extensions']);
  }

  const kept = findings.filter(([rule]) => HARD.has(rule) || !allow.has(rule));
  // A rule costs once per page, however many times it fires.
  const rules = new Set(kept.map(([rule]) => rule));
  const soft = [...rules].filter((rule) => PENALTY[rule] < 1);
  const total = Math.min(MAX_PENALTY, [...rules].reduce((sum, rule) => sum + (PENALTY[rule] < 1 && soft.length < 2 ? 0 : PENALTY[rule]), 0));
  const hardFails = [...rules].filter((rule) => HARD.has(rule));
  // Repeats of a rule add nothing: show a few of each, and the count.
  for (const rule of rules) {
    const lines = [...new Set(kept.filter(([r]) => r === rule).map(([, text]) => text))];
    for (const text of lines.slice(0, 5)) console.log(rule + ": " + text);
    if (lines.length > 5) console.log(rule + ": ...and " + (lines.length - 5) + " more");
  }
  for (const p of seen.placeholders) console.log('placeholder (no penalty, must be in the asset list): "' + p + '"');
  console.log("Hard gate: " + (hardFails.length ? "FAIL (" + hardFails.join(", ") + ")" : "PASS"));
  console.log("Penalty: " + total);
  await browser.close();
  process.exit(kept.length ? 1 : 0);
})().catch((e) => { console.error(e.message); process.exit(2); });
JS
