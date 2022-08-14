#/bin/bash

PREFIX=/tmp/homebrew
mkdir -p $PREFIX

# Build gawk
curl -LO --insecure https://ftp.gnu.org/gnu/gawk/gawk-5.1.1.tar.xz
tar xf gawk-5.1.1.tar.xz
cd gawk-5.1.1
./configure --prefix="${PREFIX}" --disable-mpfr --without-libsigsegv
make
make install
cd ..
rm -rf gawk-5.1.1

# Build sed
curl -LO --insecure https://ftp.gnu.org/gnu/sed/sed-4.8.tar.xz
tar xf sed-4.8.tar.xz
cd sed-4.8
./configure --prefix="${PREFIX}" --without-selinux
make install
cd ..
rm -rf sed-4.8

# Build make
curl -LO --insecure https://ftp.gnu.org/gnu/make/make-4.3.tar.gz
tar xzf make-4.3.tar.gz
cd make-4.3
./configure --prefix="${PREFIX}"
make install
cd ..
rm -rf make-4.3

# Build m4
curl -LO --insecure https://ftp.gnu.org/gnu/m4/m4-1.4.19.tar.xz
tar xf m4-1.4.19.tar.xz
cd m4-1.4.19
./configure --prefix="${PREFIX}"
make
make install
cd ..
rm -rf m4-1.4.19

# Build bison
curl -LO --insecure https://ftp.gnu.org/gnu/bison/bison-3.8.2.tar.xz
tar xf bison-3.8.2.tar.xz
cd bison-3.8.2
./configure --prefix="${PREFIX}" M4="${PREFIX}/bin/m4"
make install
cd ..
rm -rf bison-3.8.2

# Build GCC
curl -LO --insecure https://ftp.gnu.org/gnu/gcc/gcc-9.5.0/gcc-9.5.0.tar.xz
tar xf gcc-9.5.0.tar.xz
cd gcc-9.5.0

# Download GCC support libraries
./contrib/download_prerequisites

# Disable building documentation
gcc_cv_prog_makeinfo_modern=no

mkdir build
cd build

# Disable everything that isn't needed to build glibc.
../configure \
  --prefix="${PREFIX}" \
  --enable-languages="c,c++" \
  --disable-werror \
  --disable-nls \
  --disable-bootstrap \
  --disable-decimal-float \
  --disable-libatomic \
  --disable-libgomp \
  --disable-libquadmath \
  --disable-libsanitizer \
  --disable-libssp \
  --disable-libvtv \
  --disable-threads \
  --disable-multilib \
  --with-newlib \
  --without-headers
make
make install

cd ../..
rm -rf gcc-9.5.0

# Build Python 3
curl -LO https://www.python.org/ftp/python/3.9.13/Python-3.9.13.tar.xz
tar xf Python-3.9.13.tar.xz
cd Python-3.9.13

./configure --prefix="${PREFIX}" ac_cv_search_crypt=no ac_cv_search_crypt_r=no
make
make install

cd ..
rm -rf Python-3.9.13

cd /tmp
tar czf /home/linuxbrew/bootstrap-binaries/bootstrap-binaries.tar.gz homebrew
