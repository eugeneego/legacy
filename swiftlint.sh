#!/usr/bin/env bash

if [ "${CONFIGURATION}" == "Debug" ]; then
    export PATH="$PATH:/opt/homebrew/bin"
    if which swiftlint >/dev/null; then
        swiftlint lint --quiet
    else
        echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
    fi
fi
