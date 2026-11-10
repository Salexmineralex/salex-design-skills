#!/usr/bin/env python3
"""Check that a STYLE.md is a finished handbook before anything is built from it.

Usage: python3 why-lint.py STYLE.md

It reads the form, not the taste: the sections are in order, every decision has its
reason, source and trade-off, none rests on fashion, nothing is unresolved, no more
than six questions went to the user (five at the brief, one at the direction pick),
every decision is kept plainly or on a recorded answer ("kept" or "kept (Q1)"), every
token traces to a decision, a Signature names the move the page must show, a Why
whose only fact is "the source already did it" fails unless Source is brand, a
decision kept on "I don't know, you decide" fails (that is an assumption, not an
owner why), and the shared document default (warm off-white paper, monospace-led
type, hairline rules, small body, no imagery) fails unless an owner answer asks
for it.

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
DELEGATED = re.compile(r"\b(i don'?t know|you decide|delegat)", re.I)
MONO_FONT = re.compile(
    r"\b(mono|courier|consolas|inconsolata|cousine|menlo|andale|jetbrains|space mono|plex mono|source code|roboto mono)\b",
    re.I,
)
LOOK_WORDS = re.compile(
    r"\b(paper|beige|cream|vellum|mono(?:space)?|typewriter|hairline|1px|rules?|no (?:photos?|images?|illustrations?|imagery)|type only|small (?:type|text|body))\b",
    re.I,
)


def hex_rgb(raw):
    v = raw.lower()
    if len(v) == 3:
        v = "".join(c * 2 for c in v)
    if len(v) < 6:
        return None
    return tuple(int(v[i : i + 2], 16) for i in (0, 2, 4))


def warm_paper(rgb):
    if not rgb:
        return False
    r, g, b = rgb
    return r >= 220 and g >= 200 and b >= 170 and r >= g >= b - 4 and 14 <= (r - b) < 90


def answers_of(questions):
    found = {}
    for line in questions.splitlines():
        m = re.match(r"^- \*\*Q(\d+):\*\*(.*)$", line)
        if not m:
            continue
        ans = re.split(r"Answer:\s*", m.group(2), maxsplit=1, flags=re.I)
        found[m.group(1)] = ans[1].strip() if len(ans) > 1 else ""
    return found


def document_default(text, body):
    """The shared v2 look. Not banned: it needs an owner answer, not an assumption."""
    tokens = body.get("Tokens", "")
    decisions = body.get("Decisions", "")
    prose = decisions + "\n" + body.get("Signature", "")
    warm = False
    for m in re.finditer(r"#[0-9a-fA-F]{3,8}\b", tokens):
        if warm_paper(hex_rgb(m.group(0)[1:])):
            warm = True
            break
    fonts = re.findall(r"--font[\w-]*\s*:\s*([^;]+)", tokens, flags=re.I)
    mono = any(MONO_FONT.search(f.split(",")[0] or "") for f in fonts)
    small = False
    for m in re.finditer(
        r"--(?:font-size-|text-|size-)[\w-]*\s*:\s*(\d+(?:\.\d+)?)px", tokens, flags=re.I
    ):
        if float(m.group(1)) <= 15:
            small = True
    hair = bool(re.search(r"\b(hairline|1px)\b", prose, flags=re.I))
    no_imagery = bool(
        re.search(
            r"\b(no (?:photos?|images?|illustrations?|imagery)|type only|without (?:a )?(?:photo|image|illustration))\b",
            prose,
            flags=re.I,
        )
    )
    if not (warm and mono and small and hair and no_imagery):
        return None
    real = {
        n
        for n, ans in answers_of(body.get("Questions asked", "")).items()
        if ans and not DELEGATED.search(ans)
    }
    for entry in re.split(r"^### ", decisions, flags=re.M)[1:]:
        source = ""
        for k, v in re.findall(r"^- \*\*(.+?):\*\*(.*)$", entry, flags=re.M):
            if k.strip() == "Source":
                source = v.strip()
        cited = set(re.findall(r"Q(\d+)", source))
        if cited & real and LOOK_WORDS.search(entry):
            return None
    return (
        "document-default: warm off-white paper, monospace-led type, hairline rules, "
        "small body text and no imagery need an owner why; an assumption does not clear it"
    )


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

    question_body = body.get("Questions asked", "")
    questions = re.findall(r"^- \*\*Q\d+", question_body, flags=re.M)
    asked = answers_of(question_body)
    for title, n in cited:
        if n not in asked:
            problems.append(f"{title}: kept on Q{n}, but ## Questions asked has no Q{n}")
        elif DELEGATED.search(asked[n]):
            problems.append(
                f"{title}: kept on Q{n}, but that answer delegates the choice; log it as an assumption, not an owner why"
            )
    flagged = document_default(text, body)
    if flagged:
        problems.append(flagged)
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
