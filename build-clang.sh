#!/bin/bash
set -exv

VERSION=10.x

## modify the following as needed for your environment
# location where clang should be installed
INSTALL_PREFIX=/build/share/clang/${VERSION}
# location of gcc used to build clang
HOST_GCC=/build/share/gcc/5.3.0
# number of cores
#CPUS="-j $(nproc)"
CPUS="-j 2"
# uncomment following to get verbose output from make
#VERBOSE=VERBOSE=1

#
# gets clang tree from git
# params can be specified on command line
#
if [[ ! -d llvm-project ]]; then
   git clone --single-branch --branch release/10.x https://github.com/llvm/llvm-project.git
fi

## build clang w/gcc installed in non-standard location
set +e
rm -rf build
set -e
mkdir -p build
cd build
cmake \
 -DCMAKE_C_COMPILER=${HOST_GCC}/bin/gcc -DCMAKE_CXX_COMPILER=${HOST_GCC}/bin/g++ -DGCC_INSTALL_PREFIX=${HOST_GCC} \
 -DCMAKE_CXX_LINK_FLAGS="-L${HOST_GCC}/lib64 -Wl,-rpath,${HOST_GCC}/lib64" \
 -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
 -DLLVM_ENABLE_ASSERTIONS=ON -DCMAKE_BUILD_TYPE="Release" -DLLVM_TARGETS_TO_BUILD="X86" \
 -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra;compiler-rt" \
 ../llvm-project/llvm
make ${CPUS} ${VERBOSE}

# install it
set +e
rm -rf ${INSTALL_PREFIX}
set -e
make install
