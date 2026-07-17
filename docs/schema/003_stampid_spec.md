# StampID — Universal Stamp Identifier Specification
**Version:** 1.0.0  
**Status:** Draft  
**Owner:** StampScan  

---

## 1. Purpose

StampID is a stable, human-readable, machine-parseable identifier that uniquely and permanently identifies a philatelic item across all catalogue systems. It is the primary key of the StampScan proprietary database and the IP layer that binds cross-catalogue references together.

**Design goals:**
- Globally unique — no two stamps ever share a StampID
- Human-readable — a philatelist can read a StampID and understand it
- Stable — once assigned, a StampID never changes, even if catalogue numbers change
- Hierarchy-aware — encodes issuer → year → base issue → variety
- Sortable — lexicographic sort approximates chronological/geographical order
- URL-safe — usable in API paths with no encoding
- Compact — fits in a QR code alongside other fields

---

## 2. Format Specification

```
SID-{ISSUER}-{YEAR}-{SEQ4}-{VAR}
```

### Components

| Component  | Length   | Character Set         | Description |
|------------|----------|-----------------------|-------------|
| `SID`      | 3        | Literal               | StampScan ID prefix; distinguishes from catalogue numbers |
| `{ISSUER}` | 2–6      | A-Z, 0-9              | Issuer code (see §3) |
| `{YEAR}`   | 4        | 0-9                   | Year of issue (see §4) |
| `{SEQ4}`   | 4        | 0-9                   | 4-digit sequence within issuer×year (0001–9999) |
| `{VAR}`    | 1–4      | A-Z, 0-9              | Variety suffix (see §5) |

### Full example breakdown

```
SID-US-1869-0006-B
│   │  │    │    └── Variety B (second variety of this base stamp)
│   │  │    └─────── Sequence 6 (6th distinct design/set in 1869 US issues)
│   │  └──────────── Year 1869
│   └─────────────── Issuer code "US" (United States Post Office)
└─────────────────── StampScan ID prefix
```

---

## 3. Issuer Codes

### 3.1 Format

Issuer codes are **2–6 uppercase characters** derived from ISO 3166-1 alpha-2 country codes with extensions for historical and non-sovereign issuers.

### 3.2 Derivation Rules (in order)

1. **Current sovereign nations**: Use ISO 3166-1 alpha-2 directly  
   `US` → United States, `GB` → Great Britain, `DE` → Germany, `FR` → France

2. **Historical states (pre-unification)**: ISO-2 + 2-char state code  
   `DEPR` → Prussia, `DEBV` → Bavaria, `DESN` → Saxony, `ITAT` → Austrian Italy (Lombardy-Venetia)

3. **Colonial/mandate issues**: Metropolitan ISO-2 + colony abbreviation  
   `GBKE` → British Kenya, `FRSN` → French Senegal, `NLSN` → Dutch Surinam

4. **Occupation issues**: ISO-2 + "OC" + occupying power initials  
   `BEOCDE` → Belgium under German occupation

5. **International organisations**: "INT" + 2-char org code  
   `INTUN` → United Nations, `INTIO` → International Olympic Committee

6. **Cinderellas / locals / phantoms**: "CIN" + 2-char code  
   `CINUS` → US local stamps

### 3.3 Issuer Code Registry (seed — top issuers)

```
US      United States
GB      Great Britain
DE      Germany (Federal Republic, post-1949)
FR      France
AU      Australia
CA      Canada
RU      Russia / Soviet Union (1917–1991 stamps)
SU      USSR (1923–1991 — distinct from Imperial Russia)
JP      Japan
CN      China (PRC, post-1949)
TW      Taiwan / Republic of China
IN      India
BR      Brazil
MX      Mexico
ZA      South Africa
NL      Netherlands
BE      Belgium
CH      Switzerland
AT      Austria
IT      Italy
ES      Spain
PT      Portugal
SE      Sweden
NO      Norway
DK      Denmark
FI      Finland
PL      Poland
HU      Hungary
CZ      Czechoslovakia / Czech Republic
SK      Slovakia
RO      Romania
BG      Bulgaria
GR      Greece
TR      Turkey
EG      Egypt
NG      Nigeria
KE      Kenya
GH      Ghana
RURE    Imperial Russia (pre-1917)
GBGE    George V-era GB (separate series tracking)
DEDR    German Democratic Republic (DDR / East Germany)
DEWE    West Germany (BRD 1949–1990)
DEDT    Third Reich (Germany 1933–1945)
DEII    German Empire (Deutsches Reich 1871–1918)
DEWM    Weimar Republic (Germany 1919–1933)
FRVI    France under Vichy (1940–1944)
ITKI    Kingdom of Italy (pre-1946)
GBNI    Northern Ireland
GBSC    Scotland (regional)
GBWL    Wales (regional)
GBJE    Jersey
GBGG    Guernsey
GBIOM   Isle of Man
AUQLD   Queensland (pre-federation)
AUNSW   New South Wales (pre-federation)
AUVIC   Victoria (pre-federation)
AUSA    South Australia (pre-federation)
INTUN   United Nations (NY, Geneva, Vienna)
```

