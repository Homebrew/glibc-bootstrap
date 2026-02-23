#!/bin/bash

set -e
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

VERSION=10.5.0
SHA256SUM=25109543fdf46f397c347b5d8b7a2c7e5694a5a51cce4b9c6e1ea8a71ca307c1

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
  --enable-multiarch \
  --enable-standard-branch-protection \
  --with-newlib \
  --without-headers
make
make install

cd ../..
rm --recursive --force gcc-$VERSION

package gcc $VERSION
