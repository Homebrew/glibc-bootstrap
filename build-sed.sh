#!/bin/bash

set -e
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

VERSION=4.10
SHA256SUM=b8e72182b2ec96a3574e2998c47b7aaa64cc20ce000d8e9ac313cc07cecf28c7

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
