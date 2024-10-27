#!/bin/bash

set -e
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

VERSION=3.11.10
SHA256SUM=07a4356e912900e61a15cb0949a06c4a05012e213ecd6b4e84d0f67aabbee372

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
