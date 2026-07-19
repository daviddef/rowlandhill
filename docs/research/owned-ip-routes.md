# Owned Catalogue-Tier IP: Routes That Do Not Licence Colnect, Scott, SG or Michel

Research date: 2026-07-20. All volume and cost figures are estimates with the derivation shown.
Nothing here is legal advice; items marked **[COUNSEL]** need a lawyer before money is spent.

---

## 0. Framing: what "catalogue tier" actually decomposes into

Rowland has ~132k images with issuer + year. The gap is not one dataset, it is four, and they
have very different legal characters. Conflating them is the main way this project goes wrong.

| Layer | Example | Legal character (US) | Where it can come from |
|---|---|---|---|
| **Descriptive facts** | denomination, colour, date of issue, perforation, watermark, printer, designer, print run | Facts. Not copyrightable under *Feist*. A compilation of them can be, but only as to selection/arrangement. | PD catalogues, postal bulletins, WNS, crowd |
| **Identifiers** | "Scott 231", "SG 12a", "Mi 45" | Contested — see §1.4 | PD editions, or own system |
| **Varieties / taxonomy** | "type II, re-entry, inverted centre" | The *classification scheme* is closer to ADA v. Delta Dental territory; the existence of the variety is a fact | PD catalogues, expert crowd |
| **Values / prices** | catalogue value, realised price | **Catalogue values are probably protected** (*CDN v. Kapes*, *CCC v. Maclean Hunter*). **Realised auction prices are hard facts and are not.** | Auction archives only |

The single most useful reframing: **Rowland should not try to reproduce Scott. It should build
the fact layer + the realised-price layer, keyed by its own identifier, with catalogue numbers
carried only as *cross-reference* where legally safe.** That is a defensible, ownable asset and
it is a *different* product from Scott, not a knock-off of it.

---

## 1. Public-domain catalogue extraction

### 1.1 What is actually scanned and downloadable — verified

US copyright term: works published **1930 and earlier** are in the US public domain as of
1 January 2026. That is the operative line, not 1923 and not 1928.

Confirmed on Internet Archive by querying the advancedsearch API and the per-item metadata
endpoint (checked `access-restricted-item`, which is **absent** on the key items, meaning full
open download, not lending):

| archive.org identifier | Edition | Pages | Status |
|---|---|---|---|
| `bwb_S0-DUL-160` | **Scott 1931** (published autumn 1930) | 1,976 | open, no access restriction |
| `bwb_S0-DUL-172` | **Scott 1928** | 1,812 | open, no access restriction — **verified via `/metadata`: no `access-restricted-item`, collection `internetarchivebooks`, publicdate 2025-07-07** |
| `scottsstandardpo0000john_y0k4` | Scott 1927 (Luff / Clark) | 1,812 | open |
| `bwb_S0-DUL-156` | Scott 1926 | 1,684 | open |
| `bwb_S0-DUL-159` | Scott 1925 | 1,574 | open |
| `bwb_S0-DUL-164` | Scott 1920 | 1,308 | open |
| `bwb_S0-DUL-163` | Scott 1919 | 1,288 | open |
| `bwb_S0-DUL-154` | Scott 1916 | 1,150 | open |
| `bwb_S0-DUL-161` | Scott 1912 | 986 | open |
| `scottsstandardpo1917unse` | Scott 1917 (vol. 17), Univ. of Illinois scan | 1,260 | open; metadata explicitly states *"In public domain. Work published prior to 1923."* Tesseract 5.0 OCR, 99.55% script confidence |
| `scottsstandardpo00scot` | Scott (1897 series metadata date) | 1,542 | open; ABBYY FineReader 8.0 OCR + hOCR, scanned 2010 |
| `bwb_S0-DUL-155` | Scott 1914 | 1,104 | open |
| `standardpostages0000vari` | Standard Postage Stamp Cat. 1903 | 870 | open |

**The prize item is `bwb_S0-DUL-160` — the 1931 edition, 1,976 pages.** It is the latest edition
that is (almost certainly) US public domain, and being the latest it has the most stamps, the
most mature numbering, and the fewest subsequent renumberings between it and today.
**[COUNSEL] Verify the copyright notice date on the title page of `bwb_S0-DUL-160`.** Trade
catalogues dated for year N are typically published in the autumn of N−1 and bear a copyright
notice for N−1. If the notice reads 1930, it is PD. If it reads 1931, it is not, and you fall
back to `bwb_S0-DUL-172` (1928), which is unambiguously safe.

**Non-Scott catalogues are much worse served.** A systematic archive.org date-bounded query for
1918–1931 returned *nine* items, all Scott. There is:
- **Stanley Gibbons**: `pricedcatalogueo00stan` and `pricedcatalogue00ltdgoog` (a Google/Univ.
  of Michigan scan) exist and are open, but these are early *British Empire* volumes, not the
  full worldwide catalogue, and the editions are considerably older than 1930. HathiTrust record
  `006847227` exists for the SG priced catalogue series — HathiTrust for pre-1930 US-published
  works is full-view, but SG is UK-published, so HathiTrust will more likely serve it
  search-only. Treat SG as a supplement, not a spine.
- **Yvert et Tellier**: `cataloguedetimbr0001yver` exists (France + general colonies, ~960pp).
  First Yvert edition was 1896, 550pp. Coverage of the worldwide 1840–1930 universe from PD
  Yvert scans is poor. Gallica has not been shown to hold a usable run.
- **Michel**: no pre-1930 Michel scan located on archive.org. Michel is German-published;
  German copyright is life+70 of the author, which for a corporate trade catalogue is a mess.
  **Michel is a dead end for PD extraction.**

