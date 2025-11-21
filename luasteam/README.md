# luasteam Platform-Aware Setup

This directory contains the luasteam library binaries for multiple platforms and a platform detection system that automatically loads the correct library.

## Library Files

The following platform-specific libraries are included:

- `win32_luasteam.dll` - Windows 32-bit
- `win64_luasteam.dll` - Windows 64-bit
- `linux32_luasteam.so` - Linux 32-bit
- `linux64_luasteam.so` - Linux 64-bit
- `osx_luasteam.so` - macOS (64-bit)

## Platform Detection

The `platform.lua` module automatically detects:
- **Operating System**: Windows, Linux, or macOS
- **Architecture**: 32-bit or 64-bit

Detection uses:
1. Love2D's `love.system.getOS()` API (primary method)
2. LuaJIT's `jit.os` and `jit.arch` (fallback)

## Usage

Simply require luasteam as you normally would:

```lua
local luasteam = require("luasteam")
```

The loader will automatically:
1. Detect your platform and architecture
2. Load the correct library file
3. Return the luasteam module

## Example

```lua
function love.load()
    -- Load luasteam (automatically detects platform)
    local luasteam = require("luasteam")
    
    -- Initialize Steam
    if luasteam.init() then
        print("Steam initialized successfully!")
    else
        print("Failed to initialize Steam")
    end
end

function love.update(dt)
    -- Run Steam callbacks
    if luasteam then
        luasteam.runCallbacks()
    end
end

function love.quit()
    -- Shutdown Steam
    if luasteam then
        luasteam.shutdown()
    end
end
```

## Platform Detection API

You can also use the platform detection module directly:

```lua
local platform = require("luasteam.platform")

print("OS:", platform.getOS())           -- "windows", "linux", or "osx"
print("Arch:", platform.getArch())       -- "32" or "64"
print("Platform:", platform.getPlatformString())  -- "win64", "linux64", "osx"
print("Supported:", platform.isSupported())       -- true or false
```

## Error Handling

If the library cannot be loaded, an error will be thrown with detailed information:
- Platform detection results
- Library file path attempted
- Specific error message

## Requirements

- Love2D 11.0 or higher
- SteamWorks SDK (must be downloaded separately and placed in your project)
- Appropriate SteamWorks library for your platform (e.g., `steam_api.dll` for Windows, `libsteam_api.so` for Linux)

## Notes

- The library files must remain in the `luasteam/` directory
- Make sure you have the corresponding SteamWorks SDK library in your project root
- On Linux, you may need to set `LD_LIBRARY_PATH` if libraries aren't found automatically

## Packaging for Distribution

When packaging your Love2D game as a `.love` file, note that native libraries (`.dll`, `.so`) cannot be inside the `.love` archive. They must be placed in the same directory as the `.love` file or the Love2D executable.

For distribution, you have two options:

1. **Fused Executable**: When creating a fused executable, include the `luasteam/` directory alongside the executable
2. **Separate .love file**: Place the `luasteam/` directory in the same folder as your `.love` file

The loader will automatically find the libraries using `love.filesystem.getSource()`.

