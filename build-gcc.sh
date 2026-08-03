#!/bin/bash

set -e
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

# GCC 12 provides support for -D_FORTIFY_SOURCE=3
VERSION=12.5.0
SHA256SUM=71cd373d0f04615e66c5b5b14d49c1a4c1a08efa7b30625cd240b11bab4062b3

# Build GCC
wget --no-check-certificate https://ftp.gnu.org/gnu/gcc/gcc-$VERSION/gcc-$VERSION.tar.xz
verify_checksum gcc-$VERSION.tar.xz $SHA256SUM

tar --extract --file gcc-$VERSION.tar.xz
cd gcc-$VERSION

# Download GCC support libraries
./contrib/download_prerequisites

# Disable building documentation
export gcc_cv_prog_makeinfo_modern=no

mkdir build
cd build

# Disable everything that isn't needed to build glibc.
../configure \
  --prefix="${PREFIX}" \
  --enable-languages="c,c++" \
  --disable-werror \
  --disable-nls \
  --disable-bootstrap \
  --disable-decimal-float \
  --disable-libatomic \
  --disable-libgomp \
  --disable-libquadmath \
  --disable-libsanitizer \
  --disable-libssp \
  --disable-libvtv \
  --disable-threads \
  --disable-multilib \
  --enable-cet=auto \
  --enable-multiarch \
  --enable-standard-branch-protection \
  --with-newlib \
  --without-headers
make
make install-strip

cd ../..
rm --recursive --force gcc-$VERSION

package gcc $VERSION
