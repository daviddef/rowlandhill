# Jersey

**Date:** 19 July 2026 · **Purpose:** base-catalogue skeleton dossier for Jersey (Bailiwick of
Jersey, Channel Islands) — headline counts, issuing history, inscriptions, gaps, forgery/wallpaper
risk, image sourcing, and open questions, for the Rowland stamp database.

---

## 1. Headline counts table

| Metric | Count | Catalogue / source |
|---|---|---|
| Jersey independent-era postage stamps, 1969–2026 | **~2,973** | StampWorld ("Jersey — Postage stamps 1969–2026") |
| "Great Britain – Jersey" combined listing, 1958–present | **~2,312** | StampData (issuer 306), starts at the 1958 GB regional definitives, not 1969 |
| Occupation issues, 1941–1943 | **8** | Scott N1–N8 / Michel Jersey 1–2, 3–8 (see §2–3) |
| GB Regional Definitives for Jersey, 1958–1969 | **8** | StampWorld ("Regional Definitives Jersey") |
| Colnect "Jersey" listing | **unclear — not verified** | Two different Colnect country IDs (240 and 2615) returned pagination markers ("[1/360]", "[1/271]") that could not be confirmed as item totals; Colnect blocked automated fetch behind an Anubis bot-check |

⚠️ **No single number is trustworthy without naming its catalogue, and these three disagree by
~25%.** StampWorld's 2,973 and StampData's 2,312 cover overlapping but not identical spans
(1969–2026 vs. 1958–present) and were very likely pulled at different completeness/snapshot
dates — this is the same ±20% disagreement pattern documented for other small postal
administrations. **Trust the order of magnitude (roughly 2,300–3,000 independent-era majors),
not either exact figure**, until checked against a physical Scott or Stanley Gibbons *Channel
Islands and Isle of Man* catalogue — Stanley Lisica's dealer list (which claims to be a
"complete list of mint postage stamps, 1941–2023") and Colnect both returned HTTP 403 to
automated fetch and could not be independently confirmed.

**Does this include the occupation issues and the independent administration separately?**
No catalogue treats them as one continuous run:
- **StampWorld puts 1941–43 occupation stamps under a wholly separate heading**,
  "German WWII Occ. in Jersey" (its own country entry, not a sub-listing of "Jersey").
- **Scott gives them an "N" (occupation) prefix** — N1–N8 — outside its main Jersey numbering,
  which restarts at 1 with the October 1969 issue.
- **Michel catalogues them under the German Reich's occupation-issues apparatus** ("Kanalinseln
  Guernsey & Jersey Besetzungsausgabe," i.e. *Deutsche Besetzung*), with the Jersey stamps
  numbered 1–2 and 3–8 within that German-side listing, not inside Michel's Jersey country
  section at all. See §3 and the "gaps"/heading traps discussion in §6.
- So: the ~2,300–3,000 headline figure is **independent-era Jersey only (1969–)**. Add 8 for
  the occupation stamps (filed elsewhere) and 8 for the 1958–69 GB Regional Definitives (filed
  under Great Britain) to get the full stamp-producing history of the island.

---

## 2. First issue

There are genuinely three candidate "Jersey No. 1"s, and they are not interchangeable:

1. **1941–42 German-occupation Arms issue** — the *first stamps ever inscribed JERSEY*.
   - **1d vermilion**, issued **1 April 1941** — Scott **N2**. Design (a shield of Jersey arms)
     by Major **Norman Rybot**, adapted from a design already approved for Guernsey; printed
     **locally by the Jersey Evening Post**, typography (letterpress), unwatermarked,
     perforated 11.
   - **½d bright green**, issued **29 January 1942** — Scott **N1**, same design, second value.
   - ⚠️ Scott's own numbering (N1 = the *later*, 1942 stamp; N2 = the *earlier*, 1941 stamp) is
     what several web sources report, but this is not something this research could confirm
     against a physical Scott catalogue — it reads as an anomaly (Scott usually numbers by
     issue date) and should be verified before being loaded as fact.
