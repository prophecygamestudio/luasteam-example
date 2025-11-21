# luasteam Library Documentation

## Overview

luasteam provides Lua bindings for the Steamworks API, enabling Steam integration in Lua-based games and applications (particularly Love2D projects).

## Official Documentation

**Primary Resource**: https://luasteam.readthedocs.io

The official documentation includes:
- Getting Started guide
- Complete API reference
- Function signatures and parameters
- Callback documentation
- Code examples

## Quick Start Guide

### 1. Basic Integration

```lua
-- Load luasteam (platform detection is automatic)
local Steam = require("luasteam")

-- Initialize Steam
if Steam.init() then
    print("Steam initialized!")
else
    print("Failed to initialize Steam")
    -- Game can still run without Steam
end
```

### 2. Main Loop Integration

```lua
function love.update(dt)
    -- IMPORTANT: Call this every frame
    if Steam then
        Steam.runCallbacks()
    end
end

function love.quit()
    -- Clean shutdown
    if Steam then
        Steam.shutdown()
    end
end
```

### 3. Common Operations

```lua
-- Get user information
local steamID = Steam.user.getSteamID()
local name = Steam.friends.getPersonaName()

-- Unlock an achievement
Steam.userStats.setAchievement("ACHIEVEMENT_ID")
Steam.userStats.storeStats() -- Don't forget to store!

-- Update a stat
Steam.userStats.setStatInt("TOTAL_GAMES", 10)
Steam.userStats.storeStats()

-- Set rich presence
Steam.friends.setRichPresence("status", "In Menu")
```

## Library Contents

This directory contains:

### Core Files
- `init.lua` - Main entry point, loads the correct library
- `luasteam.lua` - Core Lua wrapper implementation
- `platform.lua` - Platform detection utilities

### Platform Libraries
- `win32_luasteam.dll` - Windows 32-bit
- `win64_luasteam.dll` - Windows 64-bit
- `linux32_luasteam.so` - Linux 32-bit
- `linux64_luasteam.so` - Linux 64-bit
- `osx_luasteam.so` - macOS 64-bit

### Additional Files
- `steam_api64.dll` - Steam API library (Windows 64-bit)
- `steam_api64.lib` - Steam API import library

## Using This Library in Your Project

### Step 1: Copy the Directory
Copy this entire `luasteam/` directory to your project. The directory structure must be preserved.

### Step 2: Add Steam Libraries
You need the appropriate Steam API libraries for your target platforms:
- Windows: `steam_api.dll` (32-bit) or `steam_api64.dll` (64-bit)
- Linux: `libsteam_api.so`
- macOS: `libsteam_api.dylib`

Place these in your project root (not in the luasteam directory).

### Step 3: Create steam_appid.txt
Create a `steam_appid.txt` file in your project root containing your Steam App ID.
For testing, use `480` (Spacewar).

### Step 4: Integrate Into Your Code
See the parent project's `steam_integration.lua` for a comprehensive example of:
- Safe initialization with error handling
- Achievement management
- Statistics tracking
- Rich presence updates
- Proper callback handling

## Platform Detection

The library automatically detects your platform using:
1. Love2D's `love.system.getOS()` (primary)
2. LuaJIT's `jit.os` and `jit.arch` (fallback)

You can access platform info directly:
```lua
local platform = require("luasteam.platform")
print(platform.getPlatformString()) -- e.g., "win64", "linux32", "osx"
```

## Common Issues and Solutions

### "Failed to load luasteam"
- Ensure all library files are in the correct location
- Check that Steam client is installed and running
- Verify steam_appid.txt exists and contains valid ID

### "Module not found"
- The luasteam directory must maintain its structure
- When packaging as .love file, native libraries must be external

### Achievements/Stats not working
- Verify they're configured in Steamworks dashboard
- Ensure you're calling `storeStats()` after updates
- Check that Steam is in online mode

## Best Practices

1. **Always check initialization**: Steam might not be available
2. **Call runCallbacks() every frame**: Required for Steam events
3. **Handle errors gracefully**: Your game should work without Steam
4. **Store stats/achievements**: Changes aren't saved automatically
5. **Test offline**: Ensure your game doesn't crash without Steam

## API Categories

The luasteam library exposes these Steam interfaces:

- **Core Functions**: init, shutdown, runCallbacks
- **ISteamFriends**: Friend list, rich presence
- **ISteamUser**: User identity, authentication
- **ISteamUserStats**: Achievements, statistics, leaderboards
- **ISteamUtils**: Utilities, overlay
- **ISteamApps**: DLC, ownership
- **ISteamUGC**: Workshop content
- **ISteamInput**: Steam Input API
- **ISteamNetworkingSockets**: P2P networking
- **ISteamGameServer**: Dedicated servers

For detailed documentation on each, visit: https://luasteam.readthedocs.io

## Example: Complete Integration

For a full working example, examine the parent project:
- `steam_integration.lua` - Basic integration module
- `main.lua` - Shows how to integrate with Love2D

## Debugging

Enable debug logging by checking the parent project's approach:
- Creates `steam_debug.log` for troubleshooting
- Logs all Steam operations and callbacks
- Helps identify integration issues

## Support

- **Documentation**: https://luasteam.readthedocs.io
- **Steamworks**: https://partner.steamgames.com/doc/
- **Example Code**: See parent project's steam_integration.lua
