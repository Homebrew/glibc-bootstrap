# glibc-bootstrap

Bootstrap binaries for compiling `glibc` from source.

## Requirements

To run the binaries built by this workflow:

For x86-64 Linux: `glibc` 2.13 or newer, and x86-64 CPU architecture with support for `-march=core2` (defined [here](https://gcc.gnu.org/onlinedocs/gcc/x86-Options.html)).

For ARM64 (AArch64) Linux: `glibc` 2.17 or newer.

To build the binaries:

A host machine capable of building and running Linux x86-64 or ARM64 Docker images.

## Installation

The bootstrap binaries are downloaded automatically whenever the `glibc` formula is built from source, including bottle builds in CI. Users need a source build when they have a non-default prefix and a host `glibc` older than Homebrew's Linux CI version.

## Building binaries outside of GitHub Actions

GitHub Actions is used to build the binaries in CI.  To build them locally:
```
# Clone the repository
git clone https://github.com/Homebrew/glibc-bootstrap
cd glibc-bootstrap

# Select the target architecture (also used when building through emulation).
arch=x86_64
platform=linux/amd64
# For ARM64, set arch=arm64 and platform=linux/arm64 instead.
docker build --platform "$platform" --tag glibc-bootstrap --file "Dockerfile.$arch" .

# Start the Docker image and leave it running the background so the binaries
# can easily be copied out after they are built.
docker run --platform "$platform" --rm --detach --user linuxbrew --name glibc-bootstrap \
  --workdir /home/linuxbrew --volume "$(pwd):/home/linuxbrew/glibc-bootstrap:ro" glibc-bootstrap sleep inf

# Call a build-*.sh script to build a specific binary.  We use build-make.sh as an example.
docker exec glibc-bootstrap /bin/bash -c "/home/linuxbrew/glibc-bootstrap/build-make.sh"

# Copy the binaries out of the container after they have been compiled.
docker cp glibc-bootstrap:/home/linuxbrew/bootstrap-binaries .
docker stop glibc-bootstrap
```

Builds use the available CPU count. Pass `--env BUILD_JOBS=2` to `docker exec` to reduce parallelism. The build prefix must be empty; after an interrupted build, recreate the container before retrying.

## Validation and releases

Run `ruby -Itests -e 'Dir["tests/test_*.rb"].sort.each { |file| require_relative file }'` (Ruby 3.2 or newer with its bundled Minitest), `shellcheck -x ./*.sh .github/scripts/*.sh`, and `actionlint` locally. Build CI checks packaged ELF architecture and glibc requirements, runs each tool in an unmodified CentOS base image, and builds and runs glibc with the combined toolchain. The integration fixture in `.github/scripts/test-glibc.sh` should track homebrew-core's glibc version.

Configure `Validate bootstrap binaries` as a required status check. It runs on every PR, including changes that do not require rebuilding the toolchain.

To release, dispatch **Upload new release** from the intended commit's branch or tag and supply the release version. Publication waits for validation, generates artifact provenance, and targets the workflow commit. An existing tag must identify that same commit. Then update the resource URLs and checksums in homebrew-core's `glibc` formula.

## Motivation

The `glibc` bottle is not relocatable and must be built from source if the user is in a non-default prefix.  While `glibc` has no runtime dependencies, it does have build dependencies which may be too new or unavailable to users without root access.  Rather than requiring the user to build these dependencies from source, we build them with GitHub Actions in this repository using a Linux image with an older version of `glibc` and a prefix of `/tmp/homebrew`.  Assuming the user has write access to `/tmp`, this approach guarantees that all users on actively maintained versions of `glibc` can install and run these binaries. The build dependency binaries are installed as resources to `/tmp/homebrew` and used to build `glibc` instead of the host toolchain.

## Copyright
Copyright (c) Homebrew maintainers.  See LICENSE.txt for details.
