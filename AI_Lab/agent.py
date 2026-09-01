import os
import json
from pathlib import Path

import ollama


# ============================================================
# CONFIGURATION
# ============================================================

PROJECT_ROOT = Path(
    "/Users/draco892/Documents/GIT/Sitrade/SitradeBanking"
).resolve()

MODEL = "gemma4:26b-mlx"

MAX_FILE_SIZE = 500_000

IGNORED_DIRECTORIES = {
    ".git",
    ".venv",
    ".idea",
    ".vscode",
    "build",
    "cmake-build-debug",
    "cmake-build-release",
}

ALLOWED_EXTENSIONS = {
    ".c",
    ".cc",
    ".cpp",
    ".cxx",
    ".h",
    ".hh",
    ".hpp",
    ".hxx",
    ".cmake",
    ".txt",
    ".json",
    ".xml",
    ".ini",
    ".conf",
    ".md",
}


# ============================================================
# SECURITY
# ============================================================

def safe_path(relative_path: str) -> Path:
    """
    Converts a project-relative path into an absolute path
    and guarantees that it remains inside PROJECT_ROOT.
    """

    path = (PROJECT_ROOT / relative_path).resolve()

    try:
        path.relative_to(PROJECT_ROOT)
    except ValueError:
        raise PermissionError(
            "Access denied: path is outside the project."
        )

    return path


# ============================================================
# TOOL: LIST FILES
# ============================================================

def list_files() -> str:
    """
    Returns the files belonging to the project.
    """

    files = []

    for root, dirs, filenames in os.walk(PROJECT_ROOT):

        dirs[:] = [
            d for d in dirs
            if d not in IGNORED_DIRECTORIES
        ]

        for filename in filenames:

            path = Path(root) / filename

            if path.suffix.lower() not in ALLOWED_EXTENSIONS:
                continue

            relative = path.relative_to(PROJECT_ROOT)

            files.append(str(relative))

    files.sort()

    return "\n".join(files)


# ============================================================
# TOOL: READ FILE
# ============================================================

def read_file(relative_path: str) -> str:
    """
    Reads a project file.
    """

    path = safe_path(relative_path)

    if not path.exists():
        return f"ERROR: file does not exist: {relative_path}"

    if not path.is_file():
        return f"ERROR: not a file: {relative_path}"

    if path.stat().st_size > MAX_FILE_SIZE:
        return (
            f"ERROR: file is too large to read "
            f"({path.stat().st_size} bytes)"
        )

    try:
        content = path.read_text(
            encoding="utf-8",
            errors="replace"
        )

        return content

    except Exception as exc:
        return f"ERROR reading file: {exc}"


# ============================================================
# TOOL: SEARCH CODE
# ============================================================

def search_code(query: str) -> str:
    """
    Searches for a string in the project source files.
    """

    results = []

    for root, dirs, filenames in os.walk(PROJECT_ROOT):

        dirs[:] = [
            d for d in dirs
            if d not in IGNORED_DIRECTORIES
        ]

        for filename in filenames:

            path = Path(root) / filename

            if path.suffix.lower() not in ALLOWED_EXTENSIONS:
                continue

            try:
                text = path.read_text(
                    encoding="utf-8",
                    errors="ignore"
                )

            except Exception:
                continue

            for line_number, line in enumerate(
                text.splitlines(),
                start=1
            ):

                if query.lower() in line.lower():

                    relative = path.relative_to(
                        PROJECT_ROOT
                    )

                    results.append(
                        f"{relative}:{line_number}: "
                        f"{line.strip()}"
                    )

    if not results:
        return "No results found."

    # Prevent enormous responses
    MAX_RESULTS = 200

    if len(results) > MAX_RESULTS:
        results = results[:MAX_RESULTS]

        results.append(
            f"\n... results truncated at {MAX_RESULTS} matches."
        )

    return "\n".join(results)


# ============================================================
# TOOLS
# ============================================================

