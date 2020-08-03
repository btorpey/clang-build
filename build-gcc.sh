#!/bin/bash
set -exv

# location where gcc should be installed
INSTALL_PREFIX=/build/share/gcc/5.3.0
# number of cores
CPUS=1
# uncomment following to get verbose output from make
#VERBOSE=VERBOSE=1
# uncomment following if you need to sudo in order to do the install
#SUDO="su buildmaster -c"

# directory that is created by un-tar
GCC_VER=gcc-5.3.0
GMP_VER=gmp-4.3.2
MPC_VER=mpc-0.8.1
MPFR_VER=mpfr-2.4.2
#CLOOG_VER=cloog-0.18.1
ISL_VER=isl-0.15

## download everything we're going to need
# compiler
[[ -e ${GCC_VER}.tar.bz2 ]]   || wget -nv http://www.netgull.com/gcc/releases/${GCC_VER}/${GCC_VER}.tar.bz2
# pre-requsites
[[ -e ${GMP_VER}.tar.bz2 ]]   || wget -nv https://gmplib.org/download/gmp/${GMP_VER}.tar.bz2
[[ -e ${MPC_VER}.tar.gz ]]    || wget -nv http://www.multiprecision.org/mpc/download/${MPC_VER}.tar.gz
[[ -e ${MPFR_VER}.tar.bz2 ]]  || wget -nv http://www.mpfr.org/${MPFR_VER}/${MPFR_VER}.tar.bz2
#[[ -e ${CLOOG_VER}.tar.gz ]]  || wget -nv ftp://gcc.gnu.org/pub/gcc/infrastructure/${CLOOG_VER}.tar.gz
[[ -e ${ISL_VER}.tar.bz2 ]]   || wget -nv ftp://gcc.gnu.org/pub/gcc/infrastructure/${ISL_VER}.tar.bz2

## untar gcc (into ${GCC_VER})
[[ -d ${GCC_VER} ]] || tar xf ${GCC_VER}.tar.bz2

## untar prereqs and move into source tree so they will be built as part of the gcc build
# gmp
if [[ ! -d ${GCC_VER}/gmp ]]; then
  tar xf ${GMP_VER}.tar.bz2
  mv ${GMP_VER} ${GCC_VER}/gmp
fi
# mpc
if [[ ! -d ${GCC_VER}/mpc ]]; then
  tar xf ${MPC_VER}.tar.gz
  mv ${MPC_VER} ${GCC_VER}/mpc
fi
# mpfr
if [[ ! -d ${GCC_VER}/mpfr ]]; then
  tar xf ${MPFR_VER}.tar.bz2
  mv ${MPFR_VER} ${GCC_VER}/mpfr
fi
## cloog
#if [[ ! -d ${GCC_VER}/cloog ]]; then
#  tar xf ${CLOOG_VER}.tar.gz
#  mv ${CLOOG_VER} ${GCC_VER}/cloog
#fi
# isl
if [[ ! -d ${GCC_VER}/isl ]]; then
  tar xf ${ISL_VER}.tar.bz2
  mv ${ISL_VER} ${GCC_VER}/isl
fi

# build gcc
cd ${GCC_VER}
rm -rf build
mkdir build
cd build
../configure --prefix=${INSTALL_PREFIX} --enable-languages=c,c++ --disable-multilib
make -j ${CPUS} ${VERBOSE}

# install it
rm -rf ${INSTALL_PREFIX}
make install
