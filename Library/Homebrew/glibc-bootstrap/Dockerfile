FROM debian/eol:wheezy
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get install -y build-essential curl bzip2

RUN useradd -m -s /bin/bash linuxbrew
