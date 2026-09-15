cd /Users/draco892/src/darktable
git fetch --all
git checkout master
git pull
cd /Users/draco892/src/darktable/packaging/macosx
./2_build_hb_darktable_custom.sh
export CODECERT="your.developer@apple.id"
./3_make_hb_darktable_package.sh
./4_make_hb_darktable_dmg.sh