cd /Users/draco892/src/darktable

git fetch --all
git checkout master
git pull

cd /Users/draco892/src/darktable/packaging/macosx

rm -rf ../../build

./2_build_hb_darktable_custom.sh

export CODECERT="draconian892@gmail.com"

rm -rf ../../build/macosx/package

./3_make_hb_darktable_package.sh

./4_make_hb_darktable_dmg.sh