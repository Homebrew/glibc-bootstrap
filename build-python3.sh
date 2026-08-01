#!/bin/bash

set -e
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

VERSION=3.11.15
SHA256SUM=272179ddd9a2e41a0fc8e42e33dfbdca0b3711aa5abf372d3f2d51543d09b625

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
