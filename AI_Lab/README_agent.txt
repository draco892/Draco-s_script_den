DRACO LOCAL CODE AGENT

A sophisticated, interactive, and read-only local AI agent designed for deep technical analysis of C++/Qt software projects. This agent acts as a virtual software engineer that can explore your codebase, search for specific symbols, and understand complex relationships between files.

FEATURES
- Deep Code Analysis: Optimized for C++, Qt, CMake, and memory management investigation.
- Interactive Shell: An interactive terminal session that allows you to chat with the agent and use built-in commands.
- Tool-Augmented Intelligence: The agent uses a set of specialized tools to interact with your local file system.
- Security First: 
    - Path Sandboxing: Prevents the agent from accessing files outside of the designated PROJECT_ROOT.
    - Read-Only Mode: Explicitly instructed to never modify files or execute shell commands.
    - File Size Protection: Limits reading to files under a specific threshold to prevent memory issues.

TOOLS
The agent has access to the following tools:
- list_files: Recursively lists all relevant source and configuration files in the project.
- read_file: Reads the content of a specific file (relative to the project root).
- search_code: Performs a string-based search across all files to find specific classes, functions, or macros.

CONFIGURATION
Before running, you must configure the following constants in the script:
- PROJECT_ROOT: The absolute path to your C++ project.
- MODEL: The Ollama model you wish to use (default is gemma4:26b-mlx).
- ALLOWED_EXTENSIONS: A whitelist of file types the agent is permitted to see.

COMMANDS
While in the interactive session, you can use:
- /files: Instantly list all project files.
- /quit: Exit the agent session.

PREREQUISITES
- Ollama installed and running.
- Python 3.x with ollama library installed (pip install ollama).
- A local model (e.g., gemma4:26b-mlx) available via Ollama.
