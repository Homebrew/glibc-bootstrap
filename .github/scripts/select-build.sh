#!/bin/bash

set -euo pipefail
build=true
if [[ ( "$EVENT" == pull_request || "$EVENT" == push ) && -n "${BASE_SHA:-}" && "$BASE_SHA" != 0000000000000000000000000000000000000000 ]] &&
   git cat-file -e "$BASE_SHA^{commit}" 2>/dev/null; then
  comparison=("$BASE_SHA" "$HEAD_SHA")
  if [[ "$EVENT" == pull_request ]]; then
    comparison=("$BASE_SHA...$HEAD_SHA")
  fi
  changes="$(git diff --name-only "${comparison[@]}" -- \
    '*.sh' 'Dockerfile*' '.github/scripts/**' 'tests/**' \
    '.github/workflows/build.yml' '.github/workflows/release.yml')"
  [[ -n "$changes" ]] || build=false
fi
echo "build=$build" >> "$GITHUB_OUTPUT"
