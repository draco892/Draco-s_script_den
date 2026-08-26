#!/usr/bin/env bash

set -Eeuo pipefail

readonly REPO_DIR="/Users/draco892/src/darktable"
readonly BRANCH="master"
readonly UPSTREAM_REMOTE="upstream"
readonly ORIGIN_REMOTE="origin"
readonly INSTALL_PREFIX="${HOME}/bin/darktable-dev"

# Imposta a 1 per includere anche i file non tracciati nello stash.
readonly INCLUDE_UNTRACKED=1

STASH_CREATED=0
STASH_REF=""

log() {
    printf '\n\033[1;34m==> %s\033[0m\n' "$*"
}

die() {
    printf '\033[1;31mError: %s\033[0m\n' "$*" >&2
    exit 1
}

cleanup() {
    local exit_code=$?

    if (( STASH_CREATED )); then
        log "Restoring local changes"

        if ! git -C "$REPO_DIR" stash pop "$STASH_REF"; then
            printf '\n\033[1;33mWarning: unable to restore the stash automatically.\033[0m\n' >&2
            printf 'The stash is still available as: %s\n' "$STASH_REF" >&2
            printf 'Resolve the situation manually before continuing.\n' >&2
        fi
    fi

    exit "$exit_code"
}

trap cleanup EXIT

command -v git >/dev/null 2>&1 || die "git is not installed or not available in PATH."
command -v brew >/dev/null 2>&1 || die "Homebrew is not installed or not available in PATH."

[[ -d "$REPO_DIR/.git" ]] || die "Not a Git repository: $REPO_DIR"

LLVM_PREFIX="$(brew --prefix llvm)"
LUA_PREFIX="$(brew --prefix lua@5.4)"
LIBSOUP_PREFIX="$(brew --prefix libsoup@2)"
ICU_PREFIX="$(brew --prefix icu4c)"

for prefix in "$LLVM_PREFIX" "$LUA_PREFIX" "$LIBSOUP_PREFIX" "$ICU_PREFIX"; do
    [[ -d "$prefix" ]] || die "Homebrew prefix does not exist: $prefix"
done

cd "$REPO_DIR"

log "Checking Git remotes"
git remote get-url "$UPSTREAM_REMOTE" >/dev/null 2>&1 \
    || die "Git remote '$UPSTREAM_REMOTE' is not configured."
git remote get-url "$ORIGIN_REMOTE" >/dev/null 2>&1 \
    || die "Git remote '$ORIGIN_REMOTE' is not configured."

log "Checking working tree"
if [[ -n "$(git status --porcelain)" ]]; then
    log "Stashing local changes"

    if (( INCLUDE_UNTRACKED )); then
        git stash push --include-untracked \
            --message "darktable build $(date '+%Y-%m-%d %H:%M:%S')"
    else
        git stash push \
            --message "darktable build $(date '+%Y-%m-%d %H:%M:%S')"
    fi

    STASH_REF="$(git rev-parse --verify refs/stash)"
    STASH_CREATED=1
fi

log "Switching to ${BRANCH}"
git switch "$BRANCH"

log "Updating from upstream"
git fetch "$UPSTREAM_REMOTE" --prune
git merge --ff-only "${UPSTREAM_REMOTE}/${BRANCH}"

log "Updating fork"
git push "$ORIGIN_REMOTE" "$BRANCH"

log "Removing previous build directory"
rm -rf -- build

log "Configuring compiler and dependencies"
export PATH="${LLVM_PREFIX}/bin:${PATH}"
export CC="${LLVM_PREFIX}/bin/clang"
export CXX="${LLVM_PREFIX}/bin/clang++"

export LDFLAGS="-L${LLVM_PREFIX}/lib ${LDFLAGS:-}"
export CPPFLAGS="-I${LLVM_PREFIX}/include ${CPPFLAGS:-}"

export CMAKE_PREFIX_PATH="${LUA_PREFIX}:${LIBSOUP_PREFIX}:${ICU_PREFIX}${CMAKE_PREFIX_PATH:+:${CMAKE_PREFIX_PATH}}"
export PKG_CONFIG_PATH="${LIBSOUP_PREFIX}/lib/pkgconfig:${ICU_PREFIX}/lib/pkgconfig${PKG_CONFIG_PATH:+:${PKG_CONFIG_PATH}}"

log "Building and installing darktable"
./build.sh \
    --install \
    --build-type RelWithDebInfo \
    --prefix "$INSTALL_PREFIX"

log "Build completed successfully"
printf 'Installed darktable at: %s\n' "$INSTALL_PREFIX"
