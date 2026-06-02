#!/bin/bash
# Builds a "drag to Applications" disk image (.dmg) for the UNOFFICIAL, Chromium-based
# YouTube Music app. The end user just double-clicks the .dmg and drags the app onto the
# Applications folder — no Terminal, no GitHub, no build step. Uses only tools built into
# macOS (hdiutil, tiffutil) — nothing to install.
#
# The pretty layout (background image + icon positions) is applied via Finder and is
# best-effort: if Finder automation is blocked (TCC), you still get a fully working DMG
# that shows the app icon next to an Applications shortcut to drag onto.
set -euo pipefail
SRC="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
APP="$SRC/YouTube Music.app"
DIST="$SRC/dist"
VOL="YouTube Music"
DMG="$DIST/YouTube-Music-macOS.dmg"
STAGE="$SRC/.dmg-stage"
RW="$SRC/.dmg-rw.dmg"

# 1. Always build a fresh app so the DMG matches source.
bash "$SRC/build.sh"

# 2. Stage the DMG contents: the app + a shortcut to /Applications + the background.
rm -rf "$STAGE"; mkdir -p "$STAGE/.background"
cp -R "$APP" "$STAGE/"
ln -s /Applications "$STAGE/Applications"
[ -f "$SRC/dmg-background.tiff" ] && cp "$SRC/dmg-background.tiff" "$STAGE/.background/background.tiff"

mkdir -p "$DIST"
rm -f "$DMG" "$RW"

# 3. Create a read-write image we can lay out, sized to fit the contents.
hdiutil create -srcfolder "$STAGE" -volname "$VOL" -fs HFS+ \
  -format UDRW -ov "$RW" >/dev/null

# 4. Mount it and arrange the window (best-effort).
DEV="$(hdiutil attach "$RW" -nobrowse -noautoopen | awk '/Apple_HFS/{print $1; exit}')"
MOUNT="/Volumes/$VOL"

if [ -f "$STAGE/.background/background.tiff" ]; then
  osascript <<OSA 2>/dev/null || echo "  (layout step skipped — Finder automation blocked; DMG still works)"
tell application "Finder"
  tell disk "$VOL"
    open
    set current view of container window to icon view
    set toolbar visible of container window to false
    set statusbar visible of container window to false
    set the bounds of container window to {200, 120, 860, 540}
    set opts to the icon view options of container window
    set arrangement of opts to not arranged
    set icon size of opts to 128
    set text size of opts to 13
    set background picture of opts to file ".background:background.tiff"
    set position of item "YouTube Music.app" of container window to {165, 205}
    set position of item "Applications" of container window to {495, 205}
    update without registering applications
    delay 1
    close
  end tell
end tell
OSA
fi

sync
hdiutil detach "$DEV" >/dev/null 2>&1 || hdiutil detach "$DEV" -force >/dev/null 2>&1 || true

# 5. Convert to a compressed, read-only image for distribution.
hdiutil convert "$RW" -format UDZO -imagekey zlib-level=9 -o "$DMG" >/dev/null

# 6. Clean up scratch.
rm -f "$RW"; rm -rf "$STAGE"

echo ""
echo "Built: $DMG"
/bin/ls -lh "$DMG" | /usr/bin/awk '{print "  size:", $5}'
echo ""
echo "Share this one file. The user: double-click the .dmg -> drag 'YouTube Music' onto"
echo "Applications -> first open (asked once): System Settings -> Privacy & Security ->"
echo "'Open Anyway'. (macOS 14 and earlier: right-click the app -> Open -> Open.)"
