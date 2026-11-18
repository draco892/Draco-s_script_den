#!/usr/bin/env bash

# Rename JPEG files without decoding, recompressing or adding logos.
set -euo pipefail
shopt -s nullglob dotglob
export LC_ALL=C

usage() {
   printf 'Usage: %s [PREFIX [START [DIGITS]]]\n' "${0##*/}"
   printf 'Defaults: DRA_SIG26_, 1, 4\n'
   printf 'Input: current working directory. Output: ./RENAME_IMAGES/ (files are moved).\n'
   printf '\nParameters are positional:\n'
   printf '  PREFIX     Non-empty prefix without slashes.\n'
   printf '  START      Non-negative decimal integer (up to 18 digits).\n'
   printf '  DIGITS     Minimum digit count, from 1 to 18.\n'
   printf '\nExample (DRA_SIG26_0042.jpeg, DRA_SIG26_0043.jpeg, ...):\n'
   printf '  bash "%s" "DRA_SIG26_" 42 4\n' "$0"
}

parameter_error() {
   printf 'Error: %s\n\n' "$1" >&2
   usage >&2
   exit 1
}

if [ "$#" -eq 1 ] && { [ "$1" = "--help" ] || [ "$1" = "-h" ]; }; then
   usage
   exit 0
fi
if [ "$#" -gt 3 ]; then
   parameter_error 'Too many arguments; expected at most three.'
fi

prefix=${1-DRA_SIG26_}
start=${2-1}
digits=${3-4}
if [ -z "$prefix" ] || [[ "$prefix" == */* ]]; then
   parameter_error 'PREFIX must be non-empty and must not contain slashes.'
fi
# Limit numeric inputs to keep arithmetic within Bash signed 64-bit integers.
if [[ ! "$start" =~ ^[0-9]{1,18}$ ]]; then
   parameter_error 'START must be a non-negative decimal integer (up to 18 digits).'
fi
if [[ ! "$digits" =~ ^[0-9]{1,2}$ ]]; then
   parameter_error 'DIGITS must be an integer from 1 to 18.'
fi
# Explicit decimal conversion also accepts values such as 0008.
start=$((10#$start))
digits=$((10#$digits))
if [ "$digits" -lt 1 ] || [ "$digits" -gt 18 ]; then
   parameter_error 'DIGITS must be an integer from 1 to 18.'
fi

# One glob gives a single filename order across both JPEG extensions.
# Skip directories and symbolic links; include hidden regular files.
files=()
for file in ./*; do
   if [ -f "$file" ] && [ ! -L "$file" ]; then
      case "$file" in
         *.[jJ][pP][gG]|*.[jJ][pP][eE][gG]) files+=("$file") ;;
      esac
   fi
done
total=${#files[@]}
if [ "$total" -eq 0 ]; then
   printf 'No JPEG files found.\n'
   exit 0
fi

# Output is always relative to the caller's working directory, not the script.
output_dir=./RENAME_IMAGES
if [ -L "$output_dir" ] || { [ -e "$output_dir" ] && [ ! -d "$output_dir" ]; }; then
   printf 'Output path must be a directory, not a file or symlink: %s\n' "$output_dir" >&2
   exit 1
fi

# Check every destination before moving files. Existing targets, including
# dangling symlinks, must never be overwritten.
targets=()
for ((i = 0; i < total; i++)); do
   printf -v target '%s/%s%0*d.jpeg' "$output_dir" "$prefix" "$digits" "$((start + i))"
   if [ -e "$target" ] || [ -L "$target" ]; then
      printf 'Destination already exists: %s\nNo files renamed.\n' "$target" >&2
      exit 1
   fi
   targets+=("$target")
done

# Use 75% of available CPU cores, as in the logo scripts. Support macOS and
# Linux, falling back to one core when detection is unavailable.
cores=$(sysctl -n hw.ncpu 2>/dev/null || getconf _NPROCESSORS_ONLN 2>/dev/null || printf '1')
if [[ ! "$cores" =~ ^[1-9][0-9]*$ ]]; then
   cores=1
fi
jobs=$((cores * 75 / 100))
jobs=$((jobs < 1 ? 1 : jobs))
jobs=$((jobs > total ? total : jobs))
for command in mv xargs mkdir; do
   command -v "$command" >/dev/null || { printf 'Missing command: %s\n' "$command" >&2; exit 1; }
done
mkdir -p "$output_dir"

rename_one() {
   local source="$1" target="$2"
      # Exit 255 tells xargs to stop scheduling new work on failure.
      # Already-running workers can still finish; no rollback is performed.
      if ! mv -n "$source" "$target"; then
         printf 'Could not rename: %s\n' "$source" >&2
         exit 255
      fi
      if [ -e "$source" ] || [ -L "$source" ]; then
         printf 'Could not rename (source still exists): %s\n' "$source" >&2
         exit 255
      fi
      printf 'renamed\n'
}
export -f rename_one

# Assign names before starting workers, so completion order cannot change the
# numbering. NUL separators preserve spaces and newlines in filenames.
if for ((i = 0; i < total; i++)); do
   printf '%s\0%s\0' "${files[i]}" "${targets[i]}"
done | xargs -0 -n 2 -P "$jobs" bash -euo pipefail -c 'rename_one "$@"' _ | (
   # Only this reader updates progress; workers never share a counter file.
   processed=0
   renamed=0
   printf 'Processed: 0/%d' "$total"
   while IFS= read -r completion; do
      processed=$((processed + 1))
      if [ "$completion" = renamed ]; then
         renamed=$((renamed + 1))
      fi
      printf '\rProcessed: %d/%d' "$processed" "$total"
   done
   printf '\nMoved and renamed %d files into RENAME_IMAGES/.\n' "$renamed"
); then
   printf 'Done. Processed %d files using up to %d parallel jobs.\n' "$total" "$jobs"
else
   printf 'Renaming failed. Some files may already have been renamed; inspect the folder before retrying.\n' >&2
   exit 1
fi
