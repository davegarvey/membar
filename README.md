# Membar

Membar is a native macOS menu-bar memory indicator. The RAM-chip fill follows Activity Monitor's Memory Used metric (App Memory + Wired + Compressed, excluding Cached Files) in ten discrete steps; the icon colour comes from macOS memory-pressure events.

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
- Swift command-line tools

## Development

```sh
swift build
swift run Membar
```

The executable and app bundle both use AppKit's accessory activation policy and `LSUIElement`, so Membar does not create a Dock icon or window. No permissions, network access, or third-party runtime dependencies are required.

## Releases

Releases use [Grubble](https://github.com/davegarvey/grubble) and conventional commits. A push to `main` opens a release PR when a version bump is needed. After that PR is merged, the version workflow creates the `vX.Y.Z` tag and the release workflow builds and publishes native arm64 and x86_64 `.app` archives. The workflow also publishes a SHA-256 checksum alongside each archive.

Release builds are unsigned by default, so users must approve Membar through Gatekeeper once. The workflow supports an optional signed and notarized mode for maintainers with an Apple Developer membership. Local builds remain unsigned unless `SIGNING_IDENTITY` and `NOTARY_PROFILE` are provided to `Scripts/package-app.sh`.

### Release signing setup

To enable signed releases, set the repository Actions variable `RELEASE_SIGNING_ENABLED` to `true` and add these GitHub Actions secrets:

| Secret | Value |
| --- | --- |
| `APPLE_CERTIFICATE_BASE64` | Base64-encoded Developer ID Application `.p12` export |
| `APPLE_CERTIFICATE_PASSWORD` | Password used for the `.p12` export |
| `APPLE_SIGNING_IDENTITY` | Exact identity from `security find-identity -v -p codesigning` |
| `APPLE_ID` | Apple Developer account email |
| `APPLE_APP_SPECIFIC_PASSWORD` | App-specific password for notarization |
| `APPLE_TEAM_ID` | Apple Developer Team ID |

Create the certificate in the Apple Developer portal, export it with its private key from Keychain Access as a password-protected `.p12`, and encode it on macOS with:

```sh
base64 -i DeveloperID.p12 | pbcopy
```

Paste the result into `APPLE_CERTIFICATE_BASE64`. Create the app-specific password at [appleid.apple.com](https://appleid.apple.com/), and add all six values under the repository's **Settings > Secrets and variables > Actions**. Add `RELEASE_SIGNING_ENABLED` with value `true` under the **Variables** tab. The existing `RELEASE_PAT` secret is still required to publish release assets.

If `RELEASE_SIGNING_ENABLED` is absent or not `true`, the workflow publishes unsigned archives normally and users follow the Gatekeeper instructions in the Install section.

After the secrets are configured, the existing `v0.0.1` release can be rebuilt by manually dispatching the Release workflow with version `v0.0.1`; its assets will be replaced with signed and notarized archives.

The version workflow requires a repository secret named `RELEASE_PAT`. It is used only to create the release tag so that GitHub triggers the tag-based build workflow. The PAT should be fine-grained and limited to this repository.

If a release build needs to be retried, dispatch the Release workflow manually with the existing tag; it uploads fresh assets to the existing release.

A future Homebrew Cask can consume these release assets once the repository has a stable public GitHub URL.

Membar is released under the MIT License. Contributions should preserve the no-telemetry, no-network, menu-bar-only design.
