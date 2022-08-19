#!/bin/bash

set -e
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

VERSION=9.5.0
SHA256SUM=27769f64ef1d4cd5e2be8682c0c93f9887983e6cfd1a927ce5a0a2915a95cf8f

# Build GCC
wget --no-check-certificate https://ftp.gnu.org/gnu/gcc/gcc-$VERSION/gcc-$VERSION.tar.xz
verify_checksum gcc-$VERSION.tar.xz $SHA256SUM

tar --extract --file gcc-$VERSION.tar.xz
cd gcc-$VERSION

# Download GCC support libraries
./contrib/download_prerequisites

# Disable building documentation
gcc_cv_prog_makeinfo_modern=no

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
  --with-newlib \
  --without-headers
make
make install

cd ../..
rm --recursive --force gcc-$VERSION

package gcc $VERSION
