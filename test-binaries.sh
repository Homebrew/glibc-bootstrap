#!/bin/bash

set -euo pipefail
export PATH=/tmp/homebrew/bin:/usr/bin:/bin
workdir="$(mktemp -d)"
trap 'rm -rf "$workdir"' EXIT
cd "$workdir"

case "$1" in
  binutils)
    printf '.text\n.globl bootstrap_symbol\nbootstrap_symbol:\n.byte 0\n' > test.s
    /tmp/homebrew/bin/as test.s -o test.o
    /tmp/homebrew/bin/ld -r test.o -o linked.o
    /tmp/homebrew/bin/nm linked.o | grep bootstrap_symbol
    ;;
  bison)
    [[ "$(printf 'eval(6 * 7)' | /tmp/homebrew/bin/m4)" == 42 ]]
    printf '%%%%\nstart: ;\n%%%%\n' > parser.y
    /tmp/homebrew/bin/bison -o parser.c parser.y
    test -s parser.c
    ;;
  gawk)
    [[ "$(/tmp/homebrew/bin/gawk 'BEGIN { print 6 * 7 }')" == 42 ]]
    ;;
  gcc)
    printf 'int bootstrap(void) { return 42; }\n' > test.c
    # The stage-zero compiler can generate assembly without system headers or binutils.
    /tmp/homebrew/bin/gcc -O2 -D_FORTIFY_SOURCE=3 -S test.c -o test.s
    /tmp/homebrew/bin/g++ -O2 -S -x c++ test.c -o test-cxx.s
    test -s test.s
    test -s test-cxx.s
    ;;
  make)
    printf 'all:\n\t@echo 42\n' > Makefile
    [[ "$(/tmp/homebrew/bin/make --no-print-directory)" == 42 ]]
    ;;
  python3)
    /tmp/homebrew/bin/python3 -B -c 'import argparse, ast, collections, decimal, json, re, subprocess, tempfile; assert json.loads("42") == 42'
    ;;
  sed)
    [[ "$(printf 'answer' | /tmp/homebrew/bin/sed 's/answer/42/')" == 42 ]]
    ;;
  *) echo "Unknown bootstrap package: $1" >&2; exit 1 ;;
esac
