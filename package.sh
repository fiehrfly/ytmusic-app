#!/bin/bash
# Produces a distributable zip of "YouTube Music.app" for installing on this Mac or
# sending to another. Builds fresh first so the package always matches source.
set -euo pipefail
SRC="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
APP="$SRC/YouTube Music.app"
DIST="$SRC/dist"
ZIP="$DIST/YouTube-Music-macOS.zip"

bash "$SRC/build.sh"

mkdir -p "$DIST"
rm -f "$ZIP"
# ditto is the macOS-correct way to archive an .app: it preserves resource forks,
# symlinks, and the ad-hoc code signature (plain `zip` can corrupt bundles).
/usr/bin/ditto -c -k --sequesterRsrc --keepParent "$APP" "$ZIP"

echo ""
echo "Packaged: $ZIP"
/bin/ls -lh "$ZIP" | /usr/bin/awk '{print "  size:", $5}'
echo ""
echo "Install on this Mac : unzip, drag 'YouTube Music.app' into /Applications, double-click."
echo "Send to another Mac : share the .zip. First open there: right-click the app -> Open -> Open"
echo "                      (ad-hoc signed, so Gatekeeper asks once). Google Chrome recommended."
