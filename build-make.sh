#!/bin/bash

set -e
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

VERSION=4.3
SHA256SUM=e05fdde47c5f7ca45cb697e973894ff4f5d79e13b750ed57d7b66d8defc78e19

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
