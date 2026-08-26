GIF Creation Sample
===================

A simple Bash script that creates an animated GIF from a sequence of JPEG images using FFmpeg.

Requirements
------------

- Bash or a compatible POSIX-style shell
- FFmpeg installed and available in your PATH
- JPEG images stored in a directory named PHOTOS

On macOS, FFmpeg can be installed with Homebrew:

    brew install ffmpeg

Directory Structure
-------------------

The script expects the input images to be located in PHOTOS/ relative to the current working directory:

    .
    ├── GifCreationSample.bash
    └── PHOTOS/
        ├── image-001.jpeg
        ├── image-002.jpeg
        └── image-003.jpeg

The images are read in the order determined by FFmpeg's glob pattern. Use filenames with a consistent naming scheme and zero-padded numbers when the order matters.

Usage
-----

From the directory containing the script and the PHOTOS directory, run:

    bash GifCreationSample.bash

The script generates:

    Dancing_Lion.gif

You can also make the script executable and run it directly:

    chmod +x GifCreationSample.bash
    ./GifCreationSample.bash

How It Works
------------

The script runs the following FFmpeg command:

    ffmpeg -framerate 10 -pattern_type glob -i "PHOTOS/*.jpeg" \
      -vf "scale=1280:-1:flags=lanczos,fps=10,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" \
      Dancing_Lion.gif

- -framerate 10 reads the input images at 10 frames per second.
- -pattern_type glob -i "PHOTOS/*.jpeg" selects all .jpeg files in the PHOTOS directory.
- scale=1280:-1 scales the output width to 1280 pixels while preserving the aspect ratio.
- flags=lanczos uses high-quality Lanczos scaling.
- fps=10 sets the output frame rate to 10 frames per second.
- palettegen generates an optimized 256-color palette for the GIF.
- paletteuse applies the generated palette to improve color quality.
- Dancing_Lion.gif is the output file.

Customization
-------------

Change the frame rate
---------------------

Replace both occurrences of 10 with the desired frame rate. For example, for 5 frames per second:

    ffmpeg -framerate 5 -pattern_type glob -i "PHOTOS/*.jpeg" \
      -vf "scale=1280:-1:flags=lanczos,fps=5,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" \
      Dancing_Lion.gif

Change the output size
----------------------

Replace 1280 with the desired width:

    scale=1920:-1

The height remains proportional to the original images.

Use a different input format
----------------------------

For PNG images, change the input pattern to:

    PHOTOS/*.png

For mixed image extensions, use multiple inputs or adapt the command to your preferred filename pattern.

Change the output filename
--------------------------

Replace Dancing_Lion.gif with the desired output path and filename.

Notes
-----

- The command currently matches lowercase .jpeg files only.
- Make sure the input images have compatible dimensions and orientation.
- Running the command again may overwrite the existing output file; FFmpeg may ask for confirmation.
- GIF files can become large. Lowering the frame rate or output width can reduce the file size.

License
-------

MIT license