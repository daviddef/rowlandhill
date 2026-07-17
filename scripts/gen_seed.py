#!/usr/bin/env python3
"""Generate 005_succession_seed.sql from the parsed Wikipedia entity inventory
plus hand-authored succession edges and vernacular aliases.

Design notes (why it is shaped this way):

* Wikipedia groups issuers into philatelic CLUSTERS ("Rhodesia" contains BSAC,
  Southern Rhodesia, Zambia, Zimbabwe...). A cluster is a naming/reference
  relation, NOT a legal parent. Clusters therefore become search_aliases, which
  is exactly the search behaviour we want: type "Rhodesia", get the lineage.
* Succession EDGES are not derivable from the clusters — USSR and Russia are
  separate clusters with no link between them, so a cluster-only graph would
  never connect Soviet stamps to Russia. Edges are hand-authored below.
* Identity: one issuer per distinct name. Names appearing in several clusters are
  usually one entity claimed by several successors (Straits Settlements ->
  Christmas Island/Labuan/Malaysia/Singapore) and are correctly merged. Purely
  GENERIC names are collisions, not shared entities, and are qualified instead.
"""
import json, re

# Generic descriptors that name no polity. Merging these across clusters would
# assert that Albania's occupation issues and America's are the same thing.
GENERIC = {"Occupation issues", "Foreign Post Offices", "Turkish Post Offices"}

def sq(s):
    return "'" + str(s).replace("'", "''") + "'" if s is not None else "NULL"

def date_lit(year, end=False):
    if year is None:
        return "NULL"
    return sq(f"{year}-12-31" if end else f"{year}-01-01")

def infer_type(name, cluster, end):
    n = name.lower()
    if "occupation" in n or "military administration" in n:
        return "occupation"
    if "post office" in n or "post abroad" in n or "postal agenc" in n or "post in" in n:
        return "post_abroad"
    if "colony" in n or "colonial" in n or "company" in n:
        return "colony"
    if "mandate" in n or "trust territory" in n:
        return "mandate"
    if "government in exile" in n:
        return "government_in_exile"
    if "state" in n and "settlements" not in n:
        return "state"
    return "national_post" if end is None else "historic"