**Conclusion: this route is a Scott route, or it is nothing.** That is uncomfortable, because
Scott is precisely the party most likely to object (§1.4).

### 1.2 Volume this actually yields

Anchors found:
- ~**57,000** regular issues worldwide 1840–1928, excluding minor varieties and revenues
  (Uihlein collection estimate).
- ~**91,000** stamps 1840–1940 per a four-month manual count against the 2007 Scott Classic
  Specialized, by a collector-blogger. The same source notes the Scott International Blue
  Album's 35,000 spaces represent ~40% of catalogued stamps of the era (→ ~87,500, consistent).
- Scott Classic Specialized covers **350+ stamp-issuing entities** for 1840–1940.

So the realistic yield from the 1931 Scott edition, at *major number* granularity:

> **~55,000–65,000 major catalogue entries covering ~330–360 issuing entities, 1840–1930.**

Each entry from a Scott listing carries roughly: country, year, Scott number, denomination,
colour, design/vignette description, perforation, watermark, and a catalogue value. Call it
7–9 populated fields per row. Against 132k images with 2 fields, that is a step change in
product quality for roughly *half* the image corpus (the pre-1930 half).

If you also want minor letter-suffix varieties, multiply by ~2.2–2.8 → 130k–180k rows. Do not
attempt this in v1; the OCR error rate on suffixed sub-entries is where extraction projects die.

Note the coverage mismatch: extraction gives you nothing for 1931–2026, which is where most of
the 132k images and nearly all consumer scanning demand actually sits. **This route fixes the
classic half of the catalogue and none of the modern half.** That is a real limitation, not a
footnote.

### 1.3 Scan quality and extraction cost

Quality is mixed and this is the operational risk.
- `scottsstandardpo00scot` was OCR'd with **ABBYY FineReader 8.0** — a 2005-era engine — and
  ships hOCR with per-word confidence. Usable as a positional scaffold.
- `scottsstandardpo1917unse` used **Tesseract 5.0.0**, modern, with high reported confidence.
- The `bwb_*` items are Better World Books donor scans, generally 300–400 dpi, quality varies
  page to page.

The hard part is not character accuracy, it is **structure**. Scott listings are dense
multi-column tables with hanging indents, inherited context (a country header governs 40 pages;
a "Perf. 12" line governs the next 15 entries), tiny illustrations interleaved, and heavy use of
ditto conventions. Flat OCR text of these pages is close to useless. You need page-image →
layout-aware extraction.

**Concrete cost model** for the 1,976-page 1931 edition:
- Page images at ~2–3 MP, sent to a vision LLM with a strict JSON schema, two passes
  (extract + self-check), ~4k input / 2k output tokens per page equivalent.
- At current frontier-model pricing this lands around **$0.05–$0.12 per page per pass**.
  1,976 pages × 2 passes ≈ **$200–$475 in inference.** Even at 5× for retries and prompt
  iteration, **under $2,500.**
- Human review is the real cost. Assume 100% review of country headers and section rules
  (~400 pages of consequence) and 10% spot-audit of entries. A competent philatelic
  proofreader at ~$25/hr doing ~60 entries/hr for review of ~6,000 sampled entries ≈ 100 hrs
  ≈ **$2,500**. Full 100% human verification of 60,000 entries would be ~1,000 hrs ≈ **$25,000**
  — do not do that up front.
- Engineering: one competent person, **6–10 weeks** to a validated pipeline plus reconciliation
  against the existing 132k images.

> **Total realistic: $5,000–$15,000 and 2–3 months to ~60,000 verified-enough rows.**
> That is by far the cheapest catalogue-tier data per row of any route here — roughly
> **$0.10–$0.25 per catalogue entry.** Colnect's €100/mo = €1,200/yr buys zero owned rows.

Cross-validation is cheap and should be built in: the 1928 and 1931 editions can be extracted
independently and diffed. Agreement between two editions is strong evidence of correct
extraction; disagreement flags a row for human review. That is a much better QA signal than
confidence scores.

### 1.4 The number-stability question — **this is where the route gets damaged**

The premise "classic-period numbering has been broadly stable" is **only partly true, and the
exception is severe.**

Hard evidence found: **Scott performed a wholesale renumbering in the 96th edition, published
1940.** That edition introduced the present prefix/suffix system — B for semi-postals, C for
airmail, J for postage due, O for officials — and *"renumbered all back-of-the-book stamps
discretely to their own groups."*

And renumbering before that was chronic. A single documented example, the 1¢ Department of
Agriculture official:

| Edition | Number |
|---|---|
| 48th ed. | 501 |
| 52nd ed. | 801 |
| 1900 ed. | 593 |
| 1915 ed. | 500 |
| 1920–1939 | 1500 |
| 1940 onward | **O1** (current) |

This is decisive for scoping:

- **Back-of-the-book (airmails, semi-postals, postage dues, officials, specials, revenues) from
  a pre-1930 edition is WORTHLESS as a source of modern Scott numbers.** Every number in those
  sections was reassigned in 1940. Extracting them and shipping them as "Scott numbers" would
  be actively wrong and would generate user-visible errors that destroy trust faster than having
  no number at all.
- **Regular postage major numbers for the classic period are substantially more stable** —
  US regular issues have carried recognisably continuous numbering since the early 1900s, and
  the 1940 reorganisation was aimed at BOB rather than at ordinary postage. But "substantially
  stable" is not "identical", and no source found asserts one-to-one identity.

