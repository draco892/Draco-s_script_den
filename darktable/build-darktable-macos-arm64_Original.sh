cd /Users/draco892/src/darktable

git switch master
git fetch upstream
git merge --ff-only upstream/master
git push origin master

rm -rf build

export PATH="$(brew --prefix llvm)/bin:$PATH"
export CC="$(brew --prefix llvm)/bin/clang"
export CXX="$(brew --prefix llvm)/bin/clang++"
export LDFLAGS="-L$(brew --prefix llvm)/lib"
export CPPFLAGS="-I$(brew --prefix llvm)/include"
export CMAKE_PREFIX_PATH="$(brew --prefix lua@5.4)"
export PKG_CONFIG_PATH="$(brew --prefix libsoup@2)/lib/pkgconfig:$(brew --prefix icu4c)/lib/pkgconfig"

./build.sh \
  --install \
  --build-type RelWithDebInfo \
  --prefix "$HOME/bin/darktable-dev"