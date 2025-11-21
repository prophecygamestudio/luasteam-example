-- Steam Integration Module for Pong Game
-- Handles all Steam-related functionality including achievements, stats, and rich presence

local steam_integration = {}

-- Steam module (loaded dynamically)
local steam = nil
local steam_initialized = false

-- Debug logging function
local function debugLog(message)
    print(message)
    local success, err = pcall(function()
        local log_file = io.open("steam_debug.log", "a")
        if log_file then
            log_file:write(os.date("[%Y-%m-%d %H:%M:%S] ") .. message .. "\n")
            log_file:close()
        end
    end)
end

-- Achievement IDs (these need to match your Steamworks dashboard)
local ACHIEVEMENTS = {
    FIRST_SCORE = "FIRST_SCORE",           -- Score your first point
    SCORE_10 = "SCORE_10",                 -- Score 10 points
    SCORE_50 = "SCORE_50",                 -- Score 50 points
    SCORE_100 = "SCORE_100",               -- Score 100 points
    WIN_GAME = "WIN_GAME",                 -- Win a game
    PERFECT_GAME = "PERFECT_GAME",         -- Win without opponent scoring
    LONG_RALLY = "LONG_RALLY",             -- Long rally (10+ hits)
}

-- Stat names (these need to match your Steamworks dashboard)
local STATS = {
    TOTAL_GAMES = "TOTAL_GAMES",
    TOTAL_POINTS = "TOTAL_POINTS",
    HIGHEST_SCORE = "HIGHEST_SCORE",
    TOTAL_HITS = "TOTAL_HITS",
}

-- Game tracking variables
local game_stats = {
    total_games = 0,
    total_points = 0,
    highest_score = 0,
    total_hits = 0,
    current_rally = 0,
    longest_rally = 0,
}

-- Initialize Steam
function steam_integration.init()
    -- Try to load luasteam
    local success, err = pcall(function()
        steam = require("luasteam")
    end)
    
    if not success then
        debugLog("Warning: Could not load luasteam: " .. tostring(err))
        debugLog("Steam features will be unavailable.")
        debugLog("Debug info: Check that Steam is running and steam_appid.txt exists.")
        return false
    end
    
    if not steam then
        debugLog("Warning: luasteam loaded but returned nil")
        return false
    end
    
    -- Initialize Steam API
    if steam and steam.init then
        debugLog("[Steam] Attempting to initialize Steam API...")
        
        -- Check for steam_appid.txt
        local appid_file = love.filesystem.getInfo("steam_appid.txt")
        if not appid_file then
            debugLog("[Steam] WARNING: steam_appid.txt not found!")
            debugLog("[Steam] Steam may not initialize without a valid App ID.")
        else
            debugLog("[Steam] Found steam_appid.txt")
        end
        
        if steam.init() then
            steam_initialized = true
            debugLog("[Steam] Steam initialized successfully!")
            
            -- Request stats and achievements (luasteam uses ISteamUserStats)
            -- Note: Stats are automatically requested on init, but we can request them explicitly
            if steam.userStats and steam.userStats.requestCurrentStats then
                steam.userStats.requestCurrentStats()
            end
            
            -- Load existing stats
            steam_integration.loadStats()
            
            return true
        else
            debugLog("[Steam] ERROR: Failed to initialize Steam")
            debugLog("[Steam] Make sure:")
            debugLog("[Steam]   1. Steam client is running")
            debugLog("[Steam]   2. steam_appid.txt exists with a valid App ID")
            debugLog("[Steam]   3. You're running the game through Steam or with Steam running")
            return false
        end
    else
        debugLog("[Steam] ERROR: Steam API not available")
        debugLog("[Steam] The luasteam library may not have loaded correctly.")
        return false
    end
end

-- Run Steam callbacks (call this in love.update)
function steam_integration.update()
    if steam_initialized and steam then
        -- Try different possible function names
        if steam.runCallbacks then
            steam.runCallbacks()
        end
    end
end

-- Shutdown Steam (call this in love.quit)
function steam_integration.shutdown()
    if steam_initialized and steam and steam.shutdown then
        -- Save stats before shutting down
        steam_integration.saveStats()
        steam.shutdown()
        print("Steam shut down")
    end
end

-- Check if Steam is initialized
function steam_integration.isInitialized()
    return steam_initialized
end

-- Get Steam username
function steam_integration.getUsername()
    if not steam_initialized or not steam then
        return nil
    end
    
    -- Try different possible API access patterns
    -- luasteam API structure may vary, so we check multiple possibilities
    if steam.friends then
        if steam.friends.getPersonaName then
            local success, username = pcall(function() return steam.friends.getPersonaName() end)
            if success and username then
                return username
            end
        end
    end
    
    if steam.getPersonaName then
        local success, username = pcall(function() return steam.getPersonaName() end)
        if success and username then
            return username
        end
    end
    
    -- Try ISteamFriends interface directly
    if steam.ISteamFriends and steam.ISteamFriends.GetPersonaName then
        local success, username = pcall(function() return steam.ISteamFriends.GetPersonaName() end)
        if success and username then
            return username
        end
    end
    
    -- If we can't get username, that's okay - just return nil
    -- The game will work fine without displaying the username
    return nil
end

