#!/bin/bash

SWIFT_URL=https://swift.org/builds/development/ubuntu1510/swift-DEVELOPMENT-SNAPSHOT-2016-02-08-a/swift-DEVELOPMENT-SNAPSHOT-2016-02-08-a-ubuntu15.10.tar.gz
ZEWO_VERSION=0.2.3

# Install apt packages
grep -q -F "deb [trusted=yes] http://apt.zewo.io/deb ./" /etc/apt/sources.list || echo "deb [trusted=yes] http://apt.zewo.io/deb ./" | sudo tee --append /etc/apt/sources.list
sudo apt-get update
sudo apt-get -y install clang libicu-dev zewo="${ZEWO_VERSION}"

# Install Swift
cd ${HOME}
wget $SWIFT_URL -O - | tar xz

if [ -d .swift ]; then
    rm -rf .swift
fi

mv $(basename "$SWIFT_URL" ".tar.gz") .swift
export PATH="${HOME}/.swift/usr/bin:${PATH}"

echo "Zewo ${ZEWO_VERSION} successfully installed!"
echo 'You may wish to add "${HOME}/.swift/usr/bin" to your PATH in your profile'
