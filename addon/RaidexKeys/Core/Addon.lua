local ADDON, T = ...
local L = T.L

local Addon = {}
T.Addon = Addon

local PREFIX = "|cffa78bffRaidex Keys|r: "

function Addon:Print(...)
    print(PREFIX .. strjoin(" ", tostringall(...)))
end

local issecretvalue = issecretvalue or function() return false end

function T.Plain(value)
    if value == nil or issecretvalue(value) then return nil end
    return value
end

local eventFrame = CreateFrame("Frame")
local handlers = {}

eventFrame:SetScript("OnEvent", function(_, event, ...)
    local list = handlers[event]
    if not list then return end
    for i = 1, #list do
        list[i](event, ...)
    end
end)

function Addon:On(event, handler)
    local list = handlers[event]
    if not list then
        if not pcall(eventFrame.RegisterEvent, eventFrame, event) then return end
        list = {}
        handlers[event] = list
    end
    list[#list + 1] = handler
end

local pending = {}
local pendingFn = {}
function Addon:Debounce(key, delay, fn)
    if pending[key] then pending[key]:Cancel() end
    pendingFn[key] = fn
    pending[key] = C_Timer.NewTimer(delay, function()
        pending[key] = nil
        pendingFn[key] = nil
        fn()
    end)
end

function Addon:Flush(key)
    local fn = pendingFn[key]
    if not fn then return end
    pending[key]:Cancel()
    pending[key], pendingFn[key] = nil, nil
    fn()
end

SLASH_RAIDEXKEYS1 = "/rk"
SLASH_RAIDEXKEYS2 = "/raidexkeys"
SlashCmdList.RAIDEXKEYS = function(input)
    local command = strtrim((input or ""):lower())
    if command == "options" or command == "config" then
        T.OpenOptions()
    elseif command == "minimap" then
        T.MinimapButton:SetShown(T.DB:Settings().minimap.hide)
    elseif command == "debug" then
        local ok, err = pcall(Addon.PrintDebug, Addon)
        if not ok then Addon:Print("debug failed: " .. tostring(err)) end
    else
        Addon:PrintStatus()
    end
end

function Addon:PrintStatus()
    local db = T.DB
    self:Print(L["Characters stored: %d"]:format(db:CountCharacters()))
    self:Print(L["Guild keys this week: %d"]:format(T.Exchange:GuildKeysThisWeek()))
    self:Print(T.Exchange:UsesLibKeystone()
        and L["Keystone exchange: through LibKeystone (another addon)"]
        or L["Keystone exchange: built in"])
    self:Print(L["Data is saved when you log out or type /reload."])
    self:Print(L["Commands: /rk, /rk options, /rk minimap, /rk debug"])
end

function Addon:PrintDebug()
    local function show(label, ...)
        local parts = {}
        for i = 1, select("#", ...) do parts[i] = tostring(T.Plain((select(i, ...))) or "nil/secret") end
        self:Print("debug " .. label .. ": " .. table.concat(parts, ", "))
    end
    show("addon version, build", C_AddOns.GetAddOnMetadata("RaidexKeys", "Version"),
        C_AddOns.GetAddOnMetadata("RaidexKeys", "X-Build"))
    show("season", C_MythicPlus.GetCurrentSeason())
    show("overall score", C_ChallengeMode.GetOverallDungeonScore())
    show("owned key (map, level)", C_MythicPlus.GetOwnedKeystoneChallengeMapID(), C_MythicPlus.GetOwnedKeystoneLevel())

    local summary = C_PlayerInfo and C_PlayerInfo.GetPlayerMythicPlusRatingSummary
        and C_PlayerInfo.GetPlayerMythicPlusRatingSummary("player")
    show("rating summary (score, runs)", summary and summary.currentSeasonScore, summary and summary.runs and #summary.runs)
    local first = summary and summary.runs and summary.runs[1]
    if first then
        local fields = {}
        for key, value in pairs(first) do fields[#fields + 1] = key .. "=" .. tostring(T.Plain(value)) end
        table.sort(fields)
        self:Print("debug summary run[1]: " .. table.concat(fields, " "))
    end

    local maps = C_ChallengeMode.GetMapTable() or {}
    show("season maps", #maps)
    local mapId = maps[1]
    if mapId then
        local scores, overall = C_MythicPlus.GetSeasonBestAffixScoreInfoForMap(mapId)
        show("affix scores for " .. mapId .. " (entries, overall)", scores and #scores, overall)
        if C_MythicPlus.GetSeasonBestForMap then
            local inTime, overTime = C_MythicPlus.GetSeasonBestForMap(mapId)
            show("season best for " .. mapId .. " (in time, over time)",
                inTime and (inTime.level .. " in " .. inTime.durationSec .. "s"),
                overTime and (overTime.level .. " in " .. overTime.durationSec .. "s"))
        end
    end
    local history = C_MythicPlus.GetRunHistory and C_MythicPlus.GetRunHistory(true, true)
    show("run history (all weeks)", history and #history)

    local guid = T.Plain(UnitGUID("player"))
    local stored = guid and T.DB:Data().chars[guid]
    local count = 0
    for _ in pairs(stored and stored.best or {}) do count = count + 1 end
    local rating = stored and stored.rating or 0
    self:Print(("debug check rating > 0 needs runs: stored rating %s, stored runs %d -> %s"):format(
        tostring(rating), count, (rating == 0 or count > 0) and "OK" or "NOT MET (game data not loaded yet)"))
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", function(self, event, name)
    if event == "ADDON_LOADED" and name == ADDON then
        T.DB:Initialize()
        T.SetupOptions()
    elseif event == "PLAYER_LOGIN" then
        self:UnregisterAllEvents()
        T.Snapshot:Start()
        T.Exchange:Start()
        T.MinimapButton:Start()
    end
end)