**Therefore: you cannot ship extracted numbers as "Scott numbers" without validation.** What you
*can* do, and what makes this route work:

1. Extract from the 1931 edition into **your own identifier space** (StampID). The *facts* —
   country, year, denomination, colour, design, perf, watermark — are unambiguously facts, are
   PD-sourced, are correct regardless of renumbering, and are the bulk of the value.
2. Treat the extracted 1931 Scott number as a **provisional cross-reference field**, clearly
   scoped to regular postage, explicitly flagged in the schema as "Scott 1931 ed.", and
   validated against a modern source before it is ever surfaced as a current Scott number.
3. Validate cheaply by **triangulation against auction data (§3)**. Siegel and other houses
   publish lot descriptions carrying *modern* Scott numbers alongside descriptions containing
   the same facts you extracted. Matching on (country, year, denomination, colour) gives you a
   1931-number → modern-number mapping, empirically derived, for exactly the stamps the market
   cares about. This is the single highest-leverage idea in this document: **§1 and §3 are
   worth more combined than either is alone.**

### 1.5 The Scott copyright-in-numbering question — **[COUNSEL], flagged not resolved**

Scott asserts copyright in its numbering system and licenses it only narrowly. There is a real
litigation history: **Scott sued Krause Publications (Minkus catalogue) over use of Scott
numbers. Krause filed a defence and the suit settled out of court**; as part of the settlement
Minkus was permitted to publish a separately-available Minkus↔Scott cross-reference, and Krause
continued referencing Scott numbers. So Scott has never won a judgment on the point — but it has
demonstrated willingness to sue, and it obtained a settlement that shaped a competitor's product.

The doctrinal landscape is genuinely split, and counsel should be given both sides:

**Arguments that the numbers are NOT protectable:**
- *Feist Publications v. Rural Telephone* (US 1991) — facts are not copyrightable; "sweat of
  the brow" is rejected. Which stamp exists is a fact.
- ***Southco v. Kanebridge*, 390 F.3d 276 (3d Cir. 2004, en banc)** — Southco's nine-digit
  fastener part numbers held **not original** and therefore uncopyrightable: once the rule
  system is fixed, "there is only one possible part number" and assignment involves no
  creativity. Scott numbers for regular postage are largely mechanical: chronological order of
  issue within a country. That is close to Southco.
- ***ATC Distribution Group v. Whatever It Takes Transmissions & Parts*, 402 F.3d 700
  (6th Cir. 2005)** — transmission parts numbering likewise held uncopyrightable.
- Copyright does not protect a *system* (17 U.S.C. §102(b); *Baker v. Selden*).
- The number of an individual stamp, used as a reference, is a short unoriginal expression;
  the merger and *scènes à faire* doctrines cut further against protection.

**Arguments that Scott has a real claim:**
- ***American Dental Association v. Delta Dental Plans Ass'n*, 126 F.3d 977 (7th Cir. 1997,
  Easterbrook, J.)** — the ADA's dental procedure **taxonomy** (five-digit code + short
  description + long description) held **copyrightable**; assigning a number to a procedure
  involved "at least a modicum of creativity." Scott's catalogue is far more like a taxonomy
  than like Southco's mechanical fastener grammar: Scott makes *editorial judgments* about
  what counts as a separate major listing versus a lettered minor variety, how to group issues,
  where a set begins and ends. Those judgments are arguably creative, and the numbers encode
  them.
- ***CDN Inc. v. Kapes*, 197 F.3d 1256 (9th Cir. 1999)** and ***CCC Information Services v.
  Maclean Hunter Market Reports*, 44 F.3d 61 (2d Cir. 1994)** — wholesale coin prices and
  used-car valuations respectively held **copyrightable**, because the publisher exercises
  judgment to "distill and extrapolate from factual data" to produce an opinion of value.
  **This is a direct hit on catalogue values.** It does not touch numbers, but it means
  **you must not extract Scott's catalogue values, even from a PD edition, as a basis for
  modern valuations** — and honestly 1931 values are commercially useless anyway.
- The compilation as a whole (selection, arrangement, coordination) is protectable even where
  individual facts are not. Bulk-extracting the *entire structure* of a Scott edition looks
  more like copying the compilation than like taking facts.
- Circuit split means forum matters; there is no clean answer.

**Additional [COUNSEL] issues nobody usually raises and that matter here:**
- **PD status is jurisdictional.** The 1931 edition being US-PD says nothing about the UK, EU,
  or Australia. If Rowland ships to the EU, the **EU sui generis database right** (Directive
  96/9/EC) protects substantial extraction from a database irrespective of originality — a
  protection with no US analogue and one that *Feist* arguments do not answer. Given Rowland is
  an app on a global store, this is not hypothetical.
- **Trademark, separate from copyright.** "SCOTT" is a trademark. Even if the numbers are free,
  describing your data as "Scott numbers" in marketing or UI invites a trademark and false-
  designation claim. Nominative fair use is a defence but not a cheap one. Prefer neutral
  labelling ("catalogue ref., 1931 std. ed.").
- **Archive.org's own terms** are irrelevant to copyright but do impose access conditions; bulk
  downloading should be rate-limited and polite. Not a legal risk, an access risk.

**My honest read (not legal advice): the *facts* extracted from a 1930-or-earlier Scott edition
are on solid ground. The *numbers* are genuinely contested and the strongest posture is to not
need them — build on StampID, carry old numbers as internal cross-reference, and derive modern
numbers empirically from auction descriptions rather than from Scott's book.**

### 1.6 Verdict on route 1

