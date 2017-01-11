#!/bin/bash

# takes the base dir as it's first arg and generates Swift files for accessing Storyboards

if which swiftgen >/dev/null; then
    swiftgen storyboards -t vdka "$1/FlowControllers/Base.lproj" --output "$1/Sources/Generated/Storyboards.swift"
else
    echo "warning: SwiftGen not installed, download it from https://github.com/AliSoftware/SwiftGen"
fi

