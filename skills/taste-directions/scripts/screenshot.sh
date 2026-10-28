#!/usr/bin/env bash
# Take a screenshot of a local HTML file or a URL, for the judges.
#
# Usage: screenshot.sh <file-or-url>[#frame-id] <out.png> [width]
#   width defaults to 1440. Use 375 for a phone-sized view.
#   With #frame-id, only the element with that id is captured (one preview frame);
#   without it, the whole page.
#
# Warns when the page scrolls sideways, when an element sticks out of the box
# around it (a button past the edge of its card), when content is cut off inside a
# box that hides overflow, when content spills out of its own element (a squeezed
# wordmark, a wrapped label in a badge), and when neighbours in a row overlap. The
# page-level check misses all of these.
#
# Uses Playwright, which downloads its own Chromium the first time (about 150 MB).
set -euo pipefail

if [ $# -lt 2 ]; then
  sed -n '2,15p' "$0"
  exit 2
fi

target="$1"
out="$2"
width="${3:-1440}"
version="1.49.1"

frame=""
case "$target" in
  *#*) frame="${target##*#}"; target="${target%#*}" ;;
esac
case "$target" in
  http://*|https://*|file://*) url="$target" ;;
  *) url="file://$(cd "$(dirname "$target")" && pwd)/$(basename "$target")" ;;
esac
mkdir -p "$(dirname "$out")"

npx -y "playwright@$version" install chromium >/dev/null 2>&1
# The folder npx put Playwright in, so node can load it as a library.
modules="$(npx -y -p "playwright@$version" -c 'cd "$(dirname "$(command -v playwright)")/.." && pwd')"