TOOLS = [
    {
        "type": "function",
        "function": {
            "name": "list_files",
            "description": (
                "List all relevant source and configuration "
                "files in the project."
            ),
            "parameters": {
                "type": "object",
                "properties": {},
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "read_file",
            "description": (
                "Read the complete contents of a project file. "
                "The path must be relative to the project root."
            ),
            "parameters": {
                "type": "object",
                "properties": {
                    "path": {
                        "type": "string",
                        "description": (
                            "Relative path of the file "
                            "inside the project."
                        ),
                    }
                },
                "required": ["path"],
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "search_code",
            "description": (
                "Search for a string, class, function, macro, "
                "error code or symbol inside the project."
            ),
            "parameters": {
                "type": "object",
                "properties": {
                    "query": {
                        "type": "string",
                        "description": "Text to search for.",
                    }
                },
                "required": ["query"],
            },
        },
    },
]


# ============================================================
# TOOL EXECUTION
# ============================================================

def execute_tool(name: str, arguments: dict) -> str:

    if name == "list_files":
        return list_files()

    if name == "read_file":
        return read_file(arguments["path"])

    if name == "search_code":
        return search_code(arguments["query"])

    return f"ERROR: unknown tool: {name}"


# ============================================================
# SYSTEM PROMPT
# ============================================================

SYSTEM_PROMPT = f"""
You are a local software engineering agent.

You are analyzing a C++/Qt project.

Project root:

{PROJECT_ROOT}

Your job is to analyze the source code accurately.

You have access to three tools:

- list_files
- search_code
- read_file

Use the tools whenever you need information about the project.

IMPORTANT:

1. Never assume that a file contains something without reading it.
2. When investigating a symbol, search for it first.
3. Read relevant files before drawing conclusions.
4. Pay attention to relationships between .h and .cpp files.
5. Analyze C++, Qt, CMake, DLL loading, memory management,
   threading, exceptions and error handling when relevant.
6. Clearly distinguish facts found in the source code from hypotheses.
7. Do not modify files.
8. Do not execute shell commands.
9. You are operating in READ-ONLY mode.

When reporting findings, mention the relevant file paths
and line numbers whenever possible.
"""


# ============================================================
# AGENT LOOP
# ============================================================

def run_agent():

    print()
    print("=" * 70)
    print("        DRACO LOCAL CODE AGENT")
    print("=" * 70)
    print()
    print(f"Model : {MODEL}")
    print(f"Root  : {PROJECT_ROOT}")
    print()
    print("READ-ONLY MODE")
    print()
    print("Commands:")
    print("  /files   -> list project files")
    print("  /quit    -> exit")
    print()

    messages = [
        {
            "role": "system",
            "content": SYSTEM_PROMPT,
        }
    ]

    while True:

        try:
            user_input = input("> ").strip()

        except (KeyboardInterrupt, EOFError):
            print()
            break

        if not user_input:
            continue

        if user_input == "/quit":
            break

        if user_input == "/files":
            print()
            print(list_files())
            print()
            continue

        messages.append(
            {
                "role": "user",
                "content": user_input,
            }
        )

        while True:

            response = ollama.chat(
                model=MODEL,
                messages=messages,
                tools=TOOLS,
            )

            message = response.message

            messages.append(message)

            # ------------------------------------------------
            # Tool calls
            # ------------------------------------------------

            if message.tool_calls:

                for tool_call in message.tool_calls:

                    name = tool_call.function.name
                    arguments = tool_call.function.arguments

                    print()
                    print(
                        f"[TOOL] {name}"
                        f"({json.dumps(arguments, ensure_ascii=False)})"
                    )

                    try:
                        result = execute_tool(
                            name,
                            arguments
                        )

                    except Exception as exc:
                        result = f"ERROR: {exc}"

                    messages.append(
                        {
                            "role": "tool",
                            "tool_name": name,
                            "content": result,
                        }
                    )

                continue

            # ------------------------------------------------
            # Final answer
            # ------------------------------------------------

            if message.content:
                print()
                print(message.content)
                print()

            break


# ============================================================
# MAIN
# ============================================================

if __name__ == "__main__":
    run_agent()