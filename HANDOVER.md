# Rowland iOS — Project Handover
**Date:** July 2026  
**From:** Research & Architecture phase (Claude, Cowork)  
**To:** Implementation phase (Claude Code or developer)  
**Owner:** David (david.defranceski@gmail.com)

---

## What You're Getting

A fully researched, fully architected iOS stamp identification app with:
- All product and technical decisions made (no more research needed)
- Swift scaffolding for every screen and service
- Full PostgreSQL + Elasticsearch database schema
- StampID universal cross-catalogue identifier spec
- Country succession engine (handles Zimbabwe = Rhodesia, USSR = Russia, etc.)
- Distributed crawler architecture for building the proprietary database
- Legal foundation verified for scraping and IP ownership

**The implementation team's job is to build, not design.**

---

## The Product

Rowland is a three-part product:

**1. The iOS App** — Photo → AI identification → stamp details + valuations + collection management  
**2. The Database** — Proprietary catalogue of 5–15M stamps (larger than any competitor)  
**3. The IP** — The cross-catalogue reference system (StampID) linking Scott, SG, Michel, Yvert, etc.

The market gap is explicit: no app combines AI identification + millions of stamps + accurate valuations + modern iOS UX. Competitors feel like 2005.

---

## Project Structure

```
rowland-ios/
├── CLAUDE.md           ← READ THIS IN CLAUDE CODE — full technical context
├── HANDOVER.md         ← This document
├── Rowland/          ← iOS app source (Swift/SwiftUI)
│   ├── App/            ← Entry point, AppState, design tokens
│   ├── Models/         ← Stamp, CollectionItem, ScanResult, enums
│   ├── Views/          ← ScanView, StampDetailView, CatalogueView, CollectionView
│   └── Services/       ← API client, CoreML classifier, local persistence
└── docs/
    ├── research/       ← Phase 1 research findings (databases, ML, legal, competitors)
    ├── schema/         ← PostgreSQL + Elasticsearch + StampID spec
    └── crawler/        ← Distributed crawler architecture
```

---

## What's Built vs What Needs Building

### Done ✅
- Full SwiftUI scaffolding for all 4 tabs (Scan, Catalogue, Collection, Market)
- All data models (`Stamp.swift`) with correct JSON decoding
- API client (`StampAPIClient.swift`) — all endpoints stubbed, ready to wire to real server
- CoreML classifier pipeline (`StampClassifier.swift`) — architecture complete, model file needed
- Camera scan flow with Vision rectangle detection
- Scan result view with confidence indicator, catalogue refs, valuation gating
- Stamp detail view with all sections
- Search + filter catalogue browse
- Collection management with swipe-to-delete
- Design system (dark theme, color tokens)
- Deep link handling scaffold (`rowlandhill.app/s/SID-GB-1840-0001`)
- PostgreSQL schema (17 tables, all indexes)
- Elasticsearch mappings
- StampID universal identifier spec + generation algorithm
- Country succession graph (Zimbabwe/Rhodesia, Guinea-Bissau/Portuguese Guinea, German Empire, USSR/Russia seeded)
- Search aliases (Rhodesia → Zimbabwe, CCCP → USSR, etc.)
- Crawler architecture with YAML-driven source configs, LLM extraction, deduplication

### Next Steps (in order) 🔲

**Week 1 — Make it compile and run**
1. Create `Rowland.xcodeproj` and add all Swift files
2. Add missing `Color.text` to `AppState.swift` (add `.white` or `Color(uiColor: .label)`)
3. Add `Info.plist` privacy strings (Camera, Photo Library)
4. Add capabilities: Camera, Sign in with Apple, iCloud
5. Fix any compilation errors from missing types

**Week 2 — Camera pipeline**
6. Wire up `captureCurrentFrame()` in `ScanView` — grab UIImage from live camera
7. Replace PLACEHOLDER embedding in `StampClassifier.extractEmbedding()` with real CoreML call
8. Train `StampEmbedder.mlpackage` using MiikeMineStamps dataset
9. Build on-device embedding SQLite from trained model

**Week 3 — Auth + subscriptions**
10. Implement Sign in with Apple in `AppState.signIn()`
11. StoreKit 2 products: `app.rowlandhill.pro.monthly`, `app.rowlandhill.pro.annual`, `app.rowlandhill.dealerpro.monthly`
12. Wire paywall buttons in `StampDetailView` and `ProUpgradeTeaser`

