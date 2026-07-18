#!/usr/bin/env python3
"""Ingest real stamp records from Wikimedia Commons into the Rowland corpus.

This is the FIRST real data in the stamps table. It is honestly image-tier, not
catalogue-tier: one record per Commons file, carrying (issuer, year, image, license).
No catalogue numbers, no denominations-as-data, and duplicates are expected (several
images of the same stamp, plus covers and sheets). Its value is (a) proving the
ingestion pipeline end-to-end into the real schema, and (b) a legally-clean training
corpus — Commons structured metadata is CC0, and only PD / CC-BY(-SA) image files are kept.

Structure exploited: Commons files sit in "Category:YYYY stamps of {COUNTRY}", themselves
under "Category:Stamps of {COUNTRY} by year". One API call per year-category (generator=
categorymembers + prop=imageinfo) yields files with their URL, license, and page id.
"""
import json, re, sys, time, urllib.parse, urllib.request

UA = "RowlandResearch/0.1 (david.defranceski@gmail.com)"
API = "https://commons.wikimedia.org/w/api.php"

# Commons country label -> (issuer name in DB, ISO-ish code for StampID)
COUNTRIES = [
    ("the United States", "USA", "US"),
    ("the United Kingdom", "Great Britain", "GB"),
    ("France", "France", "FR"),
    ("Germany", "Germany", "DE"),
    ("Switzerland", "Switzerland", "CH"),
    ("Japan", "Japan", "JP"),
    ("Canada", "Canada", "CA"),
    ("Australia", "Australia", "AU"),
    ("Austria", "Austria", "AT"),
    ("Belgium", "Belgium", "BE"),
    ("Sweden", "Sweden", "SE"),
    ("Italy", "Italy", "IT"),
    ("New Zealand", "New Zealand", "NZ"),
    ("Norway", "Norway", "NO"),
    ("Denmark", "Denmark", "DK"),
    ("Finland", "Finland", "FI"),
    ("Spain", "Spain", "ES"),
]

# Only keep genuinely reusable image licenses. Everything else is skipped, not guessed.
OK_LICENSE = re.compile(r"public domain|^pd|^cc0|cc by|cc-by|creativecommons", re.I)

def api(params):
    params = {**params, "format": "json"}
    url = API + "?" + urllib.parse.urlencode(params)
    for attempt in range(4):
        try:
            req = urllib.request.Request(url, headers={"User-Agent": UA})
            with urllib.request.urlopen(req, timeout=60) as r:
                return json.load(r)
        except Exception as e:
            if attempt == 3:
                print(f"  ! api fail: {e}", file=sys.stderr)
                return {}
            time.sleep(1.5 * (attempt + 1))
    return {}

YEAR_RE = re.compile(r"\b(1[89]\d\d|20\d\d)\b")

def year_categories(country):
    """Return [(year, category_title)] for a country. Commons is inconsistent:
    the root may be 'Stamps of X by year' or 'Postage stamps of X by year', and the
    year sits at the start ('1847 stamps of...'), mid ('Stamps of Japan, 1942') or with
    a 'postage' infix. So try both roots and pull the year from anywhere in the title."""
    roots = [f"Category:Stamps of {country} by year",
             f"Category:Postage stamps of {country} by year"]
    cats = []
    for root in roots:
        cont = {}
        while True:
            d = api({"action": "query", "list": "categorymembers", "cmtitle": root,
                     "cmtype": "subcat", "cmlimit": "500", **cont})
            for m in d.get("query", {}).get("categorymembers", []):
                t = m["title"].replace("Category:", "")
                mm = YEAR_RE.search(t)
                if mm:
                    cats.append((int(mm.group(1)), t))
            cont = d.get("continue", {})
            if not cont:
                break
        if cats:
            break   # first root that yields anything wins
    return cats

def files_in_category(cat):
    """Files in a category with their image URL, license, and pageid (one page of ≤500)."""
    out, cont = [], {}
    while True:
        d = api({"action": "query", "generator": "categorymembers",
                 "gcmtitle": f"Category:{cat}", "gcmtype": "file", "gcmlimit": "500",
                 "prop": "imageinfo", "iiprop": "url|extmetadata|mime|size", **cont})
        for p in d.get("query", {}).get("pages", {}).values():
            ii = (p.get("imageinfo") or [{}])[0]
            em = ii.get("extmetadata", {})
            lic = em.get("LicenseShortName", {}).get("value", "")
            out.append({
                "pageid": p.get("pageid"),
                "title": p.get("title", ""),
                "url": ii.get("url", ""),
                "license": lic,
                "mime": ii.get("mime", ""),
                "width": ii.get("width"), "height": ii.get("height"),
            })
        cont = d.get("continue", {})
        if not cont:
            break
    return out

def clean_subject(title, year):
    s = re.sub(r"^File:", "", title)
    s = re.sub(r"\.\w+$", "", s)               # extension
    s = re.sub(r"[_]+", " ", s).strip()
    return s[:200]

def main():
    records = []          # dicts ready for SQL
    seen_pageids = set()
    per_country_cap = int(sys.argv[1]) if len(sys.argv) > 1 else 1500

    for country, issuer, code in COUNTRIES:
        ycats = year_categories(country)
        got = 0
        for year, cat in ycats:
            if got >= per_country_cap:
                break
            for f in files_in_category(cat):
                if got >= per_country_cap:
                    break
                if not f["url"] or not f["mime"].startswith("image/"):
                    continue
                if not OK_LICENSE.search(f["license"]):
                    continue
                if f["pageid"] in seen_pageids:
                    continue
                seen_pageids.add(f["pageid"])
                records.append({
                    "issuer": issuer, "code": code, "year": year,
                    "title": f["title"], "subject": clean_subject(f["title"], year),
                    "url": f["url"], "license": f["license"],
                    "pageid": f["pageid"], "mime": f["mime"],
                    "width": f["width"], "height": f["height"],
                })
                got += 1
        print(f"  {country:<22} {got:>5} files  ({len(ycats)} year-categories)")

    # StampID sequence per (code, year)
    seq = {}
    for r in records:
        k = (r["code"], r["year"])
        seq[k] = seq.get(k, 0) + 1
        r["stamp_id"] = f"SID-{r['code']}-{r['year']}-{seq[k]:04d}"

    json.dump(records, open("commons_records.json", "w"), ensure_ascii=False)
    print(f"\nTOTAL real stamp records: {len(records)}")
    from collections import Counter
    print("by issuer:", dict(Counter(r["issuer"] for r in records)))

if __name__ == "__main__":
    main()
