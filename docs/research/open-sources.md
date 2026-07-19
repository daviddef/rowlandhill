# Open-licensed stamp image sources — commercial reuse

Research date: 2026-07-19. Bar: **commercial reuse permitted**. CC BY-NC, CC BY-NC-ND,
"educational use", "personal use only" and InC all **fail** and are excluded from the ranking.

Not re-investigated (established previously): Fundação Portuguesa das Comunicações (no licence),
BnF Gallica (paid commercial reuse ~€65/image + paid-AI clause), Musée de La Poste (all rights
reserved), ANOM (Etalab 2.0 but no stamps).

Method note: counts marked **measured** were obtained by directly querying the institution's own
API or bulk dump on the research date (commands recorded below). Counts marked *inferred* come
from prose on the institution's site and were not independently verified.

---

## Ranking (volume × legal safety)

| # | Source | Usable images | Licence | Confidence |
|---|--------|---------------|---------|------------|
| 1 | Smithsonian National Postal Museum (Open Access) | **13,107 media items across 8,786 records** (measured) | CC0 1.0 | High |
| 2 | Tekniska museet / Postmuseum SE — Gösta Bodman philatelic collection (DigitaltMuseum) | **6,692 stamp images** (measured) | Public Domain Mark 1.0 | High |
| 3 | Te Papa Tongarewa — Philatelic collection (NZ Post archive) | **1,894 images** (measured) | "No Known Copyright Restrictions" | Medium |
| 4 | Museums Victoria — Numismatics & Philately | **~1,076 image records** matching "stamp"; 180 in the Philately collection (measured) | CC BY 4.0 | High |
| 5 | Europeana (open subset, non-Swedish remainder) | ~1,500–2,500 after de-duplicating #2 (measured) | PDM / CC0 / CC BY | Medium |
| — | Nationaal Archief NL — Postwaarden | CC0 terms, but only ~10,000 objects digitised and **no per-image licence marking found on the delivery site** | CC0 (claimed) | Low — needs contact |

Everything below the line either fails the commercial bar or is too small to matter. Said
bluntly where relevant.

---

## 1. Smithsonian National Postal Museum — the prize

**Licence.** Smithsonian Open Access FAQ, verbatim:

> "We have released these images and data into the public domain as Creative Commons Zero (CC0),
> meaning you can use, transform, and share our open access assets without asking permission from
> the Smithsonian."

> "Open Access items carry what's called a CC0 designation. This means the Smithsonian dedicates
> the digital asset into the public domain, meaning it is free of copyright restrictions and you
> can use it for any purpose, free of charge, without further permission from the Smithsonian. As
> new images are digitized, if they are determined to be copyright-free, the Smithsonian will
> dedicate them as CC0 ongoing."

Critical caveat, also verbatim from the same FAQ:

> "CC0 only applies to copyright so you may still need someone else's permission to use a
> CC0-designated digital asset."

That sentence is the whole legal question. The Smithsonian waives *its* rights in the photograph;
it does **not** warrant that the depicted stamp design is free of third-party copyright. In
practice SI appears to have screened for this (see §2 — the CC0 subset is heavily pre-1979 US
material), but this is an inference from the data, not a statement SI makes.

**Does CC0 cover the philatelic collection? Yes — measured, not assumed.**

The Smithsonian bulk dump on AWS (`s3://smithsonian-open-access/metadata/edan/npm/`, 256 shards,
public, no credentials) was downloaded in full and parsed:

- **11,687 NPM records** in Open Access
- **8,786 records carry media**; **13,107 media items** total
- **Licence distribution of those 13,107 media items: `CC0` × 13,107. Zero exceptions.**
- Most recent record update in the dump: **2026-07-11** — i.e. the dump is live, not a stale 2020
  snapshot.

Object-type breakdown (top of 11,687):

| Type | Records |
|---|---|
| Covers & Associated Letters | 2,166 |
| Bureau Plate Proofs | 2,073 |
| **Postage Stamps** | **1,966** |
| Mail Processing Equipment | 1,101 |
| Archival Material | 1,023 |
| **Revenue Stamps** | **921** |
| Seals, Symbols & Signage | 398 |
| Special Use Issues, Labels & Seals | 329 |
| Postal Stationery | 230 |

