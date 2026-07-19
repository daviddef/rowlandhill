# Sao Tome and Principe

Base catalogue skeleton. Compiled from web research (July 2026). Accuracy over completeness: anything
unverified is parked in section 9, not guessed at.

---

## 1. Headline counts

**There is no single meaningful "number of Sao Tome stamps."** The catalogue-vs-catalogue gap here is
probably the widest of any issuing entity on earth, because the major Anglophone catalogues declined to
list most of the post-independence output while the databases list everything.

| Catalogue / source | Scope | Approx. major numbers | Confidence |
|---|---|---|---|
| Scott Classic Specialized (2014 ed.) | 1869–1939 only | **423** major descriptive numbers | High — explicit published figure |
| Stanley Gibbons (2014 ed., main listing) | 1869–1977 | Effectively **nothing after 1977** — reportedly not a single dobra-denominated stamp in the main SG listing | Medium — secondary report, see §9 |
| Scott (Standard, modern) | 1869–present | Lists colonial era in full; **omits large blocks of post-1990s agency output** | Medium — direction confirmed, exact cutoff unverified |
| Michel / Yvert et Tellier | 1869–present | Substantially **more** than Scott/SG; both listed disputed 2000s issues that Scott and SG did not | Medium |
| StampWorld | 1869–2021 | **~10,024** items | Low-Medium — figure from a search snippet, page 403s to direct fetch |
| Colnect | 1869–present, plus a **separate "Sao Tome and Principe: Illegal Stamps" country entity** | not counted (bot-walled) | — |

**Range to quote: roughly 400–500 major numbers for the classic colonial era (1869–1939), roughly
1,000–1,500 for a Scott/SG-style conservative listing of everything genuinely postal, and up to ~10,000
if you accept every agency-produced item a database like StampWorld records.**

**Which do I trust?** For the colonial era, **Scott Classic Specialized** — it is a hard, published,
specialist figure (423) with a stated date range. For the modern era I trust **Stanley Gibbons' silence**
as the most honest signal: SG's refusal to admit dobra-era material to its main listing is a
deliberate editorial judgement, not an omission. StampWorld's ~10,000 is a *production* count, not a
*postal* count, and should never be presented to a user as "stamps issued by Sao Tome."

Design implication: this country needs a per-record `catalogue_source` field and a
`legitimacy_status` flag more urgently than almost any other.

---

## 2. First issue

- **Year: 1869.** Confirmed across multiple independent sources (Big Blue 1840–1940, StampWorld,
  StampWorldHistory, Colnect). **Exact day/month not verified — see §9.**
- **Design: the Portuguese "Crown" (Imperial Crown) key type** — an embossed crown, no monarch's
  portrait. This is the standard Portuguese-colonies first-issue design, not a Sao Tome–specific design.
- **Catalogue numbers: Scott 1 onward.** Scott 1 = 5 reis black; Scott 4 = 25 reis rose.
  Nine denominations in the initial Crown series; **fourteen** Crown-type stamps across the full
  1869–1885 run.
- **Inscription: "S. THOMÉ E PRINCIPE"** (old orthography, with `TH`).
- **Perforations: 12½ or 13½.** A known variety: the numeral "5" appears upright (Type I) or slanting
  (Type II), catalogued at equal value.
- **Printer: not verified.** Portuguese colonial key types of this era were produced in Lisbon
  (Casa da Moeda / Imprensa Nacional are the plausible candidates) but I could not confirm which for the
  1869 Crown issue. **See §9 — do not assert a printer.**

---

## 3. Issuing periods

| Period | Dates | Issuing authority | Character of output |
|---|---|---|---|
| Portuguese colony | 1869 – 1951 | Portuguese colonial administration (Lisbon-controlled); *Correios* of the colony | Portuguese-colonies key types / omnibus designs almost exclusively |
| Portuguese overseas province | 1951 – 12 Jul 1975 | Portuguese administration, colony reclassified as an *Província Ultramarina* | Continued common designs; some province-specific commemoratives |
| Independent republic, early | 12 Jul 1975 – c. 1980s | Democratic Republic of Sao Tome and Principe, national post | Genuine national issues; thematic drift begins almost immediately |
| Agency / thematic period | c. 1980s–1990s – present | Nominally the national post, operationally **external philatelic agencies** | Mass thematic output, souvenir sheets, CTO; the "wallpaper" era |
| Contested / illegal overlay | c. 1990s – present | **No postal authority** in many cases | Bogus issues produced outside any contract (see §7) |