# --- Hand-authored succession edges -----------------------------------------
# (predecessor, successor, type, date, note). Names must match the inventory;
# any that do not are reported and skipped rather than silently inserted.
EDGES = [
    # USSR — the case cluster-grouping misses entirely
    ("USSR", "Russia", "dissolution", "1991-12-26", "USSR dissolved into 15 successor states; Russia is the continuator state"),
    ("USSR", "Ukraine", "dissolution", "1991-12-26", None),
    ("USSR", "Belarus", "dissolution", "1991-12-26", None),
    ("USSR", "Kazakhstan", "dissolution", "1991-12-26", None),
    ("USSR", "Uzbekistan", "dissolution", "1991-12-26", None),
    ("USSR", "Georgia", "dissolution", "1991-12-26", None),
    ("USSR", "Armenia", "dissolution", "1991-12-26", None),
    ("USSR", "Azerbaijan", "dissolution", "1991-12-26", None),
    ("USSR", "Moldova", "dissolution", "1991-12-26", None),
    ("USSR", "Latvia", "dissolution", "1991-12-26", "Baltic states regard 1940-91 as occupation, not succession — contested"),
    ("USSR", "Lithuania", "dissolution", "1991-12-26", "Contested: see Latvia note"),
    ("USSR", "Estonia", "dissolution", "1991-12-26", "Contested: see Latvia note"),
    ("USSR", "Kyrgyzstan", "dissolution", "1991-12-26", None),
    ("USSR", "Tajikistan", "dissolution", "1991-12-26", None),
    ("USSR", "Turkmenistan", "dissolution", "1991-12-26", None),
    ("Russia (pre-Soviet)", "USSR", "regime_change", "1923-12-30", "Russian Empire/RSFSR issues precede the USSR"),

    # Rhodesia — two living successors, the canonical many-to-many
    ("British South Africa Company", "Southern Rhodesia", "renamed", "1924-01-01", None),
    ("British South Africa Company", "Northern Rhodesia", "partition", "1924-01-01", "BSAC territory split north/south"),
    ("Southern Rhodesia", "Rhodesia and Nyasaland", "merger", "1954-01-01", None),
    ("Northern Rhodesia", "Rhodesia and Nyasaland", "merger", "1954-01-01", None),
    ("Rhodesia and Nyasaland", "Rhodesia", "dissolution", "1964-12-31", "Federation dissolved"),
    ("Rhodesia and Nyasaland", "Zambia", "dissolution", "1964-12-31", None),
    ("Rhodesia and Nyasaland", "Malawi", "dissolution", "1964-12-31", None),
    ("Rhodesia", "Zimbabwe", "renamed", "1980-04-18", "UDI Rhodesia -> Zimbabwe at independence"),

    # Germany
    ("Imperial Germany", "Weimar Republic", "regime_change", "1919-01-01", None),
    ("Weimar Republic", "Third Reich", "regime_change", "1933-01-30", None),
    ("Third Reich", "Germany (Allied Occupation)", "occupation", "1945-05-08", None),
    ("Germany (Allied Occupation)", "West Germany", "partition", "1949-05-23", None),
    ("Germany (Allied Occupation)", "East Germany", "partition", "1949-10-07", None),
    ("Germany (Allied Occupation)", "West Berlin", "partition", "1948-01-01", None),
    ("West Germany", "Germany", "merger", "1990-10-03", "Reunification"),
    ("East Germany", "Germany", "merger", "1990-10-03", "Reunification"),
    ("West Berlin", "Germany", "merger", "1990-10-03", None),

    # Yugoslavia
    ("Serbia (Kingdom of)", "Yugoslavia (Kingdom)", "merger", "1921-01-01", "Kingdom of Serbs, Croats and Slovenes"),
    ("Yugoslavia (Kingdom)", "Yugoslavia", "regime_change", "1944-01-01", None),
    ("Yugoslavia", "Serbia and Montenegro", "renamed", "2003-02-04", None),
    ("Serbia and Montenegro", "Serbia (Republic of)", "dissolution", "2006-06-05", None),
    ("Serbia and Montenegro", "Montenegro", "dissolution", "2006-06-03", None),
    ("Yugoslavia", "Croatia", "dissolution", "1991-06-25", None),
    ("Yugoslavia", "Slovenia", "dissolution", "1991-06-25", None),
    ("Yugoslavia", "North Macedonia", "dissolution", "1991-09-08", None),

    # Renames — the simple, high-value cases
    ("Ceylon", "Sri Lanka", "renamed", "1972-05-22", None),
    ("Czechoslovakia", "Czech Republic", "dissolution", "1993-01-01", "Velvet Divorce"),
    ("Czechoslovakia", "Slovakia", "dissolution", "1993-01-01", "Velvet Divorce"),
]

# --- Vernacular / inscription aliases ---------------------------------------
# What a collector reads off the stamp itself. Sourced from the Wikibooks Stamp
# Identifier and Mystic Stamp inscription indexes.
VERNACULAR = [
    ("CCCP", "USSR", "transliteration"),
    ("SSSR", "USSR", "transliteration"),
    ("Soviet Union", "USSR", "common_name"),
    ("Helvetia", "Switzerland", "local_name"),
    ("Nippon", "Japan", "local_name"),
    ("Suomi", "Finland", "local_name"),
    ("Magyar", "Hungary", "local_name"),
    ("Magyar Posta", "Hungary", "local_name"),
    ("España", "Spain", "local_name"),
    ("Espana", "Spain", "local_name"),
    ("Deutsche Bundespost", "West Germany", "local_name"),
    ("Deutsche Post", "East Germany", "local_name"),
    ("DDR", "East Germany", "abbreviation"),
    ("Deutsches Reich", "Third Reich", "local_name"),
    ("Sverige", "Sweden", "local_name"),
    ("Norge", "Norway", "local_name"),
    ("Danmark", "Denmark", "local_name"),
    ("Nederland", "Netherlands (territory in Europe)", "local_name"),
    ("Holland", "Netherlands (territory in Europe)", "common_name"),
    ("Belgie", "Belgium", "local_name"),
    ("Belgique", "Belgium", "local_name"),
    ("Osterreich", "Austria", "local_name"),
    ("Österreich", "Austria", "local_name"),
    ("Ellas", "Greece", "transliteration"),
    ("Hellas", "Greece", "transliteration"),
    ("Polska", "Poland", "local_name"),
    ("Ceska Republika", "Czech Republic", "local_name"),
    ("Ceskoslovensko", "Czechoslovakia", "local_name"),
    ("Jugoslavija", "Yugoslavia", "local_name"),
    ("Shqiperia", "Albania", "local_name"),
    ("Shqipenia", "Albania", "local_name"),
    ("Persia", "Iran", "former_name"),
    ("Siam", "Thailand", "former_name"),
    ("Myanmar", "Burma", "common_name"),
    ("Congo (Kinshasa)", "Zaire", "common_name"),
    ("Dahomey", "Benin", "former_name"),
    ("Upper Volta", "Burkina Faso", "former_name"),
    ("Basutoland", "Lesotho", "former_name"),
    ("Bechuanaland", "Botswana", "former_name"),
    ("Nyasaland", "Malawi", "former_name"),
    ("Tanganyika", "Tanzania", "former_name"),
    ("Formosa", "Taiwan", "former_name"),
    ("Ceylon", "Sri Lanka", "former_name"),
    ("Eswatini", "Swaziland", "common_name"),
    ("Persia", "Iran", "former_name"),
    ("Rhodesia", "Zimbabwe", "former_name"),
]

