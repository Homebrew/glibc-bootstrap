#!/bin/bash

set -e
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

VERSION=3.9.13
SHA256SUM=125b0c598f1e15d2aa65406e83f792df7d171cdf38c16803b149994316a3080f

# Build Python 3
wget --no-check-certificate https://www.python.org/ftp/python/$VERSION/Python-$VERSION.tar.xz
verify_checksum Python-$VERSION.tar.xz $SHA256SUM

tar --extract --file Python-$VERSION.tar.xz
cd Python-$VERSION

./configure --prefix="${PREFIX}" ac_cv_search_crypt=no ac_cv_search_crypt_r=no
make
make install

cd ..
rm --recursive --force Python-$VERSION

package python3 ${VERSION}
