# YouTube to macOS Screensaver

Turn almost any YouTube video into a native macOS `.saver` screensaver.

This project downloads a clip from YouTube, optimizes it for smooth playback, compiles a native ScreenSaver bundle, and packages it for installation.

## What it does

- Downloads a YouTube video clip with `yt-dlp`
- Transcodes to a screensaver-friendly `H.264` MP4 with `ffmpeg`
- Builds a native macOS `.saver` plugin with `clang`
- Installs the screensaver and optionally sets it as your default

## Requirements

- macOS 11+
- Xcode Command Line Tools (`xcrun`, `clang`, `codesign`)
- `yt-dlp`
- `ffmpeg`

Install tools with Homebrew:

```bash
brew install yt-dlp ffmpeg
xcode-select --install
```

## Quick start

Build with defaults:

```bash
./build-screensaver.sh
```

Then install:

```bash
./install-screensaver.sh
```

Default build values:

- Video URL: `https://www.youtube.com/watch?v=5uY3OMRulVo`
- Bundle name: `Fireplace.saver`
- Clip length: `300` seconds (5 minutes)

## Use any YouTube video

```bash
./build-screensaver.sh "<youtube-url>" "<bundle-name>.saver" <clip-seconds>
```

Example:

```bash
./build-screensaver.sh "https://www.youtube.com/watch?v=dQw4w9WgXcQ" "MyVideo.saver" 180
./install-screensaver.sh "dist/MyVideo.saver"
```

## Example done

This project has been tested with the default fireplace video:

```bash
./build-screensaver.sh "https://www.youtube.com/watch?v=5uY3OMRulVo" "Fireplace.saver" 300
./install-screensaver.sh "dist/Fireplace.saver"
```

Result:

- Built `dist/Fireplace.saver`
- Created `dist/Fireplace.saver.zip`
- Installed to `~/Library/Screen Savers/Fireplace.saver`

## Output

- Bundle: `dist/<bundle-name>.saver`
- Zip package: `dist/<bundle-name>.saver.zip`
- Downloaded source clip: `build/source-video.mp4`

## Playback behavior

- Video loops continuously
- Audio is muted
- Video scales with aspect fill to fill the screen

## Notes and caveats

- Most public YouTube videos work, but some may fail (private, DRM-protected, region-restricted, removed, or livestream-only content).
- If the preferred YouTube format is unavailable, the build script automatically falls back to `best`.
- Only use video content you have the rights to download and display.
