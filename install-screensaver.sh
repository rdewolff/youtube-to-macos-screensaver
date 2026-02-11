#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_BUNDLE="${1:-$ROOT_DIR/dist/Fireplace.saver}"
TARGET_DIR="$HOME/Library/Screen Savers"
TARGET_BUNDLE="$TARGET_DIR/$(basename "$SOURCE_BUNDLE")"
MODULE_NAME="$(basename "$TARGET_BUNDLE" .saver)"

if [[ ! -d "$SOURCE_BUNDLE" ]]; then
  echo "Screensaver bundle not found: $SOURCE_BUNDLE" >&2
  echo "Build it first with: ./build-screensaver.sh" >&2
  exit 1
fi

mkdir -p "$TARGET_DIR"
rm -rf "$TARGET_BUNDLE"
cp -R "$SOURCE_BUNDLE" "$TARGET_BUNDLE"
open "$TARGET_BUNDLE"

if command -v /usr/libexec/PlistBuddy >/dev/null 2>&1; then
  PLIST_NAME="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleName' "$TARGET_BUNDLE/Contents/Info.plist" 2>/dev/null || true)"
  if [[ -n "$PLIST_NAME" ]]; then
    MODULE_NAME="$PLIST_NAME"
  fi
fi

if defaults -currentHost write com.apple.screensaver moduleDict \
  -dict moduleName "$MODULE_NAME" path "$TARGET_BUNDLE" type -int 0; then
  # Refresh preference caches so the module selection is immediately visible.
  killall cfprefsd >/dev/null 2>&1 || true
  SET_DEFAULT_STATUS="(set as default)"
else
  SET_DEFAULT_STATUS="(could not set as default automatically)"
fi

echo "Installed: $TARGET_BUNDLE"
echo "Screen saver module: $MODULE_NAME $SET_DEFAULT_STATUS"
echo "Open System Settings > Screen Saver to verify or change it."
