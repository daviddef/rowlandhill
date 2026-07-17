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

Read that list against `CLAUDE.md`. It is close to Rowland's v1 feature set, shipped, ten
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
- If Rowland validates the category, expect a fast follow, not a considered one.

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

### 🚨 The name was not just confusable — it was taken. (Resolved: renamed to Rowland)

The working name **StampScan** is an **active competitor**, verified July 2026:

| | |
|---|---|
| **Operator** | FETCH TECHNOLOGY PTE. LTD. (Singapore) |
| **Domain** | **`stampscan.app` — theirs**, live and actively marketed |
| **Google Play** | "StampScan – Stamp Identifier" — **3.9★, 142 reviews, 5K+ downloads**, ads + IAP, updated 13 July 2026 |
| **Pitch** | AI photo ID, Scott/Michel/SG catalogue numbers, eBay + auction values, CSV export — i.e. ours |
| **Pricing** | $7.99/month or **$29.99/year** — undercuts our planned $39.99 |

**Their published figures do not match their store listing.** The site advertises "50,000+
collectors" and "4.7 on Google Play"; the Google Play listing itself showed **5K+ downloads
and 3.9★ from 142 reviews** when checked in July 2026. The site also lists Stanley Gibbons,
Scott Catalogue, the APS and Linn's under a "featured in" heading, for which we found no
corroboration. Several Play reviews report subscription and support problems.

That made the name **worse than unavailable**. A 3.9★ app whose own marketing overstates its
traction owns the search results, the `.app` domain, and the Play listing. Trading as
StampScan meant inheriting that association — for a product whose entire strategy is being
the trustworthy one.

It had also leaked into the code: `StampAPIClient.baseURL` pointed at
`https://api.stampscan.app/v1` and the entitlements declared `applinks:stampscan.app` —
**both aimed at a competitor's domain**. The Phase 1 docs invented that domain without
checking. Same failure mode as missing the competitor category entirely.

**Resolved → renamed to `Rowland`** (Sir Rowland Hill, inventor of the postage stamp).
Rationale and the outstanding trademark-clearance action are recorded in `CLAUDE.md`.

⚠️ Also note **StampSnap** (Vejo Apps) exists, and the category is thick with *-Snap*
branding (PhilSnap, CoinSnap, BuySnap, FlipSnap). Descriptive "Stamp + verb" names are
simultaneously crowded and weak as trademarks — which is why the replacement is deliberately
not one.

---

## Where They Are Weak — The Real Opportunity

The competitors are modern and well-marketed, but consistently **shallow**. Every documented
weakness maps to something Rowland already plans:

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
built — the corpus and the trained model. Until those exist, Rowland is a worse PhilSnap.

---

## What Serious Collectors Actually Say (Stamp Community Forum, Jan–Feb 2026)

The thread that was behind bot protection has now been read (David supplied it). It is the
single most valuable source found, and it is **more negative — and more useful — than the
App Store reviews**. 11 replies, 2,690 views, locked by a moderator in February 2026.

The App Store rates PhilSnap 4.7★. The experts on this forum rejected it outright. Both are
true, and the gap between them is the whole strategic problem.

### The most substantive critique (rogdcam, 12,585 posts)

> There are really no shortcuts for accuracy and Philsnap is a prime example.

His technical objections — a photo **cannot** do these:
- Identify **types** where an engraving or **colour shade** difference decides the value
- Check **watermarks** ("often important")
- Verify **perforation gauge** (the app is using an image *you* provide)
- Find faults: **thins, sealed tears**
- Check gum for **regumming, hinging, disturbance**

**None of this is fixed by a bigger database.** It is a physics limit on photo identification,
and it applies to Rowland's embedding model exactly as it applies to PhilSnap. These
attributes are frequently the entire difference between a $5 stamp and a $5,000 stamp. Any
claim we make about "accurate valuations from a photo" runs into this wall.

### The deal-breaker he names is not accuracy — it is the Scott licence

> if you want to sell a stamp or interact with other collectors you need a catalog number
> with Scott the most widely recognized and accepted. I have not seen the app having a Scott
> numbering license so **that is a deal breaker right there**.

⚠️ **This is aimed at PhilSnap but it hits Rowland harder, because cross-catalogue
referencing *is* our stated core IP.** See "Catalogue Numbers (IMPORTANT)" in `CLAUDE.md`:
"The `catalogue_refs` array is the gold — it's what makes Rowland uniquely valuable."

**Verified, and the Phase 1 legal position does not survive it:**
- Scott's publishers **claim copyright on the numbering system itself** and grant only
  **limited licences** for its use.
- Third-party sites that show Scott numbers carry notices that they are "used under a
  licensing agreement with Amos" — i.e. **a licence market exists and people pay into it**.
- "Scott" is a registered trademark; no use of the marks or copyrighted material without
  express written permission.
- Scott sued **Krause Publications** (Minkus) for infringement over exactly this. It settled
  out of court and Krause continued referencing Scott numbers — so the question is genuinely
  **unsettled**, but Scott asserts and has litigated.
- Phase 1 already noted Scott is "licensed to EzStamp" — which is evidence *against* the
  Feist theory, not for it. You do not license what is free.
- Also stale: Phase 1 says "Scott (Amos Media)". **Scott Stamp, LLC became the publisher in
  Q4 2025.**

`CLAUDE.md` asserts "Facts are free, compilation is ours (Feist)". Feist protects *facts* —
dates, denominations. A **numbering system is an original creation**, which is a materially
weaker position than the handoff assumes, and the handoff never distinguishes the two.