**Strongest route. Do it. But scope it to facts, exclude back-of-the-book numbers, exclude
catalogue values, and get counsel on the 1931-vs-1928 title-page date and on EU database right
before spending.**

---

## 2. Crowdsourcing / user contribution

### 2.1 The bootstrap problem, stated honestly

Colnect was founded in **2002** as a phonecard database, added stamps only in **autumn 2008**,
and today runs on roughly **915 contributors and ~200 volunteer editors** across 43 collectable
types, having passed 300,000 items. That is **~18 years to get where it is, and ~16 years of
that with a live community.** Discogs launched in 2000 and by February 2001 had 1,943 releases
and **56 contributors**; its first million releases took **90 months**, and only later did
growth compound (10M → 11M releases in 9 months).

The lesson is unambiguous and it is the opposite of what founders want to hear: **contribution
volume is a function of audience size, and audience size is a function of the data already being
good.** Crowdsourcing does not solve a cold start. It compounds an existing one.

Rowland has ~132k images and presumably a small user base. Running the Discogs curve from a cold
start puts meaningful catalogue coverage **5–8 years out**. That is not a viable primary
strategy.

**But crowdsourcing is an excellent *second* strategy layered on route 1.** Once you have 60,000
PD-derived rows, the contributor task changes from "create an entry from nothing" (high effort,
low reward, few people can do it) to "confirm/correct this field" (seconds, gamifiable,
thousands of people can do it). Verification crowdsourcing has a bootstrap threshold perhaps an
order of magnitude lower than creation crowdsourcing. **iNaturalist** is the proof: its research-
grade pipeline works because the *observation* is contributed cheaply and the *identification*
is a low-friction confirm-or-correct action by others.

### 2.2 Incentive models that have actually worked

- **Discogs** — status/reputation plus, critically, **direct economic self-interest**: a good
  database entry is the thing you list your record for sale against. The marketplace pays for
  the database. **Rowland analogue: if Rowland ever lists or values collections, contributors
  who improve entries improve their own sale/insurance outcomes.** This is the strongest model
  and the only one with a natural economic loop.
- **BoardGameGeek** — pure reputation, "GeekGold" soft currency, deep forum culture. Took years.
- **MusicBrainz** — ideological/open-data motivation, small dedicated editor corps. Slow, high
  quality, and structurally unable to be a proprietary moat.
- **iNaturalist** — the contribution *is* the user's own record-keeping; curation is a byproduct.
  **Rowland analogue: the user is cataloguing their own collection anyway. Make the catalogue
  entry a byproduct of the user's private collection management.** This is the highest-fit model
  for a scanning app and it is the one to design for.

### 2.3 Ownership terms — the licence models that keep the moat

This is where most people get it wrong, so be precise:

- **Discogs releases its data as CC0** — public domain dedication, with bulk data dumps at
  data.discogs.com. **Discogs does not own its data as IP at all.** Its moat is the marketplace
  network, liquidity, and brand — not the database. Anyone who tells you "be like Discogs" is
  recommending you *give the data away*. That may still be the right strategy, but it is not the
  strategy the owner asked for.
- **MusicBrainz** — core data CC0, supplementary data CC BY-NC-SA. Same conclusion.
- **BoardGameGeek** — the model that *does* preserve platform position. Per BGG's ToS: **users
  retain ownership of their submissions but grant a broad non-exclusive licence** to BGG and to
  other users to use, reproduce, distribute, display and perform that content through the site;
  BGG's XML API has separate terms restricting commercial reuse. Users may select licences for
  uploaded images/files specifically.

**Recommended licence structure for Rowland** (draft for counsel):
- Contributors **retain ownership** of their contributions (this is what makes it acceptable —
  demanding assignment is the fastest way to alienate philatelic contributors, who are older,
  proprietary about their expertise, and remember Colnect disputes).
- Contributors grant Rowland a **perpetual, irrevocable, worldwide, royalty-free, sublicensable,
  non-exclusive licence** to use, modify, and commercialise the contribution in any medium.
  Perpetual + irrevocable + sublicensable is the operative combination; without all three,
  an acquirer's diligence will flag it.
- **Rowland separately owns the compilation, schema, StampID assignments, curation, and the
  derived database as a whole** — this is the actual asset and it is Rowland's original work,
  not the contributors'.
- **No CC0, no CC BY-SA on the database.** A share-alike licence anywhere in the stack is
  fatal to the moat.
- Explicit clause that facts contributed are not claimed as owned by anyone — this avoids the
  contributor thinking they have granted away something they did not have.
- **[COUNSEL]** on EU/UK contributors: moral rights waivers where waivable, and the sui generis
  database right should be assigned to Rowland (it is assignable and it vests in the *maker* of
  the database — which, structured correctly, is Rowland).

### 2.4 Verdict on route 2

**Necessary but not sufficient, and useless as a first move.** Build the contribution
infrastructure in parallel with route 1 but expect near-zero yield until the seed data exists.
Budget: ~4–6 weeks engineering for a confirm/correct flow, plus a lawyer-drafted contributor
agreement (~$2,000–$5,000). **Yield in year 1: realistically 5,000–20,000 field corrections,
not new entries.**

---

## 3. Auction house and dealer listing data

### 3.1 What exists

- **Robert A. Siegel Auction Galleries** — continuous stamp auctions since **1930**. Catalogues
  from **1996 onward plus selected older sales** are online with images. **"Power Search" lets
  you search by Scott number, grade, keyword, condition, sale and lot number.** Virtually all
  past catalogues are downloadable free as PDF **with prices realised.** This is the single
  richest structured philatelic price archive in the world and it is publicly accessible.
