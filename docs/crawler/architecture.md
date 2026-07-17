# StampScan Crawler Architecture
**Version:** 1.0.0  
**Stack:** Node.js + Python | AWS Fargate + SQS | Playwright + Scrapy

---

## Overview

The StampScan crawler is a distributed multi-stage pipeline that discovers, extracts, deduplicates, and enriches stamp data from public web sources. It runs continuously as a background service, feeding the PostgreSQL + Elasticsearch database that powers the iOS app.

```
                    ┌─────────────────────────────────────────────────┐
                    │              CRAWLER PIPELINE                    │
                    │                                                  │
 Source configs  ──►│  DISCOVER  ──►  CRAWL  ──►  EXTRACT  ──►  DEDUP │
                    │     │            │              │             │   │
                    │     ▼            ▼              ▼             ▼   │
                    │   URLs       Raw HTML       JSON fields   Merge  │
                    │     │            │              │             │   │
                    │     └────────────┴──────────────┴─────────────┘   │
                    │                          │                         │
                    └──────────────────────────┼─────────────────────┘
                                               │
                                    ┌──────────▼──────────┐
                                    │     ENRICH          │
                                    │  • AI descriptions  │
                                    │  • Image embedding  │
                                    │  • Valuation fetch  │
                                    └──────────┬──────────┘
                                               │
                                    ┌──────────▼──────────┐
                                    │     REVIEW          │
                                    │  • Confidence score │
                                    │  • Human QA queue   │
                                    │  • Expert approval  │
                                    └──────────┬──────────┘
                                               │
                                    ┌──────────▼──────────┐
                                    │     PUBLISH         │
                                    │  • PostgreSQL write │
                                    │  • ES index update  │
                                    │  • Qdrant embedding │
                                    └─────────────────────┘
```

---

## Stage 1: Discovery

Discovers seed URLs for each configured source.

### Source configuration format

```yaml
# sources/colnect.yaml
id: colnect
name: Colnect Stamp Database
type: api           # api | static_html | js_rendered | sitemap
base_url: https://colnect.com
api_key_env: COLNECT_API_KEY
rate_limit:
  requests_per_second: 2
  burst: 10
  daily_limit: 50000
discovery:
  method: api_paginate
  endpoint: /api/1/list/items/cat/stamp
  params:
    lang: en
    per_page: 100
  pagination: cursor
crawl:
  detail_url_template: https://colnect.com/en/stamps/stamp/{id}
  fields_map:
    issuer: country_name
    year: year
    denomination: face_value
    colour: colors
    subject: name
    catalogue_refs:
      colnect: id
      scott: scott_no
      sg: sg_no
      michel: michel_no
image_fields:
  - front_image
  - back_image
priority: 1
```

```yaml
# sources/michel_online.yaml
id: michel_online
name: Michel Online Catalogue
type: js_rendered
base_url: https://www.michel.de
rate_limit:
  requests_per_second: 0.5
  daily_limit: 5000
discovery:
  method: sitemap
  sitemap_url: https://www.michel.de/sitemap.xml
  url_pattern: '/briefmarken/.*'
crawl:
  renderer: playwright
  wait_for: '.stamp-detail'
  scroll: false
  js_intercept:        # intercept API calls made by the page
    - pattern: '/api/v1/stamps/'
      save_as: json
fields_map:
  issuer: .stamp-country
  year: .stamp-year
  denomination: .stamp-face
  colour: .stamp-color
  subject: h1.stamp-title
  catalogue_refs:
    michel: .michel-number
priority: 2
```

---

## Stage 2: Crawl Workers

### Worker types

**StaticCrawler** (Scrapy-based, Python)
- For HTML sites without significant JavaScript rendering
- Fastest — 100+ pages/minute per worker
- Respects robots.txt, rate limits per source config

**JSCrawler** (Playwright-based, Node.js)
- For JavaScript-rendered sites (SPAs, lazy-loaded content)
- Network request interception to capture API calls made by the page
- Slower — 5–20 pages/minute per worker
- Auto-solves most basic bot challenges (scroll, mouse movement, viewport)

