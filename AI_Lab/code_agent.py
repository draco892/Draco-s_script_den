from pathlib import Path
from ollama import chat

# Radice del progetto: due livelli sopra rispetto a .ai_agent/code_agent.py
BASE_DIR = Path(__file__).resolve().parent.parent
# In alternativa, esplicito:
# BASE_DIR = Path("/Users/draco892/Documents/GIT/Sitrade/SitradeBanking").resolve()

def safe_path(p: str) -> Path:
    path = (BASE_DIR / p).resolve()
    if not path.is_relative_to(BASE_DIR):
        raise ValueError("Percorso fuori dalla base consentita")
    return path

def read_file(path: str) -> str:
    return safe_path(path).read_text(encoding="utf-8")

def list_directory(path: str = ".") -> list[str]:
    root = safe_path(path)
    return [f"{('[DIR] ' if e.is_dir() else '[FILE] ') + e.name}" for e in root.iterdir()]

def search_files(path: str = ".", pattern: str = "*.cpp") -> list[str]:
    import fnmatch
    root = safe_path(path)
    matches = []
    for p in root.rglob("*"):
        if fnmatch.fnmatch(p.name, pattern):
            matches.append(str(p.relative_to(BASE_DIR)))
    return matches

tools = [
    {
        "type": "function",
        "function": {
            "name": "read_file",
            "description": "Legge il contenuto di un file di testo all'interno del progetto.",
            "parameters": {
                "type": "object",
                "properties": {
                    "path": {
                        "type": "string",
                        "description": "Percorso relativo del file rispetto alla radice del progetto."
                    }
                },
                "required": ["path"]
            }
        }
    },
    {
        "type": "function",
        "function": {
            "name": "list_directory",
            "description": "Lista il contenuto di una directory nel progetto.",
            "parameters": {
                "type": "object",
                "properties": {
                    "path": {
                        "type": "string",
                        "description": "Percorso relativo della directory."
                    }
                },
                "required": []
            }
        }
    },
    {
        "type": "function",
        "function": {
            "name": "search_files",
            "description": "Cerca file nel progetto per pattern (es. '*.cpp', '*.h').",
            "parameters": {
                "type": "object",
                "properties": {
                    "path": {
                        "type": "string",
                        "description": "Directory da cui partire."
                    },
                    "pattern": {
                        "type": "string",
                        "description": "Pattern di ricerca (es. '*.cpp')."
                    }
                },
                "required": ["pattern"]
            }
        }
    },
]

available_tools = {
    "read_file": read_file,
    "list_directory": list_directory,
    "search_files": search_files,
}

messages = [
    {
        "role": "user",
        "content": (
            "Sei un assistente per analizzare codice C++ in un progetto. "
            "Puoi usare read_file, list_directory e search_files. "
            "Analizza la struttura del progetto e dimmi quali sono i file e le directory principali."
        )
    }
]

MODEL = "gemma4:12b-mlx"  # o un altro modello che vedi in `ollama list`

while True:
    response = chat(
        model=MODEL,
        messages=messages,
        tools=tools,
    )

    messages.append(response.message)

    if not response.message.tool_calls:
        print("Risposta finale:", response.message.content)
        break

    for tc in response.message.tool_calls:
        fn_name = tc.function.name
        fn_args = tc.function.arguments or {}
        fn = available_tools[fn_name]
        result = fn(**fn_args)
        messages.append({
            "role": "tool",
            "tool_name": fn_name,
            "content": str(result),
        })