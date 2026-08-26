=====================================================
    IMAGE LOGO PROCESSING - QUICK START GUIDE
=====================================================

This script automatically applies a white logo watermark to all .jpeg images in the current directory. It scales the logo automatically based on the size of the image.

------------------------------------------------------
1. PREREQUISITES
------------------------------------------------------
You must have the following tools installed:
- ImageMagick (ensure 'magick' command is available)
- bc (for mathematical calculations)
- Standard Unix utilities (xargs, sysctl, mktemp)

------------------------------------------------------
2. DIRECTORY SETUP
------------------------------------------------------
To ensure the script works correctly, organize your folders like this:

. (Current Folder)
├── processImageLogo.sh
├── [Your .jpeg files here]
└── Draco_logo/
    └── logo_White.png

Note: The script expects the logo to be found at 
../../Draco_logo/logo_White.png relative to the script's run location.

------------------------------------------------------
3. HOW TO RUN
------------------------------------------------------
1. Open your terminal.
2. Navigate to the folder containing the script and images.
3. Make the script executable:
   chmod +x processImageLogo.sh
4. Run the script:
   ./processImageLogo.sh

------------------------------------------------------
4. WHAT HAPPENS?
------------------------------------------------------
- The script detects your CPU cores and starts parallel processing.
- Each image is resized/scaled so the logo is proportional (1/12th of the diagonal).
- The logo is placed in the Bottom-Right (SouthEast) corner.
- Finished images will appear in a new folder named 'WITH_LOGO'.
- Filenames will be renamed to: DRA_FUR26_####.jpeg

------------------------------------------------------
5. TROUBLESHOOTING
------------------------------------------------------
- "No .jpeg files found": Ensure your files end exactly in .jpeg (not .jpg).
- "Command not found": Ensure ImageMagick and 'bc' are installed.
- "Invalid Number": Ensure your system's LC_NUMERIC is set to 'C' (handled by script).

------------------------------------------------------
License
------------------------------------------------------

MIT license
