# glibc-bootstrap

Bootstrap binaries for compiling `glibc` from source.

## Requirements

To run the binaries built by this workflow:

For x86-64 Linux: `glibc` 2.13 or newer, and x86-64 CPU architecture with support for `-march=core2` (defined [here](https://gcc.gnu.org/onlinedocs/gcc/x86-Options.html)).

For ARM64 (AArch64) Linux: `glibc` 2.17 or newer.

To build the binaries:

A host machine capable of building and running Linux x86-64 or ARM64 Docker images.

## Installation

The bootstrap binaries are downloaded automatically when building the `glibc` formula from source.  This will happen if the user is in a non-default prefix and has a host `glibc` that is older than the one in our CI image we use to build bottles on Linux.

## Building binaries outside of GitHub Actions

GitHub Actions is used to build the binaries in CI.  To build them locally:
```
# Clone the repository
git clone https://github.com/Homebrew/glibc-bootstrap
cd glibc-bootstrap

# Build the Docker image.
# For ARM64, use Dockerfile.arm64 instead.
docker build --tag glibc-bootstrap --file Dockerfile.x86_64 .

# Start the Docker image and leave it running the background so the binaries
# can easily be copied out after they are built.
docker run --rm --detach --user linuxbrew --name glibc-bootstrap \
  --workdir /home/linuxbrew --volume $(pwd):/home/linuxbrew/glibc-bootstrap glibc-bootstrap sleep inf

# Call a build-*.sh script to build a specific binary.  We use build-make.sh as an example.
docker exec glibc-bootstrap /bin/bash -c "/home/linuxbrew/glibc-bootstrap/build-make.sh"

# Copy the binaries out of the container after they have been compiled.
docker cp glibc-bootstrap:/home/linuxbrew/bootstrap-binaries .
```

## Motivation

The `glibc` bottle is not relocatable and must be built from source if the user is in a non-default prefix.  While `glibc` has no runtime dependencies, it does have build dependencies which may be too new or unavailable to users without root access.  Rather than requiring the user to build these dependencies from source, we build them with GitHub Actions in this repository using a Linux image with an older version of `glibc` and a prefix of `/tmp/homebrew`.  Assuming the user has write access to `/tmp`, this approach guarantees that all users on actively maintained versions of `glibc` can install and run these binaries. The build dependency binaries are installed as resources to `/tmp/homebrew` and used to build `glibc` instead of the host toolchain.

## Copyright
Copyright (c) Homebrew maintainers.  See LICENSE.txt for details.
