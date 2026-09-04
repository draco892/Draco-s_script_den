#!/bin/bash
cd /Users/draco892/src/darktable

rm -rf build

git fetch --all
git checkout master
git pull

export CC=/usr/bin/clang
export CXX=/usr/bin/clang++

export CXXFLAGS="-std=c++20 -Wno-error=unused-but-set-variable"
export CFLAGS="-Wno-error=unused-but-set-variable"

LUA_PREFIX="$(brew --prefix lua@5.4)"

cmake -S . -B build \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DCMAKE_INSTALL_PREFIX="$HOME/bin/darktable-dev" \
  -DCMAKE_PREFIX_PATH="$LUA_PREFIX" \
  -DCMAKE_CXX_COMPILER=/usr/bin/clang++ \
  -DCMAKE_C_COMPILER=/usr/bin/clang \
  -DCMAKE_CXX_STANDARD=20 \
  -DCMAKE_CXX_STANDARD_REQUIRED=ON \
  -DCMAKE_CXX_EXTENSIONS=OFF\
  -DCMAKE_CXX_FLAGS="-std=c++20"

cmake --build build -j"$(sysctl -n hw.ncpu)"
cmake --install build