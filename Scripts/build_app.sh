#!/usr/bin/env bash
#
# Build a Graphite & Ember app and wrap it into a proper .app bundle, so macOS
# shows its icon and lets the user grant it permissions.
#
# Each app calls this from a thin ./build_app.sh wrapper:
#   build_app.sh <app-folder> [debug|release] [run|install]
#     run      launch the bundle from <app-folder>/build
#     install  copy it to /Applications (replacing any copy there), then launch
#
# <app-folder>/app.conf sets APP_NAME (binary, bundle and entitlements name)
# and BUNDLE_ID.
#
set -euo pipefail

ROOT="$(cd "$1" && pwd)"; shift
source "$ROOT/app.conf"
CONFIG="${1:-release}"
DO_RUN="${2:-}"

echo "==> swift build -c $CONFIG"
swift build --package-path "$ROOT" -c "$CONFIG"

BIN_DIR="$(swift build --package-path "$ROOT" -c "$CONFIG" --show-bin-path)"
APP="$ROOT/build/$APP_NAME.app"
CONTENTS="$APP/Contents"

# App icon: if AppIcon.icns is missing, the app draws its own iconset
# (`--write-iconset`) and iconutil turns it into AppIcon.icns.
if [ ! -f "$ROOT/Resources/AppIcon.icns" ]; then
    echo "==> rendering app icon"
    ICONSET="$ROOT/build/AppIcon.iconset"
    rm -rf "$ICONSET"
    "$BIN_DIR/$APP_NAME" --write-iconset "$ICONSET"
    iconutil -c icns "$ICONSET" -o "$ROOT/Resources/AppIcon.icns"
fi

echo "==> assembling $APP"
rm -rf "$APP"
mkdir -p "$CONTENTS/MacOS" "$CONTENTS/Resources"
cp "$BIN_DIR/$APP_NAME" "$CONTENTS/MacOS/$APP_NAME"
cp "$ROOT/Resources/Info.plist" "$CONTENTS/Info.plist"
cp "$ROOT/Resources/AppIcon.icns" "$CONTENTS/Resources/AppIcon.icns"

# Ship any bundled Swift package resources (e.g. WhisperKit) next to the binary.
if compgen -G "$BIN_DIR/*.bundle" > /dev/null; then
    cp -R "$BIN_DIR"/*.bundle "$CONTENTS/Resources/"
fi

# Prefer the stable self-signed identity (from setup_signing.sh next to this
# script) so rebuilds keep their code identity and macOS keeps permission
# grants. Fall back to ad-hoc signing if it isn't set up.
SIGN_ID="One Tap Local Signing"
SIGN_KC="$HOME/Library/Keychains/onetap-signing.keychain-db"
if [ -f "$SIGN_KC" ] && security find-identity -p codesigning "$SIGN_KC" 2>/dev/null | grep -q "$SIGN_ID"; then
    echo "==> code signing (stable identity: $SIGN_ID)"
    security unlock-keychain -p onetap-local "$SIGN_KC" 2>/dev/null || true
    codesign --force --deep --sign "$SIGN_ID" --keychain "$SIGN_KC" \
        --identifier "$BUNDLE_ID" \
        --entitlements "$ROOT/Resources/$APP_NAME.entitlements" \
        "$APP"
else
    echo "==> code signing (ad-hoc — run setup_signing.sh once to stop re-granting permissions)"
    codesign --force --deep --sign - \
        --identifier "$BUNDLE_ID" \
        --entitlements "$ROOT/Resources/$APP_NAME.entitlements" \
        "$APP"
fi

echo "==> done: $APP"

if [[ "$DO_RUN" == "install" ]]; then
    echo "==> installing to /Applications"
    pkill -x "$APP_NAME" 2>/dev/null || true
    rm -rf "/Applications/$APP_NAME.app"
    cp -R "$APP" "/Applications/$APP_NAME.app"
    open "/Applications/$APP_NAME.app"
elif [[ "$DO_RUN" == "run" ]]; then
    echo "==> launching"
    open "$APP"
fi