-- Handle scoring events
function steam_integration.onScore(player_num, new_score)
    if not steam_initialized then return end
    
    game_stats.total_points = game_stats.total_points + 1
    
    -- Update stats
    steam_integration.setStat(STATS.TOTAL_POINTS, game_stats.total_points)
    
    -- Check for highest score
    if new_score > game_stats.highest_score then
        game_stats.highest_score = new_score
        steam_integration.setStat(STATS.HIGHEST_SCORE, game_stats.highest_score)
    end
    
    -- Achievement: First score
    if game_stats.total_points == 1 then
        steam_integration.unlockAchievement(ACHIEVEMENTS.FIRST_SCORE)
    end
    
    -- Achievement: Score milestones
    if new_score == 10 then
        steam_integration.unlockAchievement(ACHIEVEMENTS.SCORE_10)
    elseif new_score == 50 then
        steam_integration.unlockAchievement(ACHIEVEMENTS.SCORE_50)
    elseif new_score == 100 then
        steam_integration.unlockAchievement(ACHIEVEMENTS.SCORE_100)
    end
    
    -- Reset rally counter
    game_stats.current_rally = 0
end

-- Handle paddle hit (for rally tracking)
function steam_integration.onPaddleHit()
    if not steam_initialized then return end
    
    game_stats.total_hits = game_stats.total_hits + 1
    game_stats.current_rally = game_stats.current_rally + 1
    
    -- Update stats
    steam_integration.setStat(STATS.TOTAL_HITS, game_stats.total_hits)
    
    -- Check for longest rally
    if game_stats.current_rally > game_stats.longest_rally then
        game_stats.longest_rally = game_stats.current_rally
        
        -- Achievement: Long rally
        if game_stats.current_rally >= 10 then
            steam_integration.unlockAchievement(ACHIEVEMENTS.LONG_RALLY)
        end
    end
end

-- Handle game win
function steam_integration.onGameWin(winner_score, loser_score)
    if not steam_initialized then return end
    
    game_stats.total_games = game_stats.total_games + 1
    steam_integration.setStat(STATS.TOTAL_GAMES, game_stats.total_games)
    
    -- Achievement: Win game
    steam_integration.unlockAchievement(ACHIEVEMENTS.WIN_GAME)
    
    -- Achievement: Perfect game (win without opponent scoring)
    if loser_score == 0 then
        steam_integration.unlockAchievement(ACHIEVEMENTS.PERFECT_GAME)
    end
end

-- Update rich presence based on game state
function steam_integration.updateRichPresence(game_state, player1_score, player2_score)
    if not steam_initialized then return end
    
    if steam then
        local status = ""
        
        if game_state == "paused" then
            status = "Paused"
        elseif game_state == "playing" then
            status = string.format("Playing - %d : %d", player1_score, player2_score)
        else
            status = "In Menu"
        end
        
        -- Try different possible API access patterns
        if steam.friends and steam.friends.setRichPresence then
            steam.friends.setRichPresence("status", status)
            steam.friends.setRichPresence("score", string.format("%d-%d", player1_score, player2_score))
        elseif steam.setRichPresence then
            steam.setRichPresence("status", status)
            steam.setRichPresence("score", string.format("%d-%d", player1_score, player2_score))
        end
    end
end

-- Unlock an achievement
function steam_integration.unlockAchievement(achievement_id)
    if not steam_initialized then return end
    
    if steam then
        local userStats = steam.userStats
        if not userStats then
            return
        end
        
        -- Check if already unlocked
        if userStats.getAchievement then
            local achieved = userStats.getAchievement(achievement_id)
            if achieved then
                return -- Already unlocked
            end
        end
        
        -- Unlock the achievement
        if userStats.setAchievement then
            userStats.setAchievement(achievement_id)
            
            -- Store stats to sync with Steam
            if userStats.storeStats then
                userStats.storeStats()
            end
            
            print("Achievement unlocked: " .. achievement_id)
        end
    end
end

-- Set a stat value
function steam_integration.setStat(stat_name, value)
    if not steam_initialized then return end
    
    if steam and steam.userStats then
        local userStats = steam.userStats
        if userStats.setStat then
            userStats.setStat(stat_name, value)
        elseif userStats.set_stat then
            userStats.set_stat(stat_name, value)
        end
    end
end

-- Store stats (call after updating stats)
function steam_integration.storeStats()
    if not steam_initialized then return end
    
    if steam and steam.userStats then
        local userStats = steam.userStats
        if userStats.storeStats then
            userStats.storeStats()
        elseif userStats.store_stats then
            userStats.store_stats()
        end
    end
end

-- Load stats from Steam
function steam_integration.loadStats()
    if not steam_initialized then return end
    
    if steam and steam.userStats then
        local userStats = steam.userStats
        
        if userStats.getStat then
            game_stats.total_games = userStats.getStat(STATS.TOTAL_GAMES) or 0
            game_stats.total_points = userStats.getStat(STATS.TOTAL_POINTS) or 0
            game_stats.highest_score = userStats.getStat(STATS.HIGHEST_SCORE) or 0
            game_stats.total_hits = userStats.getStat(STATS.TOTAL_HITS) or 0
        elseif userStats.get_stat then
            game_stats.total_games = userStats.get_stat(STATS.TOTAL_GAMES) or 0
            game_stats.total_points = userStats.get_stat(STATS.TOTAL_POINTS) or 0
            game_stats.highest_score = userStats.get_stat(STATS.HIGHEST_SCORE) or 0
            game_stats.total_hits = userStats.get_stat(STATS.TOTAL_HITS) or 0
        end
    end
end

-- Save stats to Steam
function steam_integration.saveStats()
    if not steam_initialized then return end
    
    steam_integration.setStat(STATS.TOTAL_GAMES, game_stats.total_games)
    steam_integration.setStat(STATS.TOTAL_POINTS, game_stats.total_points)
    steam_integration.setStat(STATS.HIGHEST_SCORE, game_stats.highest_score)
    steam_integration.setStat(STATS.TOTAL_HITS, game_stats.total_hits)
    steam_integration.storeStats()
end

-- Get game stats (for display)
function steam_integration.getStats()
    return game_stats
end

return steam_integration

