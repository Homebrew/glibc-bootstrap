#!/bin/bash

set -e
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

VERSION=2.47
SHA256SUM=154ab23b60070e8f27013c22977f1129425d67d1e8acd6e13010e617811e4cff

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
  --disable-gprofng \
  --disable-nls

make
make install
cd ..
rm -rf binutils-$VERSION

package binutils $VERSION
