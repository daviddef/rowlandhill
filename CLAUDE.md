# StampScan iOS — Project Context for Claude Code

> **Read this first.** This file gives you complete context on what this project is, what's been built, what decisions have been made, and exactly what to do next. All key decisions are already made — your job is to implement, not re-research.

---

## What Is This?

**StampScan** is an iOS app that identifies postage stamps from a phone photo using AI, then shows details, valuations, and lets users manage their collection. The ambition is to build the world's largest proprietary philatelic database — larger and more accurate than Colnect (currently 1.6M items).

**Owner:** David (david.defranceski@gmail.com)  
**Research phase:** Complete. All architectural decisions are made. Implementation starts now.

---

## Project Structure

```
stampscan-ios/
├── CLAUDE.md                          ← YOU ARE HERE
├── HANDOVER.md                        ← Human-readable summary for David
├── StampScan/
│   ├── App/
│   │   ├── StampScanApp.swift         ← @main entry, TabView
│   │   └── AppState.swift             ← Global state, auth, subscription tiers, Color tokens
│   ├── Models/
│   │   └── Stamp.swift                ← All model types: Stamp, CollectionItem, ScanResult, enums
│   ├── Views/
│   │   ├── Scan/
│   │   │   ├── ScanView.swift         ← Camera, photo picker, processing state machine
│   │   │   └── ScanResultView.swift   ← Match display, add to collection, alt candidates
│   │   ├── Catalogue/
│   │   │   ├── CatalogueView.swift    ← Search + filter + grid browse
│   │   │   └── StampDetailView.swift  ← Full stamp detail, valuations, catalogue refs
│   │   └── Collection/
│   │       └── CollectionView.swift   ← User inventory + MarketplaceView placeholder
│   └── Services/
│       ├── API/
│       │   └── StampAPIClient.swift   ← Full REST client, all endpoints stubbed
│       ├── ML/
│       │   └── StampClassifier.swift  ← CoreML + Vision pipeline, EmbeddingDatabase
│       └── Data/
│           └── CollectionStore.swift  ← Local persistence (UserDefaults MVP → Core Data)
└── docs/
    ├── research/
    │   └── phase1-research-findings.md  ← Verified research on databases, ML, legal, competitors
    ├── schema/
    │   ├── 001_core_schema.sql          ← Full PostgreSQL schema (17 tables)
    │   ├── 002_elasticsearch_mappings.json
    │   ├── 003_stampid_spec.md          ← StampID universal identifier spec
    │   └── 004_succession_schema.sql    ← Country succession graph + search aliases
    └── crawler/
        └── architecture.md             ← Crawler pipeline design + Python/Node.js code
```

---

## Architecture Decisions — DO NOT REVISIT

These are locked. Research is done. Implement these.

### iOS Stack
- **SwiftUI** — all UI (no UIKit except where VisionKit requires it)
- **Swift Concurrency** (async/await + actors) — no Combine except where framework forces it
- **VisionKit DataScannerViewController** — camera pipeline
- **Vision framework** — `VNDetectRectanglesRequest` for stamp boundary detection
- **CoreML** — on-device embedding inference (`StampEmbedder.mlpackage`)
- **StoreKit 2** — subscriptions
- **Sign in with Apple** — only auth method
- **Core Data + NSPersistentCloudKitContainer** — collection persistence + iCloud sync (Pro tier)
- **Minimum deployment: iOS 17**

### ML / AI Identification
- **NOT a fixed-class classifier.** The model outputs a **512-dimensional embedding vector**.
- Identification = cosine similarity search against embedding database, not softmax.
- This means new stamps are added to the DB without retraining the model.
- **Backbone:** EfficientFormer-L1 (79.2% ImageNet, 1.6ms on iPhone 12, 12.3M params)
- **On-device:** Top 100K most common stamps in SQLite embedding store (`stamp_embeddings.sqlite`)
- **Server-side:** Full 5M+ corpus in Qdrant vector DB
- **Training bootstrap data:** MiikeMineStamps CMU dataset (5,056 images, 407 classes)
- **Model training pipeline:** Python/Keras → CoreML Tools export → `.mlpackage`
- The model file `StampEmbedder.mlpackage` does NOT exist yet — it needs to be trained.
- See `docs/ml-pipeline.md` (to be written) for training instructions.

### API
- Base URL: `https://api.stampscan.app/v1` (not yet deployed)
- Auth: Bearer JWT obtained via POST `/auth/apple`
- Full client is in `StampAPIClient.swift` — all endpoints are stubbed
- Response models match `Stamp.swift` exactly