NODE_PATH="$modules" node - "$url" "$out" "$width" "$frame" <<'JS'
const { chromium } = require("playwright");
const [url, out, width, frame] = process.argv.slice(2);
(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage({ viewport: { width: Number(width), height: 900 } });
  await page.goto(url, { waitUntil: "networkidle" });
  await page.evaluate(() => document.fonts.ready);
  // Let entrance animations (like a trace drawing itself) finish before capturing.
  await page.waitForTimeout(1600);
  if (frame) {
    const el = page.locator("#" + frame);
    if (!(await el.count())) {
      console.error("no element with id " + frame);
      process.exit(1);
    }
    await el.first().screenshot({ path: out });
  } else {
    await page.screenshot({ path: out, fullPage: true });
  }
  const overflow = await page.evaluate(() => document.documentElement.scrollWidth - window.innerWidth);
  if (overflow > 0) console.error("warning: the page is " + overflow + "px wider than the window (sideways scroll)");

  // A page can fit the window while something inside it is still broken. Three checks:
  // 1. an element sticks out of the box around it (a button past the edge of its card,
  //    a wrapped label spilling out of its badge), on any side the box draws an edge;
  // 2. content is cut off inside a box that hides overflow (a modal's last button);
  // 3. two neighbours in a row overlap (a button sitting on top of the wordmark).
  // SVG internals are skipped.
  const sticking = await page.evaluate((frame) => {
    const root = frame ? document.getElementById(frame) : document.body;
    const cs = (el) => getComputedStyle(el);
    const filled = (s) => (s.backgroundColor !== "rgba(0, 0, 0, 0)" && s.backgroundColor !== "transparent") || s.backgroundImage !== "none";
    // A box shows an edge on a side if it has a border there or a background.
    const edges = (el) => {
      const s = cs(el), bw = (side) => parseFloat(s["border" + side + "Width"]) > 0, f = filled(s);
      return { x: f || bw("Left") || bw("Right"), y: f || bw("Top") || bw("Bottom") };
    };
    const clipsX = (el) => /hidden|clip|auto|scroll/.test(cs(el).overflowX);
    const clipsY = (el) => /hidden|clip|auto|scroll/.test(cs(el).overflowY);
    const name = (el) => el.tagName.toLowerCase() + (el.id ? "#" + el.id : "") +
      [...el.classList].slice(0, 2).map((c) => "." + c).join("");
    const skip = (el) => el.closest("svg") && el.tagName.toLowerCase() !== "svg";
    const visible = (r) => r.width > 0 && r.height > 0;
    const found = [];
    const all = [...root.querySelectorAll("*")].filter((el) => !skip(el));

    for (const el of all) {
      const r = el.getBoundingClientRect();
      if (!visible(r)) continue;
      // 1. Sticking out, checked per axis against the nearest box that shows that edge.
      for (const axis of ["x", "y"]) {
        let box = el.parentElement, clipped = false;
        while (box && box !== root.parentElement) {
          if (axis === "x" ? clipsX(box) : clipsY(box)) { clipped = true; break; }
          if (edges(box)[axis]) break;
          box = box.parentElement;
        }
        if (clipped || !box || box === root.parentElement) continue;
        const b = box.getBoundingClientRect();
        const out = axis === "x" ? Math.max(r.right - b.right, b.left - r.left) : Math.max(r.bottom - b.bottom, b.top - r.top);
        if (out > 1) found.push(name(el) + " sticks out of " + name(box) + " by " + Math.round(out) + "px");
      }
      // 2. Cut off: a box that hides overflow but has more content than room. Scrolling
      //    boxes (overflow auto/scroll) are fine: their content can still be reached.
      const s = cs(el);
      if (/hidden|clip/.test(s.overflowX + s.overflowY) && el.children.length) {
        const cutX = /hidden|clip/.test(s.overflowX) && el.scrollWidth > el.clientWidth + 1;
        const cutY = /hidden|clip/.test(s.overflowY) && el.scrollHeight > el.clientHeight + 1;
        if (cutX || cutY) found.push("content is cut off inside " + name(el) + " (" + (cutX ? (el.scrollWidth - el.clientWidth) + "px across" : (el.scrollHeight - el.clientHeight) + "px down") + ")");
      }
      // 2b. Hidden sideways scroll: a box that scrolls sideways inside itself (a wide
      //     table on a phone). Allowed, but with no visible hint it reads as cut off,
      //     so flag it for a deliberate decision.
      if (/auto|scroll/.test(s.overflowX) && el.scrollWidth > el.clientWidth + 1)
        found.push(name(el) + " scrolls sideways inside itself (" + (el.scrollWidth - el.clientWidth) + "px hidden): hide columns or show that it scrolls");
      // 3. Overlapping neighbours in a flex or grid row.
      if (/flex|grid/.test(s.display)) {
        const kids = [...el.children].filter((k) => !skip(k) && cs(k).position !== "absolute" && cs(k).position !== "fixed" && visible(k.getBoundingClientRect()));
        // Grid items placed in the same cell on purpose (an overlay stacked on a page) are fine.
        const cell = (k) => { const c = cs(k); return c.gridRowStart !== "auto" && c.gridColumnStart !== "auto" ? c.gridRowStart + "/" + c.gridColumnStart : null; };
        // Compare what each neighbour actually paints (its box plus anything inside it
        // that overflows), so a squeezed wordmark sliding under a button still counts.
        const painted = (k) => {
          const u = k.getBoundingClientRect(), box = { left: u.left, right: u.right, top: u.top, bottom: u.bottom };
          for (const d of k.querySelectorAll("*")) {
            if (skip(d) || /absolute|fixed/.test(cs(d).position)) continue;
            const q = d.getBoundingClientRect();
            if (!visible(q)) continue;
            box.left = Math.min(box.left, q.left); box.right = Math.max(box.right, q.right);
            box.top = Math.min(box.top, q.top); box.bottom = Math.max(box.bottom, q.bottom);
          }
          return box;
        };
        for (let i = 0; i < kids.length; i++) for (let j = i + 1; j < kids.length; j++) {
          if (cell(kids[i]) && cell(kids[i]) === cell(kids[j])) continue;
          const a = painted(kids[i]), b = painted(kids[j]);
          const w = Math.min(a.right, b.right) - Math.max(a.left, b.left), h = Math.min(a.bottom, b.bottom) - Math.max(a.top, b.top);
          if (w > 1 && h > 1) found.push(name(kids[i]) + " and " + name(kids[j]) + " overlap by " + Math.round(w) + "px");
        }
      }
    }
    // 4. Spilling: text runs past the edges of the element that holds it (a squeezed
    //    wordmark, a label wrapping out of a fixed-height badge). Each piece of text is
    //    measured against its nearest non-inline container, so text inside <b> or <a>
    //    counts too; tight line heights and positioned decorations don't. Up and down
    //    only matter when that container draws a box you can see.
    const walker = document.createTreeWalker(root, NodeFilter.SHOW_TEXT);
    const range = document.createRange();
    for (let node = walker.nextNode(); node; node = walker.nextNode()) {
      if (!node.textContent.trim() || skip(node.parentElement)) continue;
      let box = node.parentElement;
      while (box !== root && /^(inline|contents)$/.test(cs(box).display)) box = box.parentElement;
      const bs = cs(box);
      if (/hidden|clip|auto|scroll/.test(bs.overflowX + bs.overflowY)) continue;
      const r = box.getBoundingClientRect();
      range.selectNodeContents(node);
      let across = 0, down = 0;
      for (const t of range.getClientRects()) {
        across = Math.max(across, t.right - r.right, r.left - t.left);
        down = Math.max(down, t.bottom - r.bottom, r.top - t.top);
      }
      if (across > 1) found.push("text spills out of " + name(box) + " (" + Math.round(across) + "px across)");
      else if (edges(box).y && down > 1) found.push("text spills out of " + name(box) + " (" + Math.round(down) + "px down)");
    }
    return [...new Set(found)].slice(0, 10);
  }, frame);
  for (const line of sticking) console.error("warning: " + line);
  await browser.close();
  console.log(out);
})();
JS
