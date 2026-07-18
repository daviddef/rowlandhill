# Corpus Status — What's Actually in the Library
**Date:** 18 July 2026
**Verified against:** PostgreSQL 16.14, full schema (001→006) applied to an empty database.

---

## Size today

| Layer | Count | Notes |
|---|---|---|
| **Stamp records** | **5,820** | First real data. Was 0. |
| Stamp images | 5,820 | One per record; every stamp has an image |
| Issuing entities | 1,181 | The succession spine (879 dead countries) |
| Succession edges | 406 | Verified lineage graph |
| Search aliases | 1,093 | CCCP→USSR, Rhodesia→lineage, vernacular names |

Integrity checks pass: **0 stamps without an issuer, 0 without an image.** The full-text
index works on the real rows; the succession graph and aliases are unchanged.

By issuer (17 countries seeded): USA 1000, Germany 1000, Finland 1000 (all hit the per-country
cap — more is available), Italy 405, Austria 363, France 339, Great Britain 317, Japan 258,
Australia 252, Norway 174, Canada 165, Switzerland 160, Sweden 159, Denmark 115, New Zealand 71,
Spain 36, Belgium 6. Coverage runs 1840 (Penny Black era) to present.

---

## What this data IS — and what it is NOT

**Source:** Wikimedia Commons, harvested via the MediaWiki API from `Stamps of {country} by
year` category trees. Reproducible: `scripts/ingest_commons.py <cap>` →
`docs/data/commons-stamp-records.json` → `scripts/load_commons.py` → `006_commons_stamps.sql`.

**It is image-tier, not catalogue-tier.** Every record carries `source_tier = 'scraped'`,
`review_status = 'pending'`, `confidence = 0.4`. It has:
- ✅ issuer, year, a real image URL, and a verified-reusable license
- ❌ no catalogue numbers (Scott/SG/Michel), no denomination-as-data, no perforation/watermark

**Licensing is clean.** Only reusable licenses were kept: 5,243 Public Domain, 313 CC0, plus
CC-BY / CC-BY-SA. Commons *structured* metadata is CC0; the image files carry their own PD/CC
license, tracked per row in `stamp_images.licence`. Nothing else was ingested.

**Known noise (why `confidence 0.4` and `pending` matter):** Commons stamp categories include
covers, full sheets, and the occasional miscategorised file (e.g. a "Die Gartenlaube" magazine
illustration surfaced under 1840 GB stamps). There are also **duplicates** — several images of
the same stamp count as several records. So 5,820 *records* is **not** 5,820 *distinct catalogued
stamps*; the true distinct count is lower. These records are a **training/image corpus and a
pipeline proof**, not a verified catalogue. They must pass human review before being treated as
catalogue truth.

---

## What this does and does not change about "beyond a million"

It does **not** move the ceiling. Commons holds ~50K stamp images total (measured, see
`corpus-measurements.md`); harvesting all 17 seeded countries harder gets to low tens of
thousands, not a million. The million-record catalogue remains an **acquisition decision** —
license Colnect (~1.4M) or take a scraping position that runs into the Scott numbering-rights
question. See `corpus-sourcing.md`.

What it **does** give:
1. **The first real data** — the schema now holds stamps, proven end to end (stamp → issuer →
   image → license → full-text search).
2. **A legally-clean training corpus** for the embedding model — 5,820 labelled images (country,
   year), 5× the MiikeMineStamps bootstrap set, and it scales to ~50K by raising the cap.
3. **A working, repeatable ingestion pipeline** any future source can reuse.

---

## Schema bug found while loading

`Stamp.swift` maps `issueYear → "issue_year"`, but the `stamps` table had **no `issue_year`
column** — the API would have failed decoding a stamp. Added `issue_year SMALLINT` to
`001_core_schema.sql` (a real column, not generated: a stamp often has a known year but an
uncertain full date). The loader populates it. This is the fourth "done" schema element that
did not survive contact with a running database.

---

## Next to grow the corpus

1. **Raise the cap / add countries** — the pipeline scales to Commons' full ~50K immediately;
   US, Germany and Finland are capped now.
2. **Deduplicate** — collapse multiple images of one stamp (perceptual hash or title
   normalisation) to get a true distinct-stamp count.
3. **Filter non-stamps** — covers, sheets and miscategorised files inflate the count.
4. **The real catalogue** still needs the licensing decision — this corpus is the foundation
   and the model's training set, not a substitute for it.
