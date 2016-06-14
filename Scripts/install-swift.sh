#!/bin/bash

# Do nothing on Darwin-based systems
if [[ "$(uname)" == "Linux" ]]; then
    SWIFT_URL=https://swift.org/builds/swift-3.0-preview-1/ubuntu1404/swift-3.0-preview-1/swift-3.0-preview-1-ubuntu14.04.tar.gz
    BASE_DIR=$(pwd)

    # Install Swift
    cd ${HOME}
    wget $SWIFT_URL -O - | tar xz

    # Make sure Swift is not already installed
    if [ -d .swift ]; then
        rm -rf .swift
    fi

    # Move to .swift, set PATH
    mv $(basename "$SWIFT_URL" ".tar.gz") .swift
    export PATH="${HOME}/.swift/usr/bin:${PATH}"

    # Move back to where we started
    cd $BASE_DIR
fi

