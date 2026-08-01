#!/bin/bash

set -e
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

VERSION=5.4.1
SHA256SUM=07f6f7342b7febe4313fc2c2542ad93d64fe20ad8717200109f105a826f5fd37

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
