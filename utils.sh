#!/bin/bash

set -e

verify_checksum() {
  FILE="$1"
  EXPECTED_CHECKSUM="$2"
  FILE_CHECKSUM="$(sha256sum "${FILE}" | cut -d ' ' -f 1)"

  if [[ "$FILE_CHECKSUM" != "$EXPECTED_CHECKSUM" ]]; then
    echo "Checksum mismatch!"
    return 1
  fi
}

package() {
  PKGNAME="$1"
  VERSION="$2"
  ARCH="$(uname -m)"

  tar --directory "$PREFIX" \
    --create --gzip --verbose \
    --file "$PKGDIR/bootstrap-$ARCH-$PKGNAME-$VERSION.tar.gz" .
  find "$PREFIX" -mindepth 1 -delete
}
