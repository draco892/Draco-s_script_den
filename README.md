# Draco's Script Den

```
 _____________________________
|                  _        |
|                 /"\       |
|                /o o\      |
|           _\/  \   / \/_  |
|            \\._/  /_.//   |
|            `--,  ,----'   |
|              /   /        |
|    ^        /    \        |
|   /|       (      )       |
|  / |     ,__\    /__,     |
|  \ \   _//---,  ,--\\_    |
|   \ \   /\  /  /   /\     |
|    \ \.___,/  /           |
|     \.______,/            |
|     Draco's Script Den    |
~~~~~~~~~~~~~~~~~~~~~~~~~~~~
```

> Where bash scripts roam free and automation dreams come true.

Welcome to my personal collection of scripts, tools, and digital contraptions. This is where I store everything from image manipulation wizardry to automation spells that make my computer do my bidding.

## What's This All About?

Think of this as my digital workshop—a place where I throw together scripts that solve my problems, automate boring tasks, and occasionally create something cool enough to share with the world. Whether you're here to steal some code, learn something new, or just see what weird things I've built, you're welcome!

## Project Structure

```
Draco-s_script_den/
├── AI_Lab/                      # AI-powered code analysis tools
│   ├── agent.py                 # Interactive Technical Analyst
│   ├── code_agent.py            # Automated Structural Explorer
│   ├── README.txt               # Lab Overview
│   ├── README_agent.txt         # Documentation for agent.py
│   └── README_code_agent.txt    # Documentation for code_agent.py
│
├── Image_Manipulation/          # Image processing and GIF creation
│   ├── GifCreation.bash         # Create animated GIFs from image sequences
│   ├── GifCreationSample.bash   # Legacy sample GIF creation script
│   ├── README_GifCreation.txt   # Documentation for GIF creation
│   └── README_processImageLogo.txt # Documentation for image/logo processing
│
├── build-darktable-macos-arm64.sh           # Build darktable on Apple Silicon
├── build-lightzone-macos-arm64.sh           # Build LightZone on Apple Silicon
├── build-lightzone-macos-arm64_app_build-2.sh  # Install LightZone as macOS app
├── port_self_update.sh                      # MacPorts maintenance script
│
├── README.md                        # You're reading it right now!
└── .gitignore                       # Keeping the repo clean, one file at a time
```

## What's Inside?

### AI Lab

The `AI_Lab/` directory contains experimental AI agents that leverage Local LLMs (via Ollama) to interact with and analyze your codebases.

- **agent.py**: An interactive, "expert-mode" agent designed for deep-dive technical analysis. It is optimized for navigating C++/Qt projects, searching for specific symbols, and understanding code relationships.
- **code_agent.py**: A lightweight, automated utility designed for structural exploration, using pattern-based searching to map out project hierarchies.

### Image Manipulation

The `Image_Manipulation/` directory contains scripts and documentation for working with images and creating animated GIFs.

- **GifCreation.bash**: Create animated GIFs from sequences of images using ffmpeg. Perfect for making tutorials, memes, or capturing animations.
- **GifCreationSample.bash**: A legacy one-liner sample script showing basic GIF creation with ffmpeg.
- **README_GifCreation.txt**: Detailed documentation on how to create GIFs from image sequences, including parameter explanations and usage examples.
- **README_processImageLogo.txt**: Documentation for image processing workflows, including logo manipulation and batch image operations.

### Build Scripts

These scripts automate the compilation and installation of open-source photography software on macOS Apple Silicon.

- **build-darktable-macos-arm64.sh**: Updates the darktable repository from upstream, synchronizes your fork, and builds a development version of darktable with LLVM and Homebrew dependencies. Includes automatic stash/restore of local changes.
- **build-lightzone-macos-arm64.sh**: Builds the LightZone photo editor using Java 21 and Homebrew dependencies. Cleans, compiles (excluding tests), and creates JAR artifacts.
- **build-lightzone-macos-arm64_app_build-2.sh**: Creates a macOS application bundle from the LightZone build and installs it into `/Applications`. Prompts before replacing existing installations and can launch the app after installation.

### System Maintenance

- **port_self_update.sh**: Keeps MacPorts up to date by refreshing the ports tree, upgrading outdated packages, and removing inactive ports. Provides colored output and fail-fast error handling for safe system maintenance.

## How to Use This Madness

### Prerequisites

- A Unix-like system (macOS, Linux, WSL)
- `bash` (shocking, I know)
- `ffmpeg` for the image manipulation goodies
- `git` for version control operations
- `sudo` access for system-level scripts
- A sense of adventure (optional but recommended)

### Quick Start

```bash
# Clone the repo
git clone https://github.com/draco892/Draco-s_script_den.git
cd Draco-s_script_den

# Make scripts executable
chmod +x *.sh Image_Manipulation/*.bash

# Run a script
./Image_Manipulation/GifCreation.bash
```

## Documentation

Each script comes with its own README or comments. Check these out:

- [`README_GifCreation.txt`](Image_Manipulation/README_GifCreation.txt) - Everything about making GIFs
- [`README_processImageLogo.txt`](Image_Manipulation/README_processImageLogo.txt) - Logo and image processing tips
- Build script READMEs in the repository root for darktable, LightZone, and MacPorts maintenance

## Contributing

Found a bug? Have an idea for improvement? Want to add your own script to the den?

1. Fork the repo
2. Create your feature branch (`git checkout -b feature/AmazingNewScript`)
3. Commit your changes (`git commit -m 'Add some amazing script'`)
4. Push to the branch (`git push origin feature/AmazingNewScript`)
5. Open a Pull Request

I'm always happy to see new scripts, improvements, or even just someone telling me my code is terrible (with suggestions, please!).

## License

Do whatever you want with this stuff. Break it, fix it, improve it, share it. Just don't blame me if your computer starts speaking in binary.

## Acknowledgments

- Thanks to all the open-source heroes whose code I've shamelessly borrowed
- Coffee, for making all of this possible
- Cruciani to make me listen more and more idiots while I listen to the Zanzara everyday 
- You, for reading this far

## Contact

- **GitHub**: [@draco892](https://github.com/draco892)
- **Issues**: [Open an issue](https://github.com/draco892/Draco-s_script_den/issues) if something breaks

---

```
  _________________________________________________
 / Made with code, caffeine and Zanzara by draco892\
 \_________________________________________________/
        \   
         \  __ \/_
           (' \`\
        _\, \ \\/
         /`\/\ \\
              \ \\
               \ \\/\/_
               /\ \\'\
             __\ `\\\
              /|`  `\\
                     \\
                      \\
                       \\    ,
                        `---'
```
