#!/usr/bin/env python3
"""Deep harvest of Wikimedia Commons stamp images — corrected descent.

WHY THIS EXISTS. The previous harvester (deep_harvest.py) descended ONLY into subcategories
whose name contained a year, or the literal string "by year":

    return bool(YEAR_RE.search(sub)) or "by year" in sub.lower()

That was a deliberate speed optimisation, on the reasoning that "by decade / by subject /
by denomination" branches merely duplicate the by-year files. For large countries that holds:
Norway files its stamps as "1949 stamps of Norway", so the year whitelist reaches everything.

For everyone else it silently harvested almost nothing. Afghanistan's tree is:

    Postage stamps of Afghanistan
      +- Postage stamps of Afghanistan by date     <- "by DATE", not "by year"
      +- Airmail stamps of Afghanistan
      +- Semi-postal stamps of Afghanistan
      +- Miniature sheets of Afghanistan
      +- Animals on stamps of Afghanistan ...

Not one of those matches a year or "by year", so descent stopped at the root and the crawler
kept only the 2 files sitting loose in the top category. We hold exactly 2 Afghanistan stamps.
Commons has 187. The same shape explains Sri Lanka (3 held / 125 available), Ghana (12 / 98),
Qatar (4 / 17) and the rest of the long tail.

The effect looked exactly like a thin source, which is why it survived so long: coverage
correlated with country size, and "big countries have more stamps online" is plausible enough
that nobody checked. It was our own filter.

THE FIX. Descend into any subcategory not on the skip list, bounded by depth and a per-country
cap. This costs more API calls on large countries, where the topical branches genuinely do
duplicate the by-year ones and dedup to nothing. That is the right trade: the previous version
was fast and wrong.

Politeness is unchanged and non-negotiable: maxlag=5, descriptive UA, exponential backoff,
bounded concurrency.
"""
import json, re, sys, time, urllib.parse, urllib.request
from concurrent.futures import ThreadPoolExecutor, as_completed

UA = "RowlandResearch/0.1 (david.defranceski@gmail.com) bulk stamp catalogue build"
API = "https://commons.wikimedia.org/w/api.php"
PER_COUNTRY_CAP = 10000
MAX_DEPTH = 4
WORKERS = 6
OK_LICENSE = re.compile(r"public domain|^pd|^cc0|cc by|cc-by|creativecommons", re.I)
YEAR_RE = re.compile(r"\b(1[89]\d\d|20[0-2]\d)\b")

# Non-stamp branches to never enter. Covers, postmarks and postal stationery are not stamps;
# forgeries and essays are not the stamp they imitate; "by artist/designer" re-slices files we
# already reach by year and costs a full extra traversal.
SKIP_SUBCAT = re.compile(
    r"postal history|covers?|cancellations?|postmark|postal stationery|meter stamp|"
    r"forg(er|ies)|fake|maximum card|essays|philatelic exhibition|philatelist|"
    r"first day cover|by artist|by designer|by photographer", re.I)


def api(params):
    params = {**params, "format": "json", "maxlag": "5"}
    url = API + "?" + urllib.parse.urlencode(params)
    delay = 0.5
    for attempt in range(6):
        try:
            req = urllib.request.Request(url, headers={"User-Agent": UA})
            with urllib.request.urlopen(req, timeout=60) as r:
                d = json.load(r)
            if "error" in d and d["error"].get("code") == "maxlag":
                time.sleep(delay); delay *= 2; continue
            return d
        except Exception:
            time.sleep(delay); delay *= 2
    return {}


def members(cat):
    """Subcategories and file records for one category."""
    subs, files, cont = [], [], {}
    while True:
        d = api({"action": "query", "generator": "categorymembers",
                 "gcmtitle": f"Category:{cat}", "gcmlimit": "500",
                 "prop": "imageinfo", "iiprop": "url|mime|extmetadata|size", **cont})
        for p in (d.get("query", {}).get("pages") or {}).values():
            t = p.get("title", "")
            if t.startswith("Category:"):
                subs.append(t.replace("Category:", ""))
            elif "imageinfo" in p:
                files.append(p)
        cont = d.get("continue", {})
        if not cont:
            break
    return subs, files


def want_descent(sub):
    """Descend into anything that isn't an explicitly non-stamp branch.

    The old version whitelisted year-bearing names only, which meant countries whose Commons
    tree is organised by type ("Airmail stamps of X") or by "by date" rather than "by year"
    were never entered at all. Dedup by pageid makes over-descent cheap in correctness terms;
    it only costs calls.
    """
    return not SKIP_SUBCAT.search(sub)


def keep_file(p, cat_year=None):
    ii = (p.get("imageinfo") or [{}])[0]
    if not ii.get("url") or not ii.get("mime", "").startswith("image/"):
        return None
    lic = ii.get("extmetadata", {}).get("LicenseShortName", {}).get("value", "")
    if not OK_LICENSE.search(lic):
        return None
    # Prefer the filename's own year; else inherit the containing category's year — a file in
    # "1949 stamps of Norway" is a 1949 stamp even when its name doesn't say so.
    ym = YEAR_RE.search(p["title"])
    year = int(ym.group(1)) if ym else cat_year
    return {"pageid": p.get("pageid"), "title": p["title"], "url": ii["url"],
            "license": lic, "mime": ii["mime"],
            "width": ii.get("width"), "height": ii.get("height"), "year": year}


def harvest_country(label, issuer_id):
    """Walk both Commons naming conventions for one country."""
    out, seen, visited = [], set(), set()
    stack = [(f"Stamps of {label}", 0), (f"Postage stamps of {label}", 0)]
    while stack and len(out) < PER_COUNTRY_CAP:
        cat, depth = stack.pop()
        if cat in visited or depth > MAX_DEPTH:
            continue
        visited.add(cat)
        cy = YEAR_RE.search(cat)
        cat_year = int(cy.group(1)) if cy else None
        subs, files = members(cat)
        for p in files:
            if len(out) >= PER_COUNTRY_CAP:
                break
            rec = keep_file(p, cat_year)
            if rec and rec["pageid"] not in seen:
                seen.add(rec["pageid"])
                rec["label"] = label
                rec["issuer_id"] = issuer_id
                out.append(rec)
        for s in subs:
            if s not in visited and want_descent(s):
                stack.append((s, depth + 1))
    return out


def main():
    cmap = json.load(open(sys.argv[1] if len(sys.argv) > 1 else "country_issuer_map.json"))
    outfile = sys.argv[2] if len(sys.argv) > 2 else "v2_records.json"
    items = sorted(cmap.items())
    all_recs, done = [], 0
    with ThreadPoolExecutor(max_workers=WORKERS) as ex:
        futs = {ex.submit(harvest_country, lbl, iid): lbl for lbl, iid in items}
        for f in as_completed(futs):
            lbl = futs[f]
            done += 1
            try:
                recs = f.result()
            except Exception as e:
                print(f"[{done}/{len(items)}] {lbl}: FAILED {e}", flush=True)
                continue
            all_recs += recs
            print(f"[{done}/{len(items)}] {lbl}: {len(recs)}  (total {len(all_recs)})",
                  flush=True)
    json.dump(all_recs, open(outfile, "w"))
    print(f"WROTE {len(all_recs)} records to {outfile}")


if __name__ == "__main__":
    main()
