# WNS (WADP Numbering System) — source assessment

Researched 2026-07-19. Primary site: `https://www.wnsstamps.post`
(canonical host redirects to `https://www.wnsstamps.post/Home/Index`).

**Bottom line up front:** the corpus is real, large, high-quality and trivially
accessible — and the licence position is **ambiguous in a way that is not safe to
resolve ourselves**. There is one sentence of copyright text and no terms-of-use
document. Do not scrape-and-ship. Do ask.

---

## 1. The licence — THE CRITICAL SECTION

### What is actually written

The **only** rights statement anywhere on the site is the footer line, present on
every page. Verbatim, as extracted from the served HTML of
`https://www.wnsstamps.post/Home/Index` on 2026-07-19:

> © Copyright UPU - WADP. The stamp designs are the property of their respective
> issuing postal authority. The issuing postal authorities have allowed the
> reproduction of the stamps displayed on this website.

That is the whole of it. I confirmed the exact wording twice: once in the rendered
page text, and once in the raw page source, where it appears as the localisation
string key `copyrightW`.

### What is NOT there — verified, not assumed

I fetched `/Home/Copyright`, `/en/Copyright`, `/Home/Legal` and `/Home/About`.
**All four return HTTP 200 with byte-identical content to the homepage.** The site
is a single-page app whose server returns the same shell for every route, so those
footer links ("Disclaimer", "Copyright") do not resolve to distinct legal documents
on this host. There is:

- **No terms of use document.**
- **No licence grant to third parties.**
- **No Creative Commons or open-data licence of any kind.**
- **No API terms.**
- **No statement about commercial use, redistribution, or machine learning.**

### Reading the sentence carefully

The operative clause is: *"The issuing postal authorities have allowed the
reproduction of the stamps displayed on this website."*

This is most naturally read as a statement that **the postal authorities granted
permission to the UPU/WADP, so that WNS itself may lawfully display them.** It is a
description of the *site's own* licence-in. It is **not**, on its face, a grant of
rights to visitors.

The alternative reading — that "reproduction ... displayed on this website" is a
blanket public permission to reproduce anything shown here — is grammatically
available but strained. Nothing on the site elsewhere supports it: no attribution
requirement, no scope limit, no commercial/non-commercial distinction. Real
open-licence grants say who may do what; this one does not.

> **This is my reading, not a stated term. I am flagging it as inference.** The
> text is genuinely ambiguous and a single sentence cannot carry the weight of a
> commercial redistribution decision.

### The structural problem underneath

Even a generous reading of the WNS sentence does not solve our problem, because
**UPU is not the rightsholder.** The sentence says so explicitly: the designs
belong to the issuing postal authorities. So:

- Any permission WNS could give us is only as broad as what ~200 separate postal
  administrations gave *them*, and we cannot see those agreements.
- Stamp designs are copyrighted works in most jurisdictions. Many postal
  administrations (Royal Mail, Australia Post, USPS, La Poste) actively assert and
  licence stamp copyright commercially. Term is typically life+70 or 70 years from
  publication — **every stamp in WNS is from 2002 onward, so essentially the entire
  corpus is in copyright everywhere.** There is no public-domain fallback here, the
  way there is for pre-1929 material.
- The photographs/artwork *within* a stamp design often carry their own separate
  rights.

**Conclusion on licence:** Publicly visible, not established as reusable. Silence
on redistribution is silence, and silence is not permission. Treat WNS as
**permission-required** until we have something in writing.

> ⚖️ **Get a real IP lawyer on this before any production use.** The specific
> questions for counsel: (a) does the footer sentence constitute a licence to third
> parties, and under whose law; (b) does training an embedding model on in-copyright
> stamp images constitute infringement or fall under a TDM/fair-use exception in our
> target markets; (c) does UPU's status as a UN specialised agency change anything
> about enforcement or about its capacity to sub-licence. Nothing in this document
> is legal advice.

### One important nuance worth raising with counsel

Our use case is **training an embedding model for stamp identification**, not
republishing images as a picture library. Those are legally quite different
postures, and several jurisdictions (EU DSM Art. 3–4, UK, Japan, Singapore) have
text-and-data-mining exceptions that may cover the former while not covering the
latter. Whether we *display* the WNS image in the app, or only use it to train a
model that matches against a user's own photo, is the single biggest lever on our
legal exposure. **Worth deciding before we approach UPU**, because it changes what
we are asking for.

