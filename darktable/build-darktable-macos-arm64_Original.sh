cd /Users/draco892/src/darktable
rm -rf build

git fetch --all
git checkout master
git pull

export PATH="$(brew --prefix llvm)/bin:$PATH"
export CC="$(brew --prefix llvm)/bin/clang"
export CXX="$(brew --prefix llvm)/bin/clang++"
export LDFLAGS="-L$(brew --prefix llvm)/lib"
export CPPFLAGS="-I$(brew --prefix llvm)/include"

LUA_PREFIX="$(brew --prefix lua@5.4)"

: "${CFLAGS:=}"
: "${CXXFLAGS:=}"
export CFLAGS="-Wno-error=unused-but-set-variable -Wno-error=unused-but-set-global $CFLAGS"
export CXXFLAGS="-Wno-error=unused-but-set-variable -Wno-error=unused-but-set-global $CXXFLAGS"

cmake -S . -B build \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DCMAKE_INSTALL_PREFIX="$HOME/bin/darktable-dev" \
  -DCMAKE_PREFIX_PATH="$LUA_PREFIX"

cmake --build build -j"$(sysctl -n hw.ncpu)"
cmake --install build