# Building the SourceGit macOS Application Bundle

These instructions are for **macOS** and describe how to build a native Apple Silicon release of SourceGit, create the `.app` bundle, add the official application icon, remove the quarantine attribute, and launch the application.

The commands are intended for Macs with Apple Silicon processors, such as M1, M2, M3, or M4.

## Prerequisites

- macOS running on Apple Silicon.
- Homebrew installed and available as `brew`.
- The required Homebrew packages installed, including OpenSSL 3 and Brotli.
- The .NET SDK installed.
- The SourceGit repository cloned locally.
- A terminal opened in the repository's root directory.
- Permission to write to `/Applications`.

If OpenSSL 3 and Brotli are not installed, install them with:

```sh
brew install openssl@3 brotli
```

Verify that the project and application icon exist:

```sh
ls src/SourceGit.csproj
ls build/resources/app/App.icns
```

## 1. Set linking environment variables

Set the library and header search paths required for linking OpenSSL and Brotli installed through Homebrew:

```sh
export LIBRARY_PATH="$(brew --prefix openssl@3)/lib:$(brew --prefix brotli)/lib:$LIBRARY_PATH"
export CPATH="$(brew --prefix openssl@3)/include:$CPATH"
```

These variables apply to the current terminal session. If you open a new terminal, run these commands again before publishing the project.

## 2. Publish the native Apple Silicon binary

Publish SourceGit in `Release` mode for the `osx-arm64` runtime. The `-o` option places the published files in the explicit output directory, while `-nodeReuse:false` disables MSBuild node reuse for this build:

```sh
dotnet publish -c Release -r osx-arm64 -o build/osx-arm64/publish src/SourceGit.csproj -nodeReuse:false
```

The published files will be available in:

```text
build/osx-arm64/publish/
```

## 3. Create the `.app` bundle structure

Create the standard directories used by a macOS application bundle:

```sh
mkdir -p /Applications/SourceGit.app/Contents/MacOS
mkdir -p /Applications/SourceGit.app/Contents/Resources
```

The bundle structure will be:

```text
/Applications/SourceGit.app/
└── Contents/
    ├── Info.plist
    ├── MacOS/
    └── Resources/
```

## 4. Create `Info.plist`

Create the bundle metadata file:

```sh
cat > /Applications/SourceGit.app/Contents/Info.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>SourceGit</string>
    <key>CFBundleDisplayName</key>
    <string>SourceGit</string>
    <key>CFBundleIdentifier</key>
    <string>com.yourname.sourcegit</string>
    <key>CFBundleVersion</key>
    <string>1.0.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleExecutable</key>
    <string>SourceGit</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF
```

Replace `com.yourname.sourcegit` with a unique bundle identifier if required. For example:

```text
com.example.sourcegit
```

The `CFBundleIconFile` entry points to `AppIcon.icns` in the bundle's `Resources` directory.

## 5. Copy the published files

Copy the files from the output directory specified by the `-o` option into the bundle's `Contents/MacOS` directory:

```sh
cp -a build/osx-arm64/publish/* /Applications/SourceGit.app/Contents/MacOS/
```

## 6. Copy the official project icon

Copy the official SourceGit icon into the bundle's `Resources` directory:

```sh
cp build/resources/app/App.icns /Applications/SourceGit.app/Contents/Resources/AppIcon.icns
```

## 7. Make the binary executable

Set the execute permission on the main SourceGit binary:

```sh
chmod +x /Applications/SourceGit.app/Contents/MacOS/SourceGit
```

## 8. Remove the quarantine attribute

Remove extended quarantine attributes from the application bundle to avoid macOS displaying a “damaged” or “corrupt app” error when launching the locally built application:

```sh
xattr -cr /Applications/SourceGit.app
```

Only run this command for software you built yourself or obtained from a source you trust. Removing quarantine attributes does not sign or notarize the application.

## 9. Launch the application

Launch SourceGit with:

```sh
open /Applications/SourceGit.app
```

You can also open `/Applications` in Finder and double-click `SourceGit.app`.

## Complete command sequence

Run the following commands from the SourceGit repository's root directory:

```sh
export LIBRARY_PATH="$(brew --prefix openssl@3)/lib:$(brew --prefix brotli)/lib:$LIBRARY_PATH"
export CPATH="$(brew --prefix openssl@3)/include:$CPATH"

brew install openssl@3 brotli

dotnet publish -c Release -r osx-arm64 -o build/osx-arm64/publish src/SourceGit.csproj -nodeReuse:false

mkdir -p /Applications/SourceGit.app/Contents/MacOS
mkdir -p /Applications/SourceGit.app/Contents/Resources

cat > /Applications/SourceGit.app/Contents/Info.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>SourceGit</string>
    <key>CFBundleDisplayName</key>
    <string>SourceGit</string>
    <key>CFBundleIdentifier</key>
    <string>com.yourname.sourcegit</string>
    <key>CFBundleVersion</key>
    <string>1.0.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleExecutable</key>
    <string>SourceGit</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

cp -a build/osx-arm64/publish/* /Applications/SourceGit.app/Contents/MacOS/
cp build/resources/app/App.icns /Applications/SourceGit.app/Contents/Resources/AppIcon.icns
chmod +x /Applications/SourceGit.app/Contents/MacOS/SourceGit
xattr -cr /Applications/SourceGit.app
open /Applications/SourceGit.app
```

> Run `brew install openssl@3 brotli` only if these packages are not already installed. If they are already available, the command can be omitted.

## Verification

Validate the property list:

```sh
plutil -lint /Applications/SourceGit.app/Contents/Info.plist
```

Verify the expected bundle files:

```sh
find /Applications/SourceGit.app -maxdepth 3 -print
```

Check the architecture of the executable:

```sh
file /Applications/SourceGit.app/Contents/MacOS/SourceGit
```

On an Apple Silicon Mac, the output should indicate an `arm64` executable.

Confirm that the application icon exists:

```sh
ls -l /Applications/SourceGit.app/Contents/Resources/AppIcon.icns
```