---

## 2. Volume

**124,354 postage stamps registered** — this figure is rendered on the WNS
homepage itself ("124,354 postage stamps registered"), read 2026-07-19.

**202 participating members**, obtained from the site's own member-list endpoint
`/Home/autoGetMembers`, which returns a JSON array of 202 `{id, name}` objects.

Coverage runs from 1 January 2002 to present — the database contains stamps issued
up to at least May 2026 (newest record seen: `BR006.2026`, Brazil, issued
2026-05-22, created in the database 2026-07-16). It is **actively maintained**.

"Members" are designated postal operators, not countries, so the list includes
sub-national and territorial issuers (Åland, Azores, Guernsey, three separate
Bosnian operators, Australian Antarctic Territory, Agion Oros Athos, etc.).

### Value relative to Wikimedia Commons

The strategic case is strong and specific. Commons is dense on US/UK/Germany/USSR
and on pre-1970 material, and **thin to empty on post-2002 small-territory issues**
— which is exactly and only what WNS holds. WNS is complementary rather than
overlapping. It is also *certified*: every record is registered by the issuing
authority, so the country/date/denomination metadata is authoritative rather than
crowd-sourced, which is worth a great deal for training labels.

Metadata per record is unusually rich (see §3) — subject, issue date, dimensions in
mm, denomination, perforation gauge, printer, printing technique, print quantity,
artist, sheet layout. That is better structured ground truth than Commons offers.

---

## 3. Access mechanics

**Browse-only officially. No documented API, no bulk export, no data dump.** But
the SPA is backed by an undocumented, unauthenticated JSON API, which I exercised
successfully:

| Endpoint | Method | Returns |
|---|---|---|
| `/Home/autoGetMembers` | GET | all 202 members with GUIDs |
| `/Home/autoGetYears` | GET | year facet |
| `/Home/autoGetMonths` | GET | month facet |
| `/Home/autoStampSearch` | GET | stamp records as JSON array |
| `/Home/autoGetStampDetails` | GET | single-stamp detail |

`autoStampSearch` accepts `member`, `allMember`, `year`, `allYear`, `ddlmonth`,
`allMonth`, `themeId`, `subTheme`, `sorting`, `searchType`, `pageIndex`,
`pageSize`, `lang`, `refine`. **POST returns 405; it is GET-only.** No auth token,
no API key, no CSRF check.

**Pagination gotcha — worth recording.** `pageIndex` does *not* return a window; it
returns a **cumulative** result set ("load more" semantics), and the response is
**capped at ~500 records** regardless. My first attempt to count per-country volume
by binary-searching for the first empty page produced garbage (identical
implausible ~12,900 totals for unrelated countries) because pages never come back
empty. The reliable method is to **iterate the `year` facet** with `allYear=0` and
sum — that is how the §6 numbers were produced.

**Image URLs** are flat, predictable, and derivable from the `ImageName` field:

```
https://www.wnsstamps.post/images/T180/{ImageName}   # 180px tall thumbnail
https://www.wnsstamps.post/images/T385/{ImageName}   # 385px tall medium
https://www.wnsstamps.post/images/O/{ImageName}      # "O" = original
```

`ImageName` is `{WNS_NUMBER}.jpg`, e.g. `FK001.2016.jpg`. Sheet-layout images live
at `/images/O/{LayoutImageName1..3}`.

**robots.txt: there is none.** I want to be precise, because the task asked me to
report what it says rather than infer. `GET https://www.wnsstamps.post/robots.txt`
returns **HTTP 200, `Content-Type: text/html`, 158,403 bytes** — it is the SPA
homepage, i.e. a soft 404. There is no robots.txt file, so there are **no
Disallow rules to comply with and no Allow rules to rely on**. The homepage does
carry `<meta name="robots" content="all">`, which is an indexing directive to
search engines and **not** a reuse or redistribution licence. *The absence of
robots.txt is not permission — it is absence of a signal.*

**Rate limiting / blocks.** No WAF challenge, no CAPTCHA, no user-agent block, and
**no hotlink protection** (images fetch fine with no `Referer`). But the origin is
weak: **8 concurrent requests reliably produced socket timeouts**, and even 4
threads was near the edge. Serial or 2–3 concurrent with a short sleep is stable.
This is a modest ASP.NET origin, not a CDN. Hammering it would be both antisocial
and self-defeating — and, given the licence position, would be scraping a source we
have no established right to use.

