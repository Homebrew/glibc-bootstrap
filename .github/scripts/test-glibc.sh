#!/bin/bash

set -euo pipefail
# shellcheck source=utils.sh
source "$(dirname "${BASH_SOURCE[0]}")/../../utils.sh"
PREFIX=/tmp/homebrew
PKGDIR="$(cd "$1" && pwd -P)"
prepare_build
workdir="$(mktemp -d)"
trap 'rm -rf "$workdir" "$PREFIX"' EXIT

for archive in "$PKGDIR"/*.tar.gz; do
  tar --extract --file "$archive" --directory "$PREFIX"
done

# Keep the integration fixture aligned with homebrew-core's glibc formula.
version=2.39
cd "$workdir"
curl --fail --location --output glibc.tar.gz "https://ftp.gnu.org/gnu/glibc/glibc-$version.tar.gz"
verify_checksum glibc.tar.gz 97f84f3b7588cd54093a6f6389b0c1a81e70d99708d74963a2e3eab7c7dc942d
tar --extract --file glibc.tar.gz

# Supply kernel headers without exposing the host's C library headers.
mkdir headers build
cp -R /usr/include/linux /usr/include/asm-generic headers/
cp -R "/usr/include/$(cc -dumpmachine)/asm" headers/asm
export PATH="$PREFIX/bin:$PATH"
export CC="$PREFIX/bin/gcc" CXX="$PREFIX/bin/g++" MAKE="$PREFIX/bin/make"
unset LDFLAGS LD_LIBRARY_PATH LD_RUN_PATH LIBRARY_PATH

args=(
  "--prefix=$workdir/install"
  "--with-headers=$workdir/headers"
  "--with-binutils=$PREFIX/bin"
  --disable-crypt --without-gd --without-selinux
  --enable-bind-now --enable-fortify-source --enable-stack-protector=strong
)
cflags='-O2 -fstack-clash-protection'
case "$(uname -m)" in
  x86_64) args+=(--enable-cet=permissive); loader=ld-linux-x86-64.so.2 ;;
  aarch64) cflags+=' -mbranch-protection=standard'; loader=ld-linux-aarch64.so.1 ;;
  *) exit 1 ;;
esac
cd build
"../glibc-$version/configure" "${args[@]}" "CFLAGS=$cflags"
"$MAKE" -j"$BUILD_JOBS"
"$MAKE" install
installed_version="$("$workdir/install/lib/$loader" --library-path "$workdir/install/lib" \
  "$workdir/install/bin/getconf" GNU_LIBC_VERSION)"
[[ "$installed_version" == "glibc $version" ]]
echo "$installed_version"
