#!/usr/bin/env bash
# Read a brand's existing tokens and assets directly from a page or a local file.
#
# Usage: read-tokens.sh <file-or-url> <out-dir> [--no-assets]
#
# Writes to <out-dir>:
#   tokens.json      what the page really uses: colors by role (text, background, every
#                    border side, outline, shadow) with greys listed apart, hover, focus,
#                    active and disabled states from the stylesheets, elevation, radii
#                    on every corner, fonts, sizes, weights, spacing, CSS variables,
#                    gradients and sample components
#   page-1440.png    the whole page at desktop width
#   page-375.png     the whole page at phone width
#   assets/          the page's logos, images, illustrations and large inline SVGs
#   assets.json      one row per asset: file, kind, source, size, alt text
#
# Run it once per page: home, pricing, a product page. Each page gets its own
# <out-dir>. Downloaded files are images only (SVGs lose scripts and event handlers)
# and are never executed.
#
# Exits 3 if the page refused to load or looks like a bot wall: ask for files instead.
# Uses Playwright, which downloads its own Chromium the first time (about 150 MB).
set -euo pipefail

if [ $# -lt 2 ]; then
  sed -n '2,23p' "$0"
  exit 2
fi

target="$1"
out="$2"
assets="yes"
[ "${3:-}" = "--no-assets" ] && assets="no"
version="1.49.1"

case "$target" in
  http://*|https://*|file://*) url="$target" ;;
  *) url="file://$(cd "$(dirname "$target")" && pwd)/$(basename "$target")" ;;
esac
mkdir -p "$out"
out="$(cd "$out" && pwd)"

npx -y "playwright@$version" install chromium >/dev/null 2>&1
# The folder npx put Playwright in, so node can load it as a library.
modules="$(npx -y -p "playwright@$version" -c 'cd "$(dirname "$(command -v playwright)")/.." && pwd')"

NODE_PATH="$modules" node - "$url" "$out" "$assets" <<'JS'
const { chromium } = require("playwright");
const crypto = require("crypto");
const fs = require("fs");
const path = require("path");
const [url, out, withAssets] = process.argv.slice(2);
const MAX_ASSETS = 60, MAX_BYTES = 10 * 1024 * 1024;
const EXT = { "image/png": ".png", "image/jpeg": ".jpg", "image/webp": ".webp", "image/avif": ".avif", "image/gif": ".gif", "image/svg+xml": ".svg" };

