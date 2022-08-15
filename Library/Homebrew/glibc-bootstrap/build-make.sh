#/bin/bash

VERSION=4.3

# Build make
curl -LO --insecure https://ftp.gnu.org/gnu/make/make-${VERSION}.tar.gz
tar xzf make-${VERSION}.tar.gz && cd make-${VERSION}
./configure --prefix="${PREFIX}" && make install
cd .. && rm -rf make-${VERSION}

cd ${PREFIX} && tar --remove-files -czf ${PKGDIR}/bootstrap-make-${VERSION}.tar.gz .