### Database (backend — not iOS)
- PostgreSQL 15 — see `docs/schema/001_core_schema.sql`
- Elasticsearch 8 — see `docs/schema/002_elasticsearch_mappings.json`
- Qdrant — vector embeddings
- Redis — valuation caching

### Monetisation — HARD PAYWALL MODEL
- **Free:** 10 scans/day, no valuations, no iCloud sync
- **StampScan Pro:** $4.99/month or $39.99/year — unlimited scans, valuations, iCloud sync
- **Dealer Pro:** $29.99/month — bulk tools, CSV export, marketplace listing
- 17-day free trial (converts at 42.5% vs 25.5% for shorter trials — see research)
- NO freemium creep. The paywall is the product's business model.

### StampID
- Universal stamp identifier: `SID-{ISSUER}-{YEAR}-{SEQ4}-{VAR}`
- Example: `SID-GB-1840-0001` = Penny Black
- Full spec in `docs/schema/003_stampid_spec.md`
- This is the primary key of the entire database and the core IP asset.

---

## What's Done vs What's TODO

### ✅ DONE (scaffolded — needs implementation)

| File | Status | Notes |
|------|--------|-------|
| `StampScanApp.swift` | ✅ Shell | Tab structure done |
| `AppState.swift` | ✅ Shell | Auth + subscription types done |
| `Stamp.swift` | ✅ Complete | All model types, CodingKeys, enums |
| `StampAPIClient.swift` | ✅ Shell | All endpoints stubbed, needs real base URL |
| `StampClassifier.swift` | ✅ Shell | Pipeline stubbed; **model file missing** |
| `ScanView.swift` | ✅ Shell | UI done; camera capture frame grab TODO |
| `ScanResultView.swift` | ✅ Complete | Full UI, add-to-collection, alt candidates |
| `StampDetailView.swift` | ✅ Complete | All sections done, needs paywall wire-up |
| `CatalogueView.swift` | ✅ Complete | Grid + search + filters |
| `CollectionView.swift` | ✅ Shell | List + sort done; Core Data migration TODO |
| `CollectionStore.swift` | ✅ Shell | UserDefaults MVP; Core Data TODO |

### 🔲 TODO — Implement These Next (in priority order)

#### Priority 1 — Core product loop (make it work end-to-end)
1. **Wire up camera frame capture in `ScanView.swift`**
   - The `captureCurrentFrame()` method needs to grab a `UIImage` from the live camera feed
   - Use `AVCaptureSession` or `DataScannerViewController`'s `capturedPhoto`
   - Then call `viewModel.identifyImage(image)`

2. **Train and export the CoreML embedding model**
   - Training script location: `docs/ml-pipeline.md` (to be written)
   - Input: MiikeMineStamps dataset + scraped corpus
   - Output: `StampEmbedder.mlpackage` → add to Xcode project
   - Replace the PLACEHOLDER in `StampClassifier.extractEmbedding()`

3. **Build the on-device embedding SQLite database**
   - Script needed: export top 100K embeddings from Qdrant → SQLite
   - File: `Resources/stamp_embeddings.sqlite`
   - Implement `EmbeddingDatabase.load()` to read from it

4. **Set up Xcode project**
   - Create `StampScan.xcodeproj` / `StampScan.xcworkspace`
   - Add all Swift files
   - Set bundle ID, signing, capabilities (Camera, PhotoLibrary, Sign in with Apple, iCloud)
   - Add Privacy strings to Info.plist

#### Priority 2 — Subscription + Auth
5. **Implement Sign in with Apple** in `AppState.signIn()`
6. **StoreKit 2 paywall** — wire up the "Upgrade" buttons in `StampDetailView` and `ProUpgradeTeaser`
   - Products: `app.stampscan.pro.monthly`, `app.stampscan.pro.annual`, `app.stampscan.dealerpro.monthly`
7. **iCloud sync** for Pro users — swap `CollectionStore` from UserDefaults to `NSPersistentCloudKitContainer`

#### Priority 3 — Polish
8. **Add `Color.text` extension** (missing — referenced in `CatalogueView` and `ScanResultView`)
9. **Country picker in FilterSheet** — load from `/v1/meta/countries`; must support succession search (typing "Rhodesia" shows Zimbabwe stamps)
10. **Topic picker in FilterSheet** — curated list of ~50 thematic categories
11. **Onboarding flow** — shown on first launch; explains the app, prompts sign-in
12. **Error states** — network offline banner, scan daily limit warning (free tier)
13. **Deep link handling** — `stampscan.app/s/SID-GB-1840-0001` → `StampDetailView`