**APIClient** (Node.js/Python, source-specific)
- For sources with formal APIs (Colnect CAPI, Wikidata SPARQL, UPU WNS)
- Highest throughput and most structured output
- Respects API rate limits from source config

### AWS Fargate worker spec

```hcl
# terraform/crawler_worker.tf (conceptual)
resource "aws_ecs_task_definition" "static_crawler" {
  family                   = "stampscan-static-crawler"
  cpu                      = "512"   # 0.5 vCPU
  memory                   = "1024"  # 1 GB
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  
  container_definitions = jsonencode([{
    name  = "crawler"
    image = "stampscan/static-crawler:latest"
    environment = [
      { name = "SQS_QUEUE_URL",   value = aws_sqs_queue.crawl_queue.url },
      { name = "S3_BUCKET",       value = aws_s3_bucket.raw_crawl.id },
      { name = "DB_URL",          value = var.db_url },
      { name = "WORKER_TYPE",     value = "static" },
    ]
  }])
}

resource "aws_ecs_task_definition" "js_crawler" {
  family  = "stampscan-js-crawler"
  cpu     = "1024"   # 1 vCPU — Playwright needs more resources
  memory  = "2048"   # 2 GB
  # ... same pattern, different image
}

# Auto-scaling based on SQS queue depth
resource "aws_appautoscaling_policy" "crawler_scale" {
  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "SQSQueueMessagesVisible"  
    }
    target_value = 100  # keep 1 worker per 100 queued URLs
  }
}
```

---

## Stage 3: LLM Extraction Layer

Raw HTML → Structured JSON using LLM-assisted field extraction. This handles the long tail of sources where CSS selectors and rigid parsers fail.

### Extraction pipeline (Python)

```python
# crawler/extraction/llm_extractor.py

import json
from anthropic import Anthropic

client = Anthropic()

STAMP_EXTRACTION_SCHEMA = {
    "issuer": "str — country or postal authority name",
    "issue_date": "str — ISO 8601 date or 'circa YYYY'",
    "denomination": "float — numeric face value",
    "currency": "str — ISO 4217 or historic currency name",
    "colour": "list[str] — colour names in English",
    "subject": "str — what is depicted on the stamp",
    "designer": "str | null",
    "printer": "str | null",
    "print_method": "str | null — lithography, engraving, photogravure, etc.",
    "perforation": "str | null — e.g. '14' or '13.5 x 14'",
    "watermark": "str | null",
    "paper_type": "str | null",
    "format": "str — stamp | minisheet | booklet_pane | coil | revenue | etc.",
    "catalogue_refs": {
        "scott":  "str | null",
        "sg":     "str | null",
        "michel": "str | null",
        "yvert":  "str | null",
        "colnect": "str | null",
    },
    "topics": "list[str] — thematic categories e.g. fauna, royalty, aviation",
    "notes": "str | null — any other relevant philatelic information",
    "confidence": "float — 0.0 to 1.0, your confidence in this extraction"
}

EXTRACTION_PROMPT = """You are a philatelic expert extracting stamp data for a database.

Extract all stamp information from the following web page content.

Schema to fill (return valid JSON matching this structure):
{schema}

Rules:
- issuer: use the official postal authority name, not generic country name (e.g. "Royal Mail" not just "UK")
- issue_date: prefer ISO 8601 (1969-07-20); for ranges use the first year; for circa dates use "circa 1923"
- denomination: numeric only (e.g. 2.5 not "2½d")
- colour: English colour names, be specific (e.g. "deep carmine" not just "red")
- subject: what is depicted, not the series name (e.g. "Portrait of Queen Elizabeth II" not "Definitive series")
- topics: use standard thematic categories: fauna, flora, royalty, aviation, sport, space, art, religion, maps, ships, trains, butterflies, etc.
- catalogue_refs: include only numbers you are certain of; omit uncertain ones
- If the page describes multiple stamps, return a JSON array of stamp objects

Page URL: {url}
Page content:
{content}"""

def extract_stamp_from_html(url: str, html_content: str, source_id: str) -> list[dict]:
    """Extract stamp data from HTML using Claude."""
    
    # Truncate to fit context (keep most relevant section)
    content = html_content[:12000]
    
    response = client.messages.create(
        model="claude-3-5-haiku-20241022",
        max_tokens=4096,
        messages=[{
            "role": "user",
            "content": EXTRACTION_PROMPT.format(
                schema=json.dumps(STAMP_EXTRACTION_SCHEMA, indent=2),
                url=url,
                content=content
            )
        }]
    )
    
    raw = response.content[0].text.strip()
    
    # Strip markdown code fences if present
    if raw.startswith("```"):
        raw = raw.split("```")[1]
        if raw.startswith("json"):
            raw = raw[4:]
    
    data = json.loads(raw)
    
    # Normalise to list
    if isinstance(data, dict):
        data = [data]
    
    # Tag source
    for item in data:
        item["source_url"] = url
        item["source_code"] = source_id
        item["source_tier"] = "scraped"
        item["review_status"] = "pending"
    
    return data