- **Heinrich Köhler** (founded 1913) — publishes prices realised online, and operates **ProFi
  (ProvenanceFinder)**, a database of known entries in auction catalogues worldwide *including
  prices realised*. Provenance-grade data for rarities.
- **Spink** — publishes prices realised at spink.com/auctions/prices.
- **philasearch.com** — an aggregator carrying Köhler, Spink, Corinphila and others, with an
  auction-results section. One integration point covering many houses.
- **Delcampe** — large marketplace, has an official **API Pass**, primarily positioned for
  sellers synchronising their own inventory rather than for bulk data extraction. Its General
  Terms and Conditions govern; the specific anti-scraping clauses were not confirmed in this
  research. **[COUNSEL] read the Delcampe charter before any automated access.**
- **eBay** — **effectively closed.** The Finding API is deprecated; sold/completed listing data
  now sits behind the **Marketplace Insights API**, which requires business-level partner
  approval, restricts you to an approved category list, and caps results at 10,000 items per
  call. Individual developers are routinely refused. **Treat eBay as unavailable.** Scraping it
  is a ToS breach and a bad look in acquisition diligence.

### 3.2 Why this is more valuable than it looks

Three reasons:

1. **Realised prices are hard facts.** Unlike Scott's *catalogue values* — which *CDN v. Kapes*
   and *CCC v. Maclean Hunter* suggest are protectable opinions of value — a hammer price is an
   event that occurred. Facts. This is the one price dataset Rowland can build without the
   copyright problem that guards the catalogue-value layer.
2. **It gives Rowland the two fields it has none of: PRICE and CONDITION.** Auction lot
   descriptions carry grade, centring, gum state, faults, certification, and provenance. No
   other route in this document delivers condition data at all.
3. **It is the validation key for route 1.** Siegel lots carry *modern* Scott numbers plus
   descriptive facts. Match those facts against your 1931-extracted rows and you empirically
   derive the 1931→modern number mapping, for free, exactly for the stamps that have market
   value. **This is the mechanism that de-risks §1.4.**

### 3.3 Volume and cost

Siegel has run sales since 1930 with online catalogues from 1996. At roughly 12–20 sales/year
since 1996 and 800–2,500 lots per sale:

> **~30 years × ~15 sales × ~1,200 lots ≈ 540,000 lot records from Siegel alone**, each with
> price realised, description, condition, and a modern Scott number. Deduplicated to distinct
> stamps this collapses to perhaps **25,000–50,000 distinct catalogue entries with real price
> history** — heavily weighted to US and to better material, which is precisely the material
> users photograph and ask "is this worth anything?"

Adding Köhler, Spink and philasearch extends coverage into Europe, Germany, and British
Commonwealth and probably doubles distinct-entry coverage.

Cost: engineering only. **4–8 weeks for a per-house ingestion pipeline plus entity resolution;
$0–$3,000 in infrastructure.** No licence fee. The PDFs are published free.

**[COUNSEL] on each house's terms of use before automated ingestion.** The prices are facts and
are not owned, but the *lot descriptions as written* are original expression, and a house's ToS
is a contract question separate from copyright. The safe design is: **ingest, extract structured
facts, discard the verbatim description text.** Store "1857 1c blue, type II, VF, PSE cert,
$4,200, Siegel sale 1093 lot 47" — do not store Siegel's prose.

### 3.4 Verdict on route 3

**Second-strongest route, and the highest-value-per-week-of-engineering. It is also the only
route that produces data Rowland's competitors mostly do not have.** Colnect has no realised
prices. This is a genuine differentiator rather than a catch-up.

---

## 4. Philatelic societies and national federations

Investigated APS/APRL, RPSL, FIP.

**This route is bad. Say so plainly.**

The APS's digital assets are **bibliographic, not philatelic**. The American Philatelic Research
Library runs the **David Straight Memorial Philatelic Union Catalog** and the **Robert A. Mason
Digital Library**, and is a founding partner of the **Global Philatelic Library**. Every one of
these is a *union catalogue of philatelic literature* — it tells you which library holds which
book. It contains **no stamp-level catalogue data whatsoever.** The word "catalog" in their
materials means library catalogue. This is the trap in route 4 and it is easy to fall into.

Societies also do not hold catalogue data to license, because they never built it — Scott, SG
and Michel are commercial publishers and the societies have historically deferred to them. FIP
is a competitive-exhibiting federation; it sets exhibition rules, not data standards.

**What is actually available from this route:**
- APRL digital collections host **out-of-copyright philatelic journals and society handbooks**.
  These are genuinely useful for *variety* data on specific countries — specialist society
  handbooks are often better than Scott on varieties — but they are unstructured prose, they are
  country-by-country, and extracting them is a much worse cost-per-row than route 1.
- **Credibility partnership, not data partnership.** An APS or RPSL endorsement of StampID
  (route 5) would matter far more than any data they could hand over. That is the only reason
  to spend time here.

**Verdict: do not pursue as a data route. Pursue as a *legitimacy* route for §5, at near-zero
cost, opportunistically.**

---

## 5. Own numbering system (StampID)

### 5.1 What adoption actually requires

The honest baseline: **there is no clear precedent of a new identifier displacing an entrenched
one in any collectibles field.** Scott, SG, Michel and Yvert have coexisted for a century
without any of them displacing the others; the market simply tolerates four incompatible systems
and cross-references between them. Attempts to add a fifth mostly fail to achieve *reference*
status even when they achieve *usage* status.

The relevant near-precedents, and what they teach:

