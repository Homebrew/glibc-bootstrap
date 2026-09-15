#!/bin/bash

set -euo pipefail
case "${1:-}" in
  ''|--validate-only) ;;
  *) echo "Usage: $0 [--validate-only]" >&2; exit 2 ;;
esac
: "${TAG:?}" "${GITHUB_SHA:?}" "${GITHUB_REPOSITORY:?}"
git check-ref-format "refs/tags/$TAG"
[[ "$(git rev-parse HEAD)" == "$GITHUB_SHA" ]]
shopt -s nullglob
archives=(bootstrap-binaries/*.tar.gz)
if [[ "${#archives[@]}" == 0 ]]; then
  echo "No bootstrap archives to release." >&2
  exit 1
fi

if refs="$(git ls-remote --exit-code --tags origin "refs/tags/$TAG" "refs/tags/$TAG^{}")"; then
  # Annotated tags advertise the commit separately from the tag object.
  tag_sha="$(awk '/\^\{\}$/ { print $1; found=1 } END { if (!found) print first } NR == 1 { first=$1 }' <<< "$refs")"
  if [[ "$tag_sha" != "$GITHUB_SHA" ]]; then
    echo "Tag $TAG does not identify the commit that produced these binaries." >&2
    exit 1
  fi
else
  status=$?
  [[ "$status" == 2 ]] || exit "$status"
fi

if [[ "${1:-}" == --validate-only ]]; then
  exit 0
fi

gh release create --repo "$GITHUB_REPOSITORY" --target "$GITHUB_SHA" \
  --generate-notes -- "$TAG" "${archives[@]}"
