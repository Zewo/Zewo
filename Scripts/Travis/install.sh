#!/usr/bin/env bash

set -e
set -o pipefail

if [[ "$TRAVIS_OS_NAME" == "linux" ]]; then
    git clone --depth 1 https://github.com/kylef/swiftenv.git ~/.swiftenv
    export SWIFTENV_ROOT="$HOME/.swiftenv"
    export PATH="$SWIFTENV_ROOT/bin:$SWIFTENV_ROOT/shims:$PATH"

    if [ -f ".swift-version" ] || [ -n "$SWIFT_VERSION" ]; then
      swiftenv install
    else
      swiftenv rehash
    fi
fi

if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
    rvm get head
    rvm install 2.2.3
    gem install xcpretty
fi
