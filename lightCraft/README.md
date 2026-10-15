# LightCraft

LightCraft is a high-performance media processing tool built with Rust, featuring support for HEIF and other modern image formats.

## Features
- HEIF support
- High-performance processing
- Command-line interface (CLI)

## Build Instructions

To build the project from source, ensure you have the Rust toolchain installed and run the following commands:

```bash
source packaging/env.sh
source packaging/fonts.sh
prepare_fonts

cargo clean

cargo build --release --locked \
  --target aarch64-apple-darwin \
  -p lightcraft -p lightcraft-cli \
  --features lightcraft/heif,lightcraft-cli/heif
```

## Packaging

To build the macOS application package, use the following command:

```bash
bash packaging/macos/package.sh --arch aarch64 --skip-build
```

The resulting application will be available in `target/macos-package/LightCraft.app`, and the DMG and ZIP files will be located in the `dist/release/` directory.
