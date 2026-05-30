#!/bin/bash
# Assembles a self-contained "YouTube Music.app" from the source files here.
# Re-run any time to rebuild from scratch.
set -euo pipefail
SRC="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
APP="$SRC/YouTube Music.app"
C="$APP/Contents"

echo "Building: $APP"
rm -rf "$APP"
mkdir -p "$C/MacOS" "$C/Resources/app/node_modules/.bin"

# Launcher + Info.plist + PkgInfo
cp "$SRC/launcher" "$C/MacOS/launcher"
chmod +x "$C/MacOS/launcher"
cp "$SRC/Info.plist" "$C/Info.plist"
printf 'APPL????' > "$C/PkgInfo"

# Payload (the Node app)
cp "$SRC/payload/ytmusic.js"  "$C/Resources/app/ytmusic.js"
cp "$SRC/payload/package.json" "$C/Resources/app/package.json"

# Bundle Playwright (pure JS → architecture-portable). Reuse a local install if present.
NM=""
for cand in \
  "$HOME/Tools/monday-mcp/node_modules" \
  "$HOME/Tools/ivari360-mcp/node_modules" \
  "$HOME/Tools/job-hunter/node_modules" \
  "$HOME/Tools/workcanvas-playwright/node_modules"; do
  if [ -d "$cand/playwright" ] && [ -d "$cand/playwright-core" ]; then NM="$cand"; break; fi
done

DST="$C/Resources/app/node_modules"
if [ -n "$NM" ]; then
  echo "Bundling Playwright from: $NM"
  cp -R "$NM/playwright"      "$DST/playwright"
  cp -R "$NM/playwright-core" "$DST/playwright-core"
  ln -sf "../playwright/cli.js"      "$DST/.bin/playwright"
  ln -sf "../playwright-core/cli.js" "$DST/.bin/playwright-core"
else
  echo "No local Playwright found. The PRIMARY path (direct Chrome) doesn't need it —"
  echo "Playwright only powers the no-Chrome fallback. Trying an optional npm install…"
  if command -v npm >/dev/null 2>&1 && ( cd "$C/Resources/app" && npm install --no-audit --no-fund ); then
    echo "Bundled Playwright via npm."
  else
    echo "Skipped Playwright (no npm/network). App still works on any Mac with Google Chrome."
  fi
fi

# Icon (best-effort — the app works without it).
if [ -f "$SRC/app.icns" ]; then
  cp "$SRC/app.icns" "$C/Resources/app.icns"
elif command -v rsvg-convert >/dev/null 2>&1 && command -v iconutil >/dev/null 2>&1 && [ -f "$SRC/icon.svg" ]; then
  echo "Generating icon…"
  set +e
  ISET="$SRC/.iconset"; rm -rf "$ISET"; mkdir -p "$ISET"
  g() { rsvg-convert -w "$1" -h "$1" "$SRC/icon.svg" -o "$2" 2>/dev/null; }
  g 16   "$ISET/icon_16x16.png"
  g 32   "$ISET/icon_16x16@2x.png"
  g 32   "$ISET/icon_32x32.png"
  g 64   "$ISET/icon_32x32@2x.png"
  g 128  "$ISET/icon_128x128.png"
  g 256  "$ISET/icon_128x128@2x.png"
  g 256  "$ISET/icon_256x256.png"
  g 512  "$ISET/icon_256x256@2x.png"
  g 512  "$ISET/icon_512x512.png"
  g 1024 "$ISET/icon_512x512@2x.png"
  iconutil -c icns "$ISET" -o "$C/Resources/app.icns" && echo "Icon built." || echo "Icon build skipped."
  rm -rf "$ISET"
  set -e
else
  echo "Icon tools unavailable; using default icon."
fi

# Ad-hoc codesign (best-effort) so macOS is happy launching it locally.
if command -v codesign >/dev/null 2>&1; then
  codesign --force --sign - "$APP" >/dev/null 2>&1 && echo "Ad-hoc signed." || echo "Codesign skipped."
fi

touch "$APP"
echo "Done: $APP"
