#!/bin/bash

set -e
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

VERSION=5.3.1
SHA256SUM=694db764812a6236423d4ff40ceb7b6c4c441301b72ad502bb5c27e00cd56f78

# Build gawk
wget --no-check-certificate https://ftp.gnu.org/gnu/gawk/gawk-$VERSION.tar.xz
verify_checksum gawk-$VERSION.tar.xz $SHA256SUM

tar --extract --file gawk-$VERSION.tar.xz
cd gawk-$VERSION
./configure --prefix="${PREFIX}" --disable-mpfr --without-libsigsegv
make
make install
cd ..
rm --recursive --force gawk-$VERSION

package gawk ${VERSION}
