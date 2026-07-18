# Getting Rowland onto TestFlight

**What's done (in the repo):** app icon, launch screen, bundle ID, version/build numbers,
capabilities, and the export-compliance flag. The app builds and launches.

**What only you can do:** anything that needs the Apple Developer account and its signing
credentials. I can't create an Apple account, hold a signing certificate, or upload a build —
those are yours. The steps below mark clearly which is which.

---

## Already configured

| Item | Value | Where |
|---|---|---|
| App icon | Gold perforated stamp, "R" monogram | `Assets.xcassets/AppIcon.appiconset` |
| Launch screen | Centered logo on `#16161B` | `Info.plist` → `UILaunchScreen` |
| Bundle ID | `app.rowlandhill` | `project.yml` |
| Version / build | `0.1.0` / `1` | `project.yml` (`MARKETING_VERSION` / `CURRENT_PROJECT_VERSION`) |
| Export compliance | `ITSAppUsesNonExemptEncryption = false` | `Info.plist` (skips the per-upload prompt) |
| Capabilities | Sign in with Apple, iCloud, camera, photos | `Rowland.entitlements`, `Info.plist` |

---

## Steps to TestFlight

### 1. Apple Developer Program — **you**
Enrol at https://developer.apple.com/programme/ ($99/year). Required for TestFlight.

### 2. Register the bundle ID and create the app — **you**
- App Store Connect → **Identifiers** → register `app.rowlandhill`, enabling **Sign in with
  Apple** and **iCloud (CloudKit)**.
- App Store Connect → **Apps → +** → new app, bundle ID `app.rowlandhill`, name "Rowland".

### 3. Set the signing team — **you** (one line, then I can do the rest)
In `project.yml`, set `DEVELOPMENT_TEAM` to your 10-character Team ID (App Store Connect →
Membership). Then `xcodegen generate`. Signing is currently blank on purpose, so device/archive
builds fail until this is set — simulator builds work without it.

### 4. Archive and upload — **you drive Xcode** (needs your signed-in Apple ID)
```bash
xcodegen generate
open Rowland.xcodeproj
```
In Xcode: select **Any iOS Device**, then **Product → Archive**. When the Organizer opens,
**Distribute App → TestFlight & App Store → Upload**. Xcode signs it with your account and
uploads to App Store Connect.

(CLI alternative once signing is set: `xcodebuild -scheme Rowland -archivePath build/Rowland.xcarchive archive`
then `xcodebuild -exportArchive …` with an export options plist. The Xcode GUI is simpler for a first upload.)

### 5. TestFlight — **you**
App Store Connect → **TestFlight** → the build appears after processing (~5–15 min). Add
internal testers (up to 100, no review) or external testers (needs a short Beta App Review).

---

## Honest gate before you invite testers

The app **builds and looks right, but does not identify stamps yet** — the CoreML model isn't
trained, so scanning returns placeholder results, and the backend API isn't deployed, so the
Catalogue tab shows its error state. For a first internal TestFlight (you and a few people
checking the UI, icon, and flows), that's fine. **Don't invite outside testers until the model
and API are live**, or the core feature will look broken. See `CLAUDE.md` → "What's Done vs
What's TODO".