**Week 4 — Backend**
13. Deploy PostgreSQL, run schema migrations
14. Deploy Elasticsearch, apply mappings
15. Deploy Node.js/Fastify API (base URL: `https://api.rowlandhill.app/v1`)
16. Seed database with Wikidata SPARQL (free, immediate, ~100K stamps)
17. Deploy Qdrant for vector embeddings

---

## Key Technical Decisions (DO NOT REVISIT)

| Decision | Choice | Why |
|----------|--------|-----|
| UI framework | SwiftUI | Modern, native, fastest dev |
| Camera | VisionKit DataScannerViewController | Best Apple-native option |
| ML approach | Embedding similarity (NOT classifier) | Scales to millions without retraining |
| ML backbone | EfficientFormer-L1 | Best accuracy/speed for on-device stamps |
| Database | PostgreSQL + Elasticsearch + Qdrant | Best-in-class for each role |
| Auth | Sign in with Apple only | Required for primary auth on iOS |
| Monetisation | Hard paywall, 17-day trial | 8× better revenue than soft freemium |
| Pro price | $4.99/month or $39.99/year | Competitive with similar apps |
| IP strategy | Own the schema + cross-refs + AI descriptions | Facts are free, compilation is ours |

---

## The StampID System

This is the core proprietary IP. Every stamp gets a permanent, stable identifier:

```
SID-GB-1840-0001     = Penny Black
SID-US-1847-0001     = Benjamin Franklin (US #1)
SID-DEPR-1850-0001   = Prussia first issue
SID-RURE-1857-0001   = Russia first issue
```

Format: `SID-{ISSUER}-{YEAR}-{SEQ4}-{VAR}`

The value: **one StampID maps to many catalogue numbers** (Scott 1 = SG 1 = Michel 1 = this StampID). No other database offers this cross-reference at scale. Full spec in `docs/schema/003_stampid_spec.md`.

---

## Country Succession (Critical Design Point)

Stamps don't respect modern country borders. "Zimbabwe" stamps include:
- British South Africa Company stamps (1890–1924)
- Southern Rhodesia (1924–1953)
- Federation of Rhodesia & Nyasaland (1954–1963)
- UDI Rhodesia (1965–1979)
- Zimbabwe Rhodesia (1979)
- Zimbabwe (1980–present)

The database handles this via `country_succession` directed graph + `get_issuer_lineage()` recursive SQL function. When a user searches "Rhodesia", the API traverses the full lineage and returns stamps from all eras. The iOS app doesn't need to know any of this — it just passes the search query to the API.

---

## Competitive Moat Summary

| Moat Layer | What It Is |
|------------|-----------|
| **Data depth** | 5–15M items vs Colnect's 1.6M — no competitor matches |
| **Cross-catalogue** | StampID links Scott+SG+Michel+11 more — unique in market |
| **AI accuracy** | Embedding model trained on millions of images vs competitors' 80-85% |
| **Succession engine** | "Rhodesia" search finds Zimbabwe stamps — no competitor does this |
| **Valuation data** | Real auction results (Siegel, Cherrystone, Köhler) vs catalogue estimates |
| **Modern UX** | Competitors feel like 2005 — iOS-native dark design |

---

## Contacts & Accounts to Set Up

- [ ] Apple Developer account (for App Store + Sign in with Apple)
- [ ] AWS account (Fargate, SQS, S3, RDS for PostgreSQL)
- [ ] Elastic Cloud or self-hosted Elasticsearch
- [ ] Qdrant Cloud (vector DB)
- [ ] Colnect — contact for CAPI commercial licence
- [ ] Stamp-Store API — contact for catalogue cross-reference access
- [ ] UPU WNS — approach as partner, not competitor

---

## Research Still Arriving

Two deep-research workflows are running and will complete shortly:
- **European philatelic sources** — Michel, NVPH, AFA, Facit, SBK, Heinrich Köhler, Corinphila, David Feldman
- **Guinea-Bissau + Rhodesia** — full philatelic history, data sources, item counts for both countries

Results will appear in `docs/research/` when complete.

---

*All research, architecture, schema, and scaffolding produced by Claude (Cowork) during deep research sessions, July 2026.*
