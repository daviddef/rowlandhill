# Yugoslav Space — Philatelic Succession Research
**Date:** 18 July 2026 · **Scope:** Croatia, Yugoslavia and successors
**Status:** researched and applied to the succession graph (10 new curated edges)

The Yugoslav space is the hardest succession case in the corpus: ~50 issuing entities, four
parallel postal administrations in 1918–21, an Axis puppet state, three simultaneous operators
in Bosnia today, and catalogues that openly disagree about what counts as a country.

---

## Corrections this research forced

**1. The NDH is not a successor — it's an occupation.**
The Independent State of Croatia (*Nezavisna Država Hrvatska*, 10 Apr 1941 – May 1945) was an
Axis puppet recognised only by Axis powers. The Allied-recognised government-in-exile ran
continuously from London, and **modern Croatia explicitly disclaims NDH continuity** — the 1991
state traces to SR Croatia of the SFRY. German expertising bodies still write "*so-called* NDH
Croatia", which is a deliberate statement about legitimacy.

We model it with `occupation` edges on both sides (Kingdom of Yugoslavia → NDH → DFJ), flagged
`[CONTESTED]`. It is therefore **absent from Croatia's succession lineage — correctly.** A
collector searching "Croatia" still reaches its 132 stamps through the **alias** layer, which is
exactly the division of labour the two-layer model exists for: aliases assert naming, edges
assert succession.

**2. Bosnia was missing from the dissolution — now added.**
Confirmed as the node most often dropped, for two reasons: its declaration (3 Mar 1992,
recognised 6 Apr 1992) falls outside the "1991 secessions" people mentally group, and BiH
**never issued as one unified authority**, so catalogue-driven lists find three fragmentary
issuers and drop the country. Macedonia and the 2003 rename are commonly dropped too.

**3. `dissolution` is the legally correct edge type, not `secession`.**
The Badinter Commission (Opinion No. 1) held the SFRY was *"in the process of dissolution"* —
**all six republics are equal successors**, and Serbia/FRY's claim to be sole continuator was
rejected (FRY had to reapply for UN membership, admitted 2000). Our edges already used
`dissolution`; this confirms it rather than changing it.

**4. Bosnia's three postal administrations are one UPU member.**
Pošte Srpske (first issue **26 Oct 1992**), Hrvatska pošta Mostar (**12 May 1993**) and BH Pošta
Sarajevo (**27 Oct 1993**) are **designated operators of a single member state**, not
independent members — and note the counterintuitive order: the Serb entity issued first, the
state post last. Modelled as `partition` edges flagged `[CONTESTED]`.

**5. "Kingdom of Serbs, Croats and Slovenes" had no end date.**
The Wikipedia-derived inventory left it open-ended. Renamed **3 October 1929**; corrected to
1918–1929 via `ISSUER_DATE_FIX` in `gen_seed.py`.

---

## Traps worth encoding across the whole corpus

These generalise well beyond Yugoslavia:

| Trap | Example |
|---|---|
| **Overprint date ≠ issue date** | Fiume's overprint reads "3-V-1945" but was issued **26 Jul 1945**; Montenegro's reads "17-IV-1941" (the capitulation date), issued 16 Jun 1941. Dealers list both wrong. |
| **Entity lifespan ≠ issuing window** | Provincia di Lubiana existed to Sept 1943 but only issued **3 May – 26 Jun 1941**. Sources saying "1941–43" describe the entity, not the stamps. |
| **Legal name ≠ inscription** | SHS renamed 1929; stamps kept the old inscription until 1931/33. Worth separate attributes. |
| **Catalogues disagree systematically** | Scott requires UPU membership + UN recognition; Michel and SG do not. Republic of Serbian Krajina, Sremsko-Baranjska Oblast and Montenegro's 1916 Bordeaux issue exist in Michel/SG but **not Scott**. A single "is a country" boolean will break — this argues for a **per-catalogue recognition field**. |
| **Forgery-heavy areas** | Fiume, Zara, Serbia 1916, RSK — catalogue data itself may be contaminated. |

---

## Entity notes

**Republic of Serbian Krajina** — proclaimed 19 Dec 1991; **first stamps 24 Mar 1993**;
dissolved **8 Aug 1995** (Operation Storm, 4–7 Aug). Never recognised by any state, never a UPU
member; mail abroad transited FR Yugoslavia. Successor region **Sremsko-Baranjska Oblast**
issued under UNTAES; **postal handover to Croatia 19 May 1997**, eight months before political
reintegration (15 Jan 1998).

**Croatia 1991** — the true first Croatian-issued item is a **postal tax stamp of 1 Apr 1991**,
three months *before* the 25 Jun declaration; first new airmail **9 Sep 1991**, first regular
postage **21 Nov 1991**.

**Fiume** — "FIUME" overprints from 1 Dec 1918; Italian Regency of Carnaro 1920; Free State
1921–24; annexed to Italy **22 Feb 1924**; Yugoslav occupation issue **26 Jul 1945**; ceded to
Yugoslavia by the Paris Peace Treaty, in force **15 Sep 1947**.

**"Yugoslav Regional Issues" 1945 were not a federal programme.** They were **local Partisan
provisionals** — each liberated post office overprinted whatever enemy stock was in its safe,
valid only in its own district with stated expiry. Zagreb's (20 Jun 1945) *postdates* the
national Tito definitive. **Macedonia had no regional provisional at all.** Belgrade's
(14–16 Dec 1944) *is* the first DFJ national issue, not a regional one.

**1918–21 was four postal administrations, not one.** Serbia (Corfu issue, valid to 15 Apr
1921), Croatia/Slavonia (overprints on Hungarian stock), Slovenia (Ljubljana "Chainbreakers")
and Bosnia (overprints on A-H stock) ran in parallel with separate currencies. Only three
carried the "SHS" abbreviation. **Our single SHS node collapses them** — a known simplification.

---

## Applied to the database

10 curated edges added; `Austria-Hungary` added as an issuer (the Wikipedia inventory omits it,
and its ~955 Commons images would otherwise be misfiled under Bosnia). Verified after rebuild:

- **Croatia** now walks back through Yugoslavia → Kingdom of Yugoslavia → SHS / Kingdom of
  Serbia, and forward from Krajina and Sremsko-Baranjska Oblast.
- **Bosnia & Herzegovina** is connected to Yugoslavia (previously orphaned) and forward to its
  Serb and Croat operators.
- Searching **"Croatia"** surfaces 131 stamps across NDH, Provincial Issues, Krajina and SBO.

## Still open

- The four 1918–21 administrations are collapsed into one SHS node.
- Per-catalogue recognition (Scott vs Michel vs SG) is not modelled; RSK/SBO would need it.
- `stampworldhistory.com` appears defunct (404s); `stampworld.com` blocks automated fetch.
  Several specifics came from lower-grade sources and are flagged in-line above — verify
  against physical Michel Südosteuropa or SG Part 3 (Balkans) before treating as authoritative.
