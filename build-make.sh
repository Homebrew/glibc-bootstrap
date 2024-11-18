#!/bin/bash

set -e
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

VERSION=4.4.1
SHA256SUM=dd16fb1d67bfab79a72f5e8390735c49e3e8e70b4945a15ab1f81ddb78658fb3

# Build make
wget --no-check-certificate https://ftp.gnu.org/gnu/make/make-${VERSION}.tar.gz
verify_checksum make-${VERSION}.tar.gz $SHA256SUM

tar --extract --gunzip --file make-${VERSION}.tar.gz
cd make-${VERSION}
./configure --prefix="${PREFIX}"
make install
cd ..
rm --recursive --force make-${VERSION}

package make ${VERSION}