---

## 4. Image quality

**Good, and better than expected. This is not a thumbnail-only corpus.**

Format is JPEG, RGB, sRGB. Measured samples from `/images/O/`:

| Stamp | Dimensions | Bytes |
|---|---|---|
| `BR006.2026` (Brazil, 2026) | 1486 × 1963 | 2.0 MB |
| `FK001.2016` (Falklands) | 900 × 727 | 123 KB |
| `NF001.2016` (Norfolk Is.) | 885 × 620 | 79 KB |
| `NA001.2008` (Namibia) | 786 × 959 | 204 KB |
| `HK001.2002` (Hong Kong) | 354 × 545 | 46 KB |
| `GE001.2002` (Georgia) | 348 × 493 | 38 KB |
| `AF001.2002` (Afghanistan) | 225 × 317 | 25 KB |
| `TL001.2002` (Timor-Leste) | 325 × 245 | 27 KB |

**Clear quality gradient by era.** 2002-era records are small (~225–350 px on the
long edge) and marginal for training. Post-2015 records are 900 px+, and current
records are ~1500–2000 px and genuinely high quality. Note the Afghanistan case:
its `/images/O/` original (225×317) is *smaller* than the `/images/T385/`
derivative (273×385), so "O" is the archived upload, not a guaranteed-largest
rendition — **fetch both and keep the larger**.

**No watermarking.** I visually inspected `FK001.2016.jpg` (Falkland Islands
short-eared owl, 900×727): clean, unmarked, sharp, well-cropped to the perforation
edge on a white ground, with the full perf pattern intact. This is close to ideal
training input — consistent framing, isolated subject, no background clutter. The
perforation edges being preserved is a real bonus for a segmentation/embedding
pipeline.

---

## 5. The contact route

**There is a published contact, and it is the right one.** From the UPU's WADP page
(`upu.int/en/universal-postal-union/activities/philately-ircs/world-association-for-the-development-of-philately-wadp`):

- **Email: `philately@upu.int`**
- Telephone: +41 31 350 33 21 / +41 31 350 35 07
- Post: Universal Postal Union, International Bureau, WADP Secretariat,
  Weltpoststrasse 4, 3015 Berne, Switzerland

The UPU Philately Programme acts as WADP secretariat and explicitly "manages the
WADP Numbering System (WNS)". So `philately@upu.int` reaches the team that actually
controls the database — not a generic press desk. The WNS site also has a "Contact
WNS" link in its header.

**Precedent for a data partnership: none found.** I found no published instance of
UPU/WADP granting bulk WNS data or image rights to a third party.

**But there is a strongly relevant precedent of a different kind, and we should
think hard about it.** UPU has *itself* launched an AI-powered stamp identification
mobile app built on WNS — "users can now identify postage stamps instantly using
their smartphone camera", positioned for customs and law-enforcement verification
of seized philatelic material. There is a shipping iOS app (`WNS Stamps`, App Store
ID `6744600173`) linked from the WNS homepage.

Two readings, and both matter:

- **Risk:** UPU is doing the thing we want to do. They may see us as a competitor
  and decline, or attach restrictive terms.
- **Opportunity:** they have already decided that AI stamp identification is a
  legitimate and desirable use of WNS, and they have already done the internal
  rights thinking that decision required. Their stated mission is *fighting
  illegal/counterfeit stamp issues* — a consumer identification app that
  authoritatively tells a collector "this is a certified WNS-registered issue"
  is **directly mission-aligned**, and is a distribution channel they do not have.

That framing — mission alignment, not "please give us your data" — is the one to
lead with. Their incentive is reach; ours is data. Those are tradeable.

---

## 6. Per-country participation (our priority list)

Membership was checked against the live `/Home/autoGetMembers` list. Stamp counts
were derived by summing the `year` facet 2002–2026 per member (the reliable method
— see the pagination gotcha in §3).

