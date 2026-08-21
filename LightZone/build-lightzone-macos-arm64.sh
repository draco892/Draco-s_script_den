#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_DIR="/Users/draco892/Documents/GIT/LightZone"
BREW_PREFIX="/opt/homebrew"
JAVA_VERSION="21"
JAVA_HOME_PATH="$BREW_PREFIX/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home"

log() {
    printf '\n[%s] %s\n' "$(date '+%H:%M:%S')" "$*"
}

fail() {
    printf '\nERROR: %s\n' "$*" >&2
    exit 1
}

trap 'printf "\nERROR: build failed at line %s\n" "$LINENO" >&2' ERR

log "Checking host architecture"
[[ "$(uname -m)" == "arm64" ]] || fail "This script requires an Apple Silicon Mac (arm64)."

log "Checking required commands"
command -v brew >/dev/null 2>&1 || fail "Homebrew is not installed. Install it from https://brew.sh/"
command -v xcode-select >/dev/null 2>&1 || fail "xcode-select is not available. Install Xcode Command Line Tools."

[[ "$(brew --prefix)" == "$BREW_PREFIX" ]] || fail "Expected Apple Silicon Homebrew at $BREW_PREFIX, found $(brew --prefix)."

log "Checking Xcode Command Line Tools"
xcode-select -p >/dev/null 2>&1 || fail "Xcode Command Line Tools are not installed. Run: xcode-select --install"

log "Installing or updating build dependencies"
brew list --versions openjdk@21 >/dev/null 2>&1 || brew install openjdk@21
brew list --versions jpeg-turbo >/dev/null 2>&1 || brew install jpeg-turbo
brew list --versions lensfun >/dev/null 2>&1 || brew install lensfun
brew list --versions libomp >/dev/null 2>&1 || brew install libomp
brew list --versions libraw >/dev/null 2>&1 || brew install libraw
brew list --versions libtiff >/dev/null 2>&1 || brew install libtiff
brew list --versions little-cms2 >/dev/null 2>&1 || brew install little-cms2
brew list --versions pkg-config >/dev/null 2>&1 || brew install pkg-config

[[ -x "$JAVA_HOME_PATH/bin/java" ]] || fail "Java 21 was not found at $JAVA_HOME_PATH"

export JAVA_HOME="$JAVA_HOME_PATH"
export PATH="$JAVA_HOME/bin:$BREW_PREFIX/bin:$PATH"

log "Checking Java version"
JAVA_MAJOR="$($JAVA_HOME/bin/java -version 2>&1 | awk -F'[.\"]' '/version/ {print $2; exit}')"
[[ "$JAVA_MAJOR" == "$JAVA_VERSION" ]] || fail "Expected Java $JAVA_VERSION, found Java $JAVA_MAJOR"

log "Checking project directory"
cd "$PROJECT_DIR"
[[ -f gradlew ]] || fail "gradlew not found in $PROJECT_DIR"
[[ -f settings.gradle.kts ]] || fail "settings.gradle.kts not found in $PROJECT_DIR"
chmod +x gradlew

log "Build environment"
printf 'Project: %s\n' "$PWD"
printf 'Architecture: %s\n' "$(uname -m)"
printf 'JAVA_HOME: %s\n' "$JAVA_HOME"
printf 'Java: '
java -version
printf 'Gradle: '
./gradlew --version

log "Cleaning project"
./gradlew clean

log "Building project (tests excluded)"
./gradlew build -x test

log "Creating JAR"
./gradlew jar

log "Build completed successfully"
printf '\nArtifacts can be found under:\n'
printf '  %s\n' "$PROJECT_DIR/build" "$PROJECT_DIR/lightcrafts/products"
printf '\nTo run LightZone:\n  cd %q && ./gradlew run\n' "$PROJECT_DIR"
printf '\nTo create a macOS application/DMG:\n  cd %q && ./gradlew jpackage\n' "$PROJECT_DIR"
