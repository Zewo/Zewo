#!/bin/bash

# Do nothing on Darwin-based systems
if [[ "$(uname)" == "Linux" ]]; then

  # Taken from https://gist.githubusercontent.com/kylef/5c0475ff02b7c7671d2a/raw/02090c7ede5a637b76e6df1710e83cd0bbe7dcdf/swiftenv-install.sh
  # Automatically installs swiftenv and run's swiftenv install.
  # This script was designed for usage in CI systems.

  git clone --depth 1 https://github.com/kylef/swiftenv.git ~/.swiftenv
  export SWIFTENV_ROOT="$HOME/.swiftenv"
  export PATH="$SWIFTENV_ROOT/bin:$SWIFTENV_ROOT/shims:$PATH"

  if [ -f ".swift-version" ] || [ -n "$SWIFT_VERSION" ]; then
    swiftenv install
  else
    swiftenv rehash
  fi
fi

