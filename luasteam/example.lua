-- Example: How to use luasteam with platform detection
-- This file demonstrates the basic usage of luasteam in a Love2D project

local luasteam = nil

function love.load()
    -- Try to load luasteam (will automatically detect platform)
    local success, err = pcall(function()
        luasteam = require("luasteam")
    end)
    
    if not success then
        print("Warning: Could not load luasteam: " .. tostring(err))
        print("Steam features will be unavailable.")
        return
    end
    
    -- Initialize Steam
    if luasteam and luasteam.init() then
        print("Steam initialized successfully!")
        
        -- Example: Get Steam user info
        local steam_id = luasteam.getSteamID()
        print("Steam ID: " .. tostring(steam_id))
    else
        print("Failed to initialize Steam")
        print("Make sure Steam is running and you have a valid app ID set.")
    end
end

function love.update(dt)
    -- Run Steam callbacks (important - must be called regularly)
    if luasteam then
        luasteam.runCallbacks()
    end
end

function love.quit()
    -- Shutdown Steam when quitting
    if luasteam then
        luasteam.shutdown()
    end
end

-- Example: Display platform information
function love.keypressed(key)
    if key == "p" then
        local platform = require("luasteam.platform")
        print("=== Platform Information ===")
        print("OS: " .. platform.getOS())
        print("Architecture: " .. platform.getArch())
        print("Platform String: " .. platform.getPlatformString())
        print("Supported: " .. tostring(platform.isSupported()))
    end
end


