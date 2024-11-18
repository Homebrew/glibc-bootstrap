#!/bin/bash

set -e
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

VERSION=2.43.1
SHA256SUM=13f74202a3c4c51118b797a39ea4200d3f6cfbe224da6d1d95bb938480132dfd

# Build binutils
wget --no-check-certificate https://ftp.gnu.org/gnu/binutils/binutils-$VERSION.tar.xz
verify_checksum binutils-$VERSION.tar.xz $SHA256SUM

tar --extract --file binutils-$VERSION.tar.xz
cd binutils-$VERSION
./configure --prefix="${PREFIX}" \
  --enable-deterministic-archives \
  --prefix="${PREFIX}" \
  --disable-werror \
  --enable-interwork \
  --enable-multilib \
  --enable-64-bit-bfd \
  --enable-targets=all \
  --disable-gprofng \
  --disable-nls

make
make install
cd ..
rm -rf binutils-$VERSION

package binutils $VERSION
