cd /Users/draco892/src/darktable

git fetch --all
git checkout master
git pull

cd /Users/draco892/src/darktable/packaging/macosx

rm -rf ../../build

./2_build_hb_darktable_custom.sh

rm -rf ../../build/macosx/package

./3_make_hb_darktable_package.sh

rm -rf /Applications/darktable.app
cp -R ../../build/macosx/package/darktable.app /Applications/