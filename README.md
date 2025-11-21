# Pong - Love2D Game

A simple two-player Pong game built with Love2D (LÖVE).

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

## Controls

- **Player 1 (Left Paddle)**: 
  - `W` - Move up
  - `S` - Move down

- **Player 2 (Right Paddle)**:
  - `↑` (Up Arrow) - Move up
  - `↓` (Down Arrow) - Move down

- **Game Controls**:
  - `Space` - Pause/Unpause
  - `Escape` - Quit game

## Gameplay

- The ball bounces between two paddles
- Score points by getting the ball past your opponent's paddle
- The ball gains spin based on where it hits the paddle
- First player to score wins (no score limit - play as long as you want!)

## Features

- Two-player local gameplay
- Score tracking
- Paddle physics with spin effect
- Pause functionality
- Simple, clean graphics
- Steam integration support (luasteam with cross-platform library loading)

## Steam Integration

This project includes full Steam integration with achievements, statistics, and rich presence!

### Features

- **Achievements**: Unlock achievements for scoring milestones, winning games, and more
- **Statistics**: Track total games, points, highest scores, and paddle hits
- **Rich Presence**: Show your game status and score to Steam friends
- **Cross-Platform**: Automatically detects your platform and loads the correct library

### Quick Start

1. **Download Steamworks SDK** from [Steamworks Partner](https://partner.steamgames.com/)
2. **Copy Steam API library** to your project root (see `STEAM_INTEGRATION.md`)
3. **Create `steam_appid.txt`** with your Steam App ID
4. **Configure achievements and stats** in Steamworks dashboard (see `STEAM_INTEGRATION.md`)

The game works perfectly fine without Steam - all Steam features are optional!

### Documentation

- **`STEAM_INTEGRATION.md`** - Complete Steam integration guide
- **`luasteam/README.md`** - luasteam library documentation

The library automatically detects:
- **Windows**: 32-bit or 64-bit
- **Linux**: 32-bit or 64-bit  
- **macOS**: 64-bit

Enjoy playing Pong!

