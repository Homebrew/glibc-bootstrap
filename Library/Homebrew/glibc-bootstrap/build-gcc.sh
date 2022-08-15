#/bin/bash

VERSION=9.5.0

# Build GCC
curl -LO --insecure https://ftp.gnu.org/gnu/gcc/gcc-$VERSION/gcc-$VERSION.tar.xz
tar xf gcc-$VERSION.tar.xz && cd gcc-$VERSION

# Download GCC support libraries
./contrib/download_prerequisites

# Disable building documentation
gcc_cv_prog_makeinfo_modern=no

mkdir build && cd build

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
make && make install

cd ../.. && rm -rf gcc-$VERSION

cd $PREFIX && tar --remove-files -czf $PKGDIR/bootstrap-gcc-$VERSION.tar.gz .