const cleanSvg = (s) => s.replace(/<script[\s\S]*?<\/script>/gi, "").replace(/\son\w+\s*=\s*("[^"]*"|'[^']*')/gi, "");

(async () => {
  const browser = await chromium.launch();
  const context = await browser.newContext({ viewport: { width: 1440, height: 900 } });
  const page = await context.newPage();
  let response;
  try {
    response = await page.goto(url, { waitUntil: "networkidle", timeout: 45000 });
  } catch (e) {
    // Busy sites never go quiet: settle for the loaded page if there is one.
    response = await page.goto(url, { waitUntil: "load", timeout: 45000 }).catch(() => null);
    if (!response) { console.error("could not load " + url + ": " + e.message.split("\n")[0]); process.exit(3); }
  }
  const status = response ? response.status() : 200;
  const title = await page.title();
  if (status >= 400 || /just a moment|attention required|access denied|verify you are human|captcha/i.test(title)) {
    console.error("the page refused to load (status " + status + ', title "' + title + '"). Ask the user for files or screenshots instead; do not try to get past it.');
    process.exit(3);
  }
  await page.evaluate(() => document.fonts.ready);
  // Scroll through the page so lazy images load, then back up.
  await page.evaluate(async () => {
    for (let y = 0; y < document.body.scrollHeight; y += 600) { window.scrollTo(0, y); await new Promise((r) => setTimeout(r, 120)); }
    window.scrollTo(0, 0);
  });
  await page.waitForTimeout(1000);

  const data = await page.evaluate(() => {
    const tally = (m, k, n = 1) => { if (k) m[k] = (m[k] || 0) + n; };
    const top = (m, n = 40) => Object.entries(m).sort((a, b) => b[1] - a[1]).slice(0, n).map(([value, count]) => ({ value, count }));
    const hex = (c) => {
      const m = c && c.match(/rgba?\(([^)]+)\)/);
      if (!m) return null;
      const p = m[1].split(/[,\s/]+/).map(parseFloat);
      if (p.length > 3 && p[3] === 0) return null;
      const h = "#" + p.slice(0, 3).map((v) => Math.round(v).toString(16).padStart(2, "0")).join("");
      return p.length > 3 && p[3] < 1 ? h + Math.round(p[3] * 255).toString(16).padStart(2, "0") : h;
    };
    const visible = (el) => { const r = el.getBoundingClientRect(), s = getComputedStyle(el); return r.width > 0 && r.height > 0 && s.visibility !== "hidden" && s.display !== "none" && +s.opacity > 0; };
    // The solid color behind an element: the nearest ancestor with an opaque background.
    const behind = (el) => {
      for (let e = el; e; e = e.parentElement) {
        const h = hex(getComputedStyle(e).backgroundColor);
        if (h && h.length === 7) return h;
        if (getComputedStyle(e).backgroundImage !== "none") return null;
      }
      return "#ffffff";
    };
    const colors = {}, backgrounds = {}, borders = {}, outlines = {}, shadowColors = {}, pairs = {}, fonts = {}, sizes = {}, weights = {}, lines = {}, radii = {}, shadows = {}, spacing = {}, gradients = {};
    const all = [...document.querySelectorAll("body, body *")].filter((el) => !el.closest("svg, script, style, noscript") && visible(el));
    for (const el of all) {
      const s = getComputedStyle(el);
      const hasText = [...el.childNodes].some((n) => n.nodeType === 3 && n.textContent.trim());
      const bg = hex(s.backgroundColor);
      tally(backgrounds, bg);
      for (const side of ["Top", "Right", "Bottom", "Left"]) if (parseFloat(s["border" + side + "Width"]) > 0 && s["border" + side + "Style"] !== "none") tally(borders, hex(s["border" + side + "Color"]));
      if (parseFloat(s.outlineWidth) > 0 && s.outlineStyle !== "none") tally(outlines, hex(s.outlineColor));
      for (const c of s.boxShadow.match(/rgba?\([^)]+\)/g) || []) tally(shadowColors, hex(c));
      if (/gradient/.test(s.backgroundImage)) tally(gradients, s.backgroundImage.slice(0, 240));
      for (const corner of ["TopLeft", "TopRight", "BottomRight", "BottomLeft"]) if (s["border" + corner + "Radius"] !== "0px") tally(radii, s["border" + corner + "Radius"]);
      if (s.boxShadow !== "none") tally(shadows, s.boxShadow.slice(0, 160));
      for (const p of ["paddingTop", "paddingLeft", "marginTop", "marginBottom", "rowGap", "columnGap"]) {
        const v = parseFloat(s[p]);
        if (v > 0) tally(spacing, Math.round(v) + "px");
      }
      if (hasText) {
        const fg = hex(s.color), b = behind(el);
        tally(colors, fg);
        if (fg && b) tally(pairs, fg + ":" + b);
        tally(fonts, s.fontFamily);
        tally(sizes, s.fontSize);
        tally(weights, s.fontWeight);
        tally(lines, s.lineHeight);
      }
    }
    const vars = {};
    const readRules = (rules) => {
      for (const r of rules) {
        if (r.cssRules && !r.selectorText) { try { readRules(r.cssRules); } catch {} continue; }
        if (!r.style) continue;
        for (const name of r.style) if (name.startsWith("--") && Object.keys(vars).length < 400) vars[name] = r.style.getPropertyValue(name).trim().slice(0, 160);
      }
    };
    // Stylesheets on another host can't be read; the computed values above still count.
    for (const sheet of document.styleSheets) { try { readRules(sheet.cssRules); } catch {} }

    const describe = (el) => {
      const s = getComputedStyle(el), r = el.getBoundingClientRect();
      return { text: (el.innerText || el.value || el.placeholder || "").trim().slice(0, 40), height: Math.round(r.height), font: s.fontFamily.split(",")[0].replace(/"/g, ""), size: s.fontSize, weight: s.fontWeight, color: hex(s.color), background: hex(s.backgroundColor), border: parseFloat(s.borderTopWidth) > 0 ? s.borderTopWidth + " " + hex(s.borderTopColor) : "none", radius: s.borderTopLeftRadius, shadow: s.boxShadow === "none" ? "none" : s.boxShadow.slice(0, 80), padding: s.padding };
    };
    const sample = (selector, n = 8) => {
      const seen = new Set(), found = [];
      for (const el of document.querySelectorAll(selector)) {
        if (!visible(el) || el.closest("svg")) continue;
        const d = describe(el), key = [d.height, d.font, d.background, d.color, d.radius, d.border].join("|");
        if (!seen.has(key)) { seen.add(key); found.push(d); }
        if (found.length >= n) break;
      }
      return found;
    };
    const components = {
      buttons: sample('button, [role="button"], a[class*="btn" i], a[class*="button" i], input[type="submit"]'),
      inputs: sample('input:not([type="submit"]):not([type="hidden"]):not([type="checkbox"]):not([type="radio"]), select, textarea'),
      links: sample("main a, article a, p a", 4),
      headings: sample("h1, h2, h3, h4", 8),
      cards: sample('[class*="card" i], article, [class*="tile" i]', 6),
      nav: sample("header, nav", 3),
      tables: sample("table", 2),
      badges: sample('[class*="badge" i], [class*="tag" i], [class*="pill" i], [class*="chip" i]', 4),
    };

    const assets = new Map();
    const isLogo = (el) => {
      const file = el.src ? el.src.split(/[?#]/)[0].split("/").pop() : "";
      const hint = [el.alt, el.id, el.className && el.className.baseVal !== undefined ? el.className.baseVal : el.className, file, el.getAttribute && el.getAttribute("aria-label")].join(" ");
      return /logo|wordmark/i.test(hint) || !!(el.closest && el.closest('header a, nav a[href="/"], a[aria-label*="home" i], [class*="logo" i]'));
    };
    const add = (src, el, kind) => {
      if (!src || /^data:/.test(src) || assets.has(src)) return;
      const r = el.getBoundingClientRect();
      assets.set(src, { src, kind, width: Math.round(r.width), height: Math.round(r.height), alt: (el.alt || el.getAttribute("aria-label") || "").slice(0, 120) });
    };
    for (const img of document.querySelectorAll("img")) {
      const r = img.getBoundingClientRect();
      if (r.width < 16 && r.height < 16) continue;
      const src = img.currentSrc || img.src;
      add(src, img, isLogo(img) ? "logo" : /\.svg(\?|$)/i.test(src) ? "illustration" : r.width >= 300 ? "image" : "icon");
    }
    for (const v of document.querySelectorAll("video[poster]")) add(v.poster, v, "video-poster");
    for (const el of all) {
      const m = getComputedStyle(el).backgroundImage.match(/url\("([^"]+)"\)/);
      if (m) { const r = el.getBoundingClientRect(); if (r.width >= 120 && r.height >= 60) add(m[1], el, "image"); }
    }
    const svgs = [];
    for (const svg of document.querySelectorAll("svg")) {
      const r = svg.getBoundingClientRect();
      if (r.width === 0 || (!isLogo(svg) && r.width < 64)) continue;
      svgs.push({ kind: isLogo(svg) ? "logo" : "illustration", width: Math.round(r.width), height: Math.round(r.height), alt: (svg.getAttribute("aria-label") || "").slice(0, 120), markup: svg.outerHTML.slice(0, 500000) });
      if (svgs.length >= 20) break;
    }
    const icon = document.querySelector('link[rel~="icon"]');
    if (icon && icon.href && !/^data:/.test(icon.href)) add(icon.href, icon, "favicon");
    const metaImg = document.querySelector('meta[property="og:image"]');
    if (metaImg && metaImg.content) add(new URL(metaImg.content, location.href).href, metaImg, "social-image");

    const body = getComputedStyle(document.body);
    const signals = {
      distinctFontFamilies: Object.keys(fonts).length,
      distinctFontSizes: Object.keys(sizes).length,
      distinctTextColors: Object.keys(colors).length,
      distinctRadii: Object.keys(radii).length,
      distinctShadows: Object.keys(shadows).length,
      imagesWithoutAlt: [...document.images].filter((i) => !i.hasAttribute("alt")).length,
      controlsWithoutName: [...document.querySelectorAll("button, a[href], input, select, textarea")].filter((e) => visible(e) && !(e.innerText || "").trim() && !e.getAttribute("aria-label") && !e.getAttribute("title") && !e.labels?.length && !e.querySelector("img[alt], svg title, [aria-label]")).length,
      sideways1440: document.documentElement.scrollWidth - innerWidth,
    };
    return {
      source: location.href, title: document.title, lang: document.documentElement.lang || null,
      bodyFont: body.fontFamily, bodyColor: hex(body.color), bodyBackground: hex(body.backgroundColor),
      colors: top(colors), backgrounds: top(backgrounds), borders: top(borders, 40), outlines: top(outlines, 10), shadowColors: top(shadowColors, 20), pairs: top(pairs, 30),
      fonts: top(fonts, 12), sizes: top(sizes, 24), weights: top(weights, 8), lineHeights: top(lines, 12),
      radii: top(radii, 16), elevation: top(shadows, 12), spacing: top(spacing, 24), gradients: top(gradients, 10),
      cssVariables: vars, components, signals, assets: [...assets.values()], svgs,
    };
  });

  // Hover, focus, active and disabled live in the stylesheets, not on the page. Read the
  // files themselves: the browser won't let a page read another file's rules.
  const sheets = await page.evaluate(() => ({ links: [...document.querySelectorAll('link[rel~="stylesheet"]')].map((l) => l.href), inline: [...document.querySelectorAll("style")].map((s) => s.textContent) }));
  const css = [...sheets.inline];
  for (const href of sheets.links) {
    try {
      if (href.startsWith("file://")) css.push(fs.readFileSync(decodeURIComponent(new URL(href).pathname), "utf8"));
      else { const res = await context.request.get(href, { timeout: 20000 }); if (res.ok()) css.push(await res.text()); }
    } catch (e) { console.error("skipped stylesheet " + href.slice(0, 120)); }
  }
  const states = {}, declared = {};
  const VALUE = /#[0-9a-f]{3,8}\b|rgba?\([^)]*\)|hsla?\([^)]*\)/gi;
  for (const text of css) {
    for (const m of text.replace(/\/\*[\s\S]*?\*\//g, "").matchAll(/([^{}]+)\{([^{}]*)\}/g)) {
      const values = m[2].match(VALUE) || [];
      for (const v of values) declared[v.toLowerCase()] = (declared[v.toLowerCase()] || 0) + 1;
      const state = m[1].match(/:(hover|focus-visible|focus|active|disabled)|\[disabled\]/);
      if (state && values.length) {
        const key = state[1] || "disabled";
        states[key] = states[key] || [];
        if (states[key].length < 40) states[key].push({ selector: m[1].trim().slice(0, 100), declarations: m[2].trim().slice(0, 200) });
      }
    }
  }
  data.states = states;
  data.declaredColors = Object.entries(declared).sort((a, b) => b[1] - a[1]).slice(0, 120).map(([value, count]) => ({ value, count }));
  // Greys are easy to miss and they carry the borders and quiet text: list them apart.
  const isGrey = (v) => { const m = v.match(/^#([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})/i); if (!m) return false; const c = m.slice(1).map((h) => parseInt(h, 16)); return Math.max(...c) - Math.min(...c) <= 24; };
  data.greys = [...new Set([...data.colors, ...data.backgrounds, ...data.borders, ...data.declaredColors].map((c) => c.value).filter(isGrey))];

  await page.screenshot({ path: path.join(out, "page-1440.png"), fullPage: true });
  await page.setViewportSize({ width: 375, height: 812 });
  await page.waitForTimeout(600);
  data.signals.sideways375 = await page.evaluate(() => document.documentElement.scrollWidth - innerWidth);
  await page.screenshot({ path: path.join(out, "page-375.png"), fullPage: true });

  const manifest = [];
  if (withAssets === "yes") {
    const dir = path.join(out, "assets");
    fs.mkdirSync(dir, { recursive: true });
    const save = (buf, ext, row) => {
      const file = row.kind + "-" + crypto.createHash("sha1").update(buf).digest("hex").slice(0, 10) + ext;
      fs.writeFileSync(path.join(dir, file), buf);
      if (!manifest.some((m) => m.file === file)) manifest.push({ file, ...row });
    };
    for (const a of data.assets.slice(0, MAX_ASSETS)) {
      try {
        let buf, type;
        if (a.src.startsWith("file://")) {
          const p = decodeURIComponent(new URL(a.src).pathname);
          buf = fs.readFileSync(p);
          type = Object.keys(EXT).find((t) => EXT[t] === path.extname(p).toLowerCase()) || (/\.jpeg$/i.test(p) ? "image/jpeg" : null);
        } else {
          const res = await context.request.get(a.src, { timeout: 20000 });
          if (!res.ok()) throw new Error("status " + res.status());
          type = (res.headers()["content-type"] || "").split(";")[0].trim().toLowerCase();
          buf = await res.body();
        }
        if (!EXT[type]) throw new Error("not an image (" + type + ")");
        if (buf.length > MAX_BYTES) throw new Error("larger than 10 MB");
        if (type === "image/svg+xml") buf = Buffer.from(cleanSvg(buf.toString("utf8")));
        save(buf, EXT[type], { kind: a.kind, source: a.src, width: a.width, height: a.height, alt: a.alt, bytes: buf.length });
      } catch (e) {
        console.error("skipped " + a.src.slice(0, 120) + ": " + e.message.split("\n")[0]);
      }
    }
    for (const s of data.svgs) {
      const markup = cleanSvg(s.markup.includes("xmlns=") ? s.markup : s.markup.replace("<svg", '<svg xmlns="http://www.w3.org/2000/svg"'));
      save(Buffer.from(markup), ".svg", { kind: s.kind, source: "inline SVG on " + data.source, width: s.width, height: s.height, alt: s.alt, bytes: markup.length });
    }
    fs.writeFileSync(path.join(out, "assets.json"), JSON.stringify(manifest, null, 2));
  }
  delete data.svgs;
  fs.writeFileSync(path.join(out, "tokens.json"), JSON.stringify(data, null, 2));
  await browser.close();
  console.log(out + ": " + data.colors.length + " text colors, " + data.fonts.length + " font stacks, " + manifest.length + " assets");
})().catch((e) => { console.error(e.message); process.exit(1); });
JS
