# Corpus Status — What's Actually in the Library
**Updated:** 18 July 2026
**Verified against:** PostgreSQL 16.14, full schema (001→006) applied to an empty database.

---

## Size today

| Layer | Count |
|---|---|
| **Stamp records** | **132,327** |
| Stamp images | 132,327 (one per record; 0 without an image) |
| …with a known year | 105,250 (80%) |
| …with a denomination | 7,607 |
| **Countries covered** | **201 of 218** modern countries |
| Distinct issuers with stamps | 216 |
| Issuing entities (succession spine) | 1,181 |
| Succession edges | 406 · Search aliases | 1,093 |

Integrity: **0 stamps without an issuer, 0 without an image.** Full-text search, the succession
graph, and aliases all work over the real rows. Visual coverage report: `docs/coverage.html`;
per-country numbers in `docs/data/world-coverage.txt` / `.json`.

This is a **23× leap in one session** (5,820 → 132,327), clearing the 100K target, with coverage
of **201 of 218** countries.

### ⚠️ One image can belong to several countries — the DB flattens this

A French Indochina stamp is filed on Commons under **Cambodia, Laos and Vietnam** alike, and
that is philatelically correct. The coverage report counts these **many-to-many** (distinct
`(image, country)` pairs). The `stamps` table does **not**: it stores one row per image with a
single `issuer_id`, so a shared image is attributed to whichever country the merge saw last.
That is why Cambodia briefly showed zero despite having 440 images — Laos had taken them all.
**Proper fix: a `stamp_issuers` join table.** Until then, treat per-country counts in the
database as approximate for shared colonial issues.

---

## How it was built

Wikimedia Commons, harvested via the MediaWiki API in three passes, all reusable-licence only,
deduped by Commons pageid:

0. **`probe_zeros.py`** — probes Commons name variants for countries showing zero, since most
   gaps are naming misses ("Stamps of Malaysia" was never tried), not missing data. Found
   categories for **82 of 95**.
1. **`deep_harvest.py`** — 162 countries, year-category descent (fast).
2. **`deep_harvest_full.py`** — 21 large countries the enumeration first *missed* (US, Germany,
   Russia, China, Switzerland…), full-depth walk.
3. **the underperformers** — 32 countries that the fast pass under-counted because they file
   stamps by series/subject rather than year (France gave 658 year-only vs 8,000 full-depth).

`load_deep.py` merges the three, extracts year + denomination from filenames, and emits
`006_commons_stamps.sql` in 1000-row batches (a single 116K-row `UNION` blows Postgres's
`max_stack_depth` — found by a scale test before the real load). Reproduce end to end:

```bash
cd scripts
python3 deep_harvest.py && python3 deep_harvest_full.py && python3 deep_harvest_under.py
python3 load_deep.py deep_records.json deep_full_records.json deep_under_records.json
```

The 41 MB merged records JSON and the 60 MB generated SQL are **gitignored** (regenerable);
the scripts and the compact coverage summaries are committed.

---

## What this data IS — and is NOT

**Image-tier, not catalogue-tier.** Every record: `source_tier=scraped`, `review_status=pending`,
`confidence=0.4`. It has issuer, year (77%), denomination (6%), a real image URL, and a
verified-reusable licence. It does **not** have catalogue numbers (Scott/SG/Michel), and it
carries the usual Commons noise: covers, full sheets, duplicates (several images of one stamp),
and the occasional miscategorised file. **So 115,987 *records* is not 115,987 *distinct
catalogued stamps*** — the true distinct count is lower. These are a training/image corpus and
a structural spine, and must pass review before being treated as catalogue truth.

**Licensing is clean** — only Public Domain / CC0 / CC-BY(-SA) files were kept, tracked per
image in `stamp_images.licence`.

**Known coverage gaps** (now 17, down from 95): Commons holds no reusable-licensed stamp
images for them: mostly modern issuers whose designs are still in copyright (Hong Kong, Jersey,
Guernsey, the Faroes, Aruba) plus recent or very small states (South Sudan, Timor-Leste, Tuvalu,
Micronesia). These need a **different source**, not a deeper crawl. A few big countries remain
under-counted (the UK sits at 362, year-only) and would jump with a full-depth pass.

---

## This does NOT change the "beyond a million" ceiling

Commons is now largely tapped at ~115K reusable records. The million-record catalogue is still
an **acquisition decision** — licence Colnect (~1.4M; draft enquiry in
`docs/colnect-licensing-email.md`) or take a scraping position that runs into the Scott
numbering-rights question. See `corpus-sourcing.md`. What this session bought:

1. **A real, structured corpus** — 116K records keyed to issuers and the succession graph,
   proven end to end.
2. **A legally-clean training set** for the embedding model — ~90K dated, labelled images.
3. **A repeatable ingestion pipeline** any future source (Smithsonian NPM ≈ 8.8K images was
   confirmed available) can reuse.

## Next to grow it further

1. Fill the 95 zero countries (naming-variant harvest) and full-depth the under-counted big ones.
2. Add Smithsonian NPM (CC0, ~8.8K) via the same loader shape.
3. Deduplicate to a true distinct-stamp count (perceptual hash / title clustering).
4. The real catalogue jump still waits on the licensing decision.
