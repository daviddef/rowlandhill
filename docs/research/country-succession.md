# Country Succession & Name Changes — Dataset Build
**Date:** 17 July 2026
**Artefacts:** `docs/schema/005_succession_seed.sql` · `docs/data/philatelic-entities.json`
· `scripts/parse_entities.py` · `scripts/gen_seed.py`
**Status:** inventory substantially complete; **succession graph ~5% complete** (see Gaps).

---

## What exists now

| | Count |
|---|---|
| **Issuing entities** | **1,181** |
| …of which dead (have a last-issue date) | **879** |
| Philatelic clusters (Wikipedia groupings) | 321 |
| **Cluster aliases** (search: "Rhodesia" → lineage) | **1,021** |
| **Vernacular aliases** (CCCP, Helvetia, Nippon…) | **46** |
| **Succession edges** (hand-authored) | **44** |

Regenerate end-to-end:

```bash
cd scripts
python3 parse_entities.py   # fetches nothing; parses wp_*.json → entities.json
python3 gen_seed.py         # entities.json → 005_succession_seed.sql
```

---

## Source

**Wikipedia, "List of entities that have issued postage stamps"** (A–E / F–L / M–Z), fetched
17 July 2026 via the MediaWiki API. Its scope is exactly ours: *"any kind of governmental
entity or officially approved organisation that has issued distinctive types of stamp for
postal purposes"*, explicitly including the defunct entities philatelists call **"dead
countries"**.

Cross-checks used for aliases: the Wikibooks *Stamp Identifier* and Mystic Stamp's
inscription index. DCStamps independently counts **650+ defunct entities**, which is the right
order of magnitude against our 879 — a useful sanity check that the inventory is not missing a
whole continent.

---

## The structural finding that shaped the model

**Wikipedia's groupings are a naming convention, not a lineage graph.** This is the thing to
understand before touching the data.

The `===Rhodesia===` group contains BSAC, Northern/Southern Rhodesia, the Federation, **and
both living successors, Zambia and Zimbabwe**. Meanwhile `===Zimbabwe===` is an *empty*
cross-reference stub. So the grouping is a **cluster of related issuers**, not a parent→child
edge.

Worse, the clusters do not connect what actually needs connecting: **USSR and Russia sit in
separate clusters with no link between them.** A cluster-only graph would never return Soviet
stamps for a "Russia" search — the exact failure the succession engine exists to prevent.

Hence the two-layer model:

1. **Clusters → `search_aliases`.** Every issuer gets an alias for each cluster it belongs to.
   Typing "Rhodesia" reaches all nine members of the lineage. This is honest: it asserts a
   philatelic naming relation, not legal succession.
2. **Succession → `issuer_succession`, hand-authored.** Real predecessor→successor edges with
   dates and types (`dissolution`, `renamed`, `partition`, `merger`, `regime_change`,
   `occupation`). Not derivable from the source; every edge is a deliberate claim.

The generator **validates every authored edge against the inventory** and refuses to emit one
whose endpoints don't exist — it reports them instead. That check caught eight bad edges
(`Czechia` is actually `Czech Republic`; `Serbia` is `Serbia (Republic of)`; there is no
`Eswatini` issuer at all — Eswatini is a *rename of Swaziland*, so it is an alias, not an edge).

### Many-to-many is real, and the docs were right to warn about it

**40 entity names appear in more than one cluster.** Most are genuinely one entity claimed by
several successors and are correctly merged:

- **Straits Settlements** → Christmas Island, Labuan, Malaysia, Singapore
- **US post in the Trust Territory of the Pacific Islands** → Marshall Islands, Micronesia, Palau
- **Rhodesia and Nyasaland** → Malawi *and* Rhodesia

A naive one-parent graph gets all of these wrong. `issuer_succession` is a proper edge list, so
it models them correctly — e.g. the Federation dissolves into **three** successors.

