# Corpus Sourcing — Where 1M+ Records Can Actually Come From
**Date:** 17 July 2026
**Method:** deep research (5 angles → 22 sources → 84 claims → 25 adversarially verified,
3 independent refutation votes each). 15 confirmed, 5 refuted, 5 unverified (the session hit
its limit mid-verification; synthesis never ran — this file is the human synthesis).
**Companion:** `corpus-measurements.md` (first-hand endpoint measurements).

---

## 1. The 5–15M target does not survive. The ceiling is ~1.5M.

`CLAUDE.md` targets **5–15M records** and calls Colnect's 1.6M the number to beat. Measured
against the field:

| Catalogue | Records | Source |
|---|---|---|
| **Colnect** | **1,432,751** stamps (table updated 2024-05-29) | [Wikipedia: Stamp catalog](https://en.wikipedia.org/wiki/Stamp_catalog) |
| Colnect (self-reported) | "1.6M+" — community-contributed, includes varieties | [blog.colnect.com](https://blog.colnect.com/) |
| **StampWorld** | **840,739** — free, with values | [Wikipedia: Stamp catalog](https://en.wikipedia.org/wiki/Stamp_catalog) |
| **StampData** | **748,921** stamp types — free, *without* values | [Wikipedia: Stamp catalog](https://en.wikipedia.org/wiki/Stamp_catalog) |
| **UPU WNS** | **124,354** registered stamps | [wnsstamps.post](https://www.wnsstamps.post/en/about-wns) |
| Michel | **no total published anywhere** | [Wikipedia: Michel catalogue](https://en.wikipedia.org/wiki/Michel_catalogue) |

**Verdict on the two internal claims:**

- **(a) "Colnect ~1.6M"** — *substantially supported*, as Colnect's own self-report. The
  independent figure is **1.43M** (May 2024). The gap is growth plus self-reporting. Treat
  **~1.4–1.6M** as the real number, and note it already **includes community-contributed
  varieties**, not just distinct issues.
- **(b) "5–15M achievable"** — ❌ **not supported by any evidence found.** No catalogue in
  existence approaches 5M. The largest thing humans have ever assembled is Colnect at ~1.5M,
  built by a community over two decades. A "5–15M item universe" would require counting every
  perforation/watermark/shade permutation — and even then nobody has demonstrated it.
- ⚠️ The Michel "850,000 stamps" figure in Phase 1 was **refuted 0-3**. Michel publishes no
  total. That number appears to have been invented, like the Wikidata 100K and `stampscan.app`.

### What this means strategically — read this before the crawler

**"Beyond a million" is not a milestone on the way to 15M. It is ~70% of the entire known
universe of catalogued stamps, and it puts us level with Colnect** — a community that has been
at this for twenty years. The moat framing in `CLAUDE.md` ("5–15M vs Colnect's 1.6M — no
competitor matches") is not achievable as stated.

That is not fatal, but it changes the strategy: we cannot win on **record count**. Colnect has
effectively already collected the universe. What is still winnable, per
`competitors-2026.md`: **cross-catalogue StampID, consistency, and trustworthy
condition-aware valuations.** Those are quality and structure plays, not volume plays.

> **Major vs minor numbers matter for any count we quote.** Scott uses two tiers — major
> listings (larger type) and minor listings — and *capital*-letter suffixes (16A) are **major**
> numbers, while *lowercase* suffixes (16a) are varieties. A naive parser treating any letter
> suffix as a variety **will misclassify major issues**.
> ([Scott/Amos](https://www.amosadvantage.com/stamp-guides/understanding-the-scott-catalogue-listings), 3-0)

---

## 2. Source-by-source: what is actually obtainable

| Source | Volume | Access | Licence position |
|---|---|---|---|
| **Colnect CAPI** | ~1.4–1.6M | API, **prior written permission required**, scoped to a declared purpose, **revocable at Colnect's discretion** | 🔑 Commercial licence — negotiate |
| **StampWorld** | 840,739 | Website; no documented API | 🔑 Terms unverified — scrape risk |
| **StampData** | 748,921 | Website; no documented API | 🔑 Terms unverified — no valuations |
| **Michel** | Unpublished | **Consumer subscription only** — €23.90 / €28.90 / €32.90 per month, plus prepaid credits. **No API, no bulk export, no data licence advertised.** (3-0) | 🔑 No programmatic route exists |
| **Scott / Scott Stamp LLC** | Unpublished | No public API | 🚨 See the numbering-rights question |
| **UPU WNS** | **124,354** (3-0) | Website | ❌ **Images not reusable** — designs remain the property of issuing postal authorities; permission covers display *on the WNS site only* (3-0) |
| **Wikimedia Commons — SDC** | ~50K+ images (measured) | **Wikibase API + SPARQL**, machine-readable by design (3-0) | ✅ **Structured data is CC0** — ingestible into a proprietary DB with no attribution obligation. Images carry their own separate licences (3-0) |
| **Smithsonian Open Access** | 11M+ records **across all units**; NPM (postal museum) included. **Per-unit stamp count unverified.** | **Bulk download** (S3 metadata dump) | ⚠️ The "CC0, no licence needed" claim was **refuted 0-3** — verify terms before ingesting |
| **Wikidata** | 12,753 (78 images) | SPARQL | ❌ Refuted — see `corpus-measurements.md` |

### The honest ranked path to 1M+

1. **Licence Colnect.** It is the only asset that gets to ~1.4M, and it exists today. Access
   needs prior written permission and stays revocable — so this is a **relationship**, not an
   integration. Everything else is a rounding error next to it.
2. **Structured Data on Commons (CC0)** — free, unblocked, legally clean, and the only source
   in the list we can ingest today without asking anyone. Tens of thousands of records, not
   hundreds. Best used for **images and weak labels**, not catalogue coverage.
3. **Smithsonian NPM bulk** — verify licence terms first (the CC0 claim did not survive).
4. **StampWorld / StampData (~840K / ~749K)** — large and free to *read*, but terms are
   unverified and scraping them collides with the catalogue-numbering question.
5. **UPU WNS (124K)** — authoritative for modern issues, useless for volume, and **images
   cannot be redistributed**. Value it as an authority-control cross-check, not a seed.

**Nothing free gets past ~100K.** Every path to 1M+ runs through a licence or a scrape. This
is an acquisition problem, not an engineering problem — the same conclusion the Scott question
reaches from the other direction.

---

## 3. Country succession — the sources that make it buildable

This is the one area where the free sources are genuinely strong, which is why it is being
built first (see `005_succession_seed.sql`).

| Source | What it gives |
|---|---|
| [**Wikipedia: List of entities that have issued postage stamps**](https://en.wikipedia.org/wiki/List_of_entities_that_have_issued_postage_stamps_(A%E2%80%93E)) (A–E, F–L, M–Z) | The master index — *"any kind of governmental entity or officially approved organisation that has issued distinctive postage stamps"*, explicitly including the defunct entities philatelists call **"dead countries"** |
| [**StampWorldHistory**](https://stampworldhistory.nl/stamps-issuing-entities/) | Exactly the fields a succession graph needs: entity, continent, **active issuing period**, **line of succession**, and which of the four major catalogues lists it |
| [**DCStamps**](https://www.dcstamps.com/list-of-dead-countries/) | **650+ defunct issuing entities** — the dead-country universe is in the high hundreds, not dozens. Self-described as incomplete |
| [**Mystic Stamp identifier**](https://info.mysticstamp.com/learn/foreign-stamp-identifier/) | Inscription → country index: the alias seed |
| [**Wikibooks Stamp Identifier**](https://en.wikibooks.org/wiki/World_Stamp_Catalogue/Stamp_Identifier) | Vernacular mappings — Helvetia→Switzerland, CCCP→USSR, Nippon→Japan, Siam→Thailand, Rhodesia→Zimbabwe, Ceylon→Sri Lanka, Danzig→Poland |

**Scale check: 650+ defunct entities.** `004_succession_schema.sql` currently seeds **four**
lineages. The gap between the schema and the data is the work.

---

## Unverified — the session limit killed these before a verdict

Do not treat as settled:

- Scott catalogue numbers are copyrighted with only limited third-party licences (3 votes
  errored). **This is the gating legal question and it remains formally unverified here** —
  though it was independently corroborated earlier; see `competitors-2026.md`.
- Scott's major-vs-minor suffix convention (lowercase = variety).
- Michel and Scott have materially different country coverage (Michel lists Cuba, Iraq, North
  Korea where Scott omits them) — meaning **no single catalogue is the full corpus** and totals
  are not directly comparable.
- Michel includes "wallpaper" / non-postal issues, inflating its count against a strict
  definition of "distinct postage stamps actually issued".
