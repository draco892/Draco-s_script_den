# SourceGit

SourceGit is a powerful tool for managing and interacting with source code, designed to provide a seamless experience for developers.

## Development and Build

This section provides instructions for building and publishing the SourceGit application, specifically targeting macOS with Apple Silicon.

### Prerequisites

- macOS (Apple Silicon)
- Homebrew
- .NET SDK
- OpenSSL 3 and Brotli (via Homebrew)

### Building and Publishing

To build and publish the application for macOS:

```sh
export LIBRARY_PATH="$(brew --prefix openssl@3)/lib:$(brew --prefix brotli)/lib:$LIBRARY_PATH"
export CPATH="$(brew --prefix openssl@3)/include:$CPATH"

brew install openssl@3 brotli

dotnet publish -c Release -r osx-arm64 -o build/osx-arm64/publish src/SourceGit.csproj -nodeReuse:false
```

### Creating the Application Bundle

Follow the detailed instructions in [sourcegit-mac-app-bundle.md](sourcegit-mac-app-bundle.md) to create a native `.app` bundle for macOS.

## Running SourceGit

To run SourceGit in development mode, use:

```sh
dotnet run --project src/SourceGit.csproj
```

For general commands, refer to `sourcegit_run_command_original.txt`.