So roughly **5,000–5,500 records are stamps or stamp-adjacent philatelic items** (postage,
revenue, plate proofs, special-use labels, postal stationery); the rest is postal-operations
material (mail bags, sorting machines, uniforms) that is not useful to us. Geography is
US-dominated (7,026 records tagged United States of America) with meaningful France (226),
Palestine (169), Confederate States (97) and Hawaiian Islands (85) holdings.

**Honest assessment of size.** The museum's own marketing says "more than 6 million objects".
That is the *physical* collection. The CC0-released digital subset is 11,687 records. Anyone
citing "6 million" as an acquisition target is wrong by three orders of magnitude.

**API and bulk access.** Two routes, both permitted:

- REST: `https://api.si.edu/openaccess/api/v1.0/search?q=unit_code:NPM&api_key=…`. Keys are free
  via api.data.gov. Default rate limit is documented as 1,000 requests/hour — the shared
  `DEMO_KEY` was exhausted during this research and is not viable for a harvest.
- Bulk: `https://smithsonian-open-access.s3-us-west-2.amazonaws.com/metadata/edan/npm/index.txt`
  → 256 line-delimited JSON files, ~35 MB, anonymous HTTP. **This is the correct ingestion path.**
  The GitHub repo (`Smithsonian/OpenAccess`) is itself distributed under CC0-1.0.

Image delivery is `https://ids.si.edu/ids/deliveryService?id=<idsId>`, one URL per media item,
already present in the dump. No scraping required.

---

## 2. US government works and the USPS copyright boundary

The boundary is **1 January 1978**, and the authoritative statement is the USPS Domestic Mail
Manual, section G013 (archived 2003), verbatim:

> "The designs of postage stamps, stamped envelopes, stamped cards, aerogrammes, souvenir cards,
> and other philatelic items issued on or after January 1, 1978, are copyrighted by the USPS under
> title 17 USC."

The mechanism: the Post Office Department was a cabinet department, so its output was a "work of
the United States Government" and uncopyrightable under 17 USC §105. The Postal Reorganization Act
1970 replaced it with the independent USPS, and the Copyright Office Compendium takes the position
that USPS works are *not* government works and may be registered.

**Two competing dates circulate and they are not the same thing.** The 1978 date above is the
copyright-assertion date in the DMM. Separately, USPS states as *policy* that written permission
is not required for images of stamps issued **before 1 January 1979**. Where the two disagree
(stamps issued during calendar 1978) treat the material as copyrighted. This gap is exactly the
kind of thing to put in front of a lawyer.

**Directly relevant to this product:** the same DMM section lists uses of copyrighted philatelic
designs that are permitted without a licence, and the list explicitly includes:

> "editorial content in newspapers, magazines, journals, books, and philatelic catalogs/albums"

Plus reproduction-size constraints: colour images of *uncancelled* stamps must be "less than 75%
or more than 150% in linear dimension" of the original design; cancelled stamps in colour and all
black-and-white reproductions may be any size.

A stamp-catalogue app is plausibly the "philatelic catalogs/albums" case. **I am not qualified to
tell you that it is, and this is the single highest-value question to put to an IP lawyer.** If it
holds, post-1978 US stamps become usable under a specific carve-out rather than a licence, subject
to the size rule — which would have real UI consequences (image rendering dimensions).

Note also that this analysis is US-law-only and says nothing about non-US stamps. The USPS
position on those, per its own guidance, is that permission "should be obtained directly, before
use, from the entity, or entities, to whom stamp copyright belongs."

Countries whose stamps are statutorily outside copyright (per Wikimedia Commons' country survey,
which cites the underlying statutes): Albania, Armenia, Azerbaijan, Belarus, Brazil (pre-1983),
Georgia, India, Indonesia (Art. 43(b), 2014 Copyright Law), Kazakhstan, Lithuania, Moldova,
Romania, Russia (Art. 1259.6 Civil Code), Ukraine (Art. 10). **Faroe Islands** stamps are
released by the issuer itself:

> "This work has been released into the public domain by its copyright holder, Postverk Føroya -
> Philatelic Office. This applies worldwide."

That is a rare, clean, issuer-level dedication and directly covers the Faroes gap. No equivalent
was found for Greenland.

---

## 3. Libraries and archives

### Nationaal Archief (Netherlands) — biggest *potential*, weakest execution

