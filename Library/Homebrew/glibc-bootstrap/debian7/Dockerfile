FROM debian/eol:wheezy
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get install -y build-essential curl bzip2 libz-dev

RUN useradd -m -s /bin/bash linuxbrew

ENV PREFIX=/tmp/homebrew
RUN su - linuxbrew -c 'mkdir -p /tmp/homebrew'
ENV PKGDIR=/home/linuxbrew/bootstrap-binaries
RUN su - linuxbrew -c 'mkdir -p /home/linuxbrew/bootstrap-binaries'