---

## 4. Year Encoding

- Use the **year of issue** in 4-digit form: `1840`, `1923`, `2024`
- For undated stamps: use best-known estimate year (e.g., `1861` for circa-dated stamp)
- For very early issues with decade-level uncertainty: use decade's first year (`1850` for "ca. 1850s")
- Stamps issued across a multi-year period: use **year printing began**
- Postmaster provisionals / locals: use year of use if known, else period start

---

## 5. Variety Suffix System

The variety suffix encodes philatelic varieties within a single base stamp.

### 5.1 Base stamp (no variety)

The first distinct design/denomination in a series gets no suffix letter — but the `{VAR}` component is set to `A` in storage (omittable in display):

```
SID-US-1869-0006-A    (base stamp — the "A" may be omitted in display)
SID-US-1869-0006      (display form, equivalent)
```

### 5.2 Single-letter varieties (A–Z)

Sequential for standard philatelic varieties:

| Suffix | Typical Meaning |
|--------|----------------|
| `A`    | Base stamp (type I) |
| `B`    | Type II / second colour shade / re-engraved |
| `C`    | Type III or imperforate variety |
| `D`    | Colour variety / special printing |
| `E`    | Re-issued / new paper type |
| `P`    | Proof (by convention) |
| `E`    | Essay (by convention — use `ES` if `E` taken) |
| `X`    | Error / EFO |

### 5.3 Extended variety codes (2-char)

When single letters are exhausted or more precision is needed:

| Code | Meaning |
|------|---------|
| `NH` | Never-hinged mint variant |
| `OP` | Overprinted version |
| `UX` | Used variant (for stamps where used changes identity) |
| `RC` | Revenue cancellation |
| `PP` | Perforation variety (compound perf) |
| `WM` | Watermark variety |
| `GR` | Gutter pair / interpanneau |
| `BK` | Booklet pane |
| `CO` | Coil stamp |
| `IP` | Imperforate pair |
| `SE` | Se-tenant block |
| `MS` | Miniature sheet |

### 5.4 Full variety examples

```
SID-US-1869-0006      → Base: 1869 US Pictorial 24c "Declaration" stamp
SID-US-1869-0006-B    → Inverted centre variety
SID-US-1869-0006-X    → Error variety
SID-GB-1840-0001      → Penny Black (base, plate 1a)
SID-GB-1840-0001-B    → Plate 2 printing
SID-GB-1840-0001-IP   → Imperforate pair
SID-RURE-1857-0001    → Russia first issue (10k brown)
SID-DEPR-1850-0001    → Prussia first issue
SID-DEII-1872-0001    → German Empire, Eagle design
```

---

## 6. Cross-Reference Schema

Each StampID maps to zero-to-many catalogue numbers via the `catalogue_references` table. The cross-reference is the core IP value of the database.

### 6.1 Cross-reference record structure

```json
{
  "stamp_id": "SID-GB-1840-0001",
  "catalogue_refs": [
    { "catalogue": "sg",     "number": "1",       "primary": true,  "confirmed": true },
    { "catalogue": "scott",  "number": "1",       "primary": true,  "confirmed": true },
    { "catalogue": "michel", "number": "1",       "primary": true,  "confirmed": true },
    { "catalogue": "yvert",  "number": "1",       "primary": true,  "confirmed": false },
    { "catalogue": "colnect","number": "GB-1840-1","primary": false, "confirmed": false }
  ]
}
```

### 6.2 Catalogue number format normalisation

