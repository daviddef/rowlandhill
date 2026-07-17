# Competitive Landscape — AI Stamp Identifier Apps
**Date:** July 2026
**Status:** Verified against App Store listings, developer sites, and public reviews
**Supersedes:** the "Competitive Landscape" section of `phase1-research-findings.md`, which
missed this entire category.

---

## Why This Document Exists

David spotted **PhilSnap: Stamp ID & Values** in the App Store. It is not in the Phase 1
competitor table. Checking it turned up not one competitor but a **whole category** of
AI-powered stamp identifier apps, most launched 2024–2026, that Phase 1 did not cover.

Two Phase 1 claims do not survive contact with the App Store:

- ❌ *"Competitors feel like 2005"* — PhilSnap launched September 2025 and rates 4.7/5.
- ❌ *"No app combines AI identification + valuations + collection management"* — PhilSnap
  does all three today, and several others do too.

The opportunity is still real, but it is **not** an empty market. It is a crowded market of
shallow apps. That is a different strategy: win on depth and accuracy, not on being first
or being modern.

---

## The Main Competitor: PhilSnap

| | |
|---|---|
| **Developer** | Next Vision Limited |
| **Released** | 20 September 2025 |
| **Rating** | 4.7 / 5 from ~1,900 ratings |
| **Price** | Free with IAP; Premium ~$3.99/month or **$39.99/year** |
| **Requires** | iOS 16+ (also macOS 13+ on Apple silicon, visionOS) |

**What it already does** — photo identification (country, year, face value, series,
watermark/printing type, catalogue references "where available"), condition grading
suggestions (Fine → Superb) with cues on centering, perforations, gum, creases and
cancellations, variant/error detection, postmark insights, a collection album with notes
and purchase data plus total collection value, and an AI chat feature.

Read that list against `CLAUDE.md`. It is close to StampScan's v1 feature set, shipped, ten
months ago. **Their annual price ($39.99) is identical to our planned annual price**, and
their monthly is $1 cheaper. We cannot present $4.99/$39.99 as competitive positioning
against a free-to-download incumbent — it is price parity with a more established product.

### The developer matters more than the app

Next Vision Limited is not a philately business. They are an **identifier-app studio**:
~23 iOS apps, 4.5★ across ~48,600 ratings, ~50M installs across Google Play, and roughly
17 Android apps. Their hits are **CoinSnap – Coin Identifier** and **Rock Identifier: Stone
ID**, both 10M+ installs. Their portfolio includes ToyWorth, BuySnap, FlipSnap.

PhilSnap is the coin/rock template pointed at stamps.

**What this means strategically:**
- They have a proven ASO and distribution machine. On marketing reach, we lose.
- They will not out-research us on philately. Stamps are one of ~23 bets for them.
- They can enter — and leave — fast. Their commitment to the niche is shallow.
- If StampScan validates the category, expect a fast follow, not a considered one.

---

## The Rest of the Field

At least eight to ten AI stamp identifiers are live. From PhilSnap's own "customers also
bought": Stamp Value Stamp Identifier, Stamp Identifier, Stamp Identifier Value Scanner,
Stamp ID Pro™, Stamp Value Identifier, Stamp Identifier – Stampico, plus adjacent
Antique/Coin identifiers.

| App | Developer | Signal |
|---|---|---|
| **PhilSnap** | Next Vision Limited | 4.7★ / ~1,900 ratings. Category leader. |
| **Stampico** | 326 LAB – FZCO | 4.75★ / ~120 ratings. Subscription complaints. |
| **StampSnap** | Vejo Apps | iOS. **20+ countries only** — 8,500 US, 7,200 UK stamps. |
| **Stamp Value Stamp Identifier** | — | Reviewer: correct **~75% of the time**; valuations ranged **$4–$1,500 for one stamp**. |
| **Stamp Identifier (Colnect)** | Colnect | **3.46★ / ~1,600 ratings** on Android — the big database does not guarantee a good app. |