Currency eras (useful as a dating aid): **réis** 1869–1912 → **escudo/centavos** 1912–1977 →
**dobra** 1977–present.

---

## 4. Predecessor / successor issuers, and the key-type omnibus problem

**Catalogue names you will encounter for the same territory:**

- **"St. Thomas and Prince Islands"** — Scott's and Gibbons' traditional English heading for the
  colonial period. Early material is very frequently filed under this name, **not** under
  "Sao Tome and Principe." Any importer must alias these.
- **"S. Tomé e Príncipe" / "Província de S. Tomé e Príncipe"** — Portuguese-language and post-1951
  provincial forms.
- **"Sao Tome and Principe" / "Democratic Republic of Sao Tome and Principe"** — from 12 July 1975.
- **"Portuguese Colonies (general issues)"** — a *separate* catalogue heading. Some material valid in
  Sao Tome is catalogued there and not under the colony at all.
- **"Sao Tome and Principe: Illegal Stamps"** — Colnect maintains this as a distinct issuer entity.
  Worth mirroring as a separate namespace rather than a boolean flag.

**The key-type omnibus problem.** For most of 1869–1951 Sao Tome did not have its own stamp designs.
Portugal printed a single design and ran it for every colony — Angola, Mozambique, Macao, Cape Verde,
Portuguese India, Timor, Guinea, and Sao Tome — changing only the colony name and the currency.
Confirmed series affecting Sao Tome:

| Key type | Dates | Sao Tome count (Scott, classic era) |
|---|---|---|
| Crown / Imperial Crown | 1869–1885 | 14 |
| King Luiz ("embossed head", typographed) | 1887 | 9 |
| King Carlos | 1895 and 1898–1903 | 35 across both |
| Ceres | 1914–1926 | 40 (Scott subdivides by perf and paper) |
| Empire / "Padrões" | 1938–1939 | two issues of 18 each |

The **1898 "Vasco da Gama" 400th-anniversary omnibus** and the **Caravel** type are standard
Portuguese-colonies omnibus series and are near-certainly present for Sao Tome, but I did not obtain a
source that confirms the Sao Tome participation and counts specifically. **See §9.**

