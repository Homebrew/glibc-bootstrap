#!/bin/bash

set -e
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

VERSION=4.8
SHA256SUM=f79b0cfea71b37a8eeec8490db6c5f7ae7719c35587f21edb0617f370eeff633

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