Three names are **generic collisions, not shared entities** — "Occupation issues" appears under
both Albania and the United States, and merging them would assert they are the same thing.
These are qualified with their cluster (`Occupation issues (Albania)`). The denylist is in
`gen_seed.py`.

---

## 🚨 The schema had never been run. It did not apply.

`CLAUDE.md` lists "PostgreSQL schema (17 tables, all indexes)" as **✅ DONE**. Applied to a real
PostgreSQL 16 for the first time on 17 July 2026, **it failed immediately** — and so did the
succession engine that is the centrepiece of the whole design.

| File | Error | Cause |
|---|---|---|
| `001_core_schema.sql` | `functions in index expression must be marked IMMUTABLE` | **Two** separate problems in the FTS index: `to_tsvector('english', …)` resolves to the STABLE `to_tsvector(text,text)` (needs a `::regconfig` cast), **and** `array_to_string(anyarray,text)` is STABLE. The whole schema aborted on this one index. |
| `004_succession_schema.sql` | `recursive reference to query "lineage" must not appear within its non-recursive term` | **`get_issuer_lineage()` was invalid SQL and had never executed.** A `WITH RECURSIVE` permits one union between the non-recursive and recursive terms; it had two (`base UNION ALL walk-back UNION ALL walk-forward`), so Postgres read walk-back as part of the non-recursive term. |

`get_issuer_lineage()` also had a second, worse bug that would only have appeared at runtime:
**a bidirectional walk with no cycle guard.** A → successor B → predecessor A → successor B …
The `depth BETWEEN -20 AND 20` guard never stops it, because the oscillation keeps depth inside
the bounds forever. Fixed by carrying a `visited` path array.

Added `get_issuer_lineage_by_issuer()` — the country-level function needs a populated
`countries` + `country_succession` graph, but the real data is issuer-level (issuers rarely map
1:1 onto a modern country; that *is* the succession problem). This is the one the API should call.

**Now verified end-to-end against PostgreSQL 16.14:** all three files apply to an empty
database, and re-applying `005` is idempotent (unique indexes on `issuers(name)`,
`search_aliases(alias, entity_type, entity_id)` and
`issuer_succession(predecessor_id, successor_id, succession_type)` plus `ON CONFLICT DO NOTHING`).

```
=== Search "Rhodesia"                    === Succession walk from USSR
 British South Africa Company 1890-1924    -1  Russia (pre-Soviet)
 Rhodesia (British Colonial)  1909-1924     0  USSR
 Nyasa-Rhodesia Force (NF)    1916          1  Armenia, Azerbaijan, Belarus, Estonia,
 Southern Rhodesia            1924-1964        Georgia, Kazakhstan, Kyrgyzstan, Latvia,
 Northern Rhodesia            1925-1964        Lithuania, Moldova, Russia, Tajikistan,
 Rhodesia and Nyasaland       1954-1964        Turkmenistan, Ukraine, Uzbekistan
 Zambia                       1964-
 Zimbabwe                     1980-          (15 successors + ancestor)
```

### Footgun: `search_aliases` is polymorphic with no foreign key

`entity_id INT NOT NULL` + `entity_type TEXT` — there is no FK, so **nothing prevents an alias
pointing at a row that does not exist**, and every query *must* filter on `entity_type` or it
silently joins country ids against issuer ids. This caught me within a minute of querying:
`CCCP` appeared to resolve to "Algeria (French Colony)" because a country-scoped alias id
collided with an issuer id. The data was fine; the query was wrong. The API will hit this too —
either always filter `entity_type`, or split the table per entity type.

---

## Three parser bugs found by checking the data, not by reading the code

Recorded because each would have silently poisoned the dataset, and because they show why the
"just scrape Wikipedia" instinct needs verification at every step:

1. **Bibliography rows became stamp issuers.** The parser matched level-3 `===Entity===`
   headings but ignored level-2 `==References==`, so bullets under References/See also were
   attributed to whichever entity came last. *"Stanley Gibbons Ltd, various catalogues"* and
   *"Stuart Rossiter & John Flower, The Stamp Atlas"* were being inserted as issuers of
   Ethiopia, Luxembourg and Zululand — the final section of each of the three pages. **23 junk
   rows.**