```

---

## Stage 4: Deduplication

Prevents the same stamp from being inserted multiple times from different sources.

```python
# crawler/dedup/fingerprint.py

import hashlib
import re

def normalise_colour(colour_str: str) -> str:
    """Normalise colour to canonical form."""
    colour_str = colour_str.lower().strip()
    # Map common variants
    synonyms = {
        "carmine": ["crimson", "rose-carmine", "deep rose"],
        "ultramarine": ["blue", "deep blue", "prussian blue"],
        "green": ["myrtle green", "bottle green", "sage green"],
    }
    for canonical, variants in synonyms.items():
        if colour_str in variants:
            return canonical
    return colour_str

def normalise_denomination(denom_str: str) -> str:
    """Normalise denomination to consistent string."""
    if not denom_str:
        return "0"
    # Remove currency symbols, normalise fractions
    cleaned = re.sub(r'[^\d./]', '', str(denom_str))
    return cleaned.strip() or "0"

def compute_dedupe_fingerprint(
    issuer_code: str,
    year: int,
    denomination_raw: str,
    colours: list[str],
    perf: str | None = None
) -> str:
    """
    Compute a deduplication fingerprint.
    
    Two stamps with matching fingerprints are the SAME base stamp and
    should be merged rather than duplicated.
    """
    canonical_colours = sorted(normalise_colour(c) for c in (colours or []))
    canonical_denom = normalise_denomination(denomination_raw)
    canonical_perf = (perf or "").strip()
    
    parts = "|".join([
        issuer_code.upper(),
        str(year),
        canonical_denom,
        ",".join(canonical_colours),
        canonical_perf,
    ])
    
    return hashlib.sha256(parts.encode()).hexdigest()[:16]


class DeduplicationEngine:
    """PostgreSQL-backed deduplication using fingerprints + catalogue cross-references."""
    
    def __init__(self, db_pool):
        self.db = db_pool
    
    async def find_existing(self, stamp_data: dict) -> int | None:
        """
        Returns existing stamp ID if duplicate found, else None.
        Uses three-tier matching:
          1. Exact catalogue number match (highest confidence)
          2. Fingerprint match (medium confidence)
          3. Fuzzy match on issuer + year + subject (low confidence, human review)
        """
        async with self.db.acquire() as conn:
            
            # Tier 1: Catalogue number match
            for cat_code, cat_num in (stamp_data.get("catalogue_refs") or {}).items():
                if not cat_num:
                    continue
                row = await conn.fetchrow("""
                    SELECT s.id FROM stamps s
                    JOIN catalogue_references cr ON cr.stamp_id = s.id
                    JOIN catalogue_systems cs ON cs.id = cr.catalogue_id
                    WHERE cs.code = $1 AND cr.cat_number = $2
                """, cat_code, str(cat_num).upper())
                if row:
                    return row["id"]
            
            # Tier 2: Fingerprint match
            fp = compute_dedupe_fingerprint(
                stamp_data.get("issuer_code", ""),
                stamp_data.get("issue_year", 0),
                str(stamp_data.get("denomination", "")),
                stamp_data.get("colour", []),
                stamp_data.get("perforation"),
            )
            row = await conn.fetchrow(
                "SELECT id FROM stamps WHERE dedupe_hash = $1", fp
            )
            if row:
                return row["id"]
            
            return None
    
    async def merge_or_insert(self, stamp_data: dict) -> tuple[int, str]:
        """
        Returns (stamp_id, action) where action is 'inserted', 'merged', or 'queued_for_review'.
        """
        existing_id = await self.find_existing(stamp_data)
        
        if existing_id:
            # Merge catalogue refs and images; do not overwrite approved data
            await self._merge_catalogue_refs(existing_id, stamp_data)
            await self._merge_images(existing_id, stamp_data)
            return existing_id, "merged"
        
        # New stamp — insert
        stamp_id = await self._insert_stamp(stamp_data)
        return stamp_id, "inserted"