- **StampWorld** — free online catalogue, **over 650,000 stamps**, with its own numbering derived
  mechanically from day and country of issue (starts at 1 for a country's first stamp and
  increments). It has achieved significant *usage* — collectors use it daily — but essentially
  zero *reference* status: nobody prices or describes a stamp in the market by StampWorld number.
  **Lesson: usage does not become reference. A mechanical numbering scheme has no authority.**
- **StampData** — wiki-based free catalogue, **960 countries/areas, 205,000+ stamps**, explicitly
  experimental. Same outcome, smaller.
- **Colnect** — the successful case, and it succeeded by *not* competing on numbering: Colnect's
  contribution guidelines direct contributors to reference Scott for stamps and Krause for coins.
  **Colnect's moat is the community and the cross-reference table, not an identifier.**
- **WNS (see §6)** — the one identifier with genuine institutional authority, because the UPU
  confers it and the issuing postal administrations submit to it. **Lesson: authority comes from
  the issuer, not from the cataloguer.**
- **Minkus** — instructive failure. Minkus ran its own numbering, got sued by Scott, settled, and
  the settlement outcome was that Minkus published a **Minkus↔Scott cross-reference**. The
  cross-reference was the product. Minkus's own numbers never became reference.

### 5.2 What this means for StampID

**Do not position StampID as a competitor to Scott numbers. Position it as an internal primary
key and a cross-reference hub.** The realistic and valuable outcome is not "the world adopts
StampID"; it is "Rowland owns the authoritative mapping between Scott, SG, Michel, Yvert, WNS,
StampWorld and its own images."

**The mapping table is the ownable IP.** It is Rowland's original work of correlation. It is not
a copy of anyone's catalogue. It is defensible, it is acquirable, and — critically — it is the
thing that makes Rowland *more* valuable to Scott or SG as an acquirer rather than a threat to
be sued. An acquirer buying Rowland buys the connective tissue between every catalogue in the
market plus 132k images plus price history. That is a far better acquisition story than
"we built a fifth numbering system nobody uses."

**Adoption prerequisites if you do want external StampID adoption anyway** (in order of
importance): a permanent resolvable URI per identifier; a public, free, stable resolver; an
explicit no-revocation policy; society endorsement (§4); and at least one third party
integrating it. Expect **5+ years and no guarantee.** Do not make it a dependency.

**Verdict: keep StampID, demote its ambitions, invest in the cross-reference table instead.**

---

## 6. Routes not on the original list

### 6.1 UPU WADP Numbering System (WNS) — **the biggest omission, and it is important**

The **WADP Numbering System**, run by the **Universal Postal Union**, launched **1 January 2002**
to register every legally issued postage stamp from that date. It currently holds
**~124,100–124,400 registered stamps**, submitted by UPU-designated postal operators, at
wnsstamps.post, with a bilingual EN/FR interface and search by year, month, theme and sub-theme.
The UPU also ships a mobile app.

Why this matters enormously: **it is exactly the dataset route 1 cannot give you.** Route 1
covers 1840–1930. WNS covers 2002–present with ~124k official records. Between them the only
real gap is **1931–2001**, which is where crowdsourcing (§2) and auction data (§3) should be
aimed.

The catch: the site carries **"© Copyright UPU – WADP. The stamp designs are the property of
their respective issuing postal authority."** No public API or data-reuse terms were found on
the about page.

**Action: contact the UPU directly and ask for a data-sharing arrangement.** This is a
treaty-based international organisation whose stated mission includes promoting philately and
combating illegal stamp issues — a consumer identification app that surfaces official WNS
registration is *aligned with their mandate*, not adverse to it. The individual facts (issuer,
date, denomination, theme) are facts; the *designs* are the postal authorities' copyright, which
is why Rowland should use its own Wikimedia-sourced images rather than WNS's. **[COUNSEL] on
whether the copyright notice extends to the factual records or only to the design images.**
Cost of asking: an email. Expected value: very high. **Do this in week one.**

### 6.2 National postal administration bulletins and archives

Every postal administration publishes official issue announcements: technical data, print runs,
designer, printer, perforation, quantities issued. USPS *Postal Bulletin* runs to 1880 and is
digitised; Royal Mail, Australia Post, Canada Post, Deutsche Post and others publish current
issue data. **US federal government works are not subject to US copyright (17 U.S.C. §105)** —
the USPS Postal Bulletin is therefore a large, free, uncontested factual source for US issues,
including print-run figures Scott does not publish. Other countries vary (UK Crown copyright is
restrictive but permits reuse under the Open Government Licence for many materials).
**[COUNSEL] per jurisdiction.** Moderate volume, low cost, excellent legal position for the US.

### 6.3 Retired dealer and specialist databases for sale

A genuinely underrated route. Philately is an ageing field; specialist dealers and lifelong
country specialists retire or die with meticulously structured private databases and card files.
These are acquirable outright, with **assignment of all rights**, for sums in the **low
thousands to low tens of thousands** — and outright assignment is the cleanest possible
ownership story for an acquirer's diligence. Sourcing is through APS dealer channels, Stamp
Auction Network, and the specialist society networks. **Unpredictable in yield, superb in
ownership quality. Keep a standing watch; do not plan around it.**

### 6.4 Museum open-access collections

The **Smithsonian National Postal Museum** holds 6M+ objects (second-largest Smithsonian
collection), with **Arago** (arago.si.edu) presenting 300,000+ objects, and Smithsonian **Open
Access releases digital assets under CC0**. No dedicated Arago API was confirmed; the
Smithsonian Collections Search Center is the access point and the Smithsonian Open Access API
covers institution-wide assets. **This yields images and provenance, mostly duplicating what
Rowland already has, plus curatorial description. Low incremental value. Low priority.**

