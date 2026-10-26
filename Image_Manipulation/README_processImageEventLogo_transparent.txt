======================================================
    EVENT LOGO PROCESSING (TRANSPARENT) - QUICK START
======================================================

processImageEventLogo_transparent.sh applies two logos side by side to all
.jpeg images in the current working directory. A white vertical separator
divides the logos, and the entire group is placed in the bottom-right corner.

------------------------------------------------------
1. PREREQUISITES
------------------------------------------------------

- macOS and Bash. Run the script with bash, not sh.
- ImageMagick with the 'magick' command available in PATH.
- bc for scaling calculations.
- Standard utilities: xargs and sysctl. CPU detection uses 'sysctl -n hw.ncpu'.
- Readable logo files at the paths configured in the script.

------------------------------------------------------
2. LOGO CONFIGURATION
------------------------------------------------------

Edit these variables near the beginning of the script:

LOGO_OPACITY=0.75
LOGO_1="/Users/draco892/Pictures/Logo/GH_logo/26/GH26_Logo.png"
LOGO_2="/Users/draco892/Pictures/Logo/Draco_logo/logo_White.png"

- LOGO_1: GH26, displayed on the left.
- LOGO_2: Draco, displayed on the right.
- LOGO_OPACITY: one multiplier applied to the alpha channel of both logos
  and the separator. 0.75 means 75% opacity (25% transparency); 0 makes
  the group invisible, and 1 preserves the original opacity of its pixels.

The logos use absolute paths, so they do not need to be copied into the
photo directory. Change LOGO_1 and LOGO_2 when using different locations.

------------------------------------------------------
3. HOW TO RUN
------------------------------------------------------

Open a terminal, change to the directory containing your photos, then run:

cd "/path/to/photos"
bash "/Users/draco892/Documents/GIT/Draco-s_script_den/Image_Manipulation/processImageEventLogo_transparent.sh"

Adjust the script path if the repository is stored elsewhere.
The script takes no command-line arguments: it processes the current
working directory, even when the script itself is stored in another folder.

Only files matching *.jpeg are selected. Files ending in .jpg or uppercase
extensions are not selected, and subdirectories are not searched.
Filenames containing spaces are supported.

------------------------------------------------------
4. LAYOUT AND SCALING
------------------------------------------------------

Both logos are centered in identical square panels. The panel size depends
on the photo dimensions:

- Extreme panoramas (width / height > 3): photo height / 6.
- Portrait images (width / height < 1): photo diagonal * 0.80 / 10.
- Landscape and square images (1 <= width / height <= 3):
  photo diagonal * 0.70 / 12.

The resulting size is rounded to an integer, with a minimum of 1 pixel.
Transparent outer margins are trimmed from each logo before resizing, so
different amounts of empty PNG canvas do not affect the visible logo size.
The original PNG files are not modified.

Each logo retains its aspect ratio and fits within its square panel, with
its longest visible dimension equal to the panel size. Both are centered
horizontally and vertically, giving the current GH26 and Draco artwork
approximately the same visible width and height.

The separator is as tall as the panels and sits exactly at the horizontal
center of the assembled group. Identical panels and equal gaps on each
side keep the layout balanced. Each gap is panel size / 8, and separator
width is panel size / 80, both with a minimum of 1 pixel.

The assembled group is resized to 50% of its calculated width and height,
halving both logos, the gaps and the separator together. To change this
overall scale, edit '-resize 50%' immediately after '+append' in the script.
The group is reduced further if necessary to fit the photo, then placed
10 pixels from the right and bottom edges.

------------------------------------------------------
5. OUTPUT AND PROGRESS
------------------------------------------------------

Output is saved in WITH_EVENT_LOGO inside the current working directory:

photos/
├── photo one.jpeg
├── photo two.jpeg
└── WITH_EVENT_LOGO/
    ├── DRA_EVENT_SIG26_001.jpeg
    └── DRA_EVENT_SIG26_002.jpeg

Original photos are preserved. Output numbering follows the shell's input
file order and starts at 001 on every run. Existing output files with the
same names are overwritten; numbering uses at least three digits.

The script uses 75% of the detected CPU cores, rounded down, with at least
one parallel worker. Each ImageMagick processing command uses one thread.

A 40-character progress bar updates on the same terminal line, showing
percentage, completed images ('processed') and remaining images ('left').
The count advances only after an output image has been saved successfully.
A single reader counts completion events from all parallel workers.

At the end of a successful run, the script prints the total number of
processed images and parallel jobs. A processing failure returns a nonzero
exit status and prevents the final success message.

------------------------------------------------------
6. TROUBLESHOOTING
------------------------------------------------------

- "No .jpeg files found.": check the current directory and file extensions.
  The script exits successfully when there are no matching files.
- "Missing command: magick" or "Missing command: bc": ensure the named
  dependency is installed and available in PATH.
- "Cannot read logo: ...": correct the configured path or file permissions.
- "sysctl: unknown oid 'hw.ncpu'": the CPU detection command targets macOS.
- An ImageMagick error: check that the input image and logos are valid.
  Outputs already completed by other workers remain in WITH_EVENT_LOGO.
- Decimal formatting: LC_NUMERIC=C is set by the script so calculations
  consistently use dots as decimal separators.
