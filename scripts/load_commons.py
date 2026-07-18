#!/usr/bin/env python3
"""Turn commons_records.json into 006_commons_stamps.sql.

Emits stamps + stamp_images rows. Honest about provenance:
  - source_tier = 'scraped'  (image-tier, not catalogue-tier)
  - review_status = 'pending'
  - confidence = 0.4  (country+year is reliable; everything else is absent)
  - source_url points back to the Commons file; the image licence is carried per row.

Idempotent: keyed on stamp_id (stamps) and s3_key (stamp_images), ON CONFLICT DO NOTHING.
Issuer is resolved by name at load time, so a record whose issuer is missing is skipped by
the INSERT rather than aborting the batch.
"""
import json

def sq(s):
    if s is None: return "NULL"
    return "'" + str(s).replace("'", "''") + "'"

def main():
    recs = json.load(open("commons_records.json"))
    out = ["-- 006_commons_stamps.sql",
           "-- GENERATED from Wikimedia Commons. Image-tier corpus, not catalogue-tier.",
           "-- Regenerate: python3 ingest_commons.py <cap> && python3 load_commons.py",
           f"-- Records: {len(recs)}",
           "BEGIN;", ""]

    # stamps
    out.append("INSERT INTO stamps (stamp_id, issuer_id, issue_date, issue_year, issue_date_text,")
    out.append("  subject, source_tier, review_status, source_url, confidence)")
    rows = []
    for r in recs:
        commons_page = f"https://commons.wikimedia.org/?curid={r['pageid']}"
        issue_date = sq(f"{r['year']}-01-01")
        rows.append(
            f"SELECT {sq(r['stamp_id'])}, i.id, {issue_date}::date, {r['year']}, {sq(str(r['year']))}, "
            f"{sq(r['subject'])}, 'scraped'::data_source_tier, 'pending'::review_status, {sq(commons_page)}, 0.4 "
            f"FROM issuers i WHERE i.name = {sq(r['issuer'])}"
        )
    out.append("\nUNION ALL\n".join(rows))
    out.append("ON CONFLICT (stamp_id) DO NOTHING;")
    out.append("")

    # stamp_images — linked back to the stamp by stamp_id
    out.append("INSERT INTO stamp_images (stamp_id, s3_key, cdn_url, image_type,")
    out.append("  width_px, height_px, mime_type, is_primary, source_url, licence)")
    irows = []
    for r in recs:
        s3_key = f"commons/{r['pageid']}"
        commons_page = f"https://commons.wikimedia.org/?curid={r['pageid']}"
        w = r['width'] if r['width'] else "NULL"
        h = r['height'] if r['height'] else "NULL"
        irows.append(
            f"SELECT s.id, {sq(s3_key)}, {sq(r['url'])}, 'front', {w}, {h}, "
            f"{sq(r['mime'])}, TRUE, {sq(commons_page)}, {sq(r['license'])} "
            f"FROM stamps s WHERE s.stamp_id = {sq(r['stamp_id'])}"
        )
    out.append("\nUNION ALL\n".join(irows))
    out.append("ON CONFLICT (s3_key) DO NOTHING;")
    out.append("")
    out.append("COMMIT;")

    open("006_commons_stamps.sql", "w").write("\n".join(out))
    print(f"wrote 006_commons_stamps.sql ({len(recs)} stamps + images)")

if __name__ == "__main__":
    main()
