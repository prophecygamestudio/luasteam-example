-- Platform Detection Module
-- Detects the current operating system and architecture for cross-platform compatibility

local platform = {}

-- Detect OS using Love2D's system API or LuaJIT
function platform.getOS()
    -- Try Love2D's system API first (most reliable)
    if love and love.system then
        local os = love.system.getOS()
        -- Love2D returns: "Windows", "OS X", "Linux", "Android", "iOS"
        if os == "OS X" then
            return "osx"
        elseif os == "Windows" then
            return "windows"
        elseif os == "Linux" then
            return "linux"
        end
    end
    
    -- Fallback to LuaJIT detection
    if jit and jit.os then
        local os_name = jit.os:lower()
        if os_name == "windows" then
            return "windows"
        elseif os_name == "linux" then
            return "linux"
        elseif os_name == "osx" or os_name == "darwin" then
            return "osx"
        end
    end
    
    -- Default fallback
    return "unknown"
end

-- Detect architecture using LuaJIT
function platform.getArch()
    if jit and jit.arch then
        local arch = jit.arch:lower()
        -- Normalize architecture names
        if arch == "x64" or arch == "x86_64" or arch == "amd64" then
            return "64"
        elseif arch == "x86" or arch == "i386" or arch == "i686" then
            return "32"
        end
        return arch
    end
    
    -- Default to 64-bit if we can't detect
    return "64"
end

-- Get platform string for library naming
-- Returns: "win32", "win64", "linux32", "linux64", "osx"
function platform.getPlatformString()
    local os = platform.getOS()
    local arch = platform.getArch()
    
    if os == "windows" then
        return "win" .. arch
    elseif os == "linux" then
        return "linux" .. arch
    elseif os == "osx" then
        return "osx"  -- macOS libraries are typically universal or 64-bit only
    end
    
    return "unknown"
end

-- Get library extension for current platform
function platform.getLibraryExtension()
    local os = platform.getOS()
    if os == "windows" then
        return ".dll"
    elseif os == "linux" or os == "osx" then
        return ".so"
    end
    return ".so"  -- Default
end

-- Check if platform is supported
function platform.isSupported()
    local os = platform.getOS()
    return os == "windows" or os == "linux" or os == "osx"
end

return platform


