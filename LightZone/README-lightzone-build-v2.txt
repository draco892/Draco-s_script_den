build-lightzone-macos-arm64.sh
===============================

Overview
--------

This script automates a local LightZone build on an Apple Silicon Mac. It
prepares the Homebrew and Java environment, verifies the project checkout,
cleans previous Gradle output, builds the project without running tests, and
creates a JAR artifact.

The script is intended for development builds rather than for installing the
application directly into /Applications.

Requirements
------------

- macOS running on Apple Silicon.
- Homebrew installed at /opt/homebrew.
- Xcode Command Line Tools.
- Bash with support for strict mode.
- A LightZone checkout at:

    /Users/draco892/Documents/GIT/LightZone

- The Gradle wrapper and settings.gradle.kts in the project root.
- Internet access for installing missing Homebrew packages and resolving Gradle
dependencies.

Homebrew Dependencies
---------------------

The script checks for the following packages and installs any that are missing:

- openjdk@21
- jpeg-turbo
- lensfun
- libomp
- libraw
- libtiff
- little-cms2
- pkg-config

Java Configuration
------------------

The expected Java version is 21. The script uses this Homebrew installation:

    /opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home

It exports JAVA_HOME and places the Java and Apple Silicon Homebrew binaries at
the beginning of PATH. If Java 21 cannot be found, or if another major version
is detected, the script stops before building.

Workflow
--------

The build process consists of the following steps:

1. Confirm that the host reports arm64.
2. Check Homebrew and xcode-select.
3. Confirm that Homebrew uses the expected Apple Silicon prefix.
4. Verify that Xcode Command Line Tools are installed.
5. Install missing build dependencies.
6. Configure and validate Java 21.
7. Enter the LightZone project directory.
8. Make the Gradle wrapper executable.
9. Display project, architecture, Java, and Gradle information.
10. Remove previous Gradle build output with ./gradlew clean.
11. Build LightZone while excluding tests with ./gradlew build -x test.
12. Create the JAR with ./gradlew jar.
13. Print the locations where artifacts can be found.

Usage
-----

Make the script executable:

    chmod +x build-lightzone-macos-arm64.sh

Run it from any directory:

    ./build-lightzone-macos-arm64.sh

The script changes into PROJECT_DIR before executing Gradle, so it does not need
to be launched from the LightZone checkout.

Configuration
-------------

The following values are defined near the top of the script and can be changed
for a different local setup:

    PROJECT_DIR
        Absolute path to the LightZone source tree.

    BREW_PREFIX
        Expected Homebrew installation prefix.

    JAVA_VERSION
        Required Java major version.

    JAVA_HOME_PATH
        Location of the selected JDK installation.

Build Artifacts
---------------

After a successful build, inspect these locations:

    /Users/draco892/Documents/GIT/LightZone/build
    /Users/draco892/Documents/GIT/LightZone/lightcrafts/products

The exact artifact names depend on the current LightZone Gradle configuration.

Useful Follow-up Commands
-------------------------

Run LightZone from the project:

    cd /Users/draco892/Documents/GIT/LightZone
    ./gradlew run

Create a macOS application bundle or DMG:

    cd /Users/draco892/Documents/GIT/LightZone
    ./gradlew jpackage

Error Handling
--------------

The script uses:

    set -Eeuo pipefail

This causes it to stop when a command fails, an unset variable is referenced, or
a pipeline fails. An ERR trap reports the line where a build failure occurred.

Common Problems
---------------

Wrong architecture

The script requires uname -m to return arm64. On Intel Macs, use an adapted
build environment or run the project using the appropriate platform settings.

Homebrew prefix mismatch

The script expects native Apple Silicon Homebrew at /opt/homebrew. Verify the
installation with:

    brew --prefix

Missing Command Line Tools

Install them with:

    xcode-select --install

Java version mismatch

Verify the selected JDK and JAVA_HOME_PATH. The script requires Java 21.

Missing project files

Confirm that PROJECT_DIR contains both gradlew and settings.gradle.kts.

Build failure

Run the failing Gradle task manually from the project directory to obtain more
detailed output. The main build intentionally excludes tests; use ./gradlew
build when you also want to execute the test suite.

Notes
-----

This script installs missing Homebrew packages but does not explicitly upgrade
already installed packages. It also does not install the resulting application
into /Applications. Use a separate packaging or installation script for that
purpose.
