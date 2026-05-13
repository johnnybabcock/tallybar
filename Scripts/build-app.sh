#!/bin/bash
# Bundles a release binary into TallyBar.app for local install or Developer ID distribution.
# For Mac App Store submission see App Store/SUBMISSION.md — use Xcode Archive instead.
#
# Optional env vars:
#   SIGN_IDENTITY        Code-signing identity (default: "-" for ad-hoc)
#                        e.g. "Developer ID Application: Your Name (TEAMID)"
#   ENABLE_SANDBOX       Set to "1" to apply the App Sandbox entitlement
#                        (App Store builds require this; local dev typically off
#                        because the sandbox blocks the self-install prompt).
#   UNIVERSAL            Set to "1" to build a universal arm64 + x86_64 binary.

set -euo pipefail

cd "$(dirname "$0")/.."

BUNDLE_ID="com.johnnybabcock.TallyBar"
APP_NAME="TallyBar"
DISPLAY_NAME="TallyBar"
APP_DIR="build/${APP_NAME}.app"
SIGN_IDENTITY="${SIGN_IDENTITY:--}"
ENABLE_SANDBOX="${ENABLE_SANDBOX:-0}"
UNIVERSAL="${UNIVERSAL:-0}"

BUILD_FLAGS=(-c release)
if [ "$UNIVERSAL" = "1" ]; then
    BUILD_FLAGS+=(--arch arm64 --arch x86_64)
fi

echo "› swift build ${BUILD_FLAGS[*]}"
swift build "${BUILD_FLAGS[@]}"

# `swift build --arch a --arch b` puts the universal binary under `.build/apple/Products/Release`
if [ "$UNIVERSAL" = "1" ]; then
    BIN_SRC=".build/apple/Products/Release/${APP_NAME}"
else
    BIN_SRC=".build/release/${APP_NAME}"
fi

echo "› assembling ${APP_DIR}"
rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS" "$APP_DIR/Contents/Resources"

cp "$BIN_SRC" "$APP_DIR/Contents/MacOS/${APP_NAME}"
cp Resources/PrivacyInfo.xcprivacy "$APP_DIR/Contents/Resources/"

cat > "$APP_DIR/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key><string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key><string>${BUNDLE_ID}</string>
    <key>CFBundleName</key><string>${APP_NAME}</string>
    <key>CFBundleDisplayName</key><string>${DISPLAY_NAME}</string>
    <key>CFBundleVersion</key><string>1</string>
    <key>CFBundleShortVersionString</key><string>1.0</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>LSMinimumSystemVersion</key><string>13.0</string>
    <key>LSUIElement</key><true/>
    <key>NSHighResolutionCapable</key><true/>
    <key>NSHumanReadableCopyright</key><string>Copyright © $(date +%Y) John Babcock. All rights reserved.</string>
</dict>
</plist>
PLIST

CODESIGN_ARGS=(--force --options runtime --sign "$SIGN_IDENTITY")
if [ "$ENABLE_SANDBOX" = "1" ]; then
    CODESIGN_ARGS+=(--entitlements Resources/TallyBar.entitlements)
fi

codesign "${CODESIGN_ARGS[@]}" "$APP_DIR" >/dev/null
xattr -dr com.apple.quarantine "$APP_DIR" 2>/dev/null || true

echo "✓ Built $APP_DIR"
echo "  signed by: $SIGN_IDENTITY"
echo "  sandbox:   $([ "$ENABLE_SANDBOX" = "1" ] && echo on || echo off)"
echo "  universal: $([ "$UNIVERSAL" = "1" ] && echo on || echo off)"
echo
echo "Run:  open '$APP_DIR'"
