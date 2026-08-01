#!/bin/bash

set -e
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

M4_VERSION=1.4.21
M4_SHA256SUM=f25c6ab51548a73a75558742fb031e0625d6485fe5f9155949d6486a2408ab66
BISON_VERSION=3.8.2
BISON_SHA256SUM=9bba0214ccf7f1079c5d59210045227bcf619519840ebfa80cd3849cff5a5bf2

# Build m4
wget --no-check-certificate https://ftp.gnu.org/gnu/m4/m4-$M4_VERSION.tar.xz
verify_checksum m4-$M4_VERSION.tar.xz $M4_SHA256SUM

tar --extract --file m4-$M4_VERSION.tar.xz
cd m4-$M4_VERSION
./configure --prefix="${PREFIX}"
make
make install
cd ..
rm --recursive --force m4-$M4_VERSION

# Build bison
wget --no-check-certificate https://ftp.gnu.org/gnu/bison/bison-$BISON_VERSION.tar.xz
verify_checksum bison-$BISON_VERSION.tar.xz $BISON_SHA256SUM

tar --extract --file bison-$BISON_VERSION.tar.xz
cd bison-$BISON_VERSION
./configure --prefix="${PREFIX}" M4="${PREFIX}/bin/m4"
make install
cd ..
rm --recursive --force bison-$BISON_VERSION

package bison $BISON_VERSION
