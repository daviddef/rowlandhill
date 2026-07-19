# Image sourcing & licensing for the 17 uncovered countries

**Date:** 19 July 2026 · **Status:** PARTIAL — the Portuguese/French colonial strand completed;
the Dutch, non-EU GLAM and commercial-catalogue strands died on a session limit and have not
been run. Do not read absence of a finding here as a negative finding.

> ⚠️ **Not legal advice.** Every ruling below is a reading of a published terms page, not an
> opinion. The design-copyright layer (§4) is the part most likely to bite and the part least
> resolved. Before any commercial use, this needs an IP lawyer — the same one already queued up
> for the Scott/SG/Michel numbering question and the "Rowland" trademark.

---

## The one-line answer

**For São Tomé, Timor-Leste, Gabon and Burkina Faso there is no viable free commercial image
pipeline from national institutions.** The institution that actually holds the stamps has no
licence; the institutions with clean licences hold no stamps.

| Institution | Has stamp images? | Licence | Commercially usable? |
|---|---|---|---|
| **FPC / Museu das Comunicações** (PT) | **YES — the national collection, incl. colonial** | **none published** | **NO** |
| Musée de La Poste (FR) | Yes, incl. some colonial | "© La Poste, tous droits réservés" | **NO** — dual consent |
| BnF **Gallica** | Marginal — printed catalogues only | commercial reuse **payante** | **NO** without paid licence |
| **ANOM** (FR overseas archives) | Negligible | **Etalab 2.0, explicit commercial grant** | **YES** — but no stamps |
| Biblioteca Nacional de Portugal | No philatelic corpus | Public Domain Mark, per item | Yes for PD items — but no stamps |
| DGLAB / Torre do Tombo / AHU | No — admin records | none; sells images | **NO** |
| CTT | not published | rights asserted | **NO** |
| data.gouv.fr | **no stamp-image dataset exists** | Licence Ouverte | n/a |

---

## 1. The trap: "domaine public" ≠ free for us

Gallica is the one to watch, because it looks open and isn't. From
[Gallica's conditions](https://gallica.bnf.fr/accueil/fr/html/conditions-dutilisation-de-gallica):

> « **La réutilisation non commerciale de ces contenus est libre et gratuite** […]
> **La réutilisation commerciale de ces contenus est payante et fait l'objet d'une licence.** »

Commercial reuse is defined to include *"toute autre réutilisation des contenus générant
directement des revenus"* — which is us. Tariffs are roughly **€65 HT** per interior image,
**€75 HT** web/mobile, with volume discounts from 10 images; products and derivative works are
priced as a percentage of sales revenue.

Two things follow that are easy to get wrong:

- **The free IIIF API is not a free licence.** BnF publishes an open IIIF endpoint and an SRU
  search API, both callable without a key. Retrieving an image costs nothing; *using* it
  commercially still requires the paid licence. Free API ≠ free content.
- **Only the metadata is Etalab-licensed**, and therefore only the metadata is safely reusable.

There is also now an explicit **AI clause** in the same page, directly relevant to any embedding
or training pipeline: use of Gallica documents in AI projects, including data mining, is free
for non-profit academic research and **payante** for everything else.

The 2019 reform (HD file fee €25→€5, researcher exemption) did **not** abolish the commercial
redevance. Criticism of this as copyfraud has not changed the policy.

## 2. The bitter one: FPC has exactly what we want and no licence at all

The **Fundação Portuguesa das Comunicações** holds the Portuguese national philatelic
collection — Portuguese, **colonial** and foreign UPU-member stamps, engraving plates, original
artist designs, postmarks, FDCs, with a digitisation programme covering 1912–2022.

It publishes **no terms of use and no rights statement**. The only legal page on the site is a
GDPR privacy policy. The catalogue asserts that the heritage is the property of CTT, Portugal
Telecom and ICP-ANACOM.

**Unstated licence = unusable.** Silence is not permission. Any use needs a negotiated written
licence from FPC/CTT — which is the same shape of ask as the Colnect email already drafted, and
probably worth sending to both.

## 3. The one green light, and why it doesn't help

**ANOM** (Archives nationales d'outre-mer) is unambiguous — Etalab 2.0, with an express grant of
a *"droit non exclusif et gratuit de libre « réutilisation » **à des fins commerciales** […]
dans le monde entier et pour une durée illimitée"*, subject to crediting
`Archives nationales d'outre-mer (France)`.

But ANOM holds French colonial **administrative** archives for Gabon, Haute-Volta and AOF —
correspondence, registers, maps. **Not stamps.** Its multimedia content is also carved out to
personal/educational use only. Good for contextual imagery, useless for philately.

## 4. The layer everyone forgets: design copyright

**A clean digitisation licence does not clear the stamp design.** These are two separate rights
and both must be cleared:

- **Portugal** — stamp designs are works of applied art, **70 years p.m.a. of the designer**.
  Late-colonial São Tomé and Timor issues (1940s–1975) are overwhelmingly **still in copyright**.
- **France** — La Poste *and* the individual designers and engravers hold rights, and La Poste's
  own reproduction rules require consent from both. Gabon (1886–1960) and Haute-Volta
  (1920–1933, 1959+) fall substantially inside 70 years p.m.a.

This is why "the scan is public domain" is not the end of the analysis, and it applies to
Wikimedia Commons material too.

## 5. Where the openings actually are

From the country dossiers rather than this strand, three real ones — all needing confirmation:

- **Georgia** — Commons tags Georgian stamps `{{PD-GE-exempt}}`; Georgian law excludes state
  symbols from copyright. This reverses the assumption in the earlier skeleton. See `georgia.md`.
- **North Korea** — DPRK stamps published **before 1976** appear to be public domain on a 50-year
  corporate term, covering 1946 to the 1974 export pivot: precisely the valuable era. **Sanctions,
  not copyright, are the binding constraint** — stamps sit at HTS 9704, outside the artworks
  carve-out at 31 CFR 510.312, and whether they qualify as OFAC "informational materials" is
  unsettled. See `korea-north.md`.
- **Aruba** — its 2003 copyright statute carries a public-authority exception close to Dutch
  Auteurswet Art. 15b, arguably reaching pre-2005 stamps if rights weren't expressly reserved.
  Unconfirmed; post-2005 issues go through a commercial agent. See `aruba.md`.

## 6. Not yet researched

- Dutch institutions (relevant to Aruba)
- Non-EU GLAM: UK/Crown Dependencies (Jersey, Guernsey, Falklands), Hong Kong, Denmark/Faroes,
  Australia/Norfolk, US Trust Territory/Micronesia, Namibia
- **UPU WNS** — official images of stamps issued since 2002; participation and licence terms
  for these 17 are unestablished. Potentially the single highest-volume route.
- Commercial licensing terms from Colnect / StampWorld (Colnect blocks automated fetch behind
  Anubis, so this needs a human or a negotiated API)

## 7. Ranking, on what we know so far

1. **Negotiate.** FPC/CTT and Colnect both hold what we need and neither publishes a licence.
   A written ask costs nothing and is the only route to the colonial material.
2. **Chase the per-jurisdiction PD exceptions** — Georgia, pre-1976 DPRK, possibly Aruba. Free
   and lawful where they hold, but each needs confirming and DPRK carries sanctions risk.
3. **Own the physical stamps and photograph them.** Clears the digitisation layer entirely and
   leaves only design copyright. Slow, but it is the one route nobody can revoke.
4. **Pay BnF** — well-defined but ~€65/image and near-zero relevant holdings. Not worth it.
