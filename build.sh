#!/bin/bash
# Assembles the lean "YouTube Music.app" launcher bundle (an UNOFFICIAL, Chromium-based
# YouTube Music app). The bundle carries NO browser itself — on first run the launcher
# materializes its own branded Chromium engine into Application Support. So this bundle
# stays tiny; re-run any time to rebuild from scratch.
set -euo pipefail
SRC="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
APP="$SRC/YouTube Music.app"
C="$APP/Contents"

echo "Building: $APP"
rm -rf "$APP"
mkdir -p "$C/MacOS" "$C/Resources"

# Launcher + Info.plist + PkgInfo
cp "$SRC/launcher" "$C/MacOS/launcher"
chmod +x "$C/MacOS/launcher"
cp "$SRC/Info.plist" "$C/Info.plist"
printf 'APPL????' > "$C/PkgInfo"

# Icon (the official YouTube Music logo). Prefer a prebuilt app.icns; else render from SVG.
if [ -f "$SRC/app.icns" ]; then
  cp "$SRC/app.icns" "$C/Resources/app.icns"
elif command -v rsvg-convert >/dev/null 2>&1 && command -v iconutil >/dev/null 2>&1 && [ -f "$SRC/icon.svg" ]; then
  echo "Generating icon…"
  set +e
  ISET="$SRC/.iconset"; rm -rf "$ISET"; mkdir -p "$ISET"
  g() { rsvg-convert -w "$1" -h "$1" "$SRC/icon.svg" -o "$2" 2>/dev/null; }
  g 16 "$ISET/icon_16x16.png"; g 32 "$ISET/icon_16x16@2x.png"; g 32 "$ISET/icon_32x32.png"; g 64 "$ISET/icon_32x32@2x.png"
  g 128 "$ISET/icon_128x128.png"; g 256 "$ISET/icon_128x128@2x.png"; g 256 "$ISET/icon_256x256.png"; g 512 "$ISET/icon_256x256@2x.png"
  g 512 "$ISET/icon_512x512.png"; g 1024 "$ISET/icon_512x512@2x.png"
  iconutil -c icns "$ISET" -o "$C/Resources/app.icns" && echo "Icon built." || echo "Icon build skipped."
  rm -rf "$ISET"
  set -e
else
  echo "Icon tools unavailable; using default icon."
fi

# Ad-hoc codesign so macOS launches it cleanly.
if command -v codesign >/dev/null 2>&1; then
  codesign --force --sign - "$APP" >/dev/null 2>&1 && echo "Ad-hoc signed." || echo "Codesign skipped."
fi

touch "$APP"
echo "Done: $APP"
