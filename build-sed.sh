#!/bin/bash

set -e
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

VERSION=4.9
SHA256SUM=6e226b732e1cd739464ad6862bd1a1aba42d7982922da7a53519631d24975181

# Build sed
wget --no-check-certificate https://ftp.gnu.org/gnu/sed/sed-$VERSION.tar.xz
verify_checksum sed-$VERSION.tar.xz $SHA256SUM

tar --extract --file sed-$VERSION.tar.xz
cd sed-$VERSION
./configure --prefix="${PREFIX}" --without-selinux
make install
cd ..
rm --recursive --force sed-$VERSION

package sed $VERSION
