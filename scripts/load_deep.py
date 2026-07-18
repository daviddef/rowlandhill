#!/usr/bin/env python3
"""deep_records.json -> 006_commons_stamps.sql (supersedes the shallow 17-country load).

StampID = SID-CMN-{pageid}. The Commons pageid is globally unique and stable, so IDs are
deterministic and the load is idempotent without per-country sequence bookkeeping. These are
image-tier (source_tier=scraped, confidence=0.4); proper catalogue StampIDs come with catalogue
data. Records carry issuer_id directly (resolved at harvest via the alias graph) and a nullable
year.
"""
import json, re, sys

def sq(s):
    if s is None: return "NULL"
    return "'" + str(s).replace("'", "''") + "'"

def clean_subject(title):
    s = re.sub(r"^File:", "", title)
    s = re.sub(r"\.\w+$", "", s)
    s = re.sub(r"[_]+", " ", s).strip()
    return s[:200]

# Denomination extraction from filenames. Conservative: match a value + a known currency
# unit, else leave NULL. Not a substitute for catalogue data, but real structure for free.
DENOM_RE = re.compile(
    r"\b(\d{1,4}(?:[.,]\d{1,2})?)\s?"
    r"(d|c|ct|cts|cent(?:s|imes)?|pf|pfennig|kr|kop|kopecks?|ore|öre|"
    r"fr|franc|centavos?|centesimi|groschen|para|reis|réis|mills?|sen|"
    r"annas?|paisa|pies|penny|pence|shillings?)\b", re.I)

def extract_denomination(title):
    m = DENOM_RE.search(title)
    if not m:
        # bare currency symbol forms: $1, £2, 5¢
        m2 = re.search(r"([$£¢])\s?(\d{1,4}(?:[.,]\d{1,2})?)", title)
        if m2:
            return f"{m2.group(1)}{m2.group(2)}"
        return None
    return f"{m.group(1)}{m.group(2).lower()}"

def main(paths=None):
    paths = paths or ["deep_records.json","deep_full_records.json","deep_under_records.json"]
    # Merge all harvest files, dedup by pageid (a page in two files is loaded once).
    by_pid = {}
    for p in paths:
        try:
            for r in json.load(open(p)):
                by_pid[r["pageid"]] = r
        except FileNotFoundError:
            print(f"  (skip missing {p})")
    recs = list(by_pid.values())

    out = ["-- 006_commons_stamps.sql  (deep harvest, supersedes shallow load)",
           "-- GENERATED. Image-tier corpus from Wikimedia Commons, reusable licenses only.",
           "-- Regenerate: python3 deep_harvest*.py && python3 load_deep.py <files...>",
           f"-- Records: {len(recs)}", "BEGIN;", ""]

    BATCH = 1000   # multi-row VALUES batches; a single 90K-row UNION blows max_stack_depth

    # --- stamps: issuer_id is known directly, so a plain VALUES insert works ---
    def stamp_val(r):
        sid = f"SID-CMN-{r['pageid']}"
        y = r.get("year")
        issue_date = f"'{y}-01-01'::date" if y else "NULL"
        year_txt = sq(str(y)) if y else "NULL"
        year_val = str(y) if y else "NULL"
        denom = extract_denomination(r["title"])
        page = f"https://commons.wikimedia.org/?curid={r['pageid']}"
        return (f"({sq(sid)}, {int(r['issuer_id'])}, {issue_date}, {year_val}, {year_txt}, "
                f"{sq(denom)}, {sq(clean_subject(r['title']))}, 'scraped'::data_source_tier, "
                f"'pending'::review_status, {sq(page)}, 0.4)")

    cols = ("stamp_id, issuer_id, issue_date, issue_year, issue_date_text, "
            "denomination_text, subject, source_tier, review_status, source_url, confidence")
    for i in range(0, len(recs), BATCH):
        chunk = recs[i:i+BATCH]
        out.append(f"INSERT INTO stamps ({cols}) VALUES")
        out.append(",\n".join(stamp_val(r) for r in chunk))
        out.append("ON CONFLICT (stamp_id) DO NOTHING;\n")

    # --- images: need stamps.id (serial), so JOIN a VALUES list on the text stamp_id ---
    def img_val(r):
        sid = f"SID-CMN-{r['pageid']}"
        s3 = f"commons/{r['pageid']}"
        page = f"https://commons.wikimedia.org/?curid={r['pageid']}"
        w = r["width"] if r.get("width") else "NULL"
        h = r["height"] if r.get("height") else "NULL"
        return (f"({sq(sid)}, {sq(s3)}, {sq(r['url'])}, {w}, {h}, "
                f"{sq(r['mime'])}, {sq(page)}, {sq(r['license'])})")

    for i in range(0, len(recs), BATCH):
        chunk = recs[i:i+BATCH]
        out.append("INSERT INTO stamp_images (stamp_id, s3_key, cdn_url, image_type,")
        out.append("  width_px, height_px, mime_type, is_primary, source_url, licence)")
        out.append("SELECT s.id, v.s3, v.url, 'front', v.w, v.h, v.mime, TRUE, v.page, v.lic")
        out.append("FROM (VALUES")
        out.append(",\n".join(img_val(r) for r in chunk))
        out.append(") AS v(sid, s3, url, w, h, mime, page, lic)")
        out.append("JOIN stamps s ON s.stamp_id = v.sid")
        out.append("ON CONFLICT (s3_key) DO NOTHING;\n")

    out.append("COMMIT;")
    open("006_commons_stamps.sql", "w").write("\n".join(out))
    print(f"wrote 006_commons_stamps.sql: {len(recs)} deduped records ({BATCH}-row batches)")

if __name__ == "__main__":
    main(sys.argv[1:] if len(sys.argv) > 1 else ["deep_records.json"])
