# Corpus Sources — First-Hand Measurements
**Date:** 17 July 2026
**Method:** direct queries against live public endpoints. Every number below was measured, not
read in a blog post or inferred. Reproducing commands are included so the next reader can
re-run rather than trust.
**Status:** supersedes the "Data Sources" claims in `phase1-research-findings.md` and
`CLAUDE.md` for the two free sources. Web research on the licensed/commercial sources is
tracked separately.

> **Why this file exists.** Three Phase 1 claims have now failed under checking: the
> competitor landscape missed an entire product category, `stampscan.app` was invented as
> "our" domain while belonging to a live competitor, and the Wikidata seeding plan (below)
> does not exist. The remaining Phase 1 numbers — the 5–15M target, Colnect's 1.6M, Michel's
> ~850K — come from the same source and **must be treated as unverified until measured**.

---

## 1. Wikidata — ❌ REFUTED. Not usable as a seed.

**Phase 1 claimed:** *"Wikidata SPARQL — ✅ Free, use now — 100K+ stamp records, catalogue
cross-refs"*, and made it the immediate database seed.

**Measured:**

| Query | Result |
|---|---|
| `?i wdt:P31/wdt:P279* wd:Q37930` (postage stamp, incl. subclasses) | **12,753** |
| `?i wdt:P31 wd:Q37930` (direct) | 12,673 |
| …carrying `China movable cultural relic ID` | **12,550** |
| …carrying `country of origin` (P495) | 7,500 |
| …carrying an image (P18) | **78** |
| …carrying inception / issue date (P571) | **35** |
| …carrying face value | 21 |
| …carrying any catalogue cross-reference | **0 — no such property in use** |

**Conclusion:** Wikidata is not a stamp catalogue. It is **one Chinese museum's artefact
inventory**, bulk-imported, plus a long tail. 78 images and 35 issue dates cannot seed
anything. Every element of the Phase 1 claim is false: not 100K (12.7K), not structured
philatelic metadata (a museum accession list), and there are no catalogue cross-references at
all.

```bash
curl -sG https://query.wikidata.org/sparql \
  --data-urlencode 'query=SELECT (COUNT(DISTINCT ?i) AS ?n) WHERE { ?i wdt:P31/wdt:P279* wd:Q37930 }' \
  -H 'Accept: application/sparql-results+json' -H 'User-Agent: Rowland/0.1 (contact)'

# What data actually exists on those items:
curl -sG https://query.wikidata.org/sparql \
  --data-urlencode 'query=SELECT ?pLabel (COUNT(DISTINCT ?i) AS ?n) WHERE {
    ?i wdt:P31 wd:Q37930 . ?i ?prop ?v . ?p wikibase:directClaim ?prop .
    SERVICE wikibase:label { bd:serviceParam wikibase:language "en". }
  } GROUP BY ?pLabel ORDER BY DESC(?n) LIMIT 14' \
  -H 'Accept: application/sparql-results+json' -H 'User-Agent: Rowland/0.1 (contact)'
```

---

## 2. Wikimedia Commons — ⚠️ Real images, no catalogue. Valuable for **training**, not for records.

**Phase 1 claimed:** *"✅ Free, use now — Public domain stamp images"* — with no count.

**Measured** (CirrusSearch `deepcat:`, which walks the subcategory tree):

| Query | Files |
|---|---|
| `deepcat:"Stamps of Germany"` | **25,593** |
| `deepcat:"Stamps of the United States"` | **10,512** |
| `deepcat:"Stamps by country"` | 51,146 |
| `deepcat:"Postage stamps"` | 32 |

⚠️ **These are lower bounds, not totals.** `deepcat:` caps how many subcategories it resolves,
and the numbers prove it: "Stamps by country" (51,146) is barely above Germany + US combined
(36,105), which is arithmetically impossible if it were counting the whole tree. Shallow
`incategory:` counts are useless for the same reason — `Category:Stamps of the United States`
holds only **79 files directly** but has **40 subcategories**. A true total needs PetScan or a
category-graph walk.

**Assessment — the important nuance:**

- **As a catalogue seed: no.** Commons has files and categories, not structured records. No
  denominations, no issue dates as data, no catalogue numbers. Filenames and wikitext would
  need scraping and parsing, and the result would be dirty.
- **As ML training data: yes, and this is the actionable find.** The plan bootstraps the
  embedding model on **MiikeMineStamps (5,056 images, 407 classes)**. Germany alone on Commons
  is **25,593 images — 5× the entire planned training set**, and it is public-domain,
  categorised by country and often by year. This is the single cheapest available upgrade to
  model quality, and it is free and unblocked by any licensing question.
- Category structure gives weak labels for free (country, and often year/series), which is
  exactly what embedding training wants.

```bash
curl -sG https://commons.wikimedia.org/w/api.php \
  --data-urlencode 'action=query' --data-urlencode 'list=search' \
  --data-urlencode 'srsearch=deepcat:"Stamps of Germany"' \
  --data-urlencode 'srnamespace=6' --data-urlencode 'srlimit=1' \
  --data-urlencode 'format=json' -H 'User-Agent: Rowland/0.1 (contact)'
```

---

## What this means for "beyond a million"

Both free sources are now measured, and **neither gets close to 1M records**:

| Source | Records | Verdict |
|---|---|---|
| Wikidata | 12,753 (78 images) | Useless — museum inventory |
| Wikimedia Commons | ~50K+ images, lower bound | Training corpus, not a catalogue |

The Phase 1 plan was "seed from Wikidata + Commons, free and immediate, then licence later."
**The free seed does not exist.** Getting past 1M records means one of:

1. **A commercial licence** (Colnect, Stamp-Store), or
2. **Large-scale scraping** of Colnect / StampWorld / Michel — which runs directly into the
   unresolved catalogue-numbering rights question, or
3. **Aggregating many national/postal-museum/auction sources** — slow, and volume unproven.

All three are acquisition problems, not engineering problems. **This is the same question as
the Scott rights issue wearing a different hat, and it is the gating decision for the whole
database.**

Two open claims still to verify by measurement rather than repetition: **Colnect's 1.6M**, and
whether a **5–15M** universe of distinct philatelic items exists at all (it plausibly requires
counting every perforation/watermark/shade variety — a different thing from distinct issues).