### 6.5 Academic philatelic datasets

Effectively nonexistent as structured data. Philately has almost no academic computational
literature and no equivalent of a GBIF or a Chemical Abstracts. **Do not spend time here.**

---

## 7. Ranked recommendation

### 1st — Public-domain Scott extraction, scoped to facts (§1)

- **Do first:** extract `bwb_S0-DUL-160` (Scott 1931, 1,976pp) with `bwb_S0-DUL-172` (1928) as
  a cross-validation diff. Facts only. Exclude back-of-the-book numbers. Exclude catalogue values.
- **Yields:** ~55,000–65,000 major entries, ~330–360 issuing entities, 1840–1930, at 7–9 fields
  each. Roughly doubles the information content of the existing 132k-image corpus for its
  classic half.
- **Costs:** $5,000–$15,000 all-in ($200–$475 raw inference for a two-pass extraction of 1,976
  pages; ~$2,500 sampled human review; 6–10 weeks of one engineer). ~$0.10–$0.25 per entry.
- **Biggest risk:** **not copyright — it is the 1940 renumbering.** Back-of-the-book numbers from
  any pre-1930 edition are dead, and regular-postage stability is "substantial" but not proven
  one-to-one. If you ship extracted numbers as current Scott numbers without validating against
  §3, you will ship visible errors and burn user trust. Mitigation is structural: own identifier
  primary, extracted number as flagged cross-reference only.

### 2nd — Auction realised-price ingestion (§3)

- **Do first:** Siegel (free PDFs with prices realised, 1996–present, Power Search indexed by
  Scott number), then philasearch/Köhler/Spink. Ignore eBay — Marketplace Insights is
  partner-gated and Finding API is dead.
- **Yields:** ~540,000 lot records from Siegel alone → **25,000–50,000 distinct entries with
  real price history and condition data**, doubling with European houses. **This is the only
  route that delivers PRICE and CONDITION, which Rowland currently has zero of, and Colnect
  largely lacks.** It is also the empirical validator for §1's number mapping.
- **Costs:** $0 in licensing; 4–8 weeks engineering; <$3,000 infrastructure.
- **Biggest risk:** **contract, not copyright.** Prices are facts and are safe; the houses' terms
  of use are a separate contractual question and could restrict automated access regardless.
  Mitigation: extract structured facts and discard verbatim lot prose; get counsel per house;
  approach Siegel for a cooperative arrangement rather than scraping silently — they have a
  commercial interest in their results being cited.

### 3rd — UPU / WNS partnership (§6.1)

- **Do first:** email the UPU philately unit this week. Cost: one email.
- **Yields:** **~124,100 officially registered stamps, 2002–present** — the modern half of the
  catalogue, from the issuing authorities themselves, with institutional authority no commercial
  catalogue can match. Fills exactly the period route 1 cannot reach.
- **Costs:** near zero to ask. If a formal arrangement is required, expect a partnership
  agreement and possibly a nominal fee — but the UPU is a treaty body with a philatelic-promotion
  mandate, not a profit-maximising licensor.
- **Biggest risk:** **it is a licence, not ownership — the exact failure mode the owner
  correctly rejected with Colnect.** If the UPU will only grant revocable access, this becomes
  another rented moat. Mitigate by seeking a perpetual data-sharing MoU, or by using WNS purely
  as a *verification source* for crowd-contributed modern entries, where the owned asset is
  Rowland's verified record and WNS is merely the thing that made verification cheap.

### Explicitly deprioritised

- **§4 Societies** — bad route for data. APS/APRL hold *library* catalogues, not stamp data.
  Pursue only for credibility, at zero cost.
- **§5 StampID as a public standard** — no precedent for a new identifier displacing an
  entrenched one; StampWorld's 650k stamps bought it usage, not reference. Keep StampID as an
  internal key; **invest in the cross-reference mapping table, which is the real ownable IP.**
- **§2 Crowdsourcing as a first move** — Colnect took ~16 years with a live community; Discogs
  took 90 months to a million. It compounds a seed; it cannot create one. Build the
  confirm/correct infrastructure now, expect yield in year 2+.
- **§6.5 Academic datasets, §6.4 museums** — low or duplicative value.

### Sequence

Week 1: email UPU; counsel briefing on the four flagged questions (1931 title-page date, EU sui
generis database right, Scott numbering, auction-house terms). Weeks 1–8: Siegel ingestion in
parallel with the Scott 1931 extraction pipeline. Week 8+: reconcile the two, deriving the
1931→modern number mapping empirically. Month 4+: open the confirm/correct crowd flow on top of
seeded data.

---

## [COUNSEL] — consolidated question list

1. Does the title page of archive.org `bwb_S0-DUL-160` (Scott 1931) bear a 1930 or 1931
   copyright notice, and is it therefore US public domain?
2. Does Scott have an enforceable copyright interest in its catalogue *numbers*, given the split
   between *Southco* / *ATC Distribution* (no) and *ADA v. Delta Dental* (yes)? What is the
   effect of the Scott–Krause/Minkus settlement as precedent (it produced no judgment)?
3. Does the **EU sui generis database right** (Dir. 96/9/EC) restrict substantial extraction from
   a US-public-domain Scott edition for a globally distributed app?
4. Trademark exposure from referring to "Scott numbers" in UI or marketing; scope of nominative
   fair use.
5. Terms of use of Siegel, Spink, Heinrich Köhler, philasearch and Delcampe as regards automated
   ingestion of published prices realised — contract, distinct from copyright.
