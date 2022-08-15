#/bin/bash

VERSION=4.8

# Build sed
curl -LO --insecure https://ftp.gnu.org/gnu/sed/sed-$VERSION.tar.xz
tar xf sed-$VERSION.tar.xz && cd sed-$VERSION
./configure --prefix="${PREFIX}" --without-selinux && make install
cd .. && rm -rf sed-$VERSION

cd $PREFIX && tar --remove-files -czf $PKGDIR/bootstrap-sed-$VERSION.tar.gz .