⚠️ **Naming collision.** **StampSnap** (Vejo Apps) already exists, and the category is thick
with *-Snap* branding (PhilSnap, CoinSnap, BuySnap, FlipSnap). **"StampScan" is one letter
from "StampSnap"** and reads as a me-too entry. This needs a trademark search and a serious
look at the name before any App Store submission or domain/IP spend.

---

## Where They Are Weak — The Real Opportunity

The competitors are modern and well-marketed, but consistently **shallow**. Every documented
weakness maps to something StampScan already plans:

| Their documented gap | Evidence | Our planned answer |
|---|---|---|
| **Identification accuracy** | PhilSnap 1★ review: "falsely identifies stamps regularly", different results for the same stamp on repeat scans, and a claim that experts found information on 600+ appraised stamps incorrect. Another app self-reports ~75%. | Embedding similarity over a large corpus |
| **Thin catalogue** | StampSnap covers 20+ countries. PhilSnap reviews cite "obvious misses, especially with early U.S. issues". | 5–15M item target |
| **Valuations not condition-aware** | PhilSnap reviews: no differentiation by condition, block, or sheet; unclear what the value metric means. Another app: $4–$1,500 range on one stamp. | Real auction results, condition-graded |
| **No data export** | PhilSnap reviews request it. | Dealer Pro CSV export |
| **No country organisation / duplicate detection** | PhilSnap reviews request both. | Succession engine, collection tooling |
| **No marketplace / peer trading** | PhilSnap reviews request it. | Marketplace (Phase 4) |

This is the honest version of the thesis: **the category is proven and monetising, the
incumbents are a mile wide and an inch deep, and nobody has done the hard data work.** Our
moat was never AI photo ID — that is now table stakes. The moat is the database, the
cross-catalogue StampID, and valuations a serious collector can trust.

The uncomfortable corollary: our differentiation lives **entirely** in the two things not yet
built — the corpus and the trained model. Until those exist, StampScan is a worse PhilSnap.

---

## Recommended Revisions to Strategy

1. **Retire "competitors feel like 2005."** It is false and it is load-bearing in
   `HANDOVER.md`, `CLAUDE.md`, and the moat table. Believing it leads to under-investing in
   exactly the fight we are in.
2. **Revisit the name** before spending on App Store presence, domains, or trademarks.
3. **Revisit pricing.** $39.99/year is not competitive against an incumbent at $39.99/year
   with 1,900 ratings and a free tier. Either undercut, or justify the premium with depth
   that is visible before purchase.
4. **Reconsider the hard paywall.** The 17-day-trial / hard-paywall decision was made when
   the field looked empty. PhilSnap is free to download with IAP. A hard paywall against a
   free incumbent is a much harder sell than the Phase 1 research assumed.
5. **Treat accuracy as the wedge.** Their most damaging reviews are accuracy reviews. That
   is where a philately-serious product wins — and where an app studio running 23 products
   will not follow.
6. **Move the moat forward in the plan.** The database and the model are the product. The
   iOS shell is not.

---

## Sources

- PhilSnap — App Store: https://apps.apple.com/us/app/philsnap-stamp-id-values/id6752372987
- PhilSnap reviews: https://apps.apple.com/us/app/philsnap-stamp-id-values/id6752372987?see-all=reviews&platform=iphone
- Next Vision Limited — App Store: https://apps.apple.com/us/developer/next-vision-limited/id1532006906
- Next Vision Limited — AppBrain: https://www.appbrain.com/dev/Next+Vision+Limited/
- StampSnap: https://stampidentifier.app/
- Stampico — App Store: https://apps.apple.com/us/app/stamp-identifier-stampico/id6749361095
- Stamp Value Stamp Identifier: https://apps.apple.com/us/app/stamp-value-stamp-identifier/id6504604156
- Colnect Stamp Identifier (Android): https://www.appbrain.com/app/stamp-identifier/com.colnect.identify.stamp

**Not verified:** Stamp Community Forum has an active thread ("The Philsnap App, Has Anyone
Used This App? Is It Accurate?", TOPIC_ID=90812) that is behind bot protection and was not
read. It is likely the best independent source on real-world accuracy — worth a manual look:
https://www.stampcommunity.org/topic.asp?TOPIC_ID=90812
