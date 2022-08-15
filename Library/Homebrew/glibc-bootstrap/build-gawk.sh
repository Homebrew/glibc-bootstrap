#/bin/bash

VERSION=5.1.1

# Build gawk
curl -LO --insecure https://ftp.gnu.org/gnu/gawk/gawk-$VERSION.tar.xz
tar xf gawk-$VERSION.tar.xz && cd gawk-$VERSION
./configure --prefix="${PREFIX}" --disable-mpfr --without-libsigsegv && make && make install
cd .. && rm -rf gawk-$VERSION

cd $PREFIX && tar --remove-files -czf $PKGDIR/bootstrap-gawk-$VERSION.tar.gz .
