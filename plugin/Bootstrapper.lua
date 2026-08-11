-- MatiDev AI Bootstrapper v1.0.0
-- Publish this small script once as the Roblox Studio plugin.
-- The application UI and features are downloaded from GitHub at startup.
local HttpService = game:GetService("HttpService")
local VERSION = "1.0.0"
local MANIFEST_URL = "https://raw.githubusercontent.com/MatiYT14/ProjectAI/main/plugin/version.json"
local FALLBACK_URL = "https://raw.githubusercontent.com/MatiYT14/ProjectAI/main/plugin/Main.lua"

local function fetch(url)
    local response = HttpService:RequestAsync({Url=url, Method="GET", Headers={ ["Cache-Control"]="no-cache" }})
    if not response.Success then error("HTTP "..tostring(response.StatusCode).." while fetching MatiDev AI") end
    return response.Body
end

local function runRemote(source)
    if type(loadstring) ~= "function" then
        error("MatiDev AI requires a plugin environment with Luau source loading enabled")
    end
    local chunk, compileError = loadstring(source, "@MatiDevAI/Main.lua")
    if not chunk then error(compileError) end
    local ok, runtimeError = pcall(chunk)
    if not ok then error(runtimeError) end
end

local function reloadRemote()
    if _G.MatiDevAI_Cleanup then pcall(_G.MatiDevAI_Cleanup) end
    local latest = fetch(FALLBACK_URL)
    runRemote(latest)
end

_G.MatiDevAI_Reload = reloadRemote

local ok, manifestText = pcall(fetch, MANIFEST_URL)
local entry = FALLBACK_URL
if ok then
    local parsed = HttpService:JSONDecode(manifestText)
    if parsed.entry then entry = parsed.entry end
end
local source = fetch(entry)
runRemote(source)
