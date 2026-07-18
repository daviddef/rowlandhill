#!/usr/bin/env bash
# Archive, export and upload Rowland to TestFlight.
#
# PREREQUISITE (one time, and only you can do it): the app record must exist in
# App Store Connect. Apple's API cannot create it — POST /v1/apps returns
# "The resource 'apps' does not allow 'CREATE'" — and without it the upload fails with
# "Cannot determine the Apple ID from Bundle ID 'app.rowlandhill'".
#
#   App Store Connect → Apps → + → New App
#     Platform  : iOS
#     Name      : Rowland            (must be unique across the App Store)
#     Bundle ID : app.rowlandhill    (already registered, ID 64522MQRDN)
#     SKU       : ROWLAND001
#
# After that, this script is the whole release. Run it from the repo root.
set -euo pipefail

TEAM_ID="L9SAXP2E2W"
KEY_ID="9K9486HSDF"
ISSUER_ID="69a6de8c-a266-47e3-e053-5b8c7c11a4d1"
BUILD_DIR="${BUILD_DIR:-build}"

echo "==> Generating project"
xcodegen generate

echo "==> Archiving (Release)"
rm -rf "$BUILD_DIR/Rowland.xcarchive" "$BUILD_DIR/export"
xcodebuild -project Rowland.xcodeproj -scheme Rowland -configuration Release \
  -destination 'generic/platform=iOS' \
  -archivePath "$BUILD_DIR/Rowland.xcarchive" \
  -allowProvisioningUpdates archive

echo "==> Exporting IPA"
cat > "$BUILD_DIR/ExportOptions.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>method</key><string>app-store-connect</string>
  <key>teamID</key><string>${TEAM_ID}</string>
  <key>uploadSymbols</key><true/>
  <key>signingStyle</key><string>automatic</string>
  <key>destination</key><string>export</string>
</dict>
</plist>
EOF
xcodebuild -exportArchive \
  -archivePath "$BUILD_DIR/Rowland.xcarchive" \
  -exportOptionsPlist "$BUILD_DIR/ExportOptions.plist" \
  -exportPath "$BUILD_DIR/export" \
  -allowProvisioningUpdates

echo "==> Uploading to TestFlight"
xcrun altool --upload-app -f "$BUILD_DIR/export/Rowland.ipa" -t ios \
  --apiKey "$KEY_ID" --apiIssuer "$ISSUER_ID"

echo "==> Done. Build appears in App Store Connect → TestFlight after ~5-15 min of processing."
echo "    Bump CURRENT_PROJECT_VERSION in project.yml before each new upload."
