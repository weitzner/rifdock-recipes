#!/bin/bash

set -x
set -e

echo "--- Env"

TARGET_APPS="rosetta_scripts score"

echo "--- Configure"

pushd source/cmake
./make_project.py all

pushd build_cxx11_omp
cmake -G Ninja -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCONDA_LIB_PREFIX=${PREFIX}/lib

echo "--- Build"
ninja ${TARGET_APPS}

echo "--- Install"
ninja install | grep -v Installing: | grep -v Up-to-date:

echo "--- Build completed"
popd
popd

echo "--- Install headers"
DESTDIR="${PREFIX}"/include/rosetta_dev
mkdir -p "${DESTDIR}"

HEADER_DIRECTORIES=(
    ./source/src
    ./source/external/include
    ./source/external/dbio
)

for DIRECTORY in "${HEADER_DIRECTORIES[@]}"; do
    find "${DIRECTORY}" -type f \( -name "*.h" -o -name "*.hh" -o -name "*.hpp" -o -name "*.ipp" \) | cpio -pdm  "${DESTDIR}"
done
echo "--- Done"
