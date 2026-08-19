# Membar

Membar is a native macOS menu-bar memory indicator. The RAM-chip fill follows Activity Monitor's Memory Used value in ten discrete steps, and the icon changes color with macOS memory pressure.

## Install

### Download a release

The simplest installation is the versioned application archive from the repository's GitHub Releases page:

1. Download `Membar-<version>-arm64.zip` for Apple Silicon or `Membar-<version>-x86_64.zip` for an Intel Mac.
2. Open the archive and move `Membar.app` to `/Applications`.
3. Open `Membar.app`. It will appear in the menu bar and not in the Dock.

Release archives require macOS 13 or newer. The accompanying `.sha256` file can be used to verify an archive with `shasum -a 256`.

### First launch

Default releases are unsigned. After moving `Membar.app` to `/Applications`:

1. Control-click `Membar.app` in Finder and choose **Open**, then confirm.
2. If macOS blocks it, open **System Settings > Privacy & Security** and choose **Open Anyway**.
3. If macOS says the app is damaged and neither option is available, verify the archive came from a trusted source and run:

```sh
xattr -dr com.apple.quarantine /Applications/Membar.app
open /Applications/Membar.app
```

### Build from source

Source builds require the Swift command-line tools:

```sh
swift --version
sh Scripts/package-app.sh
open dist/Membar.app
```

The packaging script automatically builds for the current Mac architecture. Set `ARCH=arm64` or `ARCH=x86_64` to select an architecture explicitly.

To install that build for normal use:

```sh
ditto dist/Membar.app /Applications/Membar.app
open /Applications/Membar.app
```

To remove it:

```sh
rm -rf /Applications/Membar.app
```

## Requirements

- Apple Silicon or Intel Mac
- macOS 13 or newer

## Releases

Download the latest version from the repository's [GitHub Releases page](https://github.com/davegarvey/membar/releases). Releases include native archives for Apple Silicon and Intel Macs, plus a SHA-256 checksum.

Membar runs as a menu-bar-only app and does not require permissions, network access, or third-party runtime dependencies.

Membar is released under the MIT License.
