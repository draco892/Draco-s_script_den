======================================================
    JPEG RENAMING WITH SUFFIX - QUICK START GUIDE
======================================================

renameImagesWithSuffix.sh reads JPEG files from the current working directory and moves
them, renamed, into RENAME_IMAGES/ inside that same working directory.
The script location does not determine where the output folder is created.
Files are moved, not copied: they no longer remain in the source folder.
The filename format is PREFIX + padded number + SUFFIX + .jpeg.
For the version without a suffix parameter, see README_renameImages.txt.
Both versions share RENAME_IMAGES/ and refuse to overwrite existing targets.
No logos are added. Image contents and embedded metadata remain unchanged;
images are not decoded or recompressed.

------------------------------------------------------
1. PREREQUISITES
------------------------------------------------------
- Bash (available on macOS and Linux)
- Standard Unix utilities: mv, xargs, mkdir
- CPU detection: sysctl on macOS or getconf on Linux (one-core fallback)

ImageMagick, bc and logo assets are not required.

------------------------------------------------------
2. HOW TO RUN
------------------------------------------------------
Open a terminal, navigate to the folder containing the photos, and run:

  cd "/path/to/photos"
  bash "/path/to/Draco-s_script_den/Image_Manipulation/renameImagesWithSuffix.sh"

Replace the example paths with your own. Output is created automatically in
/path/to/photos/RENAME_IMAGES/. With default settings, names become:

  DRA_SIG26_0001.jpeg
  DRA_SIG26_0002.jpeg
  DRA_SIG26_0003.jpeg

To execute the script directly, first make it executable:

  chmod +x "/path/to/Draco-s_script_den/Image_Manipulation/renameImagesWithSuffix.sh"

------------------------------------------------------
3. CONFIGURABLE PARAMETERS
------------------------------------------------------
Usage:

  renameImagesWithSuffix.sh [PREFIX [START [DIGITS [SUFFIX]]]]

Parameters are positional. To change a later parameter, also supply all
preceding parameters.

- PREFIX: Filename prefix. Default: DRA_SIG26_
  Must be non-empty and must not contain / characters.
- START: First number. Default: 1.
  Must be a non-negative decimal integer, with up to 18 digits.
- DIGITS: Minimum digit count, padded with zeros. Default: 4.
  Must be an integer from 1 to 18. Larger numbers are not truncated.

- SUFFIX: Text appended after the number and before .jpeg. Default: empty.
  Must not contain / characters. Include separators explicitly: _OPENING
  produces DRA_SIG26_0042_OPENING.jpeg; OPENING produces DRA_SIG26_0042OPENING.jpeg.

Leading zeros in numeric parameters are interpreted as decimal values.

From the photo folder, use prefix DRA_SIG26_, start at 42, pad to four digits
and append the suffix _OPENING:

  bash "/path/to/Draco-s_script_den/Image_Manipulation/renameImagesWithSuffix.sh" "DRA_SIG26_" 42 4 "_OPENING"

Result inside RENAME_IMAGES/:

  DRA_SIG26_0042_OPENING.jpeg
  DRA_SIG26_0043_OPENING.jpeg
  DRA_SIG26_0044_OPENING.jpeg

Example: use a custom prefix and six digits, starting at 100, without a suffix:

  bash "/path/to/Draco-s_script_den/Image_Manipulation/renameImagesWithSuffix.sh" "EVENT_" 100 6

Result inside RENAME_IMAGES/: EVENT_000100.jpeg, EVENT_000101.jpeg, etc.

------------------------------------------------------
4. WHAT HAPPENS?
------------------------------------------------------
- Finds .jpg and .jpeg files with any capitalization, including hidden files.
- Processes regular files only; skips symbolic links and subfolders.
- Assigns consecutive numbers in filename order using the C locale.
  This is lexical order, not capture-date order or natural numeric order.
- Normalizes all matching extensions to .jpeg without changing file contents.
- Handles spaces, special characters and leading hyphens in filenames.
- Creates RENAME_IMAGES/ inside the current working directory automatically
  when JPEG files are found. Reuses an existing directory; rejects a file or
  symbolic link at that path.
- Checks every destination inside RENAME_IMAGES/ before moving any files.
  Existing destinations, including dangling symbolic links, cause it to stop.
- Renames in parallel using 75% of detected CPU cores (rounded down), with
  at least one job and no more jobs than files. Detection falls back to one
  core if unavailable. Names are assigned before workers start, so completion
  order does not affect numbering.
- A single reader displays processed and total counts, followed by a summary.
- Exits successfully when no JPEG files are found.

Do not modify the folder while the script runs. An interruption or filesystem
error may leave some files already renamed. On a worker error, no new jobs are
scheduled, but active workers may still finish. There is no automatic rollback.

------------------------------------------------------
5. HELP AND TROUBLESHOOTING
------------------------------------------------------
Display usage instructions, parameter descriptions and an example:

  bash "/path/to/Draco-s_script_den/Image_Manipulation/renameImagesWithSuffix.sh" --help

- Invalid parameters: The script prints the error and usage guide, then exits
  with status 1 before moving any files. This includes too many arguments.
- "No JPEG files found": Check the current working directory and file extensions.
  Subfolders are not searched.
- "Destination already exists": No files have been renamed. Choose a
  different prefix or starting number, or resolve conflicts in RENAME_IMAGES/.
- A filesystem error or interruption during renaming: Inspect the folder
  and RENAME_IMAGES/ before retrying, because some files may already have moved.

------------------------------------------------------
License
------------------------------------------------------

MIT license
