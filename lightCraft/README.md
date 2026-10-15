# LightCraft

LightCraft is a high-performance media processing tool built with Rust, featuring support for HEIF and other modern image formats.

## Features
- HEIF support
- High-performance processing
- Command-line interface (CLI)

## Build & Package

To build and package the application for macOS, you can use the complete script provided in `build_app_complete_script.txt` or run the following commands manually:

**Quick Complete Run:**
```bash
export CRAFT_FONTS_DIR="/Users/draco892/Documents/GIT/craft-fonts"
export CRAFT_FONTS_REQUIRED=1

cargo clean

cargo build --release --locked \
  --target aarch64-apple-darwin \
  -p lightcraft -p lightcraft-cli \
  --features lightcraft/heif,lightcraft-cli/heif \
&& bash packaging/macos/package.sh --arch aarch64 --skip-build
```

**Step-by-Step Build:**
1. Prepare the environment:
   ```bash
   source packaging/env.sh
   source packaging/fonts.sh
   prepare_fonts
   ```
2. Build the project:
   ```bash
   cargo clean
   cargo build --release --locked \
     --target aarch64-apple-darwin \
     -p lightcraft -p lightcraft-cli \
     --features lightcraft/heif,lightcraft-cli/heif
   ```
3. Package the application:
   ```bash
   bash packaging/macos/package.sh --arch aarch64 --skip-build
   ```

The resulting application will be available in `target/macos-package/LightCraft.app`, and the DMG and ZIP files will be located in the `dist/release/` directory.