2. **Multi-period entities were mangled.** Entities routinely have several disjoint issuing
   periods separated by semicolons — `Latvia 1918–1940; 1991 –`, `Czechoslovakia 1918 – 1939;
   1945 – 1992`. The parser took only the last period and left the rest **inside the entity
   name**, producing an issuer literally called `'Latvia 1918–1940'` whose start date was 1991.
   Seven entities affected, including Estonia, Lithuania and Dahomey.
3. **`"1923 only"` single-year issuers** were unparsed, leaving the year in the name
   (`'Nyasa-Rhodesia Force (NF) 1916 only'`). Fixing it recovered **123 additional dates**.

---

## Gaps — read before trusting this

- 🚨 **The succession graph is ~5% complete.** 44 edges against **879 dead entities**. The
  authored lineages are USSR (15 successors), Rhodesia, Germany, Yugoslavia, Czechoslovakia,
  Ceylon→Sri Lanka, Serbia. **Everything else — the French, British, Portuguese, Spanish, Dutch,
  Belgian and Italian colonial transitions, the Indian Native States, the German and Italian
  states, the Gulf states — has no edges yet.** The *inventory* covers them; the *graph* does
  not.
- **Cluster aliases partially cover the gap.** Search works for anything Wikipedia grouped
  together even without an edge. It fails wherever Wikipedia split a lineage across clusters,
  as with USSR/Russia — and we do not yet know how many other such splits exist.
- **Dates are year-granularity**, widened to `YYYY-01-01` / `YYYY-12-31`. Fine for search,
  **not** for adjudicating which issuer was active on a given day.
- **Multi-period entities are flattened** into one span in `issuers.active_from/active_to`,
  so Latvia reads 1918–present and the 1940–91 Soviet gap is lost. The exact periods survive in
  `philatelic-entities.json`. The schema has no period table; adding one is the fix.
- **`issuer_type` is inferred from name patterns** ("occupation", "colony", "post office"…).
  It is a guess, not a source claim.
- **Unverified against a second source.** Wikipedia is one source. DCStamps' 650+ and
  StampWorldHistory's line-of-succession data should be cross-checked before this is called
  authoritative.
- **Coverage is of entities, not stamps.** This dataset has no stamps in it. It is the spine
  the corpus hangs on — see `corpus-sourcing.md` for why the corpus itself is an acquisition
  problem.

## ⚠️ The Elasticsearch synonym filter contradicts the succession graph

`002_elasticsearch_mappings.json` carries **six hardcoded synonym lines** — against the 1,063
aliases now in `search_aliases`. It is a second, unsynchronised mechanism doing the same job,
and one line is philatelically wrong:

```
ussr,soviet union,russia,cccp        <-- makes USSR and Russia the same issuer
```

`CLAUDE.md` says this filter "handles real-time search" for succession. It cannot. A synonym is
a symmetric, undated, unqualified equality: it asserts a 1995 Russian issue and a 1970 Soviet
issue are the same thing, and gives a collector no way to ask for one and not the other. The
succession graph exists precisely to express what a synonym cannot — **direction, dates, type,
and contested-ness**.

**Recommendation:** resolve aliases at query time against `search_aliases` / the succession
graph and filter by `issuer_id`; keep ES synonyms for genuine spelling variants only
(`Espana`/`España`, `Osterreich`/`Österreich`). Do not regenerate the synonym list from the
alias table — that would encode 1,063 false equalities instead of six.

---

## Next

1. ~~Author the colonial-empire edges~~ — in progress; see the research fan-out results.
2. Cross-check against StampWorldHistory, which publishes an explicit "line of succession"
   field per entity.
3. Add an `issuer_periods` table so multi-period entities stop lying about their gaps.
4. Fix the ES synonym filter per the recommendation above.