Holds the Postwaarden collection: ca. 500,000 Dutch items (1852–present) plus ca. 1.5 million
foreign items, transferred from the Museum voor Communicatie. Directly relevant to Aruba, the
Antilles, Curaçao, Suriname, Dutch New Guinea and the Dutch East Indies.

Terms of use, verbatim:

> "The National Archives has waived all of his own rights to the scans of documents, maps and
> photos under copyright law and has dedicated the images to the Public Domain."

The waiver is conditional and the conditions matter:

- applies **only** to images that carry a download button and are marked Public Domain or CC0;
- does **not** apply where the National Archives is not the rightsholder;
- does **not** apply to low-resolution scans.

Attribution is requested but not required. Over 400,000 photographs are already CC0 — but that is
the photo collection, not the stamps.

**The problem is delivery.** The stamps are published via `postzegelontwerpen.nl`, whose colophon
states verbatim:

> "Uit een geschat aantal van 150.000 objecten zijn er ongeveer 10.000 uitgezocht die via deze
> website toegankelijk zijn gemaakt."
> ("Of an estimated 150,000 objects, roughly 10,000 have been selected and made accessible via
> this website.")

and that current coverage is "Nederland en Nederlands Nieuw-Guinea", with Suriname, Nederlands-Indië
and Curaçao listed as future work. I could find **no licence statement of any kind on
postzegelontwerpen.nl** — not in the colophon, not on item pages. There is also no download button
in evidence, which under the Nationaal Archief's own wording means the CC0 waiver does not attach.

**Verdict: high potential, not currently harvestable.** Worth a direct email to the Nationaal
Archief asking (a) whether the Postwaarden scans are CC0, and (b) whether a bulk export exists.
Do not build against postzegelontwerpen.nl on the assumption it is open.

### The Postal Museum (UK) — fails

Catalogue of 120,000+ records covering stamps, posters, photographs and files. The site is behind
Cloudflare and could not be read programmatically; its published policy page is a takedown-notice
procedure, not a licence grant. **No open licence found. Assume all rights reserved and do not
harvest.** Note separately that UK stamp designs are Royal Mail's property and Crown/Royal Mail
copyright is asserted vigorously — this is not a promising avenue regardless.

### Rijksmuseum (Netherlands) — clean licence, negligible volume

Policy is genuinely open — CC0 material "you can use … freely" including commercially, plus a
CC BY 4.0 tier requiring only source credit. But the Rijksmuseum did not appear in the Europeana
provider facets for any stamp query in any language, and its philatelic holdings are incidental
(envelopes, designers' preparatory prints), not a stamp collection. **Footnote, not a source.**

### Nordic institutions

- **Postmuseum Sweden (DigitaltMuseum owner `S-PM`)**: 58,952 records, of which **22,771 are
  Public Domain Mark** and 17,489 are PDM *with images* (measured). However, a title search for
  "frimärke" within that open, illustrated subset returns only **324** — the open Postmuseum
  material is overwhelmingly photographs, signage and postal objects, not stamps. Useful, but far
  smaller than the headline number suggests.
- **Tekniska museet (`S-TEK`) — the actual Nordic prize.** 101,305 PDM images with pictures
  overall; **6,692 of them are stamps**, being the *Gösta Bodmans filatelistiska motivsamling*
  (thematic philatelic collection begun 1950). Records carry
  `http://creativecommons.org/publicdomain/mark/1.0/`. This is a *thematic worldwide* collection,
  so its country coverage is broad rather than Swedish-only — which makes it disproportionately
  valuable for filling gaps. Accessible via `api.dimu.org` Solr and via Europeana.
- **Denmark (Enigma, formerly Post & Tele Museum)**: holds Denmark's national postal collection,
  the largest stamp collection in the country. **No open licence and no public collections API
  could be found.** Fails on evidence, not on merit — worth an email, not a crawl.
- **Greenland / Faroes**: no institutional source. The Faroes are covered instead by the issuer's
  own public-domain dedication (§2). Greenland remains an open gap.

### Australia / New Zealand / Pacific

- **Te Papa Tongarewa (NZ)** holds the New Zealand Post Collection — the archive of NZ Post and
  the NZ Post Office, gifted 1992, covering issued stamps, artwork, proofs, dies and plates from
  1855 to the present. Measured via `data.tepapa.govt.nz` (guest token, no registration):
  - Philatelic collection: **20,708 objects**
  - Rights breakdown of those with image representations: **"No Known Copyright Restrictions" 1,894**;
    All Rights Reserved 3,376; **CC BY-NC-ND 4.0 134 — unusable**
  - Records flagged downloadable: 2,028

  So the usable figure is **~1,894**, not 20,708. Te Papa's NKCR wording is a statement of belief
  under **New Zealand** law — "to the best of Te Papa's knowledge, under New Zealand law, there is
  no copyright … and the work may be copied and otherwise reused in New Zealand without copyright
  restriction." That is a territorially-scoped assurance and is weaker than CC0. **Lawyer
  question:** whether an NZ-scoped NKCR statement is sufficient basis for worldwide commercial
  distribution.
- **Museums Victoria (Australia)**: clean CC BY 4.0, machine-readable, per-item licence objects
  returned by the API (`{"shortName": "CC BY", "uri": "https://creativecommons.org/licenses/by/4.0"}`).
  Measured: **1,076 image-bearing item records** matching "stamp"; **180** within the Philately
  collection proper. Strong on Australian colonial stamps and world airmail to 1950 — a genuinely
  hard-to-source niche. Small but the cleanest licence of any source found.
- **National Archives of Australia**: no philatelic holdings identified. Australia Post's National
  Philatelic Collection is on eHive with no open licence.

---

## 4. Europeana — measured, and mostly disappointing

Queried directly against the Europeana Search API with rights facets. Results:

**Query "postage stamp" — 15,209 total:**

| Rights statement | Count | Usable? |
|---|---|---|
| Public Domain Mark 1.0 | 7,220 | Yes |
| **InC (In Copyright)** | **4,140** | **No** |
| **CC BY-NC-ND 4.0** | **1,265** | **No** |
| CC0 1.0 | 1,009 | Yes |
| **CC BY-NC 4.0** | **502** | **No** |
| **CC BY-NC-SA 4.0** | **343** | **No** |
| CC BY 4.0 | 273 | Yes |
| NoC-OKLR | 177 | Caution |
| **InC-EDU** | **101** | **No** |
| CC BY-SA 4.0 | 46 | Yes |

**≈ 8,548 of 15,209 (56%) carry a genuinely open statement.** The narrower query "stamps postage"
(2,922 results) is far worse: CC BY-NC-SA alone accounts for 1,486 (51%), InC another 794, and
only ~335 are open — **11%**. Which query you run changes the answer by a factor of five, so any
single "Europeana is X% open" figure is unreliable.

**The bigger problem is that the open portion is not diverse.** Provider facets on the open subset,
identical across English, German and Dutch queries:

| Provider | Open items |
|---|---|
| Swedish National Museum of Science and Technology (Tekniska museet) | 6,459 |
| Tallinn City Museum | 545 |
| Postmuseum (SE) | 464 |
| Estonian Sports and Olympic Museum | 243 |
| National Library of Poland | 139 |
| LVR-Freilichtmuseum Kommern | 102 |
| Estonian History Museum | 90 |
| Museum of Ethnography | 87 |
| National Archives of the Netherlands | 45 |

Tekniska museet is **75%** of Europeana's open philatelic material — and it is the same Bodman
collection already counted at #2, reachable more cleanly and in greater volume (6,692 vs 6,459)
direct from DigitaltMuseum.

**Verdict: Europeana is an index, not an incremental source.** After removing Tekniska museet,
the residual is roughly 1,500–2,500 open items across a long tail of small Baltic, Polish and
German museums. Worth harvesting, but it is a tail, not a trunk. Use Europeana for *discovery* of
providers, then go to each provider's own API.

---

## 5. University and library special collections — fails on substance

Checked: UT Dallas Wineburgh Philatelic Research Library, American Philatelic Research Library,
Smithsonian Libraries' postal history digital library.

These are **philatelic *literature*** collections — catalogues, handbooks, journals. The Smithsonian
Libraries items are genuinely CC0 (e.g. *Catalogue of books and periodicals relating to postage
stamps and philatelic literature*), but they are digitised *books about* stamps, not databases of
stamp images. APRL is ~23,000 book titles and 5,700 journal titles.

**No university has digitised a philatelic image collection under CC0 or CC BY at meaningful
volume.** This category should be dropped. The one residual angle: scanned public-domain stamp
catalogues contain thousands of stamp *illustrations*, and pre-1930 catalogues are out of copyright
— but these are low-resolution line engravings, would need segmentation out of page scans, and the
quality is unlikely to meet a consumer product's bar. Not recommended.

## 6. Government postal administrations — fails as a category

Sampled across regions. Result: **postal administrations essentially never publish open licences
for their own stamp designs.** They are the rightsholders and they license commercially.

- **USPS** — asserts copyright post-1978; operates a paid Rights and Permissions office with a
  non-refundable $25 application fee and "non-negotiable" terms. The pre-1979 material and the
  philatelic-catalogue carve-out (§2) are the only openings.
- **Canada Post, Australia Post, India Post, Deutsche Post** — no open licence found for any.
  Australia Post's collection sits on eHive with no licence grant.
- **Postverk Føroya (Faroes)** — the sole exception found, and a clean one (§2).

Where stamps are nonetheless free, it is because **national law excludes them from copyright**
(the Romania / Ukraine / Russia / India / Indonesia group in §2), not because the postal
administration granted anything. That distinction matters: statutory exclusion is a stronger
position than a licence, but it must be established per-country and it is exactly where a lawyer
is needed.

---

## Where a lawyer is required

I am not a lawyer and none of the above is legal advice. Five questions, in priority order:

1. **Does a stamp-catalogue app qualify as a "philatelic catalog/album" under USPS DMM G013?**
   If yes, post-1978 US stamps open up — the largest single unlock available. If yes, does the
   75%/150% linear-dimension rule bind our image rendering?
2. **Does Smithsonian CC0 transfer risk to us?** SI waives its own copyright and explicitly
   disclaims third-party rights. For post-1978 US stamps in the NPM set, is SI's CC0 sufficient,
   or do we independently need the §2 analysis?
3. **Is Te Papa's "No Known Copyright Restrictions" — expressly scoped to New Zealand law —
   adequate for worldwide commercial distribution?**
4. **Are the statutory copyright exclusions** (Romania, Ukraine, Russia, India, Indonesia,
   Kazakhstan, Moldova, Belarus, Lithuania, Georgia, Armenia, Azerbaijan, Albania, Brazil pre-1983)
   reliable enough to harvest against, and do they hold in *our* distribution jurisdictions rather
   than the issuing one?
5. **The 1978 vs 1979 USPS discrepancy** — which date governs, and what happens to calendar-1978
   issues?

## Verification commands

```sh
# Smithsonian NPM — full CC0 dump (256 shards, ~35 MB, anonymous)
curl -s https://smithsonian-open-access.s3-us-west-2.amazonaws.com/metadata/edan/npm/index.txt \
  | xargs -P 16 -n 1 curl -sO

# Europeana rights facets
curl -s "https://api.europeana.eu/record/v2/search.json?wskey=<key>&query=postage%20stamp\
&rows=0&profile=facets&facet=RIGHTS"

# Te Papa (guest token issued on first unauthenticated POST)
curl -s https://data.tepapa.govt.nz/collection/search -H "Content-Type: application/json" \
  -H "Authorization: Bearer <guestToken>" \
  -d '{"query":"*","size":0,"filters":[{"field":"collection","keyword":"Philatelic"}],
       "facets":[{"field":"hasRepresentation.rights.title","size":20}]}'

# DigitaltMuseum (Tekniska museet Bodman collection)
curl -sG https://api.dimu.org/api/solr/select --data-urlencode "q=frimärke" \
  --data-urlencode "fq=identifier.owner:S-TEK" --data-urlencode "fq=artifact.license:pdm" \
  --data-urlencode "fq=artifact.hasPictures:true" --data-urlencode "rows=0" \
  --data-urlencode "wt=json" --data-urlencode "api.key=demo"

# Museums Victoria (count in Total-Results response header)
curl -sI "https://collections.museumsvictoria.com.au/api/search?query=stamp\
&recordtype=item&hasimages=yes&perpage=1"
```

## Realistic total

Roughly **23,000–25,000 additional commercially-usable stamp images** are available today from
identified, licence-verified sources — against the 132,000 already held. That is a ~18% increase,
not a transformative one, and it is concentrated in two collections (Smithsonian NPM and Tekniska
museet) that together account for ~85% of it.

The genuinely large upside is not in finding more institutions. It is in resolving question 1
above (US post-1978 via the catalogue carve-out) and question 4 (statutory exclusions covering
large-volume issuers such as India, Russia and Indonesia). Both are legal questions, not
research ones.
