#!/bin/sh

set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT_DIR"

VERSION=${VERSION:-0.1.0}
ARCH=${ARCH:-$(uname -m)}
SIGNING_IDENTITY=${SIGNING_IDENTITY:-}
NOTARY_PROFILE=${NOTARY_PROFILE:-}

case "$ARCH" in
    arm64|x86_64)
        ;;
    *)
        printf '%s\n' "Unsupported architecture: $ARCH" >&2
        exit 1
        ;;
esac

if [ -n "$NOTARY_PROFILE" ] && [ -z "$SIGNING_IDENTITY" ]; then
    printf '%s\n' "NOTARY_PROFILE requires SIGNING_IDENTITY" >&2
    exit 1
fi

DIST_DIR="$ROOT_DIR/dist"
APP_DIR="$DIST_DIR/Membar.app"
APP_CONTENTS="$APP_DIR/Contents"

rm -rf "$DIST_DIR"
mkdir -p "$APP_CONTENTS/MacOS" "$APP_CONTENTS/Resources"

swift build -c release --arch "$ARCH"
BIN_PATH=$(swift build -c release --arch "$ARCH" --show-bin-path)/Membar
cp "$BIN_PATH" "$APP_CONTENTS/MacOS/Membar"
cp "$ROOT_DIR/Resources/Info.plist" "$APP_CONTENTS/Info.plist"

/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $VERSION" "$APP_CONTENTS/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $VERSION" "$APP_CONTENTS/Info.plist"

chmod 755 "$APP_CONTENTS/MacOS/Membar"

ARCHIVE="$DIST_DIR/Membar-$VERSION-$ARCH.zip"

if [ -n "$SIGNING_IDENTITY" ]; then
    printf '%s\n' "Signing with $SIGNING_IDENTITY"
    codesign --force --options runtime --timestamp \
        --sign "$SIGNING_IDENTITY" "$APP_CONTENTS/MacOS/Membar"
    codesign --force --options runtime --timestamp \
        --sign "$SIGNING_IDENTITY" "$APP_DIR"
    codesign --verify --deep --strict --verbose=2 "$APP_DIR"
else
    printf '%s\n' "Building unsigned app"
fi

create_archive() {
    rm -f "$ARCHIVE"
    ditto -c -k --sequesterRsrc --keepParent "$APP_DIR" "$ARCHIVE"
}

create_archive

if [ -n "$NOTARY_PROFILE" ]; then
    printf '%s\n' "Submitting archive for notarization"
    xcrun notarytool submit "$ARCHIVE" \
        --keychain-profile "$NOTARY_PROFILE" \
        --wait
    xcrun stapler staple "$APP_DIR"
    xcrun stapler validate "$APP_DIR"
    create_archive
fi

shasum -a 256 "$ARCHIVE" > "$ARCHIVE.sha256"

printf '%s\n' "Created $APP_DIR"
printf '%s\n' "Created $ARCHIVE"
