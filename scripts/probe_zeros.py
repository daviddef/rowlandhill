#!/usr/bin/env python3
"""For every zero-coverage country, find which Commons stamp category actually exists.

The 95 gaps are almost all naming misses, not absent data: Commons may file a country as
"Stamps of X", "Postage stamps of X", "Stamps of the X", or under a different exonym
(Czechia -> Czech Republic, Myanmar -> Burma, Ivory Coast -> Côte d'Ivoire). Probe the
variants, keep whichever exists, and report its subcategory/file shape so the harvester
knows it's worth walking.
"""
import json, re, sys, time, urllib.parse, urllib.request
from concurrent.futures import ThreadPoolExecutor, as_completed

UA = "RowlandResearch/0.1 (david.defranceski@gmail.com) coverage-gap probe"
API = "https://commons.wikimedia.org/w/api.php"

# Countries Commons files under a different name than the modern/common one.
EXONYM = {
    "Czechia": ["Czechoslovakia", "the Czech Republic", "Czech Republic"],
    "Myanmar": ["Burma"],
    "Ivory Coast": ["Côte d'Ivoire", "the Ivory Coast"],
    "Cape Verde": ["Cabo Verde"],
    "Timor-Leste": ["East Timor", "Portuguese Timor"],
    "Korea (North)": ["North Korea"],
    "Eswatini": ["Swaziland"],
    "Congo (DR)": ["the Democratic Republic of the Congo", "Zaire", "the Belgian Congo"],
    "Congo (Republic)": ["the Republic of the Congo"],
    "Vatican City": ["the Vatican", "Vatican"],
    "Palestine": ["the Palestinian Authority", "Palestine (region)"],
    "Taiwan": ["the Republic of China", "Formosa"],
    "Laos": ["Lao"],
    "Moldova": ["the Republic of Moldova"],
    "Micronesia": ["the Federated States of Micronesia"],
    "Hong Kong": ["Hong Kong"],
    "Macau": ["Macao"],
}

def api(params):
    params = {**params, "format": "json", "maxlag": "5"}
    url = API + "?" + urllib.parse.urlencode(params)
    delay = 0.5
    for _ in range(5):
        try:
            req = urllib.request.Request(url, headers={"User-Agent": UA})
            with urllib.request.urlopen(req, timeout=45) as r:
                d = json.load(r)
            if isinstance(d, dict) and d.get("error", {}).get("code") == "maxlag":
                time.sleep(delay); delay *= 2; continue
            return d
        except urllib.error.HTTPError as e:
            if e.code in (429, 503):
                time.sleep(delay); delay = min(delay * 2, 20); continue
            return {}
        except Exception:
            time.sleep(delay); delay *= 2
    return {}

def cat_shape(cat):
    """(exists, n_files, n_subcats) for a category, via categoryinfo."""
    d = api({"action": "query", "prop": "categoryinfo", "titles": f"Category:{cat}"})
    for p in d.get("query", {}).get("pages", {}).values():
        if "missing" in p:
            return (False, 0, 0)
        ci = p.get("categoryinfo") or {}
        return (True, ci.get("files", 0), ci.get("subcats", 0))
    return (False, 0, 0)

def variants(country):
    names = [country] + EXONYM.get(country, [])
    out = []
    for n in names:
        base = n[4:] if n.startswith("the ") else n
        for form in (f"Stamps of {n}", f"Postage stamps of {n}",
                     f"Stamps of the {base}", f"Postage stamps of the {base}"):
            if form not in out:
                out.append(form)
    return out

def probe(country):
    best = None
    for cat in variants(country):
        ok, files, subs = cat_shape(cat)
        if ok and (files + subs) > 0:
            score = files + subs * 30          # subcats usually hold the bulk
            if not best or score > best["score"]:
                best = {"country": country, "cat": cat, "files": files,
                        "subcats": subs, "score": score}
    return best or {"country": country, "cat": None, "files": 0, "subcats": 0, "score": 0}

def main():
    zeros = json.load(open("world_report.json"))["zero"]
    found, missing = [], []
    with ThreadPoolExecutor(max_workers=8) as ex:
        for res in as_completed([ex.submit(probe, c) for c in zeros]):
            r = res.result()
            (found if r["cat"] else missing).append(r)
    found.sort(key=lambda x: -x["score"])
    print(f"FOUND a Commons category for {len(found)} of {len(zeros)} zero countries\n")
    for r in found:
        print(f"  {r['files']:>5} files {r['subcats']:>3} subcats   {r['cat']}")
    print(f"\nNo category found ({len(missing)}): {[m['country'] for m in missing]}")
    json.dump(found, open("zero_probe.json", "w"), ensure_ascii=False)

if __name__ == "__main__":
    main()
