#!/usr/bin/env bash

if [ $# -eq 0 ]; then
    echo "Usage: $0 path_to_sourcery_souce_code"
    echo "No arguments provided"
    exit 1
fi

copyFiles() {
    local DEST="$2/Scripts/Sourcery"
    echo "Copying binary from $1 to $DEST"

    rm -rf "$DEST"
    mkdir "$DEST"

    cp -R "$1/bin/" "$DEST/bin/"
    cp -R "$1/Resources/" "$DEST/Resources/"
    cp -R "$1/Templates/" "$DEST/Templates/"
    cp "$1/README.md" "$DEST/README.md"
    cp "$1/CHANGELOG.md" "$DEST/CHANGELOG.md"
    cp "$1/LICENSE" "$DEST/LICENSE"
}

SOURCE="$1"
DESTINATION="$PWD"

echo "Building Sourcery"

(cd "$SOURCE" && rake build) && copyFiles $SOURCE $DESTINATION
