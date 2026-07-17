#!/usr/bin/env python3
"""Validate succession edges produced by the research workflow and write
researched_edges.json for gen_seed.py.

The workflow's own fact-checker is one filter; this is the second, mechanical one.
An agent that invents an entity name produces an edge that cannot load, so every
endpoint is checked character-for-character against the parsed inventory. Anything
that does not match is reported, never guessed at.

Usage:  python3 merge_edges.py workflow_output.json
"""
import json, sys
from collections import Counter

def main(path):
    raw = json.load(open(path))
    # tolerate the workflow envelope or a bare list
    edges = raw.get("result", raw).get("edges", raw) if isinstance(raw, dict) else raw

    groups = json.load(open("entities.json"))
    valid = {e["name"] for g in groups for e in g["entities"]}
    # generic names get cluster-qualified in gen_seed; mirror that here
    GENERIC = {"Occupation issues", "Foreign Post Offices", "Turkish Post Offices"}
    for g in groups:
        for e in g["entities"]:
            if e["name"] in GENERIC:
                valid.add(f'{e["name"]} ({g["group"]})')

    kept, rejected = [], []
    seen = set()
    for e in edges:
        pred, succ = e.get("predecessor", ""), e.get("successor", "")
        why = None
        if pred not in valid:
            why = f"predecessor not in inventory: {pred!r}"
        elif succ not in valid:
            why = f"successor not in inventory: {succ!r}"
        elif pred == succ:
            why = "self-edge"
        elif (pred, succ, e.get("succession_type")) in seen:
            why = "duplicate"
        if why:
            rejected.append({**e, "_rejected": why})
            continue
        seen.add((pred, succ, e.get("succession_type")))
        kept.append(e)

    json.dump(kept, open("researched_edges.json", "w"), indent=1, ensure_ascii=False)
    json.dump(rejected, open("rejected_edges.json", "w"), indent=1, ensure_ascii=False)

    print(f"in:       {len(edges)}")
    print(f"kept:     {len(kept)}")
    print(f"rejected: {len(rejected)}")
    if rejected:
        reasons = Counter(r["_rejected"].split(":")[0] for r in rejected)
        for r, n in reasons.most_common():
            print(f"   {n:>4}  {r}")
        print("\n  first few rejects:")
        for r in rejected[:8]:
            print(f"    {r['_rejected']}")
    print()
    print("  by type:", dict(Counter(e.get("succession_type") for e in kept)))
    print("  by confidence:", dict(Counter(e.get("confidence") for e in kept)))
    print("  contested:", sum(1 for e in kept if e.get("contested")))

if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else "wf_edges.json")
