FROM debian/eol:wheezy
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get install -y build-essential bzip2 libz-dev texinfo wget

RUN useradd --create-home --shell /bin/bash linuxbrew

ENV CFLAGS="-march=core2 -O2"
ENV CXXFLAGS="-march=core2 -O2"
ENV PREFIX=/tmp/homebrew
RUN su - linuxbrew --command 'mkdir --parents /tmp/homebrew'
ENV PKGDIR=/home/linuxbrew/bootstrap-binaries
RUN su - linuxbrew --command 'mkdir --parents /home/linuxbrew/bootstrap-binaries'
