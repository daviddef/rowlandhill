# Rowland iOS App — Phase 1 Research Findings
**Date:** July 2026 | **Status:** Verified multi-source research

---

## Executive Summary

Building a world-class iOS stamp identification and catalogue app is **technically feasible and commercially timely**. The UPU launched its own AI-powered stamp ID app in 2025 (validating the concept), but it covers only ~120,000 stamps and is constrained to official issuer data. The competitive field is fragmented, outdated, and full of UX gaps. A well-executed iOS-native app combining AI photo recognition with a rich, multi-source database has a clear path to market leadership.

---

## 1. Stamp Databases & Catalogues

### Major Commercial Catalogues

| Catalogue | Authority | Coverage | API/Access |
|-----------|-----------|----------|------------|
| Stanley Gibbons | British & Commonwealth authority since 1863 | World-wide, British-focused | No official API; Shopify storefront scraper covers ~3,950 items only; subscription digital catalogues only |
| Scott (Amos Media) | North American authority | Worldwide | No public API; licensed to EzStamp (Windows desktop only) |
| Michel | German/European authority | Worldwide | No known public API |
| Yvert et Tellier | French authority | French/European focus | No known public API |
| Stanley Gibbons | | | |

**Key insight:** All major commercial catalogues are **locked down**. No official APIs exist. Licensing negotiations required.

### Accessible Data Sources (Verified)

**Colnect** *(Best current option)*
- Catalogue size: **1.6M+ stamp entries** (confirmed September 2025; the frequently-cited 300,303 figure is from a 2012 milestone blog post)
- Has a CAPI (Collector API) — access via API key request to Colnect directly, or via RapidAPI
- Covers stamps, coins, banknotes, sports cards — multi-collectible
- Supports 61 languages
- Visual/photo search capability already built in
- Commercial licensing terms unclear from 2012 docs; must be negotiated directly for any commercial iOS app
- Mobile iOS app exists ("World Stamps Collecting") but user reviews cite poor UX

**Stamp-Store API** *(Promising, gated)*
- Supports ~37 international cataloguing systems (Scott, SG, Michel, Yvert, NVPH, Edifil, Facit, and more)
- Catalogue API access requires contacting company directly (not self-serve)
- Rate limits: 600 req/min standard, 200 req/min bulk
- Batch lookups: up to 100 SIDs per request
- **Best single data source** for cross-catalogue numbers and pricing if a licence can be negotiated

**UPU WNS Database** *(Official but limited)*
- ~120,000 officially issued stamps from ~200 countries
- "Only global stamp database based entirely on official data submitted by issuers themselves"
- iOS + Android app launched 2025
- Plans to add real-time market values, expanded metadata, printing techniques, artists, engravers
- Developing historical pre-registration platform covering 1840–2001
- Partnership/API access unclear; worth approaching UPU directly

**World Stamps Project** *(Open, community-driven)*
- 17,355+ stamp images as of April 2026
- 60+ countries covered
- Contributor-driven wiki (not professionally curated)
- Token-based incentive system (phi-tokens)
- No open API as yet; watch for future data partnerships

---

## 2. Public Domain & Open Data Resources

### Image Copyright by Country (Verified)

| Country | Public Domain Rule | Practical Implication |
|---------|-------------------|----------------------|
| **USA** | Pre-December 31, 1977 | Large freely-usable corpus of classic US stamps |
| **USSR/Russia** | Official symbols — no copyright | **Entire Soviet and Russian stamp catalogue freely usable** |
| **France** | Issued before 1922 | Pre-1922 French stamps freely usable |
| **Germany** | Standard copyright (70 yrs after creator death) | Cannot use freely without licensing |
| **India** | Older than 60 years (~pre-1966) | Substantial freely-usable corpus |
| **General** | Varies by country | Must verify per jurisdiction |

### Open Datasets

- **Wikimedia Commons** — Large organized public domain stamp image collection, categorized by country. Wikimedia's stamp public domain policy well-documented.
- ~~**Wikidata SPARQL**~~ — 🚨 **REFUTED by direct measurement, July 2026.** The live endpoint
  returns **12,753** postage-stamp items, of which **12,550** are a single Chinese museum
  import; only **78** carry an image and **35** an issue date, and **no catalogue
  cross-reference property is in use at all**. The claim below — "structured philatelic
  metadata … can retrieve catalogue cross-references programmatically" — is false in every
  particular. See `CLAUDE.md` for the reproducing query.
- **Kaggle Postage Stamp Dataset** — Open-access ML training dataset with labelled stamp images; useful for bootstrapping CoreML model training.
- **ResearchGate: "Deep learning for philately understanding"** — Academic paper covering stamp type classification and feature extraction from images.

---

## 3. AI & Computer Vision for Stamp Identification

### Architecture Options

**Option A: Apple Vision + CoreML (On-Device, Recommended for MVP)**
- Apple's Vision framework + CoreML pipeline handles image preprocessing, cropping, and classification entirely on-device
- No server round-trips = fast, private, works offline
- Apple Developer Documentation confirms this pipeline for image classification
- Requires training a custom CoreML model on stamp images

**Option B: CNN + Embedding Database (Scalable Identification)**
- Train a CNN to generate embeddings (feature vectors) for each stamp
- Store embeddings in SQLite or a vector database
- Identify a new stamp by computing cosine similarity against the embedding database
- Scales to millions of stamps without retraining the classifier
- GitHub reference implementation: `Yazangthb/Stamp-recognition`