```

---

## Stage 5: Enrichment

Adds AI-generated descriptions, image embeddings, and cross-catalogue data.

```python
# crawler/enrichment/enricher.py

async def enrich_stamp(stamp_id: int, stamp_data: dict, db, s3, qdrant):
    """
    Enrich a newly inserted stamp with:
    1. AI-generated philatelic description (if missing)
    2. CoreML-compatible image embedding (if image available)
    3. Cross-catalogue number resolution
    """
    
    # 1. AI description generation
    if not stamp_data.get("description"):
        description = await generate_description(stamp_data)
        await db.execute(
            "UPDATE stamps SET description = $1, updated_at = NOW() WHERE id = $2",
            description, stamp_id
        )
    
    # 2. Image embedding — download image, compute embedding, store in Qdrant
    primary_image = await db.fetchrow(
        "SELECT cdn_url, s3_key FROM stamp_images WHERE stamp_id = $1 AND is_primary = TRUE",
        stamp_id
    )
    if primary_image and not await qdrant.has_embedding(primary_image["s3_key"]):
        embedding = await compute_embedding(primary_image["cdn_url"])
        await qdrant.upsert(
            collection="stamp_embeddings",
            points=[{
                "id": stamp_id,
                "vector": embedding,
                "payload": {
                    "stamp_id": stamp_id,
                    "stamp_uuid": stamp_data["uuid"],
                    "issuer_code": stamp_data.get("issuer_code"),
                    "issue_year": stamp_data.get("issue_year"),
                }
            }]
        )


DESCRIPTION_PROMPT = """You are a professional philatelist writing a concise, accurate description
for a stamp catalogue. Write 2-3 sentences describing this stamp for a collector audience.

Include: what is depicted, printing method if known, historical context if notable, any
unusual characteristics. Do not repeat the basic metadata (year, denomination, country)
as these are shown separately. Focus on what makes this stamp interesting or distinctive.

Stamp data:
- Country/Issuer: {issuer}
- Year: {year}
- Denomination: {denomination}
- Subject: {subject}
- Colour: {colour}
- Print method: {print_method}
- Designer: {designer}
- Series: {series}
- Additional notes: {notes}

Write only the description text, no labels or headers."""

async def generate_description(stamp_data: dict) -> str:
    """Generate an AI philatelic description — this is our copyrightable IP."""
    response = client.messages.create(
        model="claude-3-5-haiku-20241022",
        max_tokens=256,
        messages=[{
            "role": "user",
            "content": DESCRIPTION_PROMPT.format(**{
                "issuer": stamp_data.get("issuer", "Unknown"),
                "year": stamp_data.get("issue_year", "Unknown"),
                "denomination": stamp_data.get("denomination_text", stamp_data.get("denomination", "")),
                "subject": stamp_data.get("subject", ""),
                "colour": ", ".join(stamp_data.get("colour", [])),
                "print_method": stamp_data.get("print_method", "unknown"),
                "designer": stamp_data.get("designer", "unknown"),
                "series": stamp_data.get("series_name", ""),
                "notes": stamp_data.get("notes", ""),
            })
        }]
    )
    return response.content[0].text.strip()
