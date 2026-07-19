#!/usr/bin/env python3
"""Measure our harvest gap per country against what Commons actually holds.

Commons is inconsistent about naming: some countries file under "Stamps of X",
others under "Postage stamps of X", and a few have both with different contents.
Our harvest evidently followed one pattern per country, so wherever Commons chose
the other one we recorded almost nothing and it looked like the source was thin.
This measures both trees, plus the colonial-era predecessor, and reports the gap.
"""
import urllib.request, urllib.parse, json, time, sys

API = "https://commons.wikimedia.org/w/api.php"
UA = {"User-Agent": "RowlandResearch/1.0 (david.defranceski@gmail.com)"}

def members(cat, typ):
    out, cont = [], None
    while True:
        q = {"action": "query", "list": "categorymembers", "cmtitle": "Category:" + cat,
             "cmlimit": "500", "cmtype": typ, "format": "json", "maxlag": "5"}
        if cont:
            q["cmcontinue"] = cont
        req = urllib.request.Request(API + "?" + urllib.parse.urlencode(q), headers=UA)
        d = json.load(urllib.request.urlopen(req, timeout=40))
        out += [m["title"] for m in d.get("query", {}).get("categorymembers", [])]
        cont = d.get("continue", {}).get("cmcontinue")
        if not cont:
            return out

def deep(cat, depth=2):
    """Files in a category tree. depth=2 covers the by-year subcategories."""
    seen, files, frontier = set(), set(), [cat]
    for _ in range(depth + 1):
        nxt = []
        for c in frontier:
            if c in seen:
                continue
            seen.add(c)
            try:
                files.update(members(c, "file"))
                nxt += [s.replace("Category:", "") for s in members(c, "subcat")]
            except Exception:
                pass
            time.sleep(0.25)
        frontier = nxt
    return files

def commons_total(name):
    """Union of both naming conventions — they overlap only partially."""
    return deep("Stamps of " + name) | deep("Postage stamps of " + name)

if __name__ == "__main__":
    targets = json.load(open(sys.argv[1]))
    results = []
    for t in targets:
        names = [t["country"]] + t.get("also", [])
        files = set()
        per = {}
        for n in names:
            f = commons_total(n)
            per[n] = len(f)
            files |= f
        results.append({"country": t["country"], "held": t["held"],
                        "commons": len(files), "breakdown": per})
        r = results[-1]
        gap = r["commons"] - r["held"]
        print(f'{r["held"]:>5} held  {r["commons"]:>5} commons  {gap:>+6}  {r["country"]}'
              f'   {r["breakdown"]}', flush=True)
    json.dump(results, open("undercover_report.json", "w"), indent=1)