6. Does the "© UPU – WADP" notice on wnsstamps.post extend to the factual registration records
   or only to the reproduced stamp designs?
7. Draft contributor agreement: perpetual, irrevocable, worldwide, royalty-free, sublicensable,
   non-exclusive licence with contributor retaining ownership; Rowland owning the compilation;
   EU/UK moral-rights waiver and assignment of sui generis database right to Rowland as maker.

---

## Sources

- [Scott 1928, archive.org `bwb_S0-DUL-172`](https://archive.org/details/bwb_S0-DUL-172)
- [Scott 1917, archive.org `scottsstandardpo1917unse`](https://archive.org/details/scottsstandardpo1917unse)
- [Scott, archive.org `scottsstandardpo00scot`](https://archive.org/details/scottsstandardpo00scot)
- [Stanley Gibbons priced catalogue, archive.org](https://archive.org/details/pricedcatalogueo00stan)
- [Stanley Gibbons priced catalogue (Google/Michigan scan)](https://archive.org/details/pricedcatalogue00ltdgoog)
- [Stanley Gibbons priced catalogue, HathiTrust record 006847227](https://catalog.hathitrust.org/Record/006847227)
- [Yvert et Tellier, archive.org](https://archive.org/details/cataloguedetimbr0001yver)
- [Scott catalogue — Wikipedia](https://en.wikipedia.org/wiki/Scott_catalogue)
- [Stamp numbering system — Wikipedia](https://en.wikipedia.org/wiki/Stamp_numbering_system)
- [Alphabet soup: Scott catalog prefixes and suffixes — Linn's](https://www.linns.com/news/postal-updates-page/alphabet-soup--scott-catalog-prefixes-and-suffixes.html)
- [Southco v. Kanebridge, 390 F.3d 276 (3d Cir. 2004)](https://law.justia.com/cases/federal/appellate-courts/F3/390/276/506642/)
- [ATC Distribution Group v. Whatever It Takes Transmissions](https://www.courtlistener.com/opinion/789715/atc-distribution-group-inc-v-whatever-it-takes-transmissions-parts/)
- [CDN Inc. v. Kapes (9th Cir. 1999)](https://caselaw.findlaw.com/court/us-9th-circuit/1082116.html)
- [CCC Information Services v. Maclean Hunter, 44 F.3d 61 (2d Cir. 1994)](https://law.justia.com/cases/federal/appellate-courts/F3/44/61/513081/)
- [How Many Stamps Were Issued Between 1840 and 1940?](http://globalstamps.blogspot.com/2010/04/how-many-stamps-were-issued-between.html)
- [Scott Classic Specialized 1840-1940 — Amos Advantage](https://www.amosadvantage.com/product/scott-catalogue-of-postage-stamps/classic/1840-1940-world-specialized)
- [Colnect — Wikipedia](https://en.wikipedia.org/wiki/Colnect)
- [The Story of Colnect](http://blog.colnect.com/2012/12/the-story-of-colnect.html)
- [Colnect stamp contribution guidelines](https://colnect.com/en/help/collecting/contribution_guidelines_stamps)
- [Discogs: a business based on public domain data](https://blog.ldodds.com/2016/11/04/discogs-a-business-based-on-public-domain-data/)
- [Discogs Data (CC0 bulk dumps)](https://data.discogs.com/)
- [Discogs Thank You — Internet Archive Blogs](https://blog.archive.org/2020/12/06/discogs-thank-you-a-commercial-community-site-with-bulk-data-access/)
- [BoardGameGeek Terms of Service](https://boardgamegeek.com/terms)
- [BoardGameGeek Licenses](https://boardgamegeek.com/licenses)
- [Siegel Auction Galleries — Past Sales](https://siegelauctions.com/auctions/past-sales)
- [Siegel Power Search](https://www.siegelinternational.com/power-search/search)
- [Heinrich Köhler ProFi ProvenanceFinder](https://heinrich-koehler.de/en/profi)
- [Spink Prices Realised](https://www.spink.com/auctions/prices)
- [philasearch.com auction results](https://www.philasearch.com/en/auctions_results.html)
- [Delcampe General Terms and Conditions](https://www.delcampe.net/en_GB/document/charter/delcampe)
- [Delcampe API](https://www.delcampe.net/en_GB/api)
- [eBay Marketplace Insights API overview](https://developer.ebay.com/api-docs/buy/marketplace-insights/static/overview.html)
- [eBay community: access to sold/completed listing data](https://community.ebay.com/t5/eBay-APIs-Talk-to-your-fellow/Access-to-sold-completed-listing-data-what-options-do-non/td-p/35398955/jump-to/first-unread-message)
- [UPU WADP Numbering System (WNS)](https://www.upu.int/en/Postal-Solutions/Technical-Solutions/Products/WADP-Numbering-System-(WNS))
- [WNS — About](https://www.wnsstamps.post/en/about-wns)
- [WNS stamp search](https://wnsstamps.post/)
- [WADP Numbering System — Wikipedia](https://en.wikipedia.org/wiki/WADP_Numbering_System)
- [American Philatelic Research Library](https://stamps.org/services/library)
- [APRL Digital Collections](https://digital.stamplibrary.org/)
- [Arago — National Postal Museum](https://arago.si.edu/)
- [National Postal Museum Collections](https://postalmuseum.si.edu/collections)
- [StampWorld](https://www.stampworld.com/en/)
- [StampWorld FAQ (numbering system)](https://www.stampworld.com/en/faq/)
- [StampData](https://stampdata.com/)
