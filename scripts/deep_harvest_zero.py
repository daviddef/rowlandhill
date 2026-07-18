#!/usr/bin/env python3
"""Fast deep harvest of Wikimedia Commons stamp images across all mapped countries.

Speed lessons from the first pass (528s/country, ~24h projected):
  - Descend ONLY into year-bearing subcategories. The "by decade / by subject / by
    denomination / by colour" branches duplicate the by-year files; walking them dedups to
    nothing but costs hundreds of calls. Whitelist descent to a year or "by year".
  - Parallelise across countries with a thread pool; dedup by pageid at LOAD time instead of
    sharing a lock-guarded set (load_deep already dedups).
Politeness held: maxlag=5, descriptive UA, exponential backoff on 429/503, bounded concurrency.
"""
import json, re, sys, time, urllib.parse, urllib.request
from concurrent.futures import ThreadPoolExecutor, as_completed

UA = "RowlandResearch/0.1 (david.defranceski@gmail.com) bulk stamp catalogue build"
API = "https://commons.wikimedia.org/w/api.php"
PER_COUNTRY_CAP = 4000
WORKERS = 6
OK_LICENSE = re.compile(r"public domain|^pd|^cc0|cc by|cc-by|creativecommons", re.I)
YEAR_RE = re.compile(r"\b(1[89]\d\d|20[0-2]\d)\b")
# Non-stamp branches to never enter.
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
            if isinstance(d, dict) and d.get("error", {}).get("code") == "maxlag":
                time.sleep(delay); delay = min(delay * 2, 20); continue
            return d
        except urllib.error.HTTPError as e:
            if e.code in (429, 503):
                time.sleep(delay); delay = min(delay * 2, 30); continue
            if attempt == 5: return {}
            time.sleep(delay); delay *= 2
        except Exception:
            if attempt == 5: return {}
            time.sleep(delay); delay *= 2
    return {}

def members(cat):
    """(subcats, file_pages) for a category, paginated."""
    subs, files, cont = [], [], {}
    while True:
        d = api({"action": "query", "generator": "categorymembers",
                 "gcmtitle": f"Category:{cat}", "gcmlimit": "500",
                 "prop": "imageinfo", "iiprop": "url|extmetadata|mime|size", **cont})
        for p in d.get("query", {}).get("pages", {}).values():
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
    """FULL depth: descend into every subcat except the non-stamp denylist. Slower, but
    captures series/subject-categorised stamps that the year-only walk misses (France gave
    658 year-only vs ~20K available)."""
    return not SKIP_SUBCAT.search(sub)

def keep_file(p, cat_year=None):
    ii = (p.get("imageinfo") or [{}])[0]
    if not ii.get("url") or not ii.get("mime", "").startswith("image/"):
        return None
    lic = ii.get("extmetadata", {}).get("LicenseShortName", {}).get("value", "")
    if not OK_LICENSE.search(lic):
        return None
    # Prefer the filename's own year; else inherit the containing category's year — a file
    # in "1949 stamps of Norway" is a 1949 stamp even when its name doesn't say so.
    ym = YEAR_RE.search(p["title"])
    year = int(ym.group(1)) if ym else cat_year
    return {"pageid": p.get("pageid"), "title": p["title"], "url": ii["url"],
            "license": lic, "mime": ii["mime"],
            "width": ii.get("width"), "height": ii.get("height"),
            "year": year}

def harvest_country(label, issuer_id):
    out, seen = [], set()
    stack = [label]   # map keys are exact Commons category titles
    visited = set()
    while stack and len(out) < PER_COUNTRY_CAP:
        cat = stack.pop()
        if cat in visited:
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
                stack.append(s)
    return out

def main():
    cmap = json.load(open("zero_harvest_map.json"))
    items = sorted(cmap.items())
    all_recs, done = [], 0
    with ThreadPoolExecutor(max_workers=WORKERS) as ex:
        futs = {ex.submit(harvest_country, lbl, iid): lbl for lbl, iid in items}
        for fut in as_completed(futs):
            lbl = futs[fut]
            try:
                recs = fut.result()
            except Exception as e:
                recs = []
                print(f"  ! {lbl}: {e}", flush=True)
            all_recs.extend(recs)
            done += 1
            print(f"  [{done:>3}/{len(items)}] {lbl:<38} {len(recs):>5}   (total {len(all_recs):,})", flush=True)
            if done % 10 == 0 or done == len(items):   # checkpoint every 10 countries
                json.dump(all_recs, open("zero_records.json", "w"), ensure_ascii=False)
    print(f"\nTOTAL: {len(all_recs):,} stamp images across {len(items)} countries")

if __name__ == "__main__":
    main()
