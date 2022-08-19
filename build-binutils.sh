#!/bin/bash

set -e
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

VERSION=2.38
SHA256SUM=e316477a914f567eccc34d5d29785b8b0f5a10208d36bbacedcc39048ecfe024

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
  --disable-nls

make
make install
cd ..
rm -rf binutils-$VERSION

package binutils $VERSION
