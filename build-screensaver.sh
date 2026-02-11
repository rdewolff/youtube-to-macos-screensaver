#!/usr/bin/env bash
set -euo pipefail

VIDEO_URL="${1:-https://www.youtube.com/watch?v=5uY3OMRulVo}"
BUNDLE_NAME="${2:-Fireplace.saver}"
CLIP_SECONDS="${3:-300}"
VIDEO_FORMAT_ID="${VIDEO_FORMAT_ID:-232}"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$ROOT_DIR/build"
DIST_DIR="$ROOT_DIR/dist"
BUNDLE_DIR="$DIST_DIR/$BUNDLE_NAME"
CONTENTS_DIR="$BUNDLE_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"
SOURCE_VIDEO="$BUILD_DIR/source-video.mp4"
PROCESSED_VIDEO="$RESOURCES_DIR/fireplace.mp4"

mkdir -p "$BUILD_DIR" "$DIST_DIR"
rm -rf "$BUNDLE_DIR"
rm -f "$SOURCE_VIDEO" "$PROCESSED_VIDEO"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"

echo "Downloading video from: $VIDEO_URL"
download_clip() {
  local format_id="$1"
  yt-dlp \
    --no-playlist \
    --downloader ffmpeg \
    --download-sections "*0-$CLIP_SECONDS" \
    -f "$format_id" \
    -o "$SOURCE_VIDEO" \
    "$VIDEO_URL"
}

if ! download_clip "$VIDEO_FORMAT_ID"; then
  echo "Preferred format $VIDEO_FORMAT_ID failed. Falling back to best available format."
  download_clip "best"
fi

echo "Optimizing video for screensaver playback"
ffmpeg -y \
  -i "$SOURCE_VIDEO" \
  -an \
  -c:v libx264 \
  -preset veryfast \
  -crf 22 \
  -pix_fmt yuv420p \
  -movflags +faststart \
  "$PROCESSED_VIDEO" >/dev/null 2>&1

cp "$ROOT_DIR/src/Info.plist" "$CONTENTS_DIR/Info.plist"

SDK_PATH="$(xcrun --show-sdk-path)"

echo "Compiling native screensaver bundle"
clang \
  -fobjc-arc \
  -isysroot "$SDK_PATH" \
  -mmacosx-version-min=11.0 \
  -framework Cocoa \
  -framework ScreenSaver \
  -framework AVFoundation \
  -framework QuartzCore \
  -framework CoreMedia \
  "$ROOT_DIR/src/FireplaceView.m" \
  -bundle \
  -o "$MACOS_DIR/Fireplace"

codesign --force --sign - "$BUNDLE_DIR" >/dev/null 2>&1 || true

ditto -c -k --keepParent "$BUNDLE_DIR" "$DIST_DIR/${BUNDLE_NAME}.zip"

echo
echo "Done."
echo "Screensaver bundle: $BUNDLE_DIR"
echo "Zip package: $DIST_DIR/${BUNDLE_NAME}.zip"
echo "Install by double-clicking: $BUNDLE_DIR"
