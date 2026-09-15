#!/bin/bash

set -euo pipefail

prepare_build() {
  : "${PREFIX:?PREFIX must be set}" "${PKGDIR:?PKGDIR must be set}"
  if [[ "$PREFIX" != /* || "$PKGDIR" != /* || -L "$PREFIX" || -L "$PKGDIR" ]]; then
    echo "Build directories must be absolute paths, not symlinks." >&2
    return 1
  fi

  mkdir -p "$PREFIX" "$PKGDIR"
  PREFIX="$(cd "$PREFIX" && pwd -P)"
  PKGDIR="$(cd "$PKGDIR" && pwd -P)"
  if [[ "$PREFIX" == / || "$PKGDIR" == / || "$PKGDIR" == "$PREFIX" || "$PKGDIR" == "$PREFIX/"* ]]; then
    echo "Use a dedicated build prefix and a separate package directory." >&2
    return 1
  fi
  if [[ -n "$(find "$PREFIX" -mindepth 1 -maxdepth 1 -print -quit)" ]]; then
    echo "Build prefix is not empty: $PREFIX" >&2
    return 1
  fi

  BUILD_JOBS="${BUILD_JOBS:-$(getconf _NPROCESSORS_ONLN)}"
  if [[ ! "$BUILD_JOBS" =~ ^[1-9][0-9]*$ ]]; then
    echo "BUILD_JOBS must be a positive integer." >&2
    return 1
  fi
  readonly PREFIX PKGDIR BUILD_JOBS
  BUILD_PREPARED=1
}

verify_checksum() {
  local file="$1" expected_checksum="$2" file_checksum
  file_checksum="$(sha256sum "$file" | cut -d ' ' -f 1)"

  if [[ "$file_checksum" != "$expected_checksum" ]]; then
    echo "Checksum mismatch: $file" >&2
    return 1
  fi
}

package() {
  local pkgname="$1" version="$2" arch
  if [[ "${BUILD_PREPARED:-0}" != 1 || ! -d "$PREFIX" || -L "$PREFIX" ]]; then
    echo "Prepare the build prefix before packaging." >&2
    return 1
  fi
  arch="$(uname -m)"

  tar --directory "$PREFIX" \
    --create --gzip --verbose \
    --file "$PKGDIR/bootstrap-$arch-$pkgname-$version.tar.gz" .
  find "$PREFIX" -mindepth 1 -delete
}
