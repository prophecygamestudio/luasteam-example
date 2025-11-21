-- luasteam Platform-Aware Loader
-- This module automatically detects the platform and loads the correct luasteam library
-- Usage: local luasteam = require("luasteam")

local platform = require("luasteam.platform")

-- Injected log function (can be set by external modules)
local injectedLogFunction = nil

-- Set the log function (allows sharing logging with other modules)
local function setLogFunction(logFunc)
    injectedLogFunction = logFunc
end

-- Debug logging function (uses injected function if available, otherwise noops)
local function debugLog(message)
    if injectedLogFunction then
        injectedLogFunction(message)
    end
    -- If no log function is injected, this is a noop
end

-- Library file mapping based on platform
local library_files = {
    win32 = "luasteam/win32_luasteam.dll",
    win64 = "luasteam/win64_luasteam.dll",
    linux32 = "luasteam/linux32_luasteam.so",
    linux64 = "luasteam/linux64_luasteam.so",
    osx = "luasteam/osx_luasteam.so"
}

-- Detect platform and load the appropriate library
local function loadLuasteam()
    debugLog("[luasteam] Starting library load...")
    
    -- Check if platform is supported
    if not platform.isSupported() then
        local os_name = platform.getOS()
        debugLog("[luasteam] ERROR: Unsupported platform: " .. os_name)
        error("luasteam: Unsupported platform: " .. os_name)
    end
    
    -- Get platform string (e.g., "win64", "linux64", "osx")
    local platform_str = platform.getPlatformString()
    local library_path = library_files[platform_str]
    
    debugLog("[luasteam] Platform detected: " .. platform_str)
    debugLog("[luasteam] OS: " .. platform.getOS() .. ", Arch: " .. platform.getArch())
    debugLog("[luasteam] Library path: " .. library_path)
    
    if not library_path then
        error("luasteam: No library found for platform: " .. platform_str)
    end
    
    -- Check if the library file exists in Love2D's filesystem
    local file_info = love.filesystem.getInfo(library_path)
    if not file_info then
        debugLog("[luasteam] ERROR: Library file not found in Love2D filesystem: " .. library_path)
        error("luasteam: Library file not found: " .. library_path .. 
              "\nPlatform detected: " .. platform_str .. 
              "\nOS: " .. platform.getOS() .. 
              "\nArch: " .. platform.getArch() ..
              "\nMake sure the library file is in the luasteam/ directory.")
    end
    
    debugLog("[luasteam] Library file found in Love2D filesystem")
    
    -- For Love2D, we need to get the actual filesystem path
    -- love.filesystem.getSource() returns the directory containing the .love file or source
    local source = love.filesystem.getSource()
    local full_path
    
    if source then
        -- Construct the full filesystem path
        -- Handle both Windows and Unix-style paths
        local separator = package.config:sub(1,1)  -- Get path separator
        full_path = source .. separator .. library_path:gsub("/", separator)
        debugLog("[luasteam] Source directory: " .. source)
        debugLog("[luasteam] Full path: " .. full_path)
    else
        -- Fallback: try relative path
        full_path = library_path
        debugLog("[luasteam] WARNING: Could not get source directory, using relative path: " .. full_path)
    end
    
    -- Check for Steam API DLL dependency before loading
    -- We'll check multiple locations and add the directory to Windows DLL search path
    local steam_api_dll = nil
    if platform_str == "win32" then
        steam_api_dll = "steam_api.dll"
    elseif platform_str == "win64" then
        steam_api_dll = "steam_api64.dll"
    end
    
    if steam_api_dll and source then
        local separator = package.config:sub(1,1)
        local steam_api_locations = {
            source .. separator .. steam_api_dll,  -- Project root
            source .. separator .. "luasteam" .. separator .. steam_api_dll,  -- luasteam subdirectory
            source .. separator .. "lib" .. separator .. steam_api_dll,  -- lib subdirectory
        }
        
        local steam_api_found_path = nil
        for _, path in ipairs(steam_api_locations) do
            local file = io.open(path, "r")
            if file then
                file:close()
                steam_api_found_path = path
                debugLog("[luasteam] Found Steam API DLL at: " .. path)
                break
            end
        end
        
        if steam_api_found_path then
            -- Extract the directory containing the DLL
            local dll_dir = steam_api_found_path:match("^(.+)[\\/][^\\/]+$")
            if dll_dir then
                -- Use FFI to add directory to Windows DLL search path
                -- SetDllDirectoryA adds the directory to Windows' DLL search order
                local ffi_loaded, ffi = pcall(require, "ffi")
                if ffi_loaded and ffi then
                    -- Define Windows types and function
                    ffi.cdef[[
                        typedef int BOOL;
                        BOOL SetDllDirectoryA(const char* lpPathName);
                    ]]
                    
                    local kernel32 = ffi.load("kernel32")
                    if kernel32 and kernel32.SetDllDirectoryA then
                        local success = kernel32.SetDllDirectoryA(dll_dir)
                        if success ~= 0 then
                            debugLog("[luasteam] Added DLL directory to Windows search path: " .. dll_dir)
                        else
                            debugLog("[luasteam] Warning: SetDllDirectoryA returned false, but continuing...")
                        end
                    else
                        debugLog("[luasteam] Warning: Could not load SetDllDirectoryA function")
                    end
                else
                    debugLog("[luasteam] FFI not available - DLL should be found via standard search paths")
                    debugLog("[luasteam] Note: If DLL loading fails, try placing " .. steam_api_dll .. " in project root")
                end
            end
        else
            debugLog("[luasteam] WARNING: Steam API DLL not found in any checked location")
            debugLog("[luasteam] Checked locations:")
            for _, path in ipairs(steam_api_locations) do
                debugLog("[luasteam]   - " .. path)
            end
            debugLog("[luasteam] The luasteam DLL requires " .. steam_api_dll)
            debugLog("[luasteam] Download it from Steamworks SDK and place it in project root or luasteam/ subdirectory")
        end
    end
    
    -- Load the native library using package.loadlib
    -- The entry point function is typically "luaopen_luasteam"
    debugLog("[luasteam] Attempting to load library...")
    local lib_handle, err = package.loadlib(full_path, "luaopen_luasteam")
    
    if not lib_handle then
        debugLog("[luasteam] ERROR: Failed to load library")
        debugLog("[luasteam] Error message: " .. (err or "unknown"))
        
        -- Provide specific guidance for common errors
        local error_msg = err or "unknown"
        local helpful_hint = ""
        if error_msg:find("could not be found") or error_msg:find("module could not be found") then
            if steam_api_dll then
                helpful_hint = "\n\nMISSING DEPENDENCY DETECTED:\n" ..
                              "The luasteam DLL requires " .. steam_api_dll .. " to be available.\n" ..
                              "Download the Steamworks SDK from https://partner.steamgames.com/\n" ..
                              "Copy " .. steam_api_dll .. " from sdk/redistributable_bin/win64/ to one of:\n" ..
                              "  - Project root: " .. (source or "project directory") .. "\n" ..
                              "  - luasteam/ subdirectory: " .. (source or "") .. "/luasteam/\n" ..
                              "  - lib/ subdirectory: " .. (source or "") .. "/lib/"
            else
                helpful_hint = "\n\nThis error usually means a required DLL dependency is missing.\n" ..
                              "For Windows, make sure steam_api64.dll (or steam_api.dll for 32-bit) is available."
            end
        end
        
        error("luasteam: Failed to load library: " .. library_path .. 
              "\nFull path attempted: " .. (full_path or "unknown") ..
              "\nError: " .. error_msg ..
              helpful_hint)
    end
    
    debugLog("[luasteam] Library handle obtained, calling initialization function...")
    
    -- Call the initialization function
    local success, luasteam = pcall(lib_handle)
    
    if not success then
        debugLog("[luasteam] ERROR: Failed to initialize library")
        debugLog("[luasteam] Error: " .. tostring(luasteam))
        error("luasteam: Error initializing library: " .. tostring(luasteam))
    end
    
    if not luasteam then
        debugLog("[luasteam] ERROR: Library returned nil")
        error("luasteam: Library loaded but returned nil")
    end
    
    debugLog("[luasteam] Library loaded successfully!")
    
    -- Add setLogFunction to the returned module so it can be called externally
    if type(luasteam) == "table" then
        luasteam.setLogFunction = setLogFunction
    end
    
    return luasteam
end

-- Load and return the luasteam module
return loadLuasteam()