**How a catalogue distinguishes them:** by the **country inscription printed on the stamp** — this is
the *only* reliable discriminator, since design, frame, and printing are identical across colonies.
Secondary discriminators are the currency unit (réis vs. centavos vs. avos vs. rupias identifies which
colony's monetary system) and, within Sao Tome itself, perforation and paper. Note the trap in the
1938–39 Empire type: **two parallel Sao Tome issues exist, one inscribed "S. TOME" and one inscribed
"S. TOME E PRINCIPE"** — same design, different catalogue runs. An OCR-based identifier must read the
full inscription string, not just match on "TOME".

---

## 5. Inscriptions (the single best identification field)

Ordered by period. Diacritics are inconsistently applied on the stamps themselves; treat accents as
optional when matching.

| Inscription as printed | Period | Notes |
|---|---|---|
| `S. THOMÉ E PRINCIPE` | 1869 – early 20th c. | Old orthography with **TH**. Strong marker for the earliest material. |
| `S. TOMÉ E PRÍNCIPE` / `S. TOME E PRINCIPE` | early 20th c. onward | Modernised orthography. Dominant colonial form. |
| `S. TOME` (alone) | 1938–39 Empire/Padrões issue | Confirmed — a distinct parallel issue to the "S. TOME E PRINCIPE" one. |
| `REPUBLICA PORTUGUESA` (with colony name) | post-1910 | Added after Portugal became a republic; appears combined with the colony name on Ceres and later types. |
| `PROVINCIA DE S. TOMÉ E PRÍNCIPE` | 1951–1975 | Marks the overseas-province reclassification. Useful hard date bracket. |
| `CORREIOS` | throughout the Portuguese period | "Posts". Generic; not by itself a dating aid. |
| `REPUBLICA DEMOCRATICA DE S. TOMÉ E PRÍNCIPE` | from 12 Jul 1975 | The independence marker. |
| `SAO TOME E PRINCIPE` / `S.TOME E PRINCIPE` | modern / agency era | Often unaccented, often English-market styling. |
| `DOBRAS` / `Db` denomination | 1977 onward | **Currency is the sharpest modern cut-off.** Any dobra-denominated stamp is post-1977 — and, per the SG position, likely outside the SG main listing. |

`PORTUGAL` as a standalone inscription on a Sao Tome stamp is **not** something I verified; combined
`REPUBLICA PORTUGUESA` + colony name is the form I can source. Do not build a matcher on a bare
`PORTUGAL` inscription for this territory.

---

## 6. Gaps

Not properly verifiable from the sources I reached. What can be said:

- The colonial era is **not** continuous — Portuguese colonies typically issued only when Lisbon ran an
  omnibus or a definitive replacement, so multi-year silences between key-type series (e.g. between the
  1887 Luiz issue and the 1895 Carlos issue) are normal and expected rather than anomalous.
- **1975 independence** is a discontinuity in authority and design but not obviously a gap in years.
- The modern era has the opposite problem: not gaps but saturation.
- **I could not obtain a year-by-year issue table** (Colnect's years list is behind a bot challenge).
  Specific empty years are therefore **unverified — see §9.** Do not populate a gaps list by inference.

---

## 7. Forgery risk and wallpaper risk

Sao Tome and Principe is among the most notorious "wallpaper" issuers in world philately. The evidence,
not the reputation:

**Documented actors and contracts**
- **Juan Marino Montero** — ran *Marino Montero International* (Argentina), president of *Mayfair
  International* printing (France), formerly *France-Philatélie* (closed 2001). Illegal Sao Tome
  material was produced through this chain and carries a Mayfair International logo.
- **Stamperija** (Lithuania) — obtained an **authorised agency contract in 2003**, running to at least
  2021. Its output is *legally issued* but classified as **"abusive"**: sold abroad, not sold in-country,
  and unrelated to the country's actual postal needs. Sao Tome and Principe is explicitly named on the
  PWMO/philatelic-community list of Stamperija client countries.
- **Topnimarka.com** (Russia) — from 2015, mass counterfeits of Sao Tome material.
- **IGPC (Inter-Governmental Philatelic Corporation)** involvement is widely *asserted* for Sao Tome but
  I did **not** find a source that documents an IGPC–Sao Tome contract. **See §9 — do not state it.**

**Institutional signals**
- **UPU / WADP:** Sao Tome and Principe has remained a UPU member but, since the WNS system launched in
  2002, has **never had a single stamp accepted into the WNS registry** — reported as "all of them do
  not meet the requirements." That is an extraordinarily strong negative signal for a country producing
  thousands of items.
- The WADP Code of Ethics definition of "abusive" — legally issued but not corresponding to the
  country's internal postal needs and not sold in the country — describes the Sao Tome modern output
  squarely.
- **FIP** refuses to accept an overwhelming part of such countries' output in competitive exhibitions.
- **Stanley Gibbons (2014):** nothing post-1977 in the main listing; no dobra-denominated stamp admitted.
- **Scott:** the 2008 edition declined to list specific disputed issues; Michel and Yvert **did** list
  them. This is the mechanical cause of the ±enormous count gap in §1.
- Thematic-society editors have taken independent action: the ATA Bird editor stopped listing Stamperija
  output entirely; the Mushroom editor prints purchase warnings.

**Three distinct categories — keep them separate in the data model:**
1. **Legitimate postal issues** (colonial era; early post-independence) — normal collectable status.
2. **Abusive but legal agency issues** (contract-authorised, catalogued by Michel/Yvert, rejected by
   SG/FIP) — the Stamperija-type bulk.
3. **Outright illegal/bogus issues** (no postal authority at all) — Mayfair/Marino Montero,
   Topnimarka counterfeits. Colnect files these under a separate country entity.

**When does the excess start?** Thematic drift begins soon after 1975. The **1977 dobra changeover is
the cleanest usable boundary** (it is where SG stops). The illegal overlay is documented from the
**1990s**, surging **2004–2007**, with counterfeiting resuming from **2015**.

**Contrast with the colonial era:** 1869–1975 output is small, slow, tied to Portuguese omnibus
programmes, genuinely postally used, and fully catalogued by every major publisher without dispute.
The 423 Scott major numbers for the entire 1869–1939 span is roughly what the modern agency era can
produce in a single year. Forgery risk in the colonial era is the *ordinary* kind — reperforations,
regummed high values, faked cancels on CTO-ish material — not the wholesale fabrication of the
modern period.

**CTO warning:** modern material is overwhelmingly cancelled-to-order and issued largely in
souvenir-sheet form; genuine commercially-used covers are close to unobtainable. A "used" modern Sao
Tome stamp should be treated as CTO by default.

---

## 8. Image sourcing

**Colonial era (1869–1975) — probably the only safely reusable material.**
- Portugal's copyright term is life + 70 years (Decree-Law 334/97 of 27 November 1997; 70 years for
  photographic works, 25 years for unpublished public-domain works). Wikimedia's `{{PD-old-70}}` applies
  to works whose author died more than 70 years ago.
- **Critical caveat: Portugal has no general "stamps are government works, therefore PD" rule** of the
  kind the US has. The term runs from the **death of the last surviving designer/engraver**, who is
  frequently unidentified for 19th-century key types. So a stamp being pre-1975 does **not**
  automatically make it PD — 1869–c.1900 material is safe on any plausible reading, but mid-20th-century
  designs (Empire 1938, Caravel, post-war commemoratives) may still be in copyright if the designer died
  after 1956. **Treat 1869–c.1910 as the confidently-PD window and audit anything later per-designer.**
- Anonymous-work and *editio princeps* rules may also apply; not researched.

**Wikimedia Commons: essentially barren.** `Category:Stamps of São Tomé and Príncipe` holds only
**10 files** plus a by-year subcategory — 1869–75 Crown types, 1881–85, and some later 20th-century
items. Nowhere near enough to seed a catalogue. Licences are per-file, not category-wide; each must be
checked.

**Other candidate sources:** the Smithsonian National Postal Museum has a Sao Tome and Principe page in
its Middle Africa exhibition (licensing terms not checked). Colnect, StampWorld, and dealer sites hold
large image sets but assert their own rights and are not reusable.

**Modern era: do not scrape.** Agency-produced designs carry asserted (if murky) copyright held by the
agency or its illustrators, and much of it derives from third-party licensed characters and photographs
— which is a second, independent infringement risk on top of the stamp copyright. There is no PD path
for post-1975 Sao Tome imagery.

---

## 9. Uncertain — explicitly NOT verified

1. **Exact day/month of the 1869 first issue.** Only the year is sourced.
2. **Printer of the 1869 Crown issue.** Lisbon is likely; the specific house is unconfirmed. Do not
   write "Casa da Moeda" without a source.
3. **StampWorld's ~10,024 figure (1869–2021)** and the ~2,451 for 2000–2009 come from a search snippet;
   StampWorld 403s on direct fetch. Not independently confirmed.
4. **The Stanley Gibbons 2014 "nothing after 1977" claim** is a secondary report from forum/community
   discussion, not read from the catalogue itself. Directionally consistent with everything else, but
   the exact cutoff year should be confirmed against a physical SG volume before publishing it.
5. **The precise year Scott stopped listing Sao Tome material**, and whether Scott's omission is a hard
   cutoff or issue-by-issue. Only "2008 Scott did not list certain disputed issues" is sourced.
6. **IGPC's involvement with Sao Tome.** Widely repeated; I found **no** supporting evidence. Treat as
   unverified until a contract or contemporaneous trade-press report is found.
7. **A specific UPU illegal-issue circular naming Sao Tome and Principe.** I confirmed the WNS-rejection
   fact and the WADP "abusive" framework, but did not locate a numbered UPU circular naming the country.
8. **Sao Tome's participation in the 1898 Vasco da Gama omnibus and the Caravel type**, and their counts.
   Both are standard Portuguese-colonies omnibus series and near-certain, but unsourced for this colony.
9. **Year-by-year gaps.** No usable year list obtained; Colnect is bot-walled.
10. **Michel and Yvert total counts.** Only the *relative* position (higher than Scott/SG) is sourced.
11. **The 1951 province reclassification date** is taken from general Portuguese colonial history, not
    from a philatelic source keyed to Sao Tome inscriptions.

### Myths and pollution flagged

- **`stampcollection.app` is AI-generated and unreliable.** It labels the 1869–1886 period
  "King Luís I Issues" — **wrong**. The 1869 first issue is the anonymous Crown key type; the King Luiz
  portrait type does not appear until **1887**. It also gives vague value ranges with no catalogue
  citation. Do not use as a source; treat similar "issuer profile" pages with the same suspicion.
- **"Sao Tome's first stamps depict King Luís"** — false, per the above.
- **"Sao Tome has issued ~10,000 stamps"** — technically what StampWorld records, but misleading as
  stated. Most of that total is agency product that Gibbons and FIP do not recognise as stamps.
- **"Scott doesn't list Sao Tome"** — overstated. Scott lists the colonial era fully; it declines
  specific modern disputed issues.

---

## 10. Sources

- https://bigblue1840-1940.blogspot.com/2015/07/ClassicStampsof-StThomasandPrinceIslands.html — Scott
  Classic Specialized 2014 count (423, 1869–1939), key-type series and counts, first-issue detail
- https://stampworldhistory.nl/country-profiles-2/africa/sao-tome-principe/ — issuing periods,
  inscription forms, currency eras, independence date
- https://www.pwmo.org/abusives/abusives-2013-en.htm — WADP/UPU "abusive" definition, Stamperija client
  list naming Sao Tome
- https://www.pwmo.org/Illegals/14-fip-prohibited-issues.htm — FIP position on prohibited issues
- https://golowesstamps.com/reference/Illegal%20Stamps/Saint%20Thomas%20and%20Prince%20Islands%20Illegal%20Stamps/saint_thomas_and_prince_islands_illegal_stamps.htm — Marino Montero / Mayfair, Stamperija 2003
  contract, Topnimarka, WNS rejection, Scott vs Michel/Yvert divergence
- https://colnect.com/en/stamps/years/country/1609-S%C3%A3o_Tom%C3%A9_and_Pr%C3%ADncipe_Illegal_Stamps/emission/33-Illegal — Colnect's separate "Illegal Stamps" issuer entity (bot-walled)
- https://www.stampworld.com/en/stamps/Sao-Tome-And-Principe/ — StampWorld listing, 1869–2021 (403 on
  direct fetch; count via search snippet)
- https://commons.wikimedia.org/wiki/Category:Stamps_of_S%C3%A3o_Tom%C3%A9_and_Pr%C3%ADncipe — 10 files
- https://commons.wikimedia.org/wiki/Commons:Copyright_rules_by_territory/Portugal — Portuguese
  copyright term, Decree-Law 334/97
- https://commons.wikimedia.org/wiki/Commons:Stamps/Public_domain — general stamp PD guidance
- https://postalmuseum.si.edu/exhibition/international-philately-africa-middle-africa/s%C3%A3o-tom%C3%A9-and-pr%C3%ADncipe — Smithsonian NPM
- https://www.stampboards.com/viewtopic.php?f=10&t=77105 — SG 2014 / dobra discussion (403 on fetch;
  content via search snippet — **weakest source used, see §9.4**)
- https://stampcollection.app/issuer/st-thomas-and-prince-islands/ — **cited as an example of
  AI-generated misinformation, not as evidence**
