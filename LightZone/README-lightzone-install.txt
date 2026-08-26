build-lightzone-macos-arm64_app_build-2.sh
==============================================

Purpose
-------

Build the LightZone macOS application and install it in /Applications. The
script uses the Gradle jpackage task to create LightZone.app, copies the result
with Apple's ditto command, and optionally opens the installed application.

Requirements
------------

- macOS on Apple Silicon or another supported macOS system.
- A LightZone checkout at:

    /Users/draco892/Documents/GIT/LightZone

- An executable Gradle wrapper at PROJECT_DIR/gradlew.
- A working :macosx:jpackage Gradle task.
- The macOS commands ditto and open.
- Permission to modify /Applications.

Workflow
--------

The script:

1. Verifies ditto and open.
2. Checks the LightZone project directory.
3. Checks that gradlew exists and is executable.
4. Changes to the project directory.
5. Runs ./gradlew :macosx:jpackage.
6. Verifies that macosx/release/LightZone.app was generated.
7. If an existing application is present, asks whether it should be replaced.
8. Copies the application to /Applications with ditto.
9. Asks whether LightZone should be opened.

Usage
-----

    chmod +x build-lightzone-macos-arm64_app_build-2.sh
    ./build-lightzone-macos-arm64_app_build-2.sh

The script can be started from any directory because it changes to PROJECT_DIR
before invoking Gradle.

Generated and Installed Paths
-----------------------------

Source application:

    /Users/draco892/Documents/GIT/LightZone/macosx/release/LightZone.app

Installed application:

    /Applications/LightZone.app

Replacement Behavior
--------------------

If /Applications/LightZone.app already exists, the script prompts for
confirmation. Answer y or yes to remove the old application and install the
new one. Any other answer cancels the installation.

The replacement uses rm -rf on the existing application bundle. Confirm the
path before running the script and do not change APP_DESTINATION to an unsafe
location.

Error Handling
--------------

The script uses strict Bash mode and an ERR trap. If a command fails, it prints
the failing line and command before exiting. It also stops when the expected
project directory, Gradle wrapper, or generated application is missing.

Troubleshooting
---------------

- If jpackage fails, run ./gradlew :macosx:jpackage manually from the project
  directory and inspect the Gradle output.
- If installation fails, verify write permission for /Applications.
- If LightZone does not open, launch /Applications/LightZone.app manually and
  inspect macOS security or quarantine prompts.
- If the generated application is not found, verify the output path used by the
  current LightZone build configuration.
