LIGHTWEIGHT CODE EXPLORER AGENT

A functional, tool-using utility designed to automate the process of navigating and inspecting a project's directory structure using an LLM. This script is more specialized toward pattern-based file searching and directory traversal.

FEATURES
- Pattern-Based Search: Uses glob patterns (e.g., *.cpp, *.h) to find files across the project hierarchy.
- Directory Navigation: Can list directory contents to help the LLM understand the project structure.
- Automated Reasoning: The script runs a single-shot conversation where the LLM uses tools to gather information until it reaches a final conclusion.
- Safe Path Traversal: Ensures all file access remains within the project's base directory.

TOOLS
The agent uses these specific tools:
- read_file: Retrieves the text content of a file.
- list_directory: Lists the names of files and folders within a specific path.
- search_files: Locates files that match a specific naming pattern (e.g., *.hpp).

CONFIGURATION
To use this script, ensure the following:
- BASE_DIR is correctly pointed to your project root.
- The MODEL variable matches a model available in your local Ollama instance (e.g., gemma4:12b-mlx).

PREREQUISITES
- Ollama installed and running.
- Python 3.x with ollama library installed (pip install ollama).
