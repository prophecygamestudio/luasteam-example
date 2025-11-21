# Love2D luasteam Integration Example

A demonstration project showing how to integrate luasteam (SteamWorks bindings for Lua) with Love2D projects. This example uses a simple Pong game to showcase various Steam features including achievements, statistics, and rich presence.

**Note**: This is primarily an example project. Other games wanting to use luasteam can copy the contents of the `luasteam` directory and adapt the integration patterns shown here.

## Requirements

- [Love2D](https://love2d.org/) (LÖVE) version 11.0 or higher
- [SteamWorks SDK](https://partner.steamgames.com/doc/sdk) (if using Steam features)

## Installation

1. Download and install Love2D from [love2d.org](https://love2d.org/)
2. Clone or download this repository

## How to Run

### Windows
- Drag the project folder onto the Love2D executable, OR
- Right-click the project folder → Open with → Love2D, OR
- Run from command line: `love .` (from the project directory)

### Mac/Linux
- Run from terminal: `love .` (from the project directory)
- Or drag the folder onto the Love2D application

## About This Example

This project serves as a practical example of integrating luasteam into a Love2D game. The Pong game demonstrates:

- Proper luasteam library loading and initialization
- Cross-platform library support (Windows 32/64-bit, Linux 32/64-bit, macOS)
- Achievement unlocking based on game events
- Statistics tracking and updates
- Rich presence status updates
- Graceful fallback when Steam is unavailable

## Using luasteam in Your Own Project

To use luasteam in your own Love2D project:

1. Copy the entire `luasteam/` directory from this project
2. Study `steam_integration.lua` for integration patterns
3. Adapt the code to your game's needs
4. Configure your achievements and stats in the Steamworks dashboard

For detailed luasteam documentation, see:
- **Official Documentation**: https://luasteam.readthedocs.io
- **Local Documentation**: `luasteam/AGENTS.md`

## Steam Integration

### Features

- **Achievements**: Unlock achievements for scoring milestones, winning games, and more
- **Statistics**: Track total games, points, highest scores, and paddle hits
- **Rich Presence**: Show your game status and score to Steam friends
- **Cross-Platform**: Automatically detects your platform and loads the correct library

### Quick Start

1. **Copy `luasteam` library** to your project
2. **Create `steam_appid.txt`** with your Steam App ID
3. **Configure achievements and stats** in Steamworks dashboard

The game works perfectly fine without Steam - all Steam features are optional!

### Documentation

- **`AGENTS.md`** - Complete project documentation and Steam integration guide
- **`luasteam/AGENTS.md`** - luasteam library documentation
- **`luasteam/README.md`** - luasteam platform setup guide

The library automatically detects:
- **Windows**: 32-bit or 64-bit
- **Linux**: 32-bit or 64-bit  
- **macOS**: 64-bit

Enjoy playing Pong!

