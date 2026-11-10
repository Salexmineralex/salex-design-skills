#!/usr/bin/env python3
"""Check that a STYLE.md is a finished handbook before anything is built from it.

Usage: python3 why-lint.py STYLE.md

It reads the form, not the taste: the sections are in order, every decision has its
reason, source and trade-off, none rests on fashion, nothing is unresolved, no more
than six questions went to the user (five at the brief, one at the direction pick),
every decision is kept plainly or on a recorded answer ("kept" or "kept (Q1)"), every
token traces to a decision, a Signature names the move the page must show, and a Why
whose only fact is "the source already did it" fails unless Source is brand.

Prints one line per problem. Exits 1 if there are any, 0 if the handbook is finished.
"""
import re
import sys

SECTIONS = ["Idea", "Principles", "Signature", "Decisions", "Tokens"]
FIELDS = ["Decision", "Why", "Instead of", "Breaks if removed", "Trade-off", "Source", "Reviewed"]
SOURCES = r"^(brief|idea|moodboard|mood board|user answer|brand|handbook|assumption)\b"
FASHION = re.compile(
    r"\b(looks? (modern|clean|sleek|nice|good|premium|professional)|feels? (modern|clean|sleek|premium)"
    r"|it'?s modern|on[- ]trend|trendy|everyone|everybody|popular|industry standard|best practice"
    r"|what (people|users) expect|standard for|common pattern|contemporary)\b",
    re.I,
)
# A Why that only points at the existing page. Allowed when Source is brand.
INHERIT = re.compile(
    r"\b("
    r"already (uses|ships|sets|has|does)|"
    r"(the )?(source|original|rendered page|homepage|existing page|brand) already|"
    r"as rendered|"
    r"copied from the source|"
    r"the stack the homepage already|"
    r"those are the colou?rs the rendered"
    r")\b",
    re.I,
)
MIN_WHY_WORDS = 10
MAX_QUESTIONS = 6


def sections(text):
    found = {}
    order = []
    current = None
    for line in text.splitlines():
        m = re.match(r"^## (.+?)\s*$", line)
        if m:
            current = m.group(1)
            order.append(current)
            found[current] = []
        elif current:
            found[current].append(line)
    return order, {k: "\n".join(v) for k, v in found.items()}


def check(text):
    problems = []
    order, body = sections(text)
    positions = []
    for name in SECTIONS:
        if name not in order:
            problems.append(f"missing section: ## {name}")
        else:
            positions.append(order.index(name))
    if positions != sorted(positions):
        problems.append("sections out of order: " + " > ".join(SECTIONS))
    if order and "Tokens" in order and order[-1] != "Tokens":
        problems.append("## Tokens must be the last section")

    sig = body.get("Signature", "").strip()
    if "Signature" in body and len(sig.split()) < 6:
        problems.append("## Signature is too thin; name the one move the page must show")

    ids = set()
    cited = []
    entries = re.split(r"^### ", body.get("Decisions", ""), flags=re.M)[1:]
    if "Decisions" in body and not entries:
        problems.append("## Decisions has no entries (### D1. ...)")
    for entry in entries:
        title = entry.splitlines()[0].strip()
        m = re.match(r"D(\d+)\b", title)
        if not m:
            problems.append(f'decision "{title}" needs a number, like "### D1. {title}"')
        else:
            ids.add(m.group(1))
        fields = dict(
            (k.strip(), v.strip())
            for k, v in re.findall(r"^- \*\*(.+?):\*\*(.*)$", entry, flags=re.M)
        )
        for field in FIELDS:
            if not fields.get(field):
                problems.append(f"{title}: missing {field}")
        why = fields.get("Why", "")
        source = fields.get("Source", "")
        if why:
            hit = FASHION.search(why)
            if hit:
                problems.append(f'{title}: Why rests on fashion ("{hit.group(0)}"); give the reason it serves the idea')
            elif len(why.split()) < MIN_WHY_WORDS:
                problems.append(f"{title}: Why is too short to be a reason ({len(why.split())} words)")
            elif INHERIT.search(why) and not re.match(r"^brand\b", source, flags=re.I):
                problems.append(
                    f'{title}: Why only says the source already did it; that is not a reason unless this run is brand-locked'
                )
        if source and not re.match(SOURCES, source, flags=re.I):
            problems.append(f"{title}: Source must be the brief, the moodboard, a user answer, the brand, the handbook or an assumption")
        reviewed = fields.get("Reviewed", "").strip().rstrip(".").lower()
        kept = re.fullmatch(r"kept(?: \(q(\d+)\))?", reviewed)
        if reviewed and not reviewed.startswith("kept"):
            problems.append(f"{title}: unresolved; ask the user or go back to the brief before building")
        elif reviewed and not kept:
            problems.append(f'{title}: Reviewed must be "kept" or "kept (Q1)"; move the history to your notes')
        elif kept and kept.group(1):
            cited.append((title, kept.group(1)))
        if "unresolved" in why.lower():
            problems.append(f"{title}: Why is unresolved")

    questions = re.findall(r"^- \*\*Q\d+", body.get("Questions asked", ""), flags=re.M)
    asked = {q[len("- **Q"):] for q in questions}
    for title, n in cited:
        if n not in asked:
            problems.append(f"{title}: kept on Q{n}, but ## Questions asked has no Q{n}")
    if len(questions) > MAX_QUESTIONS:
        problems.append(
            f"{len(questions)} questions asked; the limit is {MAX_QUESTIONS} (five at the brief, one at the direction pick). The brief is empty: go back to it"
        )

    tokens = 0
    for line in body.get("Tokens", "").splitlines():
        m = re.match(r"\s*(--[\w-]+)\s*:", line)
        if not m:
            continue
        tokens += 1
        ref = re.search(r"/\*\s*(?:D(\d+)|brand)\b", line)
        if not ref:
            problems.append(f"token {m.group(1)} doesn't name its decision (/* D1 */ or /* brand */)")
        elif ref.group(1) and ref.group(1) not in ids:
            problems.append(f"token {m.group(1)} names D{ref.group(1)}, which doesn't exist")
    if "Tokens" in body and not tokens:
        problems.append("## Tokens has no CSS custom properties")
    return problems


def main():
    if len(sys.argv) != 2:
        print(__doc__)
        return 2
    with open(sys.argv[1], encoding="utf-8") as f:
        problems = check(f.read())
    for p in problems:
        print(p)
    if problems:
        return 1
    print("handbook is finished")
    return 0


if __name__ == "__main__":
    sys.exit(main())
