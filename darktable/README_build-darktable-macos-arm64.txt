# Darktable Build Scripts for macOS ARM64

This guide provides build scripts for compiling [darktable](https://www.darktable.org/) on macOS ARM64 (Apple Silicon) with different C++ standards.

---

## 📁 Scripts Overview

| Script | C++ Standard | Status |
|--------|--------------|--------|
| `build-darktable-macos-arm64_C++17.sh` | C++17 | Stable          |
| `build-darktable-macos-arm64_C++20.sh` | C++20 | Stable          |
| `build-darktable-macos-arm64_C++23.sh` | C++23 | Partial         |
| `build-darktable-macos-arm64_C++26.sh` | C++26 | Experimental    |

---

## Prerequisites

### System Requirements
- macOS ARM64 (Apple Silicon M1/M2/M3)
- Xcode Command Line Tools (Xcode 15+ recommended)
- Homebrew package manager

### Install Dependencies

```bash
# Install required packages via Homebrew
brew install cmake lua@5.4 gtk+3 libxml2 lensfun exiv2 \
             libpng libtiff lcms2 libjpeg-turbo libraw \
             libxslt glib gettext pkg-config

# Install Xcode Command Line Tools (if not present)
xcode-select --install