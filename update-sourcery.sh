#!/usr/bin/env bash

if [ $# -eq 0 ]; then
    echo "Usage:"
    echo "  $0 /path/to/sourcery/souce/code"
    echo "  $0 github"
    echo "No arguments provided"
    exit 1
fi

copyFiles() {
    echo "Copying"
    local DEST="$2/Scripts/Sourcery"

    rm -rf "$DEST"
    mkdir "$DEST"
    mkdir "$DEST/Resources"

    cp -R "$1/bin" "$DEST/"
    cp -R "$1/Templates/Templates" "$DEST/"
    cp "$1/Resources/icon-128.png" "$DEST/Resources/"
    cp "$1/README.md" "$1/CHANGELOG.md" "$1/LICENSE" "$DEST/"
}

SOURCE="$1"
DESTINATION="$PWD"

if [ "$1" = "github" ]; then
    echo "Cloning"
    SOURCE="$PWD/.sourcery-build"
    rm -rf "$SOURCE"
    git clone --depth 1 "git@github.com:krzysztofzablocki/Sourcery.git" "$SOURCE"
fi

echo "Building"
(cd "$SOURCE" && rake build) && copyFiles "$SOURCE" "$DESTINATION"

if [ "$1" = "github" ]; then
    echo "Cleaning up"
    rm -rf "$SOURCE"
fi