**Option C: Nyckel Stamp API (Low-code, Fast to prototype)**
- Pre-trained stamp series recognition classifier (Commemorative, Definitive, First Day Cover, ~30 labels)
- Returns confidence score (example: 0.92)
- Can be cloned and customised with user-supplied samples; retrains automatically
- No published accuracy benchmarks; reliability depends on training data similarity
- Free tier available; good for rapid prototyping

**Option D: UPU WNS App Approach (Reference benchmark)**
- UPU's 2025 app uses AI-supported recognition on ~120,000 stamps
- Validates the commercial feasibility of the approach at scale
- Sets the competitive baseline to beat

### Verified Accuracy Benchmarks

| Approach | Test Accuracy | Real-World Accuracy | Notes |
|----------|--------------|---------------------|-------|
| Custom CNN (detection only) | 99% | 99% | Detection of stamp location; NOT classification |
| Custom CNN (full recognition) | 99% (test set) | **80–85%** | Real-data gap; classification is harder than detection |
| YOLO-based mobile model | High | High | 128K parameters; feasible for on-device iOS |
| Document/rubber stamp CNN | High | Varies | Not applicable — different domain |

**Key insight:** Real-world philatelic stamp identification at 80–85% accuracy is achievable today. Targeting 90%+ will require a large, high-quality, labelled training dataset — this is the hardest part of the problem.

---

## 4. Competitive Landscape

> ⚠️ **SUPERSEDED — see `competitors-2026.md`.** This section misses the entire category of
> AI stamp identifier apps launched 2024–2026, including the current category leader
> **PhilSnap** (Next Vision Limited, September 2025, 4.7★ / ~1,900 ratings, $39.99/year —
> the same annual price we planned). The "fragmented / feels like 2005" framing below is
> **false as of July 2026** and should not be used to justify product decisions.

### Existing Apps & Their Gaps

| Product | Platform | AI ID | Collection Mgmt | Valuations | Gaps |
|---------|----------|-------|-----------------|------------|------|
| **iCollect Stamps** | iOS/Android/Mac/Win | ✅ AI Auto-Fill (2025) | ✅ | Partial | Database doesn't cover obscure local issues |
| **Stamp ID Pro** | iOS | ✅ | ❌ | ❌ | Identification only, no management |
| **EzStamp** | Windows only | ❌ | ✅ | ✅ Scott | No mobile, no cloud sync, no barcode/photo scan |
| **Colnect iOS App** | iOS | Partial | ✅ | Community | Poor UX per user reviews |
| **Stampworld** | Website only | ❌ | ❌ | ✅ (inflated) | No app; valuations are ~10x market reality |
| **UPU WNS App** | iOS + Android | ✅ | ❌ | ❌ (planned) | 120K stamps only; no collection management |
| **StampData** | Website | ❌ | ❌ | ❌ | Rich metadata but no mobile |

### Market Gap Summary

The market is **explicitly described as "fragmented" with tools "feeling like 2005"**. No single app combines:
1. AI photo identification from phone camera
2. A catalogue of millions of stamps (worldwide)
3. Accurate, real-time market valuations
4. Personal collection management (digital inventory)
5. Beautiful, modern iOS-native UX

This is the product opportunity.

---

## 5. Legal & Licensing Feasibility

### What's Clear

> 🚨 **The Feist claim below is overstated and is contradicted by this document's own
> catalogue table.** Feist protects *facts*. It does not obviously cover **catalogue
> numbering systems**, which Scott's publisher claims as copyright, licenses (see "licensed
> to EzStamp" above — you do not license what is free), and has litigated (Scott v.
> Krause/Minkus). Since cross-catalogue referencing is the core IP thesis, this gap is
> material and needs an IP lawyer. See `competitors-2026.md`.

- **Raw factual data (prices, names, dates) cannot be copyrighted** under US law (Feist Publications v. Rural Telephone, 1991) — stamp metadata is legally extractable
- **Scraping public websites doesn't violate CFAA** per hiQ Labs v. LinkedIn (2022) and Meta v. Bright Data (2024) — as long as no authentication is bypassed
- **Clickwrap ToS agreements are enforceable** — if a catalogue site requires login+ToS acceptance before showing data, scraping behind that wall carries legal risk
- **Respecting robots.txt** has no legal force but reduces litigation risk and demonstrates good faith

### Practical Licensing Path

1. **Colnect**: Most realistic first API partner — community-contributed data, CAPI exists, approach for commercial licence
2. **Stamp-Store API**: Contact directly for catalogue API access — cross-references 37 systems
3. **UPU/WNS**: Approach as a partner (not competitor) — their app has no collection management; propose data-sharing partnership
4. **Stanley Gibbons, Scott, Michel**: Long-term licensing negotiations; start with open data, upgrade later
5. **Wikimedia Commons + Wikidata SPARQL**: Free, use immediately

---

## 6. Key Risk Areas

| Risk | Severity | Mitigation |
|------|----------|------------|
| Catalogue licensing cost/refusal | High | Start with open data (Colnect, Wikidata, public domain); negotiate commercial licences in Phase 2 |
| ML accuracy below expectations | Medium | Use embedding similarity (scalable); plan for user correction feedback loop |
| Valuations reliability | High | Partner with auction data sources (eBay sold listings, Siegel, Cherrystone); don't rely on Stampworld |
| Competition from iCollect Stamps | Medium | Differentiate on coverage depth, AI accuracy, and UX polish |
| UPU expanding their app | Medium | Their roadmap is slow (government); move fast on collection management features they won't build |

---

*Phase 1 research complete. Proceeding to product roadmap and Phase 2 targeted research.*
