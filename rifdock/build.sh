#!/bin/bash

set -x
set -e

echo "--- Env"

export PYVERSION=2.7
export CMAKE_FINAL_ROSETTA_PATH=${PREFIX}/lib            # from rosetta_omp package
export CMAKE_ROSETTA_PATH=${PREFIX}/include/rosetta_dev  # from rosetta_omp package
export SCHEME_INSTALL_PATH=${PREFIX}                     # sets install prefix

echo "--- Configure"

mkdir -p build
pushd build

cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS=-I\ ${PREFIX}/include -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON

echo "--- Build"
make -j7 rif_dock_test rifgen

echo "--- Install"
pushd apps/rosetta
make install

echo "--- Done"
popd
popd
