#/bin/bash

VERSION=3.9.13

# Build Python 3
curl -LO https://www.python.org/ftp/python/$VERSION/Python-$VERSION.tar.xz
tar xf Python-$VERSION.tar.xz && cd Python-$VERSION

./configure --prefix="${PREFIX}" ac_cv_search_crypt=no ac_cv_search_crypt_r=no
make && make install

cd .. && rm -rf Python-$VERSION

cd $PREFIX && tar --remove-files -czf $PKGDIR/bootstrap-python3-${VERSION}.tar.gz .
