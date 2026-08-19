# Membar

Membar is a native macOS menu-bar memory indicator. The RAM-chip fill follows Activity Monitor's Memory Used metric (App Memory + Wired + Compressed, excluding Cached Files) in ten discrete steps; the icon colour comes from macOS memory-pressure events.

## Install

### Download a release

The simplest installation is the versioned application archive from the repository's GitHub Releases page:

1. Download `Membar-<version>-arm64.zip` for Apple Silicon or `Membar-<version>-x86_64.zip` for an Intel Mac.
2. Open the archive and move `Membar.app` to `/Applications`.
3. Open `Membar.app`. It will appear in the menu bar and not in the Dock.

Release archives require macOS 13 or newer. The accompanying `.sha256` file can be used to verify an archive with `shasum -a 256`.

The first launch of an unsigned, source-built archive may be blocked by Gatekeeper. Control-click the app, choose **Open**, and confirm, or use **System Settings > Privacy & Security > Open Anyway**. Maintainers can sign and notarize release archives before publishing them for a no-warning install experience.

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
- Swift command-line tools

## Development

```sh
swift build
swift run Membar
```

The executable and app bundle both use AppKit's accessory activation policy and `LSUIElement`, so Membar does not create a Dock icon or window. No permissions, network access, or third-party runtime dependencies are required.

## Releases

Releases use [Grubble](https://github.com/davegarvey/grubble) and conventional commits. A push to `main` opens a release PR when a version bump is needed. After that PR is merged, the version workflow creates the `vX.Y.Z` tag and the release workflow builds and publishes native arm64 and x86_64 `.app` archives. The workflow also publishes a SHA-256 checksum alongside each archive.

The version workflow requires a repository secret named `RELEASE_PAT`. It is used only to create the release tag so that GitHub triggers the tag-based build workflow. The PAT should be fine-grained and limited to this repository.

If a release build needs to be retried, dispatch the Release workflow manually with the existing tag; it uploads fresh assets to the existing release.

A future Homebrew Cask can consume these release assets once the repository has a stable public GitHub URL.

Membar is released under the MIT License. Contributions should preserve the no-telemetry, no-network, menu-bar-only design.
