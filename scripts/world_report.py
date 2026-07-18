#!/usr/bin/env python3
"""Build a coverage report: EVERY country in the world with our stamp-record count,
including the many we have zero for. Reads the harvest checkpoint (deep_records.json),
aggregates by the Commons country label each record was tagged with, and overlays the
canonical world-country list so gaps show as 0.
"""
import json, re, sys
from collections import Counter

# UN member + observer states and the main stamp-issuing dependencies/territories.
WORLD = [
"Afghanistan","Albania","Algeria","Andorra","Angola","Antigua and Barbuda","Argentina","Armenia",
"Australia","Austria","Azerbaijan","Bahamas","Bahrain","Bangladesh","Barbados","Belarus","Belgium",
"Belize","Benin","Bhutan","Bolivia","Bosnia and Herzegovina","Botswana","Brazil","Brunei","Bulgaria",
"Burkina Faso","Burundi","Cambodia","Cameroon","Canada","Cape Verde","Central African Republic","Chad",
"Chile","China","Colombia","Comoros","Congo (Republic)","Congo (DR)","Costa Rica","Croatia","Cuba",
"Cyprus","Czechia","Denmark","Djibouti","Dominica","Dominican Republic","Ecuador","Egypt","El Salvador",
"Equatorial Guinea","Eritrea","Estonia","Eswatini","Ethiopia","Fiji","Finland","France","Gabon","Gambia",
"Georgia","Germany","Ghana","Greece","Grenada","Guatemala","Guinea","Guinea-Bissau","Guyana","Haiti",
"Honduras","Hungary","Iceland","India","Indonesia","Iran","Iraq","Ireland","Israel","Italy","Ivory Coast",
"Jamaica","Japan","Jordan","Kazakhstan","Kenya","Kiribati","Korea (North)","Korea (South)","Kosovo",
"Kuwait","Kyrgyzstan","Laos","Latvia","Lebanon","Lesotho","Liberia","Libya","Liechtenstein","Lithuania",
"Luxembourg","Madagascar","Malawi","Malaysia","Maldives","Mali","Malta","Marshall Islands","Mauritania",
"Mauritius","Mexico","Micronesia","Moldova","Monaco","Mongolia","Montenegro","Morocco","Mozambique",
"Myanmar","Namibia","Nauru","Nepal","Netherlands","New Zealand","Nicaragua","Niger","Nigeria",
"North Macedonia","Norway","Oman","Pakistan","Palau","Palestine","Panama","Papua New Guinea","Paraguay",
"Peru","Philippines","Poland","Portugal","Qatar","Romania","Russia","Rwanda","Saint Kitts and Nevis",
"Saint Lucia","Saint Vincent and the Grenadines","Samoa","San Marino","Sao Tome and Principe",
"Saudi Arabia","Senegal","Serbia","Seychelles","Sierra Leone","Singapore","Slovakia","Slovenia",
"Solomon Islands","Somalia","South Africa","South Sudan","Spain","Sri Lanka","Sudan","Suriname","Sweden",
"Switzerland","Syria","Taiwan","Tajikistan","Tanzania","Thailand","Timor-Leste","Togo","Tonga",
"Trinidad and Tobago","Tunisia","Turkey","Turkmenistan","Tuvalu","Uganda","Ukraine","United Arab Emirates",
"United Kingdom","United States","Uruguay","Uzbekistan","Vanuatu","Vatican City","Venezuela","Vietnam",
"Yemen","Zambia","Zimbabwe",
# stamp-issuing dependencies/territories commonly catalogued separately
"Anguilla","Aruba","Ascension Island","Bermuda","British Virgin Islands","Cayman Islands","Cook Islands",
"Faroe Islands","Falkland Islands","Gibraltar","Greenland","Guernsey","Hong Kong","Isle of Man","Jersey",
"Macau","Montserrat","Niue","Norfolk Island","Saint Helena","Turks and Caicos Islands",
]

# Commons label -> world name, where they differ.
ALIAS = {
 "the United States":"United States","the United Kingdom":"United Kingdom","the Netherlands":"Netherlands",
 "the Soviet Union":"Russia","the Democratic Republic of the Congo":"Congo (DR)",
 "the Republic of the Congo":"Congo (Republic)","the Comoros":"Comoros","Korea":"Korea (South)",
 "Macau":"Macau","Saint Kitts and Nevis":"Saint Kitts and Nevis","Ivory Coast":"Ivory Coast",
 "Czech Republic":"Czechia","Burma":"Myanmar",
}
def norm(lbl):
    if lbl in ALIAS: return ALIAS[lbl]
    return lbl[4:] if lbl.startswith("the ") else lbl

def main(paths=None):
    paths = paths or ["deep_records.json","deep_full_records.json","deep_under_records.json"]
    by_pid = {}
    for p in paths:
        try:
            for r in json.load(open(p)):
                by_pid[r["pageid"]] = r
        except FileNotFoundError:
            pass
    recs = list(by_pid.values())
    vol = Counter()
    hist = Counter()   # labels that aren't a modern world country (historical entities)
    worldset = set(WORLD)
    for r in recs:
        w = norm(r["label"])
        if w in worldset:
            vol[w] += 1
        else:
            hist[r["label"]] += 1

    covered = [(c, vol[c]) for c in WORLD if vol[c] > 0]
    zero    = [c for c in WORLD if vol[c] == 0]
    covered.sort(key=lambda x: -x[1])

    out = []
    out.append(f"WORLD COVERAGE — {len([c for c,_ in covered])} of {len(WORLD)} modern countries have stamps")
    out.append(f"Total records: {len(recs):,}   (harvest may still be running)\n")
    out.append("== COVERED (by volume) ==")
    for c, n in covered:
        out.append(f"  {n:>6,}  {c}")
    out.append(f"\n== ZERO — {len(zero)} modern countries with NO stamps yet ==")
    for i in range(0, len(zero), 3):
        out.append("  " + " · ".join(f"{c}" for c in zero[i:i+3]))
    out.append(f"\n== HISTORICAL / colonial entities also harvested ({len(hist)}) ==")
    for lbl, n in hist.most_common():
        out.append(f"  {n:>6,}  {lbl}")
    print("\n".join(out))
    json.dump({"covered":covered,"zero":zero,"historical":hist.most_common()},
              open("world_report.json","w"), ensure_ascii=False)

if __name__ == "__main__":
    main(sys.argv[1:] if len(sys.argv)>1 else None)
