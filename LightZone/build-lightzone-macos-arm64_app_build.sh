#!/usr/bin/env bash

set -Eeuo pipefail

readonly PROJECT_DIR="/Users/draco892/Documents/GIT/LightZone"
readonly APP_NAME="LightZone.app"
readonly APP_SOURCE="${PROJECT_DIR}/macosx/release/${APP_NAME}"
readonly APPLICATIONS_DIR="/Applications"
readonly APP_DESTINATION="${APPLICATIONS_DIR}/${APP_NAME}"

log() {
    printf '\n\033[1;34m==> %s\033[0m\n' "$*"
}

die() {
    printf '\033[1;31mError: %s\033[0m\n' "$*" >&2
    exit 1
}

on_error() {
    local exit_code=$?

    printf '\033[1;31mBuild failed at line %s: %s\033[0m\n' \
        "$1" "$2" >&2

    exit "$exit_code"
}

trap 'on_error "$LINENO" "$BASH_COMMAND"' ERR

command -v ditto >/dev/null 2>&1 || die "ditto is not available."
command -v open >/dev/null 2>&1 || die "open is not available."

[[ -d "$PROJECT_DIR" ]] || die "Project directory not found: $PROJECT_DIR"
[[ -x "$PROJECT_DIR/gradlew" ]] || {
    die "Gradle wrapper not found or not executable: $PROJECT_DIR/gradlew"
}

cd "$PROJECT_DIR"

log "Building LightZone macOS application"
./gradlew :macosx:jpackage

[[ -d "$APP_SOURCE" ]] || {
    die "Generated application not found: $APP_SOURCE"
}

if [[ -e "$APP_DESTINATION" ]]; then
    printf '\nThe application is already installed at:\n%s\n\n' \
        "$APP_DESTINATION"

    read -r -p "Replace the existing application? [y/N] " answer

    case "$answer" in
        [yY]|[yY][eE][sS])
            log "Removing previous installation"
            rm -rf -- "$APP_DESTINATION"
            ;;
        *)
            die "Installation cancelled."
            ;;
    esac
fi

log "Installing ${APP_NAME} into ${APPLICATIONS_DIR}"
ditto "$APP_SOURCE" "$APP_DESTINATION"

log "Installation completed successfully"
printf 'Installed application: %s\n' "$APP_DESTINATION"

read -r -p "Open LightZone now? [y/N] " open_answer

case "$open_answer" in
    [yY]|[yY][eE][sS])
        open "$APP_DESTINATION"
        ;;
esac
