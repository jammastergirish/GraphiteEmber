#!/usr/bin/env bash
#
# Package <app-folder>/build/<APP_NAME>.app into a distributable .dmg and print
# its SHA-256. Run build_app.sh first (release.sh does both).
#
#   make_dmg.sh <app-folder>
#
# <app-folder>/app.conf sets APP_NAME and DISPLAY_NAME (the disk image's name).
#
# For a public download that opens without Gatekeeper warnings, the .app must
# be signed with a "Developer ID Application" certificate and notarized; use
# release.sh for that.
#
set -euo pipefail

ROOT="$(cd "$1" && pwd)"
source "$ROOT/app.conf"
APP="$ROOT/build/$APP_NAME.app"

if [ ! -d "$APP" ]; then
    echo "error: $APP not found — run ./build_app.sh release first." >&2
    exit 1
fi

VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$APP/Contents/Info.plist")
DMG="$ROOT/build/$APP_NAME-$VERSION.dmg"
STAGING="$(mktemp -d)"

cp -R "$APP" "$STAGING/"
ln -s /Applications "$STAGING/Applications"   # drag-to-install target

rm -f "$DMG"
hdiutil create -volname "$DISPLAY_NAME" \
    -srcfolder "$STAGING" -ov -format UDZO "$DMG" >/dev/null
rm -rf "$STAGING"

# Version-less copy so a permanent …/releases/latest/download/<APP_NAME>.dmg
# link always resolves. Upload BOTH assets to each GitHub Release.
cp "$DMG" "$ROOT/build/$APP_NAME.dmg"

echo "Created $DMG"
echo "        $ROOT/build/$APP_NAME.dmg (version-less copy for the 'latest' link)"
echo -n "SHA-256: "
shasum -a 256 "$DMG" | awk '{print $1}'
