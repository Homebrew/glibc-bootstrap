# glibc-bootstrap

Bootstrap binaries for compiling `glibc` from source.

## Requirements

Linux with `glibc` 2.13 or newer.

x86-64 CPU architecture with support for `-march=core2` (defined [here](https://gcc.gnu.org/onlinedocs/gcc/x86-Options.html))

## Installation

The bootstrap binaries are downloaded automatically when building the `glibc` formula from source.  This will happen if the user is in a non-default prefix and has a host `glibc` that is older than the one in our CI image we use to build bottles on Linux.

## Motivation

The `glibc` bottle is not relocatable and must be built from source if the user is in a non-default prefix.  While `glibc` has no runtime dependencies, it does have build dependencies which may be too new or unavailable to users without root access.  Rather than requiring the user to build these dependencies from source, we build them with GitHub Actions in this repository using a Linux image with an older version of `glibc` and a prefix of `/tmp/homebrew`.  Assuming the user has write access to `/tmp`, this approach guarantees that all users on actively maintained versions of `glibc` (2.17 or newer) can install and run these binaries. The build dependency binaries are installed as resources to `/tmp/homebrew` and used to build `glibc` instead of the host toolchain.

## Copyright
Copyright (c) Homebrew maintainers.