```

---

## Stage 6: SQS Queue Design

```
                 ┌─────────────────────────────────────────┐
                 │          SQS QUEUES                      │
                 │                                          │
  Discovery  ──► │  crawl-discovery (priority)              │
                 │  Visibility: 30s | Retention: 4 days     │
                 │  DLQ after 3 failures                    │
                 │                                          │
  URLs       ──► │  crawl-static   (high throughput)        │
                 │  Visibility: 60s | Batch: 10             │
                 │                                          │
  JS pages   ──► │  crawl-js       (lower throughput)       │
                 │  Visibility: 120s | Batch: 1             │
                 │                                          │
  Raw HTML   ──► │  extract        (LLM extraction)         │
                 │  Visibility: 90s | Batch: 5              │
                 │                                          │
  JSON data  ──► │  dedup          (fast, DB lookups)       │
                 │  Visibility: 30s | Batch: 20             │
                 │                                          │
  New stamps ──► │  enrich         (AI + embedding)         │
                 │  Visibility: 300s | Batch: 1             │
                 │                                          │
  Approved   ──► │  publish        (DB + ES + Qdrant write) │
                 │  Visibility: 30s | Batch: 10             │
                 └─────────────────────────────────────────┘
```

### Message format (example: crawl-static)

```json
{
  "job_id": "crawl_42891",
  "source_code": "colnect",
  "url": "https://colnect.com/en/stamps/stamp/12345",
  "depth": 1,
  "parent_url": "https://colnect.com/en/stamps/list/country/US",
  "priority": 1,
  "retry_count": 0,
  "metadata": {
    "expected_fields": ["issuer", "year", "denomination", "catalogue_refs"],
    "known_cat_refs": { "colnect": "12345" }
  },
  "created_at": "2025-11-01T10:23:00Z"
}
```

---

## Stage 7: Rate Limiting & Politeness

```python
# crawler/politeness/rate_limiter.py

import asyncio
import time
from collections import defaultdict

class SourceRateLimiter:
    """
    Per-source rate limiting with token bucket algorithm.
    Ensures we never exceed source-configured request rates.
    """
    
    def __init__(self):
        self._buckets: dict[str, dict] = defaultdict(dict)
    
    def configure(self, source_code: str, rps: float, burst: int = 10):
        self._buckets[source_code] = {
            "rps": rps,
            "burst": burst,
            "tokens": burst,
            "last_refill": time.monotonic(),
        }
    
    async def acquire(self, source_code: str):
        bucket = self._buckets[source_code]
        while True:
            now = time.monotonic()
            elapsed = now - bucket["last_refill"]
            bucket["tokens"] = min(
                bucket["burst"],
                bucket["tokens"] + elapsed * bucket["rps"]
            )
            bucket["last_refill"] = now
            
            if bucket["tokens"] >= 1:
                bucket["tokens"] -= 1
                return  # proceed
            
            wait = (1 - bucket["tokens"]) / bucket["rps"]
            await asyncio.sleep(wait)

# Crawl headers — identify ourselves honestly
DEFAULT_HEADERS = {
    "User-Agent": "StampScan-Bot/1.0 (https://stampscan.app/bot; bot@stampscan.app)",
    "Accept": "text/html,application/xhtml+xml",
    "Accept-Language": "en-US,en;q=0.9",
}
```

---

## Monitoring & Alerting

### Key metrics (CloudWatch)

| Metric | Alert Threshold | Action |
|--------|----------------|--------|
| `crawl_queue_depth` | >50,000 | Scale up workers |
| `extract_error_rate` | >10% | Investigate LLM extraction failures |
| `dedup_collision_rate` | >40% | Source already well-covered, reduce priority |
| `new_stamps_per_hour` | <100 | Check worker health / source availability |
| `embedding_lag_hours` | >24h | Scale enrichment workers |
| `human_review_queue` | >10,000 | Increase reviewer pool / auto-approve above 0.95 confidence |

### Daily crawl report format (email/Slack)

```
📮 StampScan Crawl Report — 2025-11-01

Crawled today:    12,847 pages
New stamps added:  3,421
Merged/updated:    9,026
Queued for review:   401
Errors:              234  (1.8%)

Top sources:
  colnect:         6,241 pages  →  1,847 new stamps
  wikimedia:       3,109 pages  →    823 new stamps  
  michel_online:   1,503 pages  →    412 new stamps
  wikidata_sparql:   891 API calls → 189 new stamps

DB total: 847,221 stamps (↑3,421 from yesterday)
Embedding coverage: 73.2%
ES index sync: ✅ current
```
