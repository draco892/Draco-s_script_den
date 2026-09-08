=====================================================
    IMAGE LOGO PROCESSING (TRANSPARENT) - QUICK START
=====================================================

This script automatically applies a white logo watermark with transparency to all .jpeg images in the current directory. It uses an intelligent scaling system to maintain visual consistency across varying image proportions.

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
├── processImageLogo_transparent.sh
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
   chmod +x processImageLogo_transparent.sh
4. Run the script:
   ./processImageLogo_transparent.sh

------------------------------------------------------
4. WHAT HAPPENS?
------------------------------------------------------
- Parallel Processing: Detects CPU cores and optimizes workload.
- Intelligent Scaling:
    - Extreme Panoramas (Aspect Ratio > 3:1): Scaled to 1/6th of the image height.
    - Vertical Images (Aspect Ratio < 1): Scaled to ~8% of the diagonal.
    - Regular/Square Images: Scaled to ~6% of the diagonal (reduced by 30%).
- Visuals: The logo is placed in the Bottom-Right (SouthEast) corner with 50% opacity.
- Output: Finished images appear in a 'WITH_LOGO' folder.
- Filenames: Renamed to DRA_SIG26_####.jpeg

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
`