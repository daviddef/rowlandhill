# Burkina Faso

Base-catalogue skeleton. Research date: 2026-07-19.

**Critical framing:** this is a *two-name, three-discontinuity* country. Catalogue material is split across
**Upper Volta (Haute-Volta)** and **Burkina Faso** headings in every major catalogue, and a 15-year block of
its postal history is catalogued under *other countries entirely*. Any ingest that treats "Burkina Faso" as a
single continuous issuer will be wrong.

---

## 1. Headline counts

A count without a named catalogue is meaningless — the majors disagree by roughly ±20% because they differ on
what counts as a major number (Scott splits some sets Yvert lumps), and far more importantly they differ on
**whether to list modern agency material at all**.

| Catalogue | Scope | Approx. major numbers | Confidence |
|---|---|---|---|
| Scott Classic Specialized 1840–1940 | Upper Volta 1920–1931 (postage + postage due) | **89** | **High** — explicitly stated figure, 2014 edition |
| Colnect (aggregator, not a printed catalogue) | "Burkina Faso" entity, all periods | **~974** | Medium — aggregator; inclusion criteria looser than Scott |
| StampWorld | Upper Volta 1920–1984; Burkina Faso 1984–2019 | Not verified (site returned HTTP 403) | **Unverified** |
| Scott Standard (Vol. 1, A–B) | Burkina Faso 1984–present | **Not verified** | **Unverified** |
| Stanley Gibbons (Part 2, France & Colonies) | Both headings | **Not verified** | **Unverified** |
| Michel (Übersee) | Both headings | **Not verified** | **Unverified** |
| Yvert et Tellier | Both headings | **Not verified** | **Unverified** |

**Working range for total major numbers across both names: roughly 900–1,400**, depending entirely on how much
post-1990 agency output the catalogue admits. Treat this as a soft range, not a fact. The 89 Scott Classic
figure for 1920–1931 is the only count here I would put in a database without a caveat flag.

### Why Yvert et Tellier is the authority here

Y&T is the reference standard for French colonial and ex-French-African areas, and Burkina Faso is squarely in
that group. Reasons that actually matter:

- The issuing authority was French, the stamps were French-printed and French-inscribed, and the primary
  collector market and dealer trade for this material has always been French-speaking. Y&T numbering is what
  French auction houses, dealers, and specialist literature quote.
- Y&T carries the *French colonial* structural logic — it understands "Haut-Sénégal et Niger", "A.O.F.", and
  the colonial-omnibus issues as a coherent system, whereas Anglophone catalogues treat them as unrelated
  country headings.
- Y&T publishes a dedicated volume set for exactly this material: historically **Tome 2** (French colonies,
  split into 2-1 colonies and 2-2 independent African states), and since c.2018 a consolidated
  **Timbres d'Afrique francophone, Volume 1 — "De Afars et Issas à Haute-Volta"**. That volume title is itself
  informative: Y&T files this country under **Haute-Volta**, alphabetically at H, not under B for Burkina.

**Practical consequence for the database:** if you key on Y&T, expect the country label "Haute-Volta" to be the
primary heading with Burkina Faso as a continuation, which is the inverse of Scott/SG practice.

---

## 2. First issue

There are **two distinct "first issues"** and conflating them is the single most common error in dealer listings.

### 2a. Upper Volta's first issue (1920)

- **Date:** December 1920. *(Month is well attested; exact day not verified.)*
- **What it is:** stamps of **Upper Senegal and Niger** (Haut-Sénégal et Niger), 1914–1917 issue, overprinted
  **"HAUTE-VOLTA"**.
- **Subject depicted:** the **"Camel with Rider"** design of Upper Senegal and Niger — i.e. Upper Volta's first
  stamps depict a design that is not its own. Between 1920 and 1928, 28 camel-with-rider stamps in many colours
  were overprinted, some with new face values (surcharges).
- **Overprint colours:** black, blue and red (surcharges in the same range).
- **Technical:** typographed, perforation 13½ × 14.
- **Catalogue number:** Scott #1 begins the sequence; Y&T Haute-Volta #1 likewise. **Exact Scott/Y&T number for
  the specific first value not verified** — do not populate a precise number without checking a physical
  catalogue.
- **Printer:** **Not verified.** French colonial keytypes of this period were generally produced by the
  Imprimerie des Timbres-Poste, Paris, but I could not confirm the printer for this specific overprint and the
  overprinting itself may have been done locally or in Dakar. See §9.
- **Postage dues:** an eight-stamp overprinted postage-due set also appeared in 1920.

**First stamps of Upper Volta's own design:** 1928 pictorial definitives, three designs, catalogued as
**"Hausa Chief", "Hausa Woman", "Hausa Warrior"**. Note a live scholarly dispute — the figures depicted are
probably **Fulani (Peul)**, not Hausa; the "Hausa" naming is a colonial-era catalogue convention that has been
carried forward uncritically. Worth recording the catalogue title *and* the correction.

### 2b. Burkina Faso's first issue under the new name (1984)

- **Rename:** 4 August 1984, under **Thomas Sankara** (first anniversary of his 4 August 1983 coup).
  "Burkina Faso" = roughly "land of upright/honest people", from Mooré and Dioula.
- **First stamps inscribed BURKINA FASO:** an **airmail set depicting butterflies, issued 23 October 1984**
  (per StampWorld). A second 1984 issue, **National Defence, 21 November 1984**, follows.
- **Transitional overprints:** yes — existing Upper Volta stock was overprinted with the new name. A documented
  example is the **1984 "Aid for Sahel"** issue, being a **1983 Upper Volta stamp overprinted**.
- **Printer:** **Not verified.**

> **MYTH FLAGGED.** Multiple dealer/aggregator pages (WorthPoint and downstream copies) state the first
> Burkina Faso stamps were *"an airmail set published on May 23, 1984."* **This does not survive checking.**
> The country was not renamed until 4 August 1984, so a May 1984 stamp could not bear the name. The claim is
> almost certainly a mangling of the **23 October** butterflies airmail set — the day number survived, the
> month was invented. This is a textbook AI-generated-content artifact and it is propagating. Do not ingest it.

---

## 3. Issuing periods table

| Period | Issuing authority | Stamps used / issued |
|---|---|---|
| 1890s – 1904 | French colonial administration; **Senegambia and Niger** | Stamps of the parent colony |
| 1904 – 1920 | **Upper Senegal and Niger** (Haut-Sénégal et Niger) | Stamps of Upper Senegal and Niger |
| Dec 1920 – 1932 | **Colony of Upper Volta** (French West Africa) | Own issues: overprints from 1920, own definitives from 1928 |
| 1 Jan 1933 – 1944 | **Côte d'Ivoire, French Sudan, Niger** (partitioned administration) | **No Upper Volta issues.** Stamps of the neighbouring colonies |
| 1944 – 1959 | **Afrique Occidentale Française (A.O.F.)** | A.O.F. federal issues supersede individual colony issues |
| 4 Sep 1947 – 1958 | Upper Volta **reconstituted** as a territory | Reconstituted politically, but **still no own stamps** — A.O.F. issues continue |
| Dec 1958 – 4 Aug 1960 | **Republic of Upper Volta** (autonomous, within French Community) | Own issues **resume 1959** |
| 5 Aug 1960 – Aug 1984 | **Republic of Upper Volta** (independent) | Own issues |
| 4 Aug 1984 – present | **Burkina Faso** | Own issues; heavy agency involvement from the 1990s |

Note the important asymmetry: **political reconstitution (1947) and postal resumption (1959) are twelve years
apart.** Sources that say "Upper Volta resumed stamps in 1947" are wrong.

---

## 4. Predecessor / successor issuers (catalogue names)

This is the critical field. Chased precisely:

**Before 1920 — Upper Senegal and Niger**
- Catalogue name: **Upper Senegal and Niger** (Scott/SG) / **Haut-Sénégal et Niger** (Y&T, Michel).
- Prior to that, **Senegambia and Niger** administered the postal service (to 1904).
- The 1920 Upper Volta first issue is *physically* Upper Senegal and Niger stamps. Cross-reference required.

**1920–1932 — Upper Volta**
- Catalogue name: **Upper Volta** (Scott/SG) / **Haute-Volta** (Y&T, Michel).

**THE 1932 DISSOLUTION — the hard part**

- The colony was **dissolved 5 September 1932**. Upper Volta stamps were **withdrawn / discontinued 1 January
  1933** — so the postal cut-off is 1 Jan 1933, not the Sept 1932 political date. Record both.
- Territory was partitioned among **three** colonies: **Côte d'Ivoire (Ivory Coast)**, **French Sudan**, and
  **Niger**. The largest share — the cercles of Bobo-Dioulasso, Gaoua, Kaya, eastern Dédougou, Koudougou,
  Ouagadougou and Tenkodogo — went to **Côte d'Ivoire**, the stated rationale being that the territory would
  benefit from Ivory Coast's stronger economic development.
- **From 1933 to 1944**, stamps used in the former Upper Volta were **those of the colonies that absorbed it**.
- **From 1944 to 1959**, these were superseded by **Afrique Occidentale Française (A.O.F.)** federal issues.

> **SOURCE CONFLICT — flagged, unresolved.** Sources disagree on the third absorbing colony.
> - Wikipedia (Burkina Faso postal history) and Big Blue: **Ivory Coast, French Sudan, Niger**.
> - StampWorldHistory and Wikipedia (Ivory Coast postal history): **French Sudan, Ivory Coast, and Dahomey**.
>
> The *administrative* partition is solidly documented as **Ivory Coast / French Sudan / Niger** — Dahomey was
> not an absorbing party in 1932. The Dahomey mentions are most plausibly an error, but because two independent
> sources repeat it I am not calling it settled. **Populate Ivory Coast / French Sudan / Niger; flag Dahomey as
> a disputed fourth.** See §9.

**1933 Côte d'Ivoire overprints — catalogued under a DIFFERENT country**
- When Upper Volta was dissolved, **16 types of Upper Volta stamps were overprinted "CÔTE D'IVOIRE"**.
- **These are catalogued under Ivory Coast, not Upper Volta.** This is exactly the cross-country-name case that
  breaks naive ingests: the stamps are physically Upper Volta stamps, but a collector searching "Upper Volta"
  will not find them. Build an explicit cross-reference.

**"Haute-Côte d'Ivoire"**
- I searched specifically for this term as a catalogue heading and **found no evidence that any major catalogue
  uses "Haute-Côte d'Ivoire" / "Upper Ivory Coast" as a philatelic country heading.** The concept exists in
  administrative history (the Upper Volta cercles attached to Ivory Coast were informally the "upper" Ivory
  Coast), but the philatelic material is filed under plain **Côte d'Ivoire**. Treat "Haute-Côte d'Ivoire" as a
  *historical/administrative* term, **not** a catalogue issuer name. See §9 — I could not check printed Y&T.

**1947 reconstitution**
- Upper Volta revived **4 September 1947** as part of the French Union, with its previous boundaries.
- **It did not resume its own stamps.** A.O.F. issues continued to serve the territory.

**Republic of Upper Volta**
- **December 1958**: Republic of Upper Volta proclaimed (autonomous republic within the French Community).
- **1959**: own issues **resume**. First republican stamp marks the **1st anniversary of the Republic** and
  memorialises **Daniel Ouezzin Coulibaly**, president of the governing council, recently deceased.
- **5 August 1960**: full independence. A **1960 definitive series of 18 stamps depicting African animal masks**
  marks the period; also a Maurice Yaméogo (first president) commemorative and two 25-franc issues for
  African technical/economic cooperation bodies.

**Burkina Faso**
- From **4 August 1984**, under **Thomas Sankara**. Sankara also issued two stamps in 1984 for the first
  anniversary of his regime, showing a stylised portrait of the president and an armed soldier.

---

## 5. Inscriptions (text actually printed)

| Inscription as printed | Period | Notes |
|---|---|---|
| `HAUT-SÉNÉGAL-NIGER` / `HAUT SÉNÉGAL ET NIGER` | pre-1920 base stamps | The underlying stamps of the 1920 overprints |
| `HAUTE-VOLTA` (as **overprint**) | Dec 1920 – 1928 | Overprinted onto Upper Senegal & Niger camel-and-rider stamps, in black, blue or red |
| `HAUTE-VOLTA` (printed in design) | 1928 – 1932 | Own definitives (the "Hausa"/Fulani types) |
| `AFRIQUE OCCIDENTALE FRANÇAISE` | on Upper Volta stamps **until 1932** | Appears alongside HAUTE-VOLTA on colonial-period issues, marking A.O.F. federation membership |
| `AFRIQUE OCCIDENTALE FRANÇAISE` / `A.O.F.` | 1944 – 1959 | On the **A.O.F. federal issues** used in the territory. **These are catalogued under French West Africa, not Upper Volta** |
| `CÔTE D'IVOIRE` (as **overprint** on Upper Volta stamps) | 1933 | 16 types. Catalogued under Ivory Coast |
| `RÉPUBLIQUE DE HAUTE-VOLTA` | 1959 – 1984 | The republican inscription, both pre- and post-independence |
| `BURKINA FASO` | Aug/Oct 1984 – present | |
| `BURKINA FASO` overprinted on `HAUTE-VOLTA` stamps | 1984 transitional | e.g. the "Aid for Sahel" 1983 Upper Volta stamp overprinted |

**Period-to-inscription discipline:** `HAUTE-VOLTA` alone (overprint) → 1920–28. `HAUTE-VOLTA` + `AFRIQUE
OCCIDENTALE FRANÇAISE` → 1928–32. `RÉPUBLIQUE DE HAUTE-VOLTA` → 1959–84 (the word *RÉPUBLIQUE* is the reliable
discriminator between colonial and republican Upper Volta). `BURKINA FASO` → 1984+.

> **MYTH FLAGGED.** English Wikipedia and several sites copying it render the 1920 overprint as
> **"HAUTE-VOLTE"** (with an E). This is a **typo**, propagated by copying. The overprint reads
> **HAUTE-VOLTA**. Do not create a variety record for "HAUTE-VOLTE".

---

## 6. Gaps

**The big one — the dissolution gap: 1 January 1933 to 1959. 26 years with no stamps of its own.**

Break it into two sub-gaps, because they have different causes and different catalogue homes:

1. **1 Jan 1933 – 1944 (political dissolution).** The colony did not exist. Mail used stamps of Côte d'Ivoire,
   French Sudan and Niger per partition zone. *Cause: 5 Sept 1932 dissolution.*
2. **1944 – 1958 (federal supersession).** A.O.F. issues served the whole federation. Even after Upper Volta was
   politically reconstituted on **4 Sept 1947**, it issued nothing of its own for another twelve years.
   *Cause: A.O.F. federal postal policy, not the dissolution.*

So: the **political** gap is 1932–1947; the **philatelic** gap is **1933–1959**. These are different spans and
sources routinely conflate them. The philatelic gap is the one a stamp database cares about.

**Other gaps:** no evidence found of significant issuing gaps 1959–1984 or 1984–present. Post-1990 the problem
is the opposite — over-issuing (§7). Whether Burkina Faso had genuine *lean* years in the 2000s–2010s where
official output nearly ceased while agency output continued is **unverified** and would be worth checking, as
it materially affects how one reads the modern catalogue.

---

## 7. Forgery risk and wallpaper risk

### Verdict up front

The wallpaper reputation is **PARTLY deserved, but the specific accusation usually levelled is the wrong one.**
The documented modern problem for Burkina Faso is **outright illegal/bogus issues produced by third-party
counterfeiters** — *not* the classic Stamperija/IGPC agency-contract wallpaper model. That distinction matters
and most secondary sources get it wrong.

### What is actually documented

**Illegal/bogus issues — well evidenced, recent, and specific:**
- **"stampsv" (eBay) / "stampsv1" (Delcampe)**, a **Lithuania-based** operation, began selling **backdated 2021**
  Burkina Faso stamps in **mid-2022**. Documented as: *"This new 'style' of illegal stamps was not on the market
  in 2021 so it is fairly certain that the illegal stamps have been back dated."*
- **Scale: 26+ sets** attributed to this producer for 2021 alone — Birds of Prey, Butterflies, Cats (two
  variants), Dinosaurs, Dogs, Elephants, Giraffes, Hippopotamus, Lions, Lynx, Mushrooms, Owls, Pandas,
  Panthers, Parrots, Prehistoric Man, Pumas, Rhinoceros, Snakes, Space, Tigers, Zebras. Each in souvenir sheets
  of 6 and single sheets. This is a pure topical-bait subject list — the tell is that no genuine postal
  administration issues 26 charismatic-megafauna sets in one year.
- **topnimarka.com (Moscow, Russia)** produced **one** Burkina Faso set in 2021: *Paintings by Gevorg
  Bashinjaghyan* (April 2021), in souvenir sheets of 4, 2 and 1.

**UPU status — important nuance:**
- Burkina Faso **is named** by the UPU/WNS-adjacent listings among administrations where investigations into
  denouncements are ongoing.
- **BUT: Burkina Faso has never requested a UPU Circular describing illegal stamps** bearing its name. So there
  is **no UPU circular for Burkina Faso**. The absence of a circular is *not* evidence the issues are genuine —
  it reflects the administration's inaction. Record this precisely; "no UPU circular" is easily misread.

**IGPC / Stamperija:**
- I found **no direct evidence** tying either **IGPC** or **Stamperija** to a Burkina Faso contract. Both are
  repeatedly named in the general literature on illegal African issues, and generic sources assume they are
  behind Burkina Faso output, but I could not confirm a Burkina Faso-specific agency agreement with either.
  **Treat the IGPC/Stamperija–Burkina Faso link as UNVERIFIED**, not established.

**CTO material:**
- CTO Burkina Faso material circulates in bulk (e.g. "1984–1995 various CTO" lots). Consistent with the general
  West African pattern of favour-cancelled remainders sold into the packet trade. Genuine postal use of such
  material is minimal, so CTO copies carry little premium and should not be treated as "used".

**When does the excess start?** Best evidence points to the **1990s onward** for agency-style output generally,
with the **documented illegal wave concentrated around 2021–2022** (and backdated). The colonial and early
republican periods (1920–32, 1959–c.1985) are **not** wallpaper — they are legitimate, postally-used, and
modestly priced (about 65% of Scott Classic Upper Volta 1920–31 catalogues under $1).

### Catalogue treatment

- Scott's listing criteria **do not incorporate the UPU code of ethics**, so Scott may list issues the UPU
  regards as illegitimate, and conversely may omit others. Scott and UPU disagreement is structural, not
  accidental.
- Concretely: **several modern Burkina Faso stamps previously carrying dashed (unvalued) entries in Scott were
  given values for the first time in the 2020 catalogue** — direct evidence that Scott has historically held
  modern Burkina Faso material at arm's length, listing it without endorsing a market value.
- Whether Scott **outright declines to list** specific Burkina Faso issues: **not verified** — I could not
  access the Scott listing itself. The dashed-value evidence is strong but is not the same as non-listing.

### Practical risk rating

| Period | Forgery risk | Wallpaper risk |
|---|---|---|
| 1920 overprints | **HIGH** — overprints and surcharges are trivially forged; expertisation advised on better values | Low |
| 1928–1932 definitives | Moderate | Low |
| 1959–c.1985 | Low | Low–moderate (CTO) |
| c.1990–2015 | Low | **Moderate–high** (CTO, agency-style topicals) |
| 2016–present, esp. 2021 | Low (they aren't copies of anything) | **VERY HIGH** — substantial documented bogus output |

Note the 1920 overprints deserve genuine caution: a forged overprint on a genuine, cheap Upper Senegal and Niger
camel stamp is the classic low-effort/high-margin forgery, and this issue is exactly that setup.

---

## 8. Image sourcing

**Are colonial/Upper Volta issues more freely available than modern ones? Yes, substantially — but not
automatically public domain.**

- **Wikimedia Commons has no country-specific stamp exemption for Burkina Faso.** Commons'
  *Copyright rules by territory/Burkina Faso* requires a work to be PD or freely licensed in **both** Burkina
  Faso **and** the United States. Commons' *Stamps/Public domain* page records **"No information available"**
  for Burkina Faso — meaning no established free-licence basis. **Assume modern Burkina Faso stamps are
  copyright-encumbered and not usable.**
- **French colonial-era issues are the realistic source.** Commons treats French stamps as PD where the
  **designer died more than 70 years ago**. The 1920 overprints and 1928 definitives are strong candidates —
  but the test is **designer death date, not issue date**, so it must be assessed **per stamp**, and Commons
  offers no blanket French-colonial rule. Many 1920s colonial designers are anonymous or unattributed, which
  makes clearance harder, not easier.
- **US-side status:** pre-1930 publication is now PD in the US by date alone, which cleanly covers the 1920
  overprints and helps (but does not fully clear) the 1928 issues. The Burkina Faso-side test still applies.
- **Practical recommendation:** treat **1920–1932 Upper Volta** as the sourceable window, cleared per-stamp on
  designer death date; treat **1959–1984 Upper Volta** as case-by-case and probably still in copyright; treat
  **1984+ Burkina Faso** as **not sourceable** under a free licence.
- **Do not** source images from the illegal/bogus 2021 material — beyond copyright, ingesting it would give
  fabricated issues catalogue legitimacy.
- **Not verified:** whether Commons actually *holds* a meaningful quantity of Upper Volta / Burkina Faso stamp
  images. I confirmed the copyright framework, not the inventory. Audit
  `Category:Stamps of Burkina Faso` and `Category:Stamps of Upper Volta` directly before planning around it.

---

## 9. Uncertain — explicitly NOT verified

1. **Total catalogue counts for Scott, SG, Michel and Yvert et Tellier** (both country headings). Only the Scott
   Classic 1920–1931 figure of 89 is confirmed. The 900–1,400 range in §1 is an estimate, not a finding.
2. **The exact day in December 1920** of the first issue. Month confirmed; day not.
3. **Printer of the 1920 overprints and of the 1928 definitives.** Not established, and I would not assume
   Imprimerie des Timbres-Poste without confirmation, since the overprinting may have been done separately from
   the base-stamp printing.
4. **Printer of the 1984 Burkina Faso first issues.** Not established.
5. **Ivory Coast / French Sudan / Niger vs Dahomey** as the third absorbing colony after 1932 (§4). Two sources
   say Dahomey. I believe they are wrong but have not resolved it against a primary source.
6. **"Haute-Côte d'Ivoire" as a catalogue heading.** I found no catalogue using it, but I could not check
   printed Y&T or Michel, which is precisely where such a heading would appear if it exists anywhere.
7. **Whether the first Burkina Faso-inscribed stamp is the 23 Oct 1984 butterflies airmail set**, or whether a
   transitional overprint preceded it. The overprints and the butterflies set are both 1984; their relative
   order is unconfirmed. StampWorld's 23 Oct date was obtained via search summary, **not** from the site
   directly (StampWorld returned HTTP 403).
8. **Exact Scott / Y&T catalogue numbers** for any specific stamp. None verified against a catalogue.
9. **Whether Scott outright omits any Burkina Faso issues** (as opposed to listing them with dashed values).
10. **Any IGPC or Stamperija contract with Burkina Faso.** Widely assumed in secondary sources, not confirmed.
11. **Whether Wikimedia Commons holds usable images** in quantity (§8).
12. **Post-1985 issuing gaps** — whether official output ever effectively ceased (§6).
13. **The 16 Upper Volta stamps overprinted "CÔTE D'IVOIRE" in 1933** — exact date, catalogue numbers, and
    which Ivory Coast catalogue range they occupy. The fact is confirmed; the details are not.

### Myths flagged (do not ingest)

- **"First Burkina Faso stamps, 23 May 1984."** Impossible — the rename was 4 August 1984. Almost certainly a
  corruption of 23 October 1984. Appears on WorthPoint and downstream AI-generated dealer pages.
- **"HAUTE-VOLTE" overprint.** A typo on English Wikipedia, copied widely. The overprint reads HAUTE-VOLTA.
- **"Upper Volta resumed stamps in 1947."** No — reconstituted 1947, stamps resumed **1959**.
- **"Hausa Chief / Woman / Warrior" (1928).** Catalogue titles, but the subjects are probably **Fulani**.
- **Wikipedia's "known as Upper Volta until July 1984"** is loose; the rename was **4 August 1984**.

---

## 10. Sources

- https://en.wikipedia.org/wiki/Postage_stamps_and_postal_history_of_Burkina_Faso
- https://en.wikipedia.org/wiki/Postage_stamps_and_postal_history_of_Ivory_Coast
- https://en.wikipedia.org/wiki/French_Upper_Volta
- https://en.wikipedia.org/wiki/Burkina_Faso
- https://en.wikipedia.org/wiki/Illegal_stamp
- https://stampworldhistory.nl/country-profiles-2/africa/upper-volta/
- http://bigblue1840-1940.blogspot.com/2016/11/ClassicalStampsofupper-volta.html
- https://golowesstamps.com/reference/Illegal%20Stamps/Burkina%20Faso%20Illegal%20Stamps/burkina_faso_illegal_stamps_2021.htm
- https://golowesstamps.com/reference/Illegal%20Stamps/illegal_stamps.htm
- https://www.pwmo.org/articles/illegals-summary.htm
- https://www.pwmo.org/Illegals/14-fip-prohibited-issues.htm
- https://www.upu.int/en/Universal-Postal-Union/Activities/Philately-IRCs/Philatelic-circulars
- https://commons.wikimedia.org/wiki/Commons:Copyright_rules_by_territory/Burkina_Faso
- https://commons.wikimedia.org/wiki/Commons:Stamps/Public_domain
- https://commons.wikimedia.org/wiki/Commons:Stamps/Africa/en
- https://www.yvert.com/A-276518-afrique-francophone-volume-1-2023-catalogue-des-timbres-des-pays-d-afrique-de-afars-et-issas-a-haute-volta.aspx
- https://www.philatelie72.com/materiel-librairie/produit/12812/tome-2022-catalogue-de-cotation-yvert-et-tellier-des-colonies-francaises
- https://www.britannica.com/topic/history-of-Burkina-Faso
- https://www.britannica.com/place/French-West-Africa
- https://postalmuseum.si.edu/exhibition/international-philately-africa-western-africa/burkina-faso
- https://www.linns.com/news/world-stamps-postal-history/what-s-new-for-2020-scott-standard-catalog-volumes-1a-and-1b
- https://en.mimi.hu/philately/wallpaper.html
- https://www.stampboards.com/viewtopic.php?t=38713
- https://www.forbes.com/sites/richardlehmann/2019/05/15/the-abuse-of-topical-collectors/
- https://colnect.com/en/stamps/countries/catalog/276-Stamp_Number

**Retrieval failures (noted for redo):** stampworld.com (HTTP 403), colnect.com item pages (bot challenge),
stampencyclopedia.miraheze.org (HTTP 403), linns.com stamp-identifier article (returned navigation shell only).
