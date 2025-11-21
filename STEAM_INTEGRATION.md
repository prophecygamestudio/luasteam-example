# Steam Integration Guide

This document explains the Steam integration features in the Pong game.

## Overview

The game includes full Steam integration using the `luasteam` library, which provides:
- **Achievements** - Unlock achievements for various milestones
- **Statistics** - Track player statistics (games played, points scored, etc.)
- **Rich Presence** - Show current game status on Steam profile
- **User Information** - Display Steam username in-game

## Setup Requirements

### 1. Steamworks SDK

You need to download the Steamworks SDK from the [Steamworks Partner website](https://partner.steamgames.com/).

After downloading, copy the appropriate Steam API library to your project root:
- **Windows 32-bit**: `sdk/redistributable_bin/steam_api.dll`
- **Windows 64-bit**: `sdk/redistributable_bin/win64/steam_api64.dll`
- **Linux 32-bit**: `sdk/redistributable_bin/linux32/libsteam_api.so`
- **Linux 64-bit**: `sdk/redistributable_bin/linux64/libsteam_api.so`
- **macOS**: `sdk/redistributable_bin/osx32/libsteam_api.dylib`

### 2. Steam App ID

Create a `steam_appid.txt` file in your project root with your Steam App ID (for testing, you can use a test App ID from Steamworks).

### 3. Steamworks Dashboard Configuration

You need to configure the following in your Steamworks dashboard:

#### Achievements

Create these achievements with the exact IDs:
- `FIRST_SCORE` - Score your first point
- `SCORE_10` - Score 10 points
- `SCORE_50` - Score 50 points
- `SCORE_100` - Score 100 points
- `WIN_GAME` - Win a game (first to 10 points)
- `PERFECT_GAME` - Win without opponent scoring
- `LONG_RALLY` - Complete a rally of 10+ hits

#### Statistics

Create these statistics with the exact names:
- `TOTAL_GAMES` - Total number of games played (INT)
- `TOTAL_POINTS` - Total points scored across all games (INT)
- `HIGHEST_SCORE` - Highest score in a single game (INT)
- `TOTAL_HITS` - Total paddle hits across all games (INT)

#### Rich Presence

Configure rich presence keys:
- `status` - Current game status
- `score` - Current score

## Features

### Achievements

The game automatically unlocks achievements when players reach milestones:

- **First Score**: Unlocked when scoring the first point
- **Score Milestones**: Unlocked at 10, 50, and 100 points
- **Win Game**: Unlocked when winning a game (first to 10 points)
- **Perfect Game**: Unlocked when winning without the opponent scoring
- **Long Rally**: Unlocked during a rally with 10+ consecutive hits

### Statistics Tracking

The game tracks:
- Total games played
- Total points scored
- Highest score in a single game
- Total paddle hits

Statistics are automatically saved to Steam and persist across game sessions.

### Rich Presence

Steam friends can see:
- Current game status (Playing, Paused)
- Current score (Player 1 : Player 2)

### UI Indicator

The game displays:
- Steam connection status (top-right corner)
- Steam username (when connected)

## Code Structure

### `steam_integration.lua`

This module handles all Steam functionality:
- Initialization and shutdown
- Achievement unlocking
- Statistics tracking
- Rich presence updates
- Event callbacks

### Integration in `main.lua`

The main game file:
- Initializes Steam on startup
- Updates Steam callbacks every frame
- Tracks scoring events
- Tracks paddle hits for rally counting
- Updates rich presence
- Shuts down Steam on exit

## Testing

### Without Steam

The game works perfectly fine without Steam. If Steam is not available:
- The game continues normally
- Steam features are simply unavailable
- A "Steam: Offline" indicator is shown

### With Steam

To test Steam features:
1. Make sure Steam client is running
2. Have a valid `steam_appid.txt` file
3. Run the game through Steam or with Steam running
4. Play the game and trigger achievements
5. Check your Steam profile to see achievements and stats

## Troubleshooting

### Steam Not Initializing

- Make sure Steam client is running
- Verify `steam_appid.txt` exists and contains a valid App ID
- Check that the Steam API library is in the project root
- Verify luasteam library is correctly loaded (check console for errors)

### Achievements Not Unlocking

- Verify achievement IDs match exactly with Steamworks dashboard
- Make sure achievements are published (not just in draft)
- Check that stats are being stored (`steam_integration.storeStats()`)
- Verify Steam is actually initialized (check UI indicator)

### Statistics Not Updating

- Verify stat names match exactly with Steamworks dashboard
- Make sure stats are configured as the correct type (INT)
- Check that `storeStats()` is being called after updates
- Verify Steam is initialized and connected

## API Reference

### Main Functions

```lua
local steam = require("steam_integration")

-- Initialize Steam (call in love.load)
steam.init()

-- Update Steam callbacks (call in love.update)
steam.update()

-- Shutdown Steam (call in love.quit)
steam.shutdown()

-- Check if Steam is initialized
local is_init = steam.isInitialized()

-- Get Steam username
local username = steam.getUsername()
```

### Event Handlers

```lua
-- Called when a player scores
steam.onScore(player_num, new_score)

-- Called when paddle hits ball (for rally tracking)
steam.onPaddleHit()

-- Called when a game is won
steam.onGameWin(winner_score, loser_score)

-- Update rich presence
steam.updateRichPresence(game_state, player1_score, player2_score)
```

### Statistics

```lua
-- Get current game statistics
local stats = steam.getStats()
-- Returns: { total_games, total_points, highest_score, total_hits, ... }
```

## Notes

- The game gracefully handles Steam being unavailable
- All Steam features are optional - the game works without Steam
- Statistics and achievements are automatically saved
- Rich presence updates in real-time as you play


