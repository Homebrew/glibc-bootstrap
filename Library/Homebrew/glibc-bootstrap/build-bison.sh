#/bin/bash

M4_VERSION=1.4.19
BISON_VERSION=3.8.2

# Build m4
curl -LO --insecure https://ftp.gnu.org/gnu/m4/m4-$M4_VERSION.tar.xz
tar xf m4-$M4_VERSION.tar.xz && cd m4-$M4_VERSION
./configure --prefix="${PREFIX}" && make && make install
cd .. && rm -rf m4-$M4_VERSION

# Build bison
curl -LO --insecure https://ftp.gnu.org/gnu/bison/bison-$BISON_VERSION.tar.xz
tar xf bison-$BISON_VERSION.tar.xz && cd bison-$BISON_VERSION
./configure --prefix="${PREFIX}" M4="${PREFIX}/bin/m4" && make install
cd .. && rm -rf bison-$BISON_VERSION

cd $PREFIX && tar --remove-files -czf $PKGDIR/bootstrap-bison-$BISON_VERSION.tar.gz .