2. **1943 Blampied "Pictorial"/"Views" issue** — Scott **N3–N8**, SG **3–8**, Michel Jersey
   **3–8**. Six stamps in three release tranches: **1 June 1943** (½d, 1d), **8 June 1943**
   (1½d, 2d), **29 June 1943** (2½d, 3d). Depicted, respectively: a Jersey farm entrance,
   Portelet Bay, Corbière lighthouse, Elizabeth Castle, Mont Orgueil Castle, and vraic
   (seaweed) gathering by horse and cart. Designed by the Jersey-born artist **Edmund
   Blampied**; engraved/printed by **Henri Cortot** at the **Atelier de Fabrication des
   Timbres-Poste in Paris** (production had to go to occupied France because local Jersey
   printing couldn't manage the multi-colour pictorial work). Blampied was paid £60 for the
   designs. Both the Bailiff of Jersey and the German Field Commandant approved the subjects;
   per Blampied's own 1945 letter to his American patron Harold Baily, the Germans chose four
   of the six subjects and Blampied chose the ½d and 3d.
3. **1969 first independent-administration issue** — **1 October 1969**, the date Jersey's own
   postal administration began. A 15-stamp definitive set (Crown Agents managed production;
   printer **Harrison & Sons Ltd**, photogravure, unwatermarked, perf 14½) plus commemoratives
   issued the same day. This is the one every catalogue treats as **"Jersey No. 1"** in its
   main country listing — Scott, SG, Michel and StampWorld all restart numbering here, and file
   the two WWII-era candidates elsewhere (see §1). One value seen cited is Scott #12 (5p, Arms
   of Jersey and the Royal Mace). Design credit for the set's distinctive per-value colour-panel
   concept is attributed to **Victor Whiteley** (who had used the same device on Norfolk
   Island's definitives) — this attribution could not be cross-checked against a second
   independent source and should be treated as provisional.

**Bottom line for the schema:** treat 1969 as Jersey's catalogue "No. 1" (that's what every
major catalogue does), but do not let a country-keyed ingestion silently drop the 1941–43
occupation stamps — they need their own bucket, cross-linked, exactly as flagged in §1 and §6.

---

## 3. Issuing periods table

| Period | Authority | Notes |
|---|---|---|
| Pre-1941 | **Great Britain / GPO** | No Jersey-inscribed stamps; the island used plain GB definitives, as it had since GB stamps first reached the Channel Islands |
| 1 Apr 1941 – 29 Jun 1943 (design), valid to 13 Apr 1946 | **German occupation authorities**, with Bailiff of Jersey sign-off on subjects | Arms (1941–42) and Blampied Pictorial (1943) issues; production partly local (Jersey Evening Post) and partly Paris (Cortot) |
| 1945–1958 | **Great Britain / GPO** | Liberation (9 May 1945); no Jersey-specific stamps at all — plain GB definitives resumed |
| 1958 – 30 Sep 1969 | **Great Britain / GPO** (Regional issues) | GB "Regional Definitives" for Jersey — Wilding/Machin-era Queen's-head definitives with a Jersey heraldic badge, valid for postage GB-wide |
| 1 Oct 1969 – 30 Jun 2006 | **States of Jersey Postal Administration** (statutory committee, created by the Post Office (Jersey) Law 1969) | Full independent stamp-issuing authority begins |
| 1 Jul 2006 – present | **Jersey Post International Ltd ("Jersey Post")** | Incorporated as a limited company under the Postal Services (Jersey) Law 2005, opening the sector to competition; still the designated universal-service / Class II operator |

---

## 4. Predecessor / successor issuers (catalogue-heading names)

- **Great Britain** — the predecessor for all pre-1958 and 1945–1958 use, and the parent
  heading StampData files Jersey material under even for the post-1958 material ("Great
  Britain – Jersey").
- **"Regional Definitives Jersey"** — StampWorld's heading for the 1958–1969 GB regional
  definitives (paired with an equivalent "Regional Definitives Guernsey" heading).
- **"German WWII Occ. in Jersey"** — StampWorld's separate heading for the 1941–43 occupation
  issues; Michel's equivalent is inside its **Deutsches Reich / Kanalinseln Besetzungsausgabe**
  section, not a Jersey section.
- **Jersey** (from 1969) — the independent-administration heading in every catalogue.
- No successor exists; Jersey has issued continuously since 1969 under its own name.

---

## 5. Inscriptions

- **1941–42 Arms issue and 1943 Blampied Pictorial issue**: inscribed **JERSEY** and
  **POSTAGE** plus denomination. No wording referencing "occupation" or the German authority
  appears on the stamps themselves.
  - The 3d Blampied value carries a **"GR" cipher** (for *Georgius Rex*, i.e. George VI) in the
    scrollwork flanking the value — see the myth-check in §7 for exactly what is and is not
    documented about this.
- **1958–1969 GB Regional Definitives**: these carry **no printed country name at all** — they
  are identified only by the Queen's head plus a small heraldic badge (Jersey's own arms
  device), with denomination as the only printed text. This matters for search/OCR tooling: a
  text-inscription search for "JERSEY" will not find this decade of stamps at all; they are
  identifiable only by the badge graphic.
