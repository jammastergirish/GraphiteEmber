#!/usr/bin/env bash
#
# Build a public, notarized release of a Graphite & Ember app: sign with
# Developer ID + Hardened Runtime, package a .dmg, notarize with Apple, and
# staple the ticket. The result opens on any Mac without Gatekeeper warnings.
#
#   release.sh <app-folder>
#
# One-time prerequisites:
#   1. Apple Developer Program membership.
#   2. A "Developer ID Application" certificate in your login keychain
#      (Xcode → Settings → Accounts → Manage Certificates → +).
#   3. A notarytool credential profile:
#        xcrun notarytool store-credentials "OneTapNotary" \
#          --apple-id "you@example.com" --team-id "YOURTEAMID" \
#          --password "app-specific-password"   # appleid.apple.com → App-Specific Passwords
#
# Usage (through the app's ./release.sh wrapper):
#   SIGN_ID="Developer ID Application: Your Name (TEAMID)" \
#   NOTARY_PROFILE="OneTapNotary" \
#   ./release.sh
#
# SIGN_ID may also be a certificate's SHA-1 fingerprint, which avoids
# ambiguity when two certificates share a name.
#
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$1" && pwd)"
source "$ROOT/app.conf"
: "${SIGN_ID:?set SIGN_ID to your 'Developer ID Application: …' identity (security find-identity -p codesigning -v)}"
: "${NOTARY_PROFILE:?set NOTARY_PROFILE to your notarytool keychain profile name}"

APP="$ROOT/build/$APP_NAME.app"
ENTITLEMENTS="$ROOT/Resources/$APP_NAME.entitlements"

echo "==> building app bundle"
"$HERE/build_app.sh" "$ROOT" release

echo "==> signing with Developer ID + Hardened Runtime"
codesign --force --deep --options runtime --timestamp \
    --sign "$SIGN_ID" \
    --identifier "$BUNDLE_ID" \
    --entitlements "$ENTITLEMENTS" \
    "$APP"
codesign --verify --strict --verbose=2 "$APP"

echo "==> packaging .dmg"
"$HERE/make_dmg.sh" "$ROOT"
VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$APP/Contents/Info.plist")
DMG="$ROOT/build/$APP_NAME-$VERSION.dmg"

echo "==> signing the .dmg"
codesign --force --timestamp --sign "$SIGN_ID" "$DMG"
codesign --verify --verbose=2 "$DMG"

echo "==> notarizing (a few minutes)…"
xcrun notarytool submit "$DMG" --keychain-profile "$NOTARY_PROFILE" --wait

echo "==> stapling the notarization ticket"
xcrun stapler staple "$DMG"
xcrun stapler validate "$DMG"
cp "$DMG" "$ROOT/build/$APP_NAME.dmg"   # refresh the version-less copy with the stapled DMG

echo "==> release ready"
echo "$DMG"
echo -n "SHA-256: "; shasum -a 256 "$DMG" | awk '{print $1}'
