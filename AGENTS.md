# Agent Documentation for Love2D luasteam Integration Example

## Project Overview

This is an **example project** demonstrating how to integrate luasteam (SteamWorks bindings for Lua) with Love2D games. The project uses a simple Pong game as a vehicle to showcase Steam integration patterns.

**Key Purpose**: To serve as a reference implementation that other developers can study and adapt for their own Love2D projects that need Steam integration.

## Project Structure

```
love-steam/
├── main.lua               # Main game entry point
├── steam_integration.lua  # Steam integration module (study this!)
├── steam_appid.txt       # Steam App ID (480 for SpaceWar test app)
└── luasteam/             # luasteam library directory (can be copied to other projects)
    ├── init.lua          # Main luasteam loader
    ├── platform.lua      # Platform detection
    ├── luasteam.lua      # Core luasteam implementation
    ├── AGENTS.md         # luasteam documentation and usage guide
    └── [platform libs]   # Platform-specific binaries
```

## Key Components

### 1. steam_integration.lua
This is the main reference implementation showing:
- How to initialize luasteam safely
- Achievement and stat management
- Rich presence updates
- Graceful error handling
- Platform-agnostic loading

### 2. luasteam Directory
Self-contained luasteam library that can be copied wholesale to other projects. Includes:
- Cross-platform library loading
- Automatic platform detection
- All necessary binaries for Windows/Linux/macOS

## Working with This Project

### For Code Modifications
- The Pong game itself is intentionally simple - avoid overcomplicating it
- Focus improvements on the Steam integration examples
- Ensure all changes maintain the educational clarity of the example

### For Documentation Updates
- Keep explanations clear and focused on the integration aspects
- Include practical examples and common pitfalls
- Reference the official luasteam documentation: https://luasteam.readthedocs.io

### Testing Steam Features
- Use Steam App ID 480 (SpaceWar) for testing
- Run Steam client before testing
- Check steam_debug.log for integration issues
- Test with both Steam running and not running

## Steam Setup Details

### Steamworks SDK Files
After downloading the Steamworks SDK, copy the appropriate Steam API library to your project root:
- **Windows 32-bit**: `sdk/redistributable_bin/steam_api.dll`
- **Windows 64-bit**: `sdk/redistributable_bin/win64/steam_api64.dll`
- **Linux 32-bit**: `sdk/redistributable_bin/linux32/libsteam_api.so`
- **Linux 64-bit**: `sdk/redistributable_bin/linux64/libsteam_api.so`
- **macOS**: `sdk/redistributable_bin/osx32/libsteam_api.dylib`

### Example Configuration

#### Achievements (as configured in this example)
- `FIRST_SCORE` - Score your first point
- `SCORE_10` - Score 10 points
- `SCORE_50` - Score 50 points
- `SCORE_100` - Score 100 points
- `WIN_GAME` - Win a game (first to 10 points)
- `PERFECT_GAME` - Win without opponent scoring
- `LONG_RALLY` - Complete a rally of 10+ hits

#### Statistics (as configured in this example)
- `TOTAL_GAMES` - Total number of games played (INT)
- `TOTAL_POINTS` - Total points scored across all games (INT)
- `HIGHEST_SCORE` - Highest score in a single game (INT)
- `TOTAL_HITS` - Total paddle hits across all games (INT)

#### Rich Presence Keys
- `status` - Current game status
- `score` - Current score

## Common Tasks

### Adding New Steam Feature Examples
1. Implement the feature in `steam_integration.lua`
2. Add clear comments explaining the implementation
3. Update documentation with the new example
4. Test thoroughly on multiple platforms if possible

### Updating luasteam
1. Replace binaries in the luasteam directory
2. Test all existing functionality
3. Update platform.lua if new platforms are supported
4. Document any API changes

## Important Notes

- This is an EXAMPLE project - prioritize clarity over complexity
- The luasteam directory should remain self-contained and portable
- All Steam features should fail gracefully when Steam is not available
- Keep the Pong game simple to maintain focus on the integration

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

## API Reference Examples

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

## Resources

- **luasteam Documentation**: https://luasteam.readthedocs.io
- **SteamWorks Documentation**: https://partner.steamgames.com/doc/
- **Love2D Documentation**: https://love2d.org/wiki/Main_Page

## Version Information

- Love2D: 11.0+
- luasteam: Latest version as of project creation
- Supported Platforms: Windows (32/64-bit), Linux (32/64-bit), macOS (64-bit)