- **1969–present**: **JERSEY** is the standard inscription; **BAILIWICK OF JERSEY** also appears
  on many issues (commonly on commemoratives and higher values), and this varies by design year
  rather than following one fixed rule.
- **1948 GB Channel Islands Liberation commemoratives** (1d and 2½d, Great Britain, issued 10
  May 1948 for the third anniversary of Liberation, designs by Blampied, John Minton and J.R.R.
  Stobie depicting **vraicing** / seaweed-gathering): these are inscribed as ordinary **GREAT
  BRITAIN** stamps — notably, **no wording on the stamps themselves references Liberation or
  the occupation at all**. Contemporary sources (the Postal Museum's stamp-history note and a
  30 June 1948 Hansard exchange) record this as a point of public/parliamentary complaint at
  the time — the commemorative occasion is not commemorated in the design's text.
- **Jèrriais/Norman-French wording**: Jersey's Jèrriais name for the Bailiwick is *Bailliage dé
  Jèrri*. **Could not verify that Jèrriais wording has ever appeared on a Jersey postage
  stamp** — treat as unconfirmed, not as an inscription alias, until a specific stamp is found
  carrying it (see §9).

---

## 6. Gaps

- **1945–1958 (13 years): no Jersey-inscribed stamps at all.** After Liberation the occupation
  issues were demonetised (valid until 13 April 1946) and the island reverted to plain,
  undifferentiated GB definitives — the same stamps used anywhere else in the UK. This is a
  genuine content gap for a Jersey-keyed catalogue: searching "Jersey" for this period returns
  nothing, correctly, because nothing Jersey-specific was issued.
- **1958–1969 (11 years): Jersey-associated but not Jersey-inscribed.** The GB Regional
  Definitives exist and are used specifically in Jersey, but as noted in §5 carry no printed
  country name — a pure text/inscription search will not surface them even though a
  badge/design search should.
- **1969–present: no gap.** Issuing has been continuous and (per §7) increasingly frequent.

---

## 7. Forgery risk and wallpaper risk

**Forgery risk — real and specifically documented for the occupation issues:**
- The 1941–43 Arms and Blampied issues are catalogued in the German Philatelic Society's
  *Reference Manual of Forgeries* and the *Barefoot Forgery & Reprint Guide*. Genuine copies
  are perforated; **imperforate examples are reprints or forgeries, not genuine varieties.**
- **1970s–80s "facsimile" reprints** of the Arms stamps appeared in sheets of 25, later
  reclassified as reprints (not innocent facsimiles) after some entered dealer stock
  mis-described as genuine. They are hard to tell apart by eye; tells include superior
  printing/rouletting quality and thinner, harder paper than the WWII originals.
- **A separate, extremely rare item: 1940 trial swastika overprints on ordinary GB George VI
  definitives.** These were a never-issued 1940 trial — proposed but suppressed before
  circulation because of feared local reaction — with only tiny quantities produced (as few as
  4 copies of some high values, up to 60 of low values). Almost all surviving examples are in
  museum collections; multiple auction-house and forgery-reference sources state that
  **almost everything offered on the open market is a forgery**, with one source noting
  perfect condition is itself the tell ("if they are perfect they are undoubtedly forgeries").
  Any of these offered casually should be treated as suspect by default.

**Wallpaper risk — Jersey is a genuine, legitimate postal administration, but its modern
issuing behaviour earns fair criticism, and this dossier states that plainly:**
- Jersey is **not** an IGPC/Stamperija client and does not appear (so far as this research
  could establish) on the UPU's illegal-issue circulars — it is a UPU-member postal
  administration producing its own stamps through its own philatelic department, which is a
  different and more legitimate category than the fantasy/agency-mill "illegal issue" problem.