| Country | In WNS? | Stamps | Coverage span |
|---|---|---|---|
| Afghanistan | ✅ | 87 | 2002–2012 |
| Aruba | ✅ | **609** | 2002–2019 |
| Burkina Faso | ✅ | 137 | 2002–2019 |
| Falkland Islands (Malvinas) | ✅ | 284 | 2002–**2026** |
| Faroe Islands | ✅ | **632** | 2002–2024 |
| Gabon | ✅ | 90 | 2002–2018 |
| Georgia | ✅ | 230 | 2002–2013 |
| **Guernsey** | ⚠️ member, **0 stamps** | 0 | — |
| Hong Kong, China | ✅ | **1,766** | 2002–**2026** |
| **Jersey** | ⚠️ member, **0 stamps** | 0 | — |
| **North Korea (DPRK)** | ❌ **not a member** | — | — |
| **Micronesia** | ❌ **not a member** | — | — |
| Namibia | ✅ | 272 | 2002–2017 |
| Norfolk Island | ✅ | 15 | 2016–2018 |
| **São Tomé and Príncipe** | ⚠️ member, **0 stamps** | 0 | — |
| South Sudan | ❌ not listed (only "Sudan", 112 stamps, 2002–2013) | — | — |
| Timor-Leste | ✅ | 19 | 2002–2016 |
| **Tuvalu** | ❌ **not a member** | — | — |

**Reading this table honestly:**

- **11 of 18 give us real material.** Roughly **4,250 certified images** across the
  priority list, which is a meaningful dent in exactly the gaps Commons leaves.
- **The standouts are Hong Kong (1,766, current through 2026), Faroe Islands (632)
  and Aruba (609).** Hong Kong alone is probably worth the exercise.
- **Registration ≠ participation.** Guernsey, Jersey and São Tomé and Príncipe are
  listed as members but have contributed **nothing**. Membership in the list is not
  evidence of data. This is why I counted rather than trusting the roster — the
  member list would have told us 16/18 were covered, and the truth is 11/18.
- **Four are simply absent:** DPRK, Micronesia, Tuvalu, South Sudan. WNS will never
  solve these; they need a different source. (Note that DPRK, Micronesia and Tuvalu
  are also among the most heavily "illegal issue"–affected names in philately, which
  may be precisely why they are not in a counterfeit-fighting register.)
- **Most participation lapsed.** Afghanistan stops in 2012, Georgia 2013, Namibia
  2017, Gabon 2018, Aruba 2019. Only Hong Kong and the Falklands are current to
  2026. WNS is a *historical* 2002–~2018 snapshot for most of our priority list, not
  a live feed.

---

## Recommendation

**Yes, pursue it — but through the front door, and not yet at scale.**

The case for: 124k certified, authoritatively-labelled, unwatermarked images with
rich structured metadata, concentrated in exactly the post-2002 small-territory
space where Commons fails us. Image quality is adequate-to-excellent and improving
by year. There is a real named contact who owns the asset. Nothing else we have
looked at combines volume, label quality and gap coverage like this.

The case for caution: **we have no licence.** One ambiguous sentence, no terms of
use, no open licence, and a rightsholder structure (~200 postal administrations,
everything in copyright, nothing older than 2002) that means UPU may not even be
able to grant us what we want without going back to its members. The undocumented
API and missing robots.txt make it *easy* to take, which is exactly the trap —
technical accessibility is not permission, and a source we cannot lawfully use is
not a source. Scraping it would also risk poisoning the partnership conversation
with the one organisation that could legitimise the whole corpus for us.

**Very next action: email `philately@upu.int`.** One message, addressed to the WADP
Secretariat / WNS team. It should:

1. Introduce the product and lead with **mission alignment** — helping collectors
   verify that an issue is WNS-certified directly serves WADP's anti-illegal-issue
   mandate, and puts the WNS register in front of consumers, which their own app is
   already trying to do.
2. Ask the two licence questions plainly: *does the footer statement extend any
   reuse right to third parties, and if not, under what terms could a commercial
   identification product use WNS images?*
3. Distinguish the two asks explicitly — **(a) training an embedding model on the
   images, versus (b) displaying WNS images in-app** — because (a) may be far
   easier for them to grant, and it is the one we actually need. Offer to take (a)
   alone.
4. Offer something real: attribution, WNS-number linkback, deep links to the
   registry, and counterfeit-detection telemetry back to them.
5. Ask whether bulk access exists in any form for partners.

**In parallel, and before we send it:** decide internally whether we need to
*display* WNS images or only *train* on them, since that determines what we ask
for. And book time with IP counsel on the three questions in §1 — we should not
sign or rely on anything here without it.

**Do not scrape in the meantime.** Not even "just for evaluation". If we want a
feasibility read on image quality, the handful of samples measured in §4 is enough
to conclude it is good, and that conclusion is already in hand.