#### Priority 4 — Backend (separate repo/team)
14. **Deploy API** — Node.js/Fastify on AWS
15. **PostgreSQL schema** — run `docs/schema/001_core_schema.sql` and `004_succession_schema.sql`
16. **Elasticsearch** — apply `docs/schema/002_elasticsearch_mappings.json`
17. **Crawler** — Python/Node.js workers per `docs/crawler/architecture.md`
18. **Seed database** — start with Wikidata SPARQL + Wikimedia Commons (free, immediate)

---

## Key Technical Notes

### Country Succession (CRITICAL for search)
Searching "Rhodesia" must return stamps from ALL related issuers:
- BSAC Territory (1890–1924)
- Southern Rhodesia (1924–1953)
- Federation of Rhodesia & Nyasaland (1954–1963)
- UDI Rhodesia (1965–1979)
- Zimbabwe Rhodesia (1979)
- Zimbabwe (1980–present)

The PostgreSQL `get_issuer_lineage()` function handles this recursively.
The `search_aliases` table handles name variant matching.
The Elasticsearch `synonym_filter` in `002_elasticsearch_mappings.json` handles real-time search.

**On iOS:** When the user types "Rhodesia" in the search bar, the API handles the translation. No iOS-side special casing needed.

### Scan Flow (detailed)
```
User taps camera → DataScannerViewController opens
User frames stamp → Vision VNDetectRectanglesRequest finds stamp boundary
User taps capture → UIImage captured, sent to StampClassifier.identify()
StampClassifier:
  1. detectStampRegion() — Vision rectangle detection, crop
  2. extractEmbedding() — CoreML inference → 512-dim float array
  3. EmbeddingDatabase.search() — cosine similarity, top-10 on-device
  4. If confidence < 0.85 → api.searchByEmbedding() — server-side Qdrant
  5. api.fetchStamp(id:) — load full stamp detail
  6. Return ScanResult
ScanView switches to .result(scanResult) → ScanResultView appears
```

### Catalogue Numbers (IMPORTANT)
The `catalogue_refs` array on a `Stamp` is the gold — it's what makes StampScan uniquely valuable.
Scott 1 = SG 1 = Michel 1 = SID-GB-1840-0001 (for the Penny Black).
Always display catalogue refs in `StampDetailView`. They're the key differentiator vs competitors.

### Valuation Gating
- `stamp.valuation` is `nil` for free users (API returns null for unsubscribed users)
- `StampDetailView.ValuationSection` already handles this — shows upgrade prompt if `subscription == .free`
- Do NOT try to fetch valuations client-side — the server enforces the gate

---

## Design System

All design tokens are in `AppState.swift`:
```swift
Color.stampGold     = #F0A500  // Primary accent — gold
Color.stampSurface  = #16161B  // Background
Color.stampCard     = #181E27  // Card surface
Color.stampBorder   = #303640  // Dividers
Color.stampMuted    = #8B949E  // Secondary text
```
**NOTE:** `Color.text` is missing from `AppState.swift` — add it as `.white` or `Color(uiColor: .label)`.

Dark mode only (no light mode support in v1).

---

## Data Sources & Legal (summary)

| Source | Status | What it gives |
|--------|--------|---------------|
| Wikidata SPARQL | ✅ Free, use now | 100K+ stamp records, catalogue cross-refs |
| Wikimedia Commons | ✅ Free, use now | Public domain stamp images |
| Colnect CAPI | 🔑 Needs licence | 1.6M stamps, all fields |
| Stamp-Store API | 🔑 Needs contact | 37 catalogue systems cross-referenced |
| UPU WNS | 🤝 Partner approach | 120K official stamps |
| Michel Online | 🔑 Scrape or licence | ~850K stamps (Germany/Europe authority) |

**Legal foundation:**
- Facts (dates, denominations, catalogue numbers) are not copyrightable (Feist v. Rural, 1991)
- Scraping public sites is legal (hiQ v. LinkedIn 2022, Meta v. Bright Data 2024)
- OUR IP: schema, taxonomy, AI descriptions, valuation time-series, cross-reference compilation
- EU sui generis database right protects our whole database for 15 years

---

## Running Research (awaiting results)

Two deep-research workflows were kicked off and will complete soon. Results to be added to:
- `docs/research/europe-sources.md` — European philatelic sources (Michel, NVPH, AFA, Facit, etc.)
- `docs/research/guinea-bissau.md` — Guinea-Bissau stamp history + sources
- `docs/research/rhodesia.md` — Full Rhodesia/Zimbabwe lineage stamp history

---

## Questions? Decisions Needed?

Before asking David, check:
1. This file — most answers are here
2. `docs/research/phase1-research-findings.md` — detailed research
3. `docs/schema/003_stampid_spec.md` — StampID questions
4. `docs/schema/004_succession_schema.sql` — country name questions

If genuinely stuck, ask David via david.defranceski@gmail.com.
