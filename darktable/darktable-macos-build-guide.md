# Building darktable and Creating a macOS .app Bundle

This guide covers building darktable from source on macOS (Homebrew-based, Apple clang, C++26) and packaging it into a `.app` bundle you can drop into `/Applications`.

## Prerequisites (one-time setup)

```bash
cd /Users/draco892/src/darktable/packaging/macosx
./1_install_hb_dependencies.sh
```

This installs the Homebrew dependencies needed both to build darktable and to package it (dylib bundler, gtk-mac-bundler, etc.).

## Step 1 — Get the latest source

```bash
cd /Users/draco892/src/darktable
git fetch --all
git checkout master
git pull
```

## Step 2 — Build and install darktable (Release)

The custom build script `packaging/macosx/2_build_hb_darktable_custom.sh` has been configured with:

- `CMAKE_BUILD_TYPE=Release`
- Apple clang (`/usr/bin/clang` / `/usr/bin/clang++`) with C++26
- `CMAKE_OSX_DEPLOYMENT_TARGET=13.5` (required — older targets are unsupported)
- `CMAKE_PREFIX_PATH` pointing to the Homebrew `lua@5.4` prefix
- `BINARY_PACKAGE_BUILD=ON` (required for a relocatable app bundle)
- Install prefix set to `installDir` (`../../build/macosx`), which is what the packaging script expects

Run it:

```bash
cd /Users/draco892/src/darktable/packaging/macosx
./2_build_hb_darktable_custom.sh
```

This wipes and recreates `darktable/build`, configures, compiles with all CPU cores, and installs into `darktable/build/macosx`.

**Convenience shortcut:**

You can also use the `build-darktable-macos_Release_Custom.sh` script to handle the git checkout and compilation in one go:

```bash
./build-darktable-macos_Release_Custom.sh
```

## Step 3 — Create the .app bundle

```bash
./3_make_hb_darktable_package.sh
```

Optional: to sign with your own developer certificate, export `CODECERT` before running it:

```bash
export CODECERT="your.developer@apple.id"
./3_make_hb_darktable_package.sh
```

This script gathers the binaries, bundles all Homebrew dylib dependencies with correct rpaths, and assembles a self-contained bundle at:

```
darktable/build/macosx/package/darktable.app
```

## Step 4 — Test it in place (optional)

```bash
build/macosx/package/darktable.app/Contents/MacOS/darktable \
  --configdir ~/.config/darktable/ --cachedir ~/.cache/darktable/
```

## Step 5 — Install to Applications

```bash
cp -R build/macosx/package/darktable.app /Applications/
```

## Optional — Build a DMG instead

```bash
./4_make_hb_darktable_dmg.sh
```

Produces `darktable-<version>+<commit>-{arm64|x86_64}.dmg` in `build/macosx`.

## Notes / Limitations

- The bundle links against whatever Homebrew library versions are currently installed — rebuild the bundle after major Homebrew upgrades, or `brew pin` your working set.
- The DMG (if built) is not notarized by Apple; the app itself may only be ad-hoc signed unless `CODECERT` was set.
- `darktable-curve-tool` and `darktable-noiseprofile` are bundled but are extra utilities, not part of the main GUI.
- To rebuild from scratch, just repeat Steps 2–3 — the build script cleans `darktable/build` automatically each time.