- **But the volume is high for the population.** Jersey issued roughly **17 separate stamp
  programmes in 2025 alone** (per WOPA+'s release list — Yearbook, Sky at Night, Letters to
  Santa, RAF Association, History of Black Butter, two Post & Go series, a royal birthday, the
  Witch Trials of Jersey, shipbuilding history, a royal-visit anniversary, the Opera House
  anniversary, two separate Gerald Durrell issues, EUROPA, SEPAC, and Lunar New Year — Year of
  the Snake) against a resident population of only **~104,000** (2025 estimate). That is one
  new stamp-issue event roughly every three weeks, for an island smaller than a mid-sized town.
  A stamp-collector forum thread explicitly groups Jersey with Guernsey and the Isle of Man as
  Crown Dependencies whose output runs "in excess of postal needs," and separately notes their
  heavy advertising spend in *Gibbons Stamp Monthly* may make the trade press reluctant to
  relegate their issues to catalogue appendix sections the way agency-driven countries are.
- **Honest verdict: Jersey is not a "wallpaper" issuer in the illegal/fantasy sense (the
  stamps are real, valid, and locally produced), but it is a commercially-driven, high-volume
  issuer whose modern output leans heavily on generic collector-facing themes (Lunar New Year,
  EUROPA, SEPAC, celebrity-adjacent royal anniversaries) alongside genuinely local subjects.**
  This is the same "agency-topical drift" pattern seen in other small philatelic administrations,
  just self-produced rather than contracted out — a real complaint, but a lesser charge than
  outright illegitimacy.

**The Blampied "hidden GR" claim — checked and needs correction, not repetition:**
⚠️ The claim as commonly phrased ("Blampied hid the letters GR in the 1943 ½d design") **does
not survive checking.** What is actually documented:
- The **GR cipher appears on the 3d value**, not the ½d, per the primary dealer/collector
  source (threeisacollection.org) that discusses the full Blampied set and cites Blampied's
  own 1945 letter.
- It is not really "hidden" — it's an open (if easily overlooked) design element in the value
  scrollwork, plausibly missed by German censors rather than deliberately concealed in the way
  the term "hidden" implies. One source frames it as "presumably not noticed by the German
  authorities," which is a much weaker claim than "cunningly hidden."
- **The genuinely documented hidden-resistance-message stamps are a different design entirely**:
  Major **Norman Rybot's** 1941 red 1d and 1942 green ½d Arms stamps (the *earlier*, non-Blampied
  issue) carry tiny letters in the corners — 'A' × 4 on the 1941 1d, reportedly standing for
  *"Ad Avernum Adolfe Atrox"* ("To Hell with atrocious Adolf"), and 'AA'/'BB' ("Atrocious
  Adolf"/"Bloody Benito") on the 1942 ½d — per Jersey Heritage's own published account, which
  treats this as confirmed by Rybot's own later account, not as an unverified legend.
- **The popular "GR/Blampied/½d" version conflates two different designers, two different
  denominations, and two different kinds of symbolism** (an open royal cipher vs. genuinely
  concealed anti-Axis lettering). Any ingestion pulling this "fact" from a generic dealer page
  should be corrected to attribute the *documented* hidden lettering to Rybot's Arms issue, and
  treat the GR-on-Blampied's-3d claim as real but much more mundane than "hidden."

---

## 8. Image sourcing

- **Wikimedia Commons Category:Stamps_of_Jersey contains only 8 files** — nowhere near enough
  for catalogue coverage. Contents: a 1992 Mesny 150th-anniversary commemorative, a Diamond
  Jubilee display image, a Dumaresq Family Coat of Arms stamp, a small "Edmond Blampied
  timbres" image, an 1877 William Mesny commemorative, a 2020 "Litera of Jersey" Post & Go
  label, a composite "Nazi-jersey-1941-1943" image, and an RHS Chelsea Flower Show 2012 stamp.
  Licensing is file-by-file ("available under licenses specified on their description page"),
  not blanket — each would need individual verification before reuse.
- **Copyright status, modern era (1969–present): still in copyright, and actively commercial.**
  Jersey Post (Jersey Post International Ltd) designs, produces and markets its stamps as
  ongoing collectible products; there is no indication Jersey applies a UK-style Crown
  Copyright regime to its own post-1969 output, and no free/public-domain carve-out for it was
  found. Treat all 1969-present Jersey Post designs as actively copyrighted commercial IP
  belonging to Jersey Post.
- **The 1958–1969 GB Regional Definitives are public domain**, on the same basis as ordinary
  GB stamps of that era: pre-1 October 1969 British stamp designs were Crown Copyright, which
  expires 50 years after publication — so anything from this window passed into the public
  domain by 2019 at the latest.
- **The 1941–45 occupation issues' copyright status could not be confirmed either way.** They
  were designed under Bailiff sign-off (a Crown/States civil authority) but produced and
  approved jointly with the German occupying Feldkommandantur, and partly printed in occupied
  Paris — a genuinely unusual chain of authorship that no source addressed directly. By
  ordinary UK Crown Copyright logic (pre-Oct-1969, now 80+ years old) they would already be
  long out of copyright; but because the "Crown" side of authorship is entangled with a wartime
  occupying power's commission, this dossier is **not asserting** a copyright status for them —
  flagged as Uncertain in §9 rather than assumed free to use.
- **Net effect for sourcing:** the only images clearly safe to use today are the 1958–1969 GB
  regional Jersey stamps (all now public domain) and whatever individual pre-1969 items on
  Commons carry an explicit PD tag. Anything from 1969 onward needs a licence from Jersey Post
  or must be sourced through fair-use/critical-commentary contexts, not bulk ingestion.

---

## 9. Uncertain — flagged, not asserted

- **Exact current Scott/SG/Michel highest catalogue numbers for Jersey** — Stanley Lisica's
  dealer list (claims a complete 1941–2023 mint listing) and Colnect's Jersey pages both
  returned HTTP 403 to automated fetch; no reliable current top-number was obtained from either.
- **Reconciling StampWorld's 2,973 vs. StampData's 2,312** — both are plausible orders of
  magnitude but were evidently measured over different spans/snapshots; neither should be
  treated as exact without a physical-catalogue check.
- **Colnect's actual Jersey total** — two different Colnect country IDs (240, 2615) surfaced
  in search, with ambiguous pagination markers ("[1/360]", "[1/271]") that could not be
  confirmed as item counts rather than page counts; not used in the headline table.
- **Scott's N1/N2 numbering order** (N1 reported as the later, 1942 stamp; N2 as the earlier,
  1941 stamp) — this reads as an anomaly and could not be checked against a physical catalogue.
- **Whether Jèrriais wording has ever appeared printed on an actual Jersey stamp** — the
  language and the Jèrriais name for the Bailiwick are real, but no specific stamp carrying
  Jèrriais text was identified.
- **Full per-value designer/printer attribution for the 1 October 1969 first independent
  issue** — Victor Whiteley's role in the set's colour-panel design concept is reported by one
  source (Jerripedia) and could not be cross-checked against a second independent source.
- **Copyright status of the 1941–45 occupation issues** — see §8; genuinely unclear given the
  mixed Bailiff/occupying-authority chain of approval, and not resolved by any source found.
- **Exact designer of the 1941 Arms design's Guernsey precedent** and the precise chain by
  which it was "already approved in Guernsey" before Jersey adopted it — mentioned in passing
  by one source, not independently corroborated.

---

## 10. Sources

- StampWorld — [Jersey, Postage stamps 1969–2026](https://www.stampworld.com/en/stamps/Jersey/) · [Regional Definitives Jersey, 1958–1969](https://www.stampworld.com/en/stamps/Regional-Definitives-Jersey/) · [German WWII Occ. in Jersey](https://www.stampworld.com/en/stamps/German-WWII-Occ.-in-Jersey/)
- StampData — [Great Britain – Jersey (issuer 306)](https://stampdata.com/stamps.php?fissuer=306&ffunction=postage)
- Colnect — [Jersey stamps (country 240)](https://colnect.com/en/stamps/list/country/240-Jersey) · [Jersey stamps (country 2615)](https://colnect.com/en/stamps/list/country/2615-Jersey) *(both blocked by bot-check; unverified)*
- Stanley Lisica LLC — [Jersey Stamps, complete mint list 1941–2023](https://www.stanleylisica.com/plist_hr/jers.htm) *(403 to automated fetch; unverified)*
- Wikipedia — [Postage stamps and postal history of Jersey](https://en.wikipedia.org/wiki/Postage_stamps_and_postal_history_of_Jersey) · [Bailiwick of Jersey](https://en.wikipedia.org/wiki/Bailiwick_of_Jersey) · [Country definitives](https://en.wikipedia.org/wiki/Country_definitives) · [List of postage stamps of Guernsey](https://en.wikipedia.org/wiki/List_of_postage_stamps_of_Guernsey) · [German occupation of the Channel Islands](https://en.wikipedia.org/wiki/German_occupation_of_the_Channel_Islands)
- Jerripedia / theislandwiki.org — [Jersey postage stamps issued during the German Occupation](https://www.theislandwiki.org/index.php/Jersey_postage_stamps_issued_during_the_German_Occupation) · [The story of Jersey's first stamp issues in 1969](https://www.theislandwiki.org/index.php/The_story_of_Jersey's_first_stamp_issues_in_1969)
- threeisacollection.org — [Jersey Pictorial Issue stamps, 1943 — Blampied](https://www.threeisacollection.org/blampied/blampied_stamps.html)
- Jersey Heritage — [Secret Stamps (object in focus)](https://www.jerseyheritage.org/research-and-collections/object-in-focus/secret-stamps/)
- A Stamp A Day — [Jersey #12 (1969)](https://stampaday.wordpress.com/2017/03/15/jersey-12-1969/) · [Jersey Under German Occupation #N8 (1943)](https://stampaday.wordpress.com/2017/03/16/jersey-under-german-occupation-n8-1943/)
- stampforgeries.com — [Forged Stamps of Jersey](http://stampforgeries.com/forged-stamps-of-jersey/)
- Postal Museum — [Channel Islands Liberation stamp history](https://www.postalmuseum.org/collections/highlights/philatelic-collection/british-stamps/george-vi-stamps/channel-islands-liberation/)
- UK Parliament Hansard — [Channel Islands Liberation (Stamp Issue), 30 June 1948](https://api.parliament.uk/historic-hansard/commons/1948/jun/30/channel-islands-liberation-stamp-issue)
- briefmarken.cc — [Kanalinseln Guernsey & Jersey, MiNr. 1–3, 4–5, Jersey 1–2, 3–8](https://www.briefmarken.cc/kanalinseln-guernsey-jersey-michel-nummer-1-3-4-5-jersey-1-2-3-8-postfrisch?a=276007) *(Michel numbering, confirms occupation issues sit under the German-Reich occupation-issues apparatus, not a Jersey country section)*
- Paul Fraser Collectibles — [1940 Jersey swastika stamps see $25,500 in Chartwell auction](https://www.paulfrasercollectibles.com/blogs/postage-stamps/1940-jersey-swastika-stamps-see-25-500-in-chartwell-auction) · [WWII Jersey swastika stamps to make $39,500 at auction](https://www.paulfrasercollectibles.com/blogs/postage-stamps/wwii-jersey-swastika-stamps-to-make-39-500-at-auction)
- Jersey Post — [About Jersey Post](https://www.jerseypost.com/about-us/about-jersey-post/)
- On this day in Jersey — [Jersey Post International is founded](https://history.je/jersey-post-international-is-founded/)
- WOPA+ — [2025 Jersey Stamp Releases](https://www.wopa-plus.com/en/stamps/releaseyear/&loc=JE&ry=2025)
- StampBoards forum — wallpaper/excessive-issue discussion threads (["Discuss recent exploitative stamp issues"](https://www.stampboards.com/viewtopic.php?t=94484), ["Crazy wallpaper stamps or 'illegal' stamps of today"](https://www.stampboards.com/viewtopic.php?f=13&t=38713))
- Wikimedia Commons — [Category:Stamps of Jersey](https://commons.wikimedia.org/wiki/Category:Stamps_of_Jersey)
- statisticstimes.com — [Jersey population 2025](https://statisticstimes.com/demographics/country/jersey-population.php)
- RPSL — [The German Occupation of the Channel Islands 1940–1945 (handout PDF)](https://www.rpsl.org.uk/rpsl/Displays/Handouts/DISP_20160929_001.pdf) *(fetched but returned as unreadable binary/image content; not usable as a text source)*
