#!/usr/bin/env python3
"""Parse Wikipedia's 'List of entities that have issued postage stamps' (A-E, F-L, M-Z)
into a structured succession dataset.

Wikitext shape:
    ===Zimbabwe===                         <- grouping = modern successor entity
    * [[...|Rhodesia]]  1890 – 1924        <- issuing entity + active period
    * Occupation issues                    <- entity, no dates

The heading is Wikipedia's own grouping of historical issuers under the modern
territory, which is exactly the succession edge we need.
"""
import json, re, sys

SRC = {
    "wp_AE.json": "List of entities that have issued postage stamps (A–E)",
    "wp_FL.json": "List of entities that have issued postage stamps (F–L)",
    "wp_MZ.json": "List of entities that have issued postage stamps (M–Z)",
}

DASH = r"[–—\-]"

def strip_markup(s: str) -> str:
    s = re.sub(r"\{\{[^{}]*\}\}", "", s)              # templates
    s = re.sub(r"\[\[[^\]|]*\|([^\]]*)\]\]", r"\1", s)  # [[target|display]] -> display
    s = re.sub(r"\[\[([^\]]*)\]\]", r"\1", s)          # [[target]] -> target
    s = re.sub(r"<!--.*?-->", "", s, flags=re.S)       # comments
    s = re.sub(r"<ref[^>]*>.*?</ref>", "", s, flags=re.S)
    s = re.sub(r"<ref[^>]*/>", "", s)
    s = re.sub(r"'''?", "", s)                          # bold/italic
    return s

def parse_periods(text: str):
    """Split 'Name 1918–1940; 1991 –' into ('Name', [(1918,1940), (1991,None)]).

    Entities routinely have SEVERAL disjoint issuing periods separated by ';' —
    Latvia and Estonia (1918-1940, then 1991-) and Czechoslovakia (1918-1939, then
    1945-1992) all do. Parsing only the last period leaves the earlier ones stranded
    inside the entity name ('Latvia 1918-1940'), which is both a wrong name and a
    lost period.

    Returns (name, periods). periods may be empty when no dates are given.
    """
    # The date section begins at the first standalone year followed by a range dash,
    # a semicolon, 'only', or end-of-line. Entity names themselves don't carry years.
    m = re.search(rf"\s(\d{{4}})\s*(?={DASH}|;|only\b|$)", text, re.I)
    if not m:
        return text.strip(), []

    name = text[: m.start()].strip()
    datepart = text[m.start():].strip()
    periods = []
    for chunk in datepart.split(";"):
        chunk = chunk.strip()
        if not chunk:
            continue
        mo = re.match(r"^(\d{4})\s+only$", chunk, re.I)
        if mo:
            y = int(mo.group(1))
            periods.append((y, y))
            continue
        mr = re.match(rf"^(\d{{4}})\s*{DASH}\s*(\d{{4}})?$", chunk)
        if mr:
            periods.append((int(mr.group(1)), int(mr.group(2)) if mr.group(2) else None))
            continue
        ms = re.match(r"^(\d{4})$", chunk)
        if ms:
            y = int(ms.group(1))
            periods.append((y, y))
            continue
        # Unrecognised tail (e.g. a parenthetical) — keep it on the name so nothing
        # is silently dropped.
        name = f"{name} {chunk}".strip()
    return name, periods

def main():
    groups = []        # {group, part, entities:[{name,start,end}]}
    for fname, title in SRC.items():
        d = json.load(open(fname))
        wt = d["parse"]["wikitext"]["*"]
        current = None
        for raw in wt.splitlines():
            line = raw.rstrip()
            # Level-2 headings (==References==, ==See also==, ==External links==) close the
            # entity list. Without this the bullets under them get attributed to whichever
            # entity happened to be last, which silently turns bibliography rows
            # ("Stanley Gibbons Ltd, various catalogues") into stamp issuers.
            h2 = re.match(r"^==\s*([^=].*?)\s*==\s*$", line)
            if h2:
                current = None
                continue
            h = re.match(r"^===\s*(.+?)\s*===\s*$", line)
            if h:
                current = {"group": strip_markup(h.group(1)).strip(),
                           "source": title, "entities": []}
                groups.append(current)
                continue
            if current is None:
                continue
            if not line.startswith("*"):
                continue
            body = strip_markup(line.lstrip("*").strip())
            body = body.replace("\t", " ")
            body = re.sub(r"\s+", " ", body).strip()
            if not body:
                continue
            name, periods = parse_periods(body)
            name = name.strip(" ,;")
            if not name:
                continue
            current["entities"].append({
                "name": name,
                "periods": [{"start": s, "end": e} for s, e in periods],
                # Convenience span for the single-column schema; periods keeps the gaps.
                "start": periods[0][0] if periods else None,
                "end": periods[-1][1] if periods else None,
            })

    groups = [g for g in groups if g["group"] not in ("List", "See also", "References", "External links")]
    json.dump(groups, open("entities.json", "w"), indent=1, ensure_ascii=False)

    total_ent = sum(len(g["entities"]) for g in groups)
    dated = sum(1 for g in groups for e in g["entities"] if e["start"])
    dead = sum(1 for g in groups for e in g["entities"] if e["end"])
    multi = [g for g in groups if len(g["entities"]) > 1]

    print(f"groups (modern territories): {len(groups)}")
    print(f"issuing entities:            {total_ent}")
    print(f"  with a start date:         {dated}")
    print(f"  with an end date (dead):   {dead}")
    print(f"groups with >1 entity:       {len(multi)}")
    multiperiod = [(g["group"], e) for g in groups for e in g["entities"] if len(e["periods"]) > 1]
    print(f"entities with >1 issuing period: {len(multiperiod)}")
    for grp, e in multiperiod[:6]:
        ps = "; ".join(f"{p['start']}-{p['end'] or ''}" for p in e["periods"])
        print(f"   [{grp}] {e['name']}  ->  {ps}")
    print()
    print("sanity — Rhodesia cluster:")
    for g in groups:
        if g["group"] == "Rhodesia":
            for e in g["entities"]:
                print(f"   {e['start'] or '?':>4}-{e['end'] or '   ':<4}  {e['name']}")
    print()
    print("largest groups:")
    for g in sorted(groups, key=lambda x: -len(x["entities"]))[:8]:
        print(f"   {len(g['entities']):>3}  {g['group']}")

if __name__ == "__main__":
    main()
