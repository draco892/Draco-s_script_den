# Image Manipulation

Utilities for renaming JPEG files, adding logos and creating animated GIFs.

| Script | Purpose | Guide |
| --- | --- | --- |
| `renameImages.sh` | Move and rename JPEG files into RENAME_IMAGES/ | [JPEG renaming guide](README_renameImages.txt) and instructions below |
| `renameImagesWithSuffix.sh` | Same parallel workflow with a configurable filename suffix | [JPEG renaming with suffix guide](README_renameImagesWithSuffix.txt) |
| `processImageLogo.sh` | Apply a white logo with adaptive sizing | [Logo guide](README_processImageLogo.txt) |
| `processImageLogo_transparent.sh` | Apply a single logo with 50% opacity | [Transparent logo guide](README_processImageLogo_transparent.txt) |
| `processImageEventLogo_transparent.sh` | Apply two event logos and a separator | [Event logo guide](README_processImageEventLogo_transparent.txt) |
| `GifCreation.bash` | Create animated GIFs using ffmpeg | [GIF guide](README_GifCreation.txt) |

## Rename JPEG files without logos

`renameImages.sh` reads JPEG files from the current working directory and moves
them, with their new names, into `RENAME_IMAGES/`, created inside that same
working directory. The script location does not determine the output location.
Files are moved, not copied: they no longer remain in the source folder.
The script does not add logos, decode images or recompress them: image contents and
embedded metadata remain unchanged. It requires Bash and the standard `mv`,
`xargs` and `mkdir` utilities, available on macOS and Linux; ImageMagick and `bc` are
not required. CPU detection uses `sysctl` on macOS or `getconf` on Linux,
falling back to one core if detection is unavailable.

```text
Usage: renameImages.sh [PREFIX [START [DIGITS]]]
```

| Parameter | Default | Meaning |
| --- | --- | --- |
| `PREFIX` | `DRA_SIG26_` | Non-empty filename prefix without `/` characters |
| `START` | `1` | First number, non-negative decimal integer, up to 18 digits |
| `DIGITS` | `4` | Minimum number of digits, from 1 to 18, padded with zeros |

Parameters are positional. To change a later parameter, also supply the preceding
ones. Leading zeros in numeric parameters are accepted as decimal values.
Invalid parameters display an error, usage instructions, parameter descriptions and an example, then exit
with status 1 before renaming any files. Use `--help` for the same usage guide.

```bash
# Run from the folder containing the photos.
cd "/path/to/photos"

# Default output: RENAME_IMAGES/DRA_SIG26_0001.jpeg, ...
bash "/path/to/Draco-s_script_den/Image_Manipulation/renameImages.sh"

# Custom prefix, starting at 42, with six digits: EVENT_000042.jpeg, ...
bash "/path/to/Draco-s_script_den/Image_Manipulation/renameImages.sh" "EVENT_" 42 6

# Run from the photo folder, starting at 100 with four digits.
cd "/path/to/photos"
bash "/path/to/Draco-s_script_den/Image_Manipulation/renameImages.sh" "DRA_SIG26_" 100 4
```

- Matches `.jpg` and `.jpeg` with any capitalization, including hidden files.
- Processes only regular files in that folder; skips symlinks and subfolders.
- Assigns numbers in filename order using the C locale. The order is lexical,
  not chronological or natural numeric order.
- Normalizes the extension to `.jpeg` without changing file contents.
- The digit count is a minimum width: numbers that exceed it are not truncated.
- Supports spaces, special characters and leading hyphens in filenames.
- Checks all destination names before renaming. If a destination already
  exists inside `RENAME_IMAGES/`, it stops without moving any files. Choose
  another prefix or starting number, or resolve the conflicting names.
- Creates `RENAME_IMAGES/` automatically when JPEG files are found. An existing
  output directory is reused; a file or symlink at that path is rejected.
- Renames in parallel using 75% of detected cores (rounded down), with at least
  one job and at most as many jobs as files. Names are assigned before workers
  start, preserving filename order regardless of completion order.
- A single reader shows processed and total counts. An empty folder exits successfully.

Do not modify the folder while the script runs. An interruption or filesystem
error can leave some files already renamed; the script does not roll them back.
On a worker error, no new jobs are scheduled, but active workers may still finish.
Use `--help` to display usage.

## Rename JPEG files with a suffix

`renameImagesWithSuffix.sh` adds a fourth positional parameter, `SUFFIX`, while
keeping the same defaults for prefix, starting number and digit count:

```text
Usage: renameImagesWithSuffix.sh [PREFIX [START [DIGITS [SUFFIX]]]]
```

```bash
cd "/path/to/photos"
bash "/path/to/Draco-s_script_den/Image_Manipulation/renameImagesWithSuffix.sh" "DRA_SIG26_" 42 4 "_OPENING"
```

The resulting names are `RENAME_IMAGES/DRA_SIG26_0042_OPENING.jpeg`,
`RENAME_IMAGES/DRA_SIG26_0043_OPENING.jpeg`, etc. The suffix is inserted exactly
as supplied, after the padded number and before `.jpeg`: include `_` explicitly
if desired. It defaults to empty and must not contain `/` characters.

This version also moves the source JPEG files into `RENAME_IMAGES/` inside the
current working directory, uses parallel jobs based on 75% of detected cores,
checks all destinations before moving files, and shows usage on invalid
parameters. Both versions share the output folder and refuse to overwrite
existing targets. See the [dedicated guide](README_renameImagesWithSuffix.txt)
for requirements, examples and troubleshooting.
