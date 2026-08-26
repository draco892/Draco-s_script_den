build-darktable-macos-arm64.sh
================================

A Bash script for updating, building, and installing a local Apple Silicon
(macOS ARM64) development build of darktable.

The script automates the complete workflow:

1. Validate the required tools and directories.
2. Check the Git remotes and the working tree.
3. Temporarily stash local changes, including untracked files.
4. Switch to the master branch.
5. Fetch and fast-forward the local branch from upstream/master.
6. Push the updated master branch to origin.
7. Remove the previous build directory.
8. Configure LLVM and Homebrew dependencies.
9. Build and install darktable with RelWithDebInfo symbols.
10. Restore the local changes when the script exits.

Requirements
------------

- macOS running on Apple Silicon.
- Bash.
- Git.
- Homebrew.
- A local darktable Git checkout.
- An upstream Git remote pointing to the official darktable repository.
- An origin Git remote pointing to your fork.
- The following Homebrew packages:

  - llvm
  - lua@5.4
  - libsoup@2
  - icu4c

- darktable's build.sh script and all of its additional build dependencies.

Configuration
-------------

Edit the constants at the beginning of the script if your environment differs:

    REPO_DIR
        Absolute path to the local darktable repository. The default is:
        /Users/draco892/src/darktable

    BRANCH
        Branch to update and build. The default is master.

    UPSTREAM_REMOTE
        Remote used to retrieve the latest darktable source. The default is
        upstream.

    ORIGIN_REMOTE
        Remote used to update your fork. The default is origin.

    INSTALL_PREFIX
        Destination directory for the installed development build. The default
        is $HOME/bin/darktable-dev.

    INCLUDE_UNTRACKED
        Set to 1 to include untracked files in the temporary stash. Set to 0
        to stash only tracked changes.

Expected Git Remotes
--------------------

The script expects both remotes to exist:

    git remote add upstream <darktable-upstream-url>
    git remote add origin <your-fork-url>

You can inspect the current configuration with:

    git remote -v

Usage
-----

Make the script executable:

    chmod +x build-darktable-macos-arm64.sh

Run it from any directory:

    ./build-darktable-macos-arm64.sh

The script changes into REPO_DIR before performing Git and build operations, so
its current working directory does not need to be the darktable checkout.

What the Script Does
--------------------

Validation

The script uses strict Bash settings:

    set -Eeuo pipefail

It stops when a command fails, an unset variable is used, or a command in a
pipeline fails. Before touching the repository, it checks that Git and
Homebrew are available, that the repository exists, and that the required
Homebrew prefixes can be found.

Working Tree Protection

If the repository contains changes, the script creates a temporary stash. With
INCLUDE_UNTRACKED=1, untracked files are included as well. The stash is restored
by the cleanup handler when the script exits, including after a build failure.

If automatic restoration fails, the script prints the stash reference so that
it can be recovered manually. Do not delete that stash until the working tree
has been checked.

Repository Synchronization

The script switches to the configured branch, fetches upstream with pruning,
and performs a fast-forward-only merge from upstream/BRANCH. This prevents the
script from silently creating a merge commit or overwriting divergent local
history.

After the local branch has been updated, it pushes the branch to origin. This
means that running the script also synchronizes the fork with upstream.

Build Configuration

The script selects the Homebrew LLVM toolchain:

    CC=clang
    CXX=clang++

It also configures compiler and linker search paths through LDFLAGS, CPPFLAGS,
CMAKE_PREFIX_PATH, and PKG_CONFIG_PATH. These paths help CMake and pkg-config
find Lua, libsoup, ICU, and LLVM installations managed by Homebrew.

The build is started with:

    ./build.sh --install --build-type RelWithDebInfo --prefix "$INSTALL_PREFIX"

RelWithDebInfo provides an optimized build while retaining debugging
information, which is useful for development and troubleshooting.

Installation
------------

The installed files are placed under:

    $HOME/bin/darktable-dev

The exact location is controlled by INSTALL_PREFIX. If darktable does not
start from the installed location, verify that the directory structure matches
what darktable's build.sh expects and check the build output for missing
runtime dependencies.

Safety Notes
------------

- Review the values of REPO_DIR, UPSTREAM_REMOTE, and ORIGIN_REMOTE before the
  first run.
- The script removes the repository's build directory with rm -rf. Make sure
  REPO_DIR points to the intended darktable checkout.
- The script pushes to origin. Confirm that origin is your intended fork or
  remote before running it.
- The script performs a fast-forward-only update. Local commits that diverge
  from upstream/master will stop the script instead of being overwritten.
- A stash created by this script may contain untracked files. Check the stash
  if restoration reports a conflict.

Troubleshooting
---------------

Git remote not configured

Add or correct the required remotes, then verify them with git remote -v.

Homebrew dependency not found

Install the missing package with Homebrew and verify its prefix manually. For
example:

    brew install llvm lua@5.4 libsoup@2 icu4c

Build fails after an update

Read the first error reported by build.sh. Confirm that all darktable build
dependencies are installed and that the selected Homebrew packages are
compatible with the current darktable source.

Local changes are not restored

The script prints the stash reference when git stash pop cannot complete. Save
or inspect the conflicting files, then restore the stash manually, for example:

    git stash list
    git stash show --stat <stash-reference>
    git stash pop <stash-reference>

The branch cannot be fast-forwarded

The local branch and upstream/master have diverged. Inspect the differences
before deciding whether to rebase, merge, reset, or preserve the local commits.
The script intentionally does not make that decision automatically.

License
-------

This README documents the build script. The darktable project and its source
code are distributed under their own licenses. Consult the darktable
repository for the authoritative licensing information.