def load_researched_edges(path="researched_edges.json"):
    """Merge in succession edges produced by the research workflow.

    Each was proposed by a historian agent and then survived a skeptical fact-checker.
    The hand-curated EDGES above remain the trusted core and win on conflict.
    """
    import os
    if not os.path.exists(path):
        return []
    data = json.load(open(path))
    out = []
    for e in data:
        note = (e.get("notes") or "").strip()
        tags = []
        if e.get("contested"):
            tags.append("CONTESTED")
        if e.get("confidence") and e["confidence"] != "high":
            tags.append(f"confidence={e['confidence']}")
        if tags:
            note = (note + " " if note else "") + "[" + "; ".join(tags) + "]"
        out.append((e["predecessor"], e["successor"], e["succession_type"],
                    e.get("succession_date") or None, note or None))
    return out


def main():
    groups = json.load(open("entities.json"))

    # name -> {clusters, start, end}
    issuers = {}
    for g in groups:
        cluster = g["group"]
        for e in g["entities"]:
            key = f'{e["name"]} ({cluster})' if e["name"] in GENERIC else e["name"]
            rec = issuers.setdefault(key, {"clusters": set(), "start": e["start"], "end": e["end"]})
            rec["clusters"].add(cluster)
            # widest observed active window
            if e["start"] and (rec["start"] is None or e["start"] < rec["start"]):
                rec["start"] = e["start"]
            if rec["end"] is not None and e["end"] is None:
                rec["end"] = None          # an open period wins: still issuing
            elif rec["end"] is not None and e["end"] and e["end"] > rec["end"]:
                rec["end"] = e["end"]

    out = []
    w = out.append
    w("-- 005_succession_seed.sql")
    w("-- Philatelic issuer inventory + succession graph + search aliases.")
    w("--")
    w("-- GENERATED — do not hand-edit. Regenerate with scripts/gen_seed.py.")
    w("-- Inventory source: Wikipedia, 'List of entities that have issued postage stamps'")
    w("--   (A-E, F-L, M-Z), fetched 17 July 2026. Scope: 'any kind of governmental entity")
    w("--   or officially approved organisation that has issued distinctive postage stamps'.")
    w("-- Succession edges and vernacular aliases are HAND-AUTHORED (see script) because")
    w("--   Wikipedia's groupings are a naming convention, not a lineage graph: USSR and")
    w("--   Russia sit in separate groups with no link between them.")
    w("--")
    w(f"-- Issuers: {len(issuers)}   Succession edges: {len(EDGES)}   Vernacular aliases: {len(VERNACULAR)}")
    w("")
    w("BEGIN;")
    w("")
    w("-- Idempotency: the seed keys issuers by name, and an alias points at an entity once.")
    w("CREATE UNIQUE INDEX IF NOT EXISTS issuers_name_key ON issuers (name);")
    w("CREATE UNIQUE INDEX IF NOT EXISTS search_aliases_uniq")
    w("  ON search_aliases (alias, entity_type, entity_id);")
    w("CREATE UNIQUE INDEX IF NOT EXISTS issuer_succession_uniq")
    w("  ON issuer_succession (predecessor_id, successor_id, succession_type);")
    w("")
    w("-- ---------------------------------------------------------------------------")
    w("-- 1. Issuers")
    w("-- ---------------------------------------------------------------------------")
    w("INSERT INTO issuers (name, issuer_type, active_from, active_to, notes) VALUES")
    rows = []
    for name in sorted(issuers):
        r = issuers[name]
        cl = ", ".join(sorted(r["clusters"]))
        note = f"Philatelic cluster: {cl}. Source: Wikipedia list of stamp-issuing entities."
        rows.append(f"  ({sq(name)}, {sq(infer_type(name, cl, r['end']))}, "
                    f"{date_lit(r['start'])}, {date_lit(r['end'], end=True)}, {sq(note)})")
    w(",\n".join(rows))
    w("ON CONFLICT (name) DO NOTHING;")
    w("")
    w("-- ---------------------------------------------------------------------------")
    w("-- 2. Cluster aliases — typing 'Rhodesia' must reach every issuer in the lineage.")
    w("--    A cluster is a philatelic naming relation, not a claim of legal succession.")
    w("-- ---------------------------------------------------------------------------")
    w("INSERT INTO search_aliases (alias, alias_type, entity_type, entity_id)")
    alias_rows = []
    emitted = set()
    for name in sorted(issuers):
        for cl in sorted(issuers[name]["clusters"]):
            if cl == name or (cl, name) in emitted:
                continue
            emitted.add((cl, name))
            alias_rows.append(
                f"SELECT {sq(cl)}, 'former_name', 'issuer', id\n"
                f"  FROM issuers WHERE name = {sq(name)}")
    w("\nUNION ALL\n".join(alias_rows))
    w("ON CONFLICT (alias, entity_type, entity_id) DO NOTHING;")
    w("")
    w("-- ---------------------------------------------------------------------------")
    w("-- 3. Vernacular / inscription aliases — what is printed on the stamp itself.")
    w("-- ---------------------------------------------------------------------------")
    w("INSERT INTO search_aliases (alias, alias_type, entity_type, entity_id)")
    vr = []
    missing_alias = []
    dupes = 0
    for alias, target, atype in VERNACULAR:
        if target not in issuers:
            missing_alias.append((alias, target))
            continue
        if (alias, target) in emitted:
            # Already covered by a cluster alias of the same name (e.g. "Rhodesia").
            dupes += 1
            continue
        emitted.add((alias, target))
        vr.append(f"SELECT {sq(alias)}, {sq(atype)}, 'issuer', id\n"
                  f"  FROM issuers WHERE name = {sq(target)}")
    w("\nUNION ALL\n".join(vr))
    w("ON CONFLICT (alias, entity_type, entity_id) DO NOTHING;")
    w("")
    w("-- ---------------------------------------------------------------------------")
    w("-- 4. Succession edges — hand-authored. NOT derivable from the clusters.")
    w("-- ---------------------------------------------------------------------------")
    w("INSERT INTO issuer_succession (predecessor_id, successor_id, succession_type, succession_date, notes)")
    er = []
    missing_edge = []
    seen_edges = set()
    all_edges = list(EDGES)
    researched = load_researched_edges()
    for edge in researched:
        key = (edge[0], edge[1], edge[2])
        if key not in {(e[0], e[1], e[2]) for e in EDGES}:
            all_edges.append(edge)
    for pred, succ, stype, date, note in all_edges:
        if (pred, succ, stype) in seen_edges:
            continue
        seen_edges.add((pred, succ, stype))
        if pred not in issuers or succ not in issuers:
            missing_edge.append((pred, succ, pred not in issuers, succ not in issuers))
            continue
        date_sql = f"{sq(date)}::date" if date else "NULL::date"
        er.append(f"SELECT p.id, s.id, {sq(stype)}, {date_sql}, {sq(note)}\n"
                  f"  FROM issuers p, issuers s WHERE p.name = {sq(pred)} AND s.name = {sq(succ)}")
    w("\nUNION ALL\n".join(er))
    w("ON CONFLICT (predecessor_id, successor_id, succession_type) DO NOTHING;")
    w("")
    w("COMMIT;")
    w("")

    open("005_succession_seed.sql", "w").write("\n".join(out))

    print(f"issuers:            {len(issuers)}")
    print(f"cluster aliases:    {len(alias_rows)}")
    print(f"vernacular aliases: {len(vr)}  (skipped {len(missing_alias)} missing, {dupes} already covered by a cluster alias)")
    print(f"succession edges:   {len(er)}  (curated {len(EDGES)}, researched {len(researched)}, skipped {len(missing_edge)})")
    if missing_alias:
        print("\n  aliases skipped — no matching issuer:")
        for a, t in missing_alias:
            print(f"    {a!r} -> {t!r}")
    if missing_edge:
        print("\n  edges skipped — name not in inventory:")
        for p, s, pm, sm in missing_edge:
            print(f"    {p!r} -> {s!r}   (missing: {'pred' if pm else ''}{' & ' if pm and sm else ''}{'succ' if sm else ''})")

if __name__ == "__main__":
    main()