**This needs a real IP lawyer before the crawler is built, not after.** It is cheap to ask
now and ruinous to discover once the database exists and the app is live. It is the one
open question that could invalidate the core IP thesis rather than merely reshape it.

### The market is not who the strategy assumes

Every experienced voice in the thread recommends **against** apps, in favour of a cheap
second-hand catalogue:

- **gvol21** (441 posts): "don't even bother with these apps. Not worth the time. Pick up a
  catalog - even an older, used one will do".
- **Hello123**: "Dont buy the app, buy the Scott Catalog."
- **Tiger Dude**: "Scott Catalogs ... plus google image search will meet most needs."
- **guykickinit** (Pillar, 819 posts): "I use a 2008. Cheaper and still the same stamps."

And the influence is measurable — **Bobcat126 arrived intending to try the app and left
without it** after reading rogdcam:

> Ok then I'll disregard downloading the app.

**One expert post killed a download in three hours.** That is the distribution risk for a
paid, depth-positioned product: the people we would build the depth *for* are the people who
will tell everyone else not to install it.

### The one enthusiast is the actual customer

**GravelDave** (New Member, **4 posts**) is the lone positive voice:

> I think the app is an excellent place for a novice to start. I have no idea where to even
> start looking in a catalogue. I can spend hours looking for 1 stamp. the app will likely
> find the stamp, the issue, and year. I can do this in 30 seconds and less for each stamp.

Note who he is: a beginner with 4 posts, versus critics with 12,585 / 7,081 / 819. The value
is **triage speed for someone who cannot use a catalogue** — hours to 30 seconds.

**This is the strategic contradiction at the centre of Rowland.** Sort the two audiences:

| | Serious collectors | Novices |
|---|---|---|
| Want the 5–15M catalogue + Scott cross-refs | ✅ | ❌ (don't know what a Scott number is) |
| Will accept a photo-based ID | ❌ (needs watermark, perf, gum in hand) | ✅ |
| Will pay $39.99/year | Already own a $20 used catalogue | Unproven past novelty |
| Recommend us to others | Decisive | No influence |

**We are planning a deep-catalogue product for the audience that rejects apps, and shipping
photo ID to the audience that doesn't need the depth.** The 5–15M corpus — the single most
expensive thing in the plan — serves the people least likely to buy. That contradiction is
not resolved anywhere in the handoff, and it should be resolved before the crawler spend.

### The genuine opening: consistency

GravelDave's guess at the mechanism is the most actionable line in the thread:

> I think what the app does is use ChatGPT or some other AI agent to look for the stamps, and
> it returns two values: a low and a high ... the app then takes the average and assigns a
> value to your stamp.

If that is right — and the 1★ report of **"different result for the same stamp over and
over"** and the **$4–$1,500** range on one stamp both point the same way — then the
incumbents have **no database at all**. They are an LLM guessing against web search at
inference time.

**That is a real, demonstrable, defensible wedge, and it is not "more stamps".** A genuine
database returns *the same answer every time*, and can show provenance for it. "Consistent
and sourced" beats "bigger" as a claim, because a user can verify it in ten seconds by
scanning the same stamp twice — and it is precisely what an app-studio template cannot copy
without doing the data work.

---

## Recommended Revisions to Strategy

Ordered by what could invalidate the plan, not by what is easiest.

1. 🚨 **Get an IP lawyer's answer on Scott/SG/Michel numbering rights — before the crawler.**
   Cross-catalogue referencing is the stated core IP. Scott claims copyright on the numbering
   system, licenses it, and has litigated it. The Feist "facts are free" theory in `CLAUDE.md`
   does not obviously cover a numbering system, and the handoff never separates the two. If
   the answer is "you need a licence", the entire moat is a licensing negotiation rather than
   an engineering project — and that changes what this company is. **Answer this first.**
2. 🚨 **Resolve the audience contradiction.** Depth serves collectors who reject apps; photo
   ID serves novices who don't need depth. Pick one and let the roadmap follow, or state
   explicitly how a 5–15M corpus earns its cost against the novice who actually pays. This
   is the difference between a $200/month data bill and a rational plan.
3. **Reposition the moat from "bigger" to "consistent and sourced."** The incumbents appear
   to be LLM-guessing with no database — same stamp, different answers; $4–$1,500 on one
   valuation. A real database gives repeatable, provenance-backed answers. That is
   demonstrable in ten seconds and an app studio cannot fake it.
4. **Be honest about what a photo cannot do.** Watermarks, perforation gauge, gum state,
   thins, sealed tears, colour shades — a camera cannot see these, and they often *are* the
   value. Ship condition as **user-declared input**, not AI-inferred output, and say so. The
   apps that overclaim here are the ones collecting the 1★ reviews.
5. **Retire "competitors feel like 2005."** False, and load-bearing in `HANDOVER.md`,
   `CLAUDE.md`, and the moat table.
6. **Revisit the name** before any App Store, domain, or trademark spend — "StampSnap"
   already exists.
7. **Revisit pricing and the hard paywall.** $39.99/year and a hard paywall were chosen when
   the field looked empty. The incumbent is free to download at the same annual price with
   1,900 ratings.
8. **Consider courting the experts rather than dismissing them.** They are hostile to apps
   but decisive in influence — one post killed a download in three hours. A Scott licence
   plus honest condition handling is what would flip rogdcam. Nothing else in the plan will.

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