Catalogue numbers vary by system. Normalise to:
- Strip leading zeros (Scott `001` → `1`)  
- Uppercase suffix letters (`1a` → `1A`)  
- Preserve prefix letters (`C1`, `J1`, `O1` for air/postage-due/official)  
- Store raw original in `cat_number_raw` alongside normalised `cat_number`

### 6.3 Ambiguity and collision handling

When a single catalogue number maps to multiple physical stamps (e.g., Scott includes both mint and used valuations under one number but they're physically different stamps):

- Create separate StampIDs with variety suffixes
- Flag as `ambiguous_source_number: true` in the cross-ref record
- The `is_primary` flag identifies which StampID is the canonical match for that catalogue number

### 6.4 Merge and split operations

Over time, catalogues split or merge numbers (e.g., Scott adds a `1A` that was previously just `1`). Handle via:

```sql
-- StampID aliases table
CREATE TABLE stamp_id_aliases (
  id              BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  canonical_id    BIGINT NOT NULL REFERENCES stamps(id),
  alias_stamp_id  TEXT NOT NULL UNIQUE,   -- old/merged StampID
  reason          TEXT,                   -- 'split', 'merge', 'reclassification'
  effective_date  DATE,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);
```

Old StampIDs resolve to their canonical successor via this table — permanent stable URLs.

---

## 7. API Representation

### 7.1 URL form
```
GET /v1/stamps/SID-GB-1840-0001
GET /v1/stamps/SID-US-1869-0006-B
GET /v1/stamps/by-catalogue/sg/1
GET /v1/stamps/by-catalogue/scott/1
```

### 7.2 JSON response shape
```json
{
  "stamp_id": "SID-GB-1840-0001",
  "uuid": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "issuer": {
    "code": "GB",
    "name": "Great Britain",
    "country_iso": "GB"
  },
  "format": "stamp",
  "issue_date": "1840-05-06",
  "denomination": { "value": 1, "currency": "GBP", "text": "1d" },
  "colour": ["black"],
  "subject": "Queen Victoria — profile left",
  "description": "The world's first adhesive postage stamp, issued 6 May 1840. Engraved portrait of Queen Victoria in black ink on bluish-white paper. Designed by William Wyon RA based on the 1837 City Medal. Printed by Perkins Bacon in sheets of 240.",
  "catalogue_refs": [
    { "catalogue": "sg",     "number": "1",  "confirmed": true },
    { "catalogue": "scott",  "number": "1",  "confirmed": true },
    { "catalogue": "michel", "number": "1",  "confirmed": true }
  ],
  "valuations": {
    "mint": { "usd_typical": 4500, "usd_range": [2000, 12000], "source": "auction_realised", "as_of": "2025-11-01" },
    "used": { "usd_typical": 125,  "usd_range": [40, 800],     "source": "auction_realised", "as_of": "2025-11-01" }
  },
  "images": {
    "primary": "https://cdn.stampscan.app/stamps/GB/1840/0001/front_800.jpg",
    "thumbnail": "https://cdn.stampscan.app/stamps/GB/1840/0001/thumb_200.jpg"
  },
  "source_tier": "official",
  "confidence": 0.99
}
```

---

## 8. StampID Generation Algorithm

```python
import re

ISSUER_REGISTRY = {
    # Loaded from database at runtime
}

def generate_stamp_id(issuer_code: str, issue_year: int, seq: int, variety: str = "A") -> str:
    """
    Generate a StampID.
    
    Args:
        issuer_code: Registered issuer code (e.g., "GB", "DEPR", "INTUN")
        issue_year: 4-digit year of issue
        seq: Sequence number within issuer+year (1-9999)
        variety: Variety suffix (default "A" = base stamp)
    
    Returns:
        StampID string, e.g., "SID-GB-1840-0001-A"
    """
    if issuer_code not in ISSUER_REGISTRY:
        raise ValueError(f"Unknown issuer code: {issuer_code}")
    if not 1840 <= issue_year <= 2100:
        raise ValueError(f"Invalid year: {issue_year}")
    if not 1 <= seq <= 9999:
        raise ValueError(f"Sequence out of range: {seq}")
    if not re.match(r'^[A-Z0-9]{1,4}$', variety):
        raise ValueError(f"Invalid variety suffix: {variety}")
    
    return f"SID-{issuer_code}-{issue_year}-{seq:04d}-{variety}"


def parse_stamp_id(stamp_id: str) -> dict:
    """Parse a StampID into its components."""
    pattern = r'^SID-([A-Z0-9]{2,6})-(\d{4})-(\d{4})(?:-([A-Z0-9]{1,4}))?$'
    m = re.match(pattern, stamp_id)
    if not m:
        raise ValueError(f"Invalid StampID format: {stamp_id}")
    
    issuer, year, seq, variety = m.groups()
    return {
        "issuer_code": issuer,
        "issue_year": int(year),
        "sequence": int(seq),
        "variety": variety or "A",
        "is_base": (variety is None or variety == "A"),
    }


def next_sequence(issuer_code: str, issue_year: int, db_cursor) -> int:
    """Get the next available sequence number for an issuer+year."""
    db_cursor.execute("""
        SELECT COALESCE(MAX(
            CAST(SPLIT_PART(stamp_id, '-', 4) AS INT)
        ), 0) + 1
        FROM stamps
        WHERE stamp_id LIKE %s
    """, (f"SID-{issuer_code}-{issue_year}-%",))
    return db_cursor.fetchone()[0]
```

---

## 9. Uniqueness Guarantees

### 9.1 Database constraint
```sql
-- stamps.stamp_id has UNIQUE constraint (see schema 001)
-- Enforced at DB level — no application-level collision possible
```

### 9.2 Collision prevention during bulk import
When importing from multiple sources simultaneously:
- Use a distributed lock on `(issuer_code, issue_year)` during sequence allocation
- Or use PostgreSQL advisory locks: `pg_try_advisory_lock(issuer_id * 10000 + year % 10000)`
- Or use a dedicated `stamp_id_sequences` table with `SELECT ... FOR UPDATE`

### 9.3 Deduplication fingerprint
Before assigning a new StampID, compute a deduplication fingerprint:

```python
import hashlib

def dedupe_fingerprint(issuer_code: str, year: int, denomination: str,
                        colour: list[str], perf: str | None) -> str:
    """
    Compute a deduplication fingerprint for a stamp.
    Two stamps with identical fingerprints are considered the same base stamp.
    """
    canonical = "|".join([
        issuer_code.upper(),
        str(year),
        denomination.lower().strip(),
        ",".join(sorted(c.lower().strip() for c in colour)),
        (perf or "").strip()
    ])
    return hashlib.sha256(canonical.encode()).hexdigest()[:16]
```

This fingerprint is stored as `stamps.dedupe_hash` (add column to schema) and has a UNIQUE index per `(issuer_id, dedupe_hash)` to prevent duplicate base stamps during crawl imports.

---

## 10. StampID in QR Codes and Physical Stamps

For printed catalogues, stock cards, or dealer inventory sheets:

```
QR content: https://stampscan.app/s/SID-GB-1840-0001
Short form:  stampscan.app/s/SID-US-1869-0006-B
Barcode:     Code 128 of the full StampID string
```

The `/s/` shortpath redirects to the full API response in the iOS app via Universal Links.

---

## 11. Versioning and Governance

- StampID spec version is `MAJOR.MINOR.PATCH` (this is v1.0.0)
- **MAJOR**: Breaking changes to format (never expected — designed for permanence)
- **MINOR**: New issuer codes, variety codes, or extensions (backward compatible)
- **PATCH**: Clarifications, documentation fixes
- The Issuer Code Registry is managed in the `issuers` database table and has a versioned export at `/v1/meta/issuer-codes`
- Deprecated StampIDs are never deleted — only aliased via `stamp_id_aliases`

---

## 12. Migration from Existing Catalogue Numbers

### 12.1 Reverse lookup API
```
GET /v1/stamps/by-catalogue/scott/1
GET /v1/stamps/by-catalogue/sg/200a
GET /v1/stamps/by-catalogue/michel/1
```

### 12.2 Bulk translation endpoint
```
POST /v1/stamps/translate-catalogue
Body: { "catalogue": "scott", "numbers": ["1", "2", "3", "C1", "J1"] }
Returns: [{ "cat_number": "1", "stamp_id": "SID-US-1847-0001", "confidence": 1.0 }, ...]
```

This is a **key commercial feature** — dealers and collectors who want to migrate their Scott or SG inventories into the app can do a one-shot bulk translation.
