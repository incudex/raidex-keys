local _, T = ...
local Addon, Plain = T.Addon, T.Plain

local PREFIX = "LibKS"
local THROTTLE = 3
local GUILD_INTERVAL = 600
local ENOUGH_TIME = 10

local Exchange = {}
T.Exchange = Exchange

local lks
local party = {}

local function fullName(name)
    if not name then return nil end
    if name:find("-", 1, true) then return name end
    return name .. "-" .. (GetNormalizedRealmName() or "")
end

local function isSelf(name)
    return fullName(name) == fullName(UnitName("player"))
end

local function currentGuild()
    if not IsInGuild() then return nil end
    local name, _, _, realm = GetGuildInfo("player")
    name = Plain(name)
    if not name then return nil end
    return T.DB:Guild(name, realm or GetRealmName())
end

local function received(level, mapId, rating, sender, channel)
    local who = fullName(sender)
    if not (who and level) then return end
    if level < 0 or isSelf(who) then return end
    local entry = {
        mapId = level > 0 and mapId or nil,
        level = level > 0 and level or nil,
        rating = rating,
    }
    if channel == "GUILD" then
        local guild = currentGuild()
        if not guild then return end
        entry.seenAt = GetServerTime()
        guild.keys[who] = entry
    elseif channel == "PARTY" then
        party[who] = entry
    end
end

local lastSent = {}
local waiting = {}

local function canSend(channel)
    if IsInInstance() then return false end
    if channel == "GUILD" then return IsInGuild() end
    return IsInGroup(LE_PARTY_CATEGORY_HOME)
end

local function send(channel, kind, build)
    if not canSend(channel) then return end
    local slot = channel .. " " .. kind
    local wait = THROTTLE - (GetTime() - (lastSent[slot] or 0))
    if wait > 0 then
        if not waiting[slot] then
            waiting[slot] = C_Timer.NewTimer(wait + 0.1, function()
                waiting[slot] = nil
                send(channel, kind, build)
            end)
        end
        return
    end
    lastSent[slot] = GetTime()
    C_ChatInfo.SendAddonMessage(PREFIX, build(), channel)
end

local function ownAnswer(channel)
    return function()
        local mapId, level = T.Snapshot:OwnKey()
        local rating = math.floor(T.Snapshot:Rating() + 0.5)
        if not mapId then
            return ("0,0,%d"):format(rating)
        end
        if channel == "GUILD" and not T.DB:Settings().shareWithGuild then
            return ("-1,-1,%d"):format(rating)
        end
        return ("%d,%d,%d"):format(level, mapId, rating)
    end
end

local function onAddonMessage(_, prefix, message, channel, sender)
    if prefix ~= PREFIX or (channel ~= "PARTY" and channel ~= "GUILD") then return end
    message, sender = Plain(message), Plain(sender)
    if not message or not sender then return end
    if message == "R" then
        if not isSelf(sender) then send(channel, "answer", ownAnswer(channel)) end
        return
    end
    local level, mapId, rating = message:match("^(%-?%d+),(%-?%d+),(%d+)$")
    if level then
        received(tonumber(level), tonumber(mapId), tonumber(rating), sender, channel)
    end
end

local lastAsked = { PARTY = 0, GUILD = 0 }

function Exchange:Ask(channel)
    if not canSend(channel) then return end
    lastAsked[channel] = GetTime()
    if lks and lks.Request then
        lks.Request(channel)
    else
        send(channel, "R", function() return "R" end)
    end
end

function Exchange:RefreshParty()
    if GetTime() - lastAsked.PARTY > ENOUGH_TIME then self:Ask("PARTY") end
end

function Exchange:UsesLibKeystone()
    return lks ~= nil
end

function Exchange:PartyKnown()
    local size = GetNumGroupMembers()
    if size == 0 then return nil end
    local known = 1
    local prefix = IsInRaid() and "raid" or "party"
    for i = 1, size do
        local name, realm = UnitFullName(prefix .. i)
        name, realm = Plain(name), Plain(realm)
        if name then
            local who = realm and realm ~= "" and (name .. "-" .. realm) or fullName(name)
            if not isSelf(who) and party[who] then known = known + 1 end
        end
    end
    return known, size
end

function Exchange:GuildKeysThisWeek()
    local guild = currentGuild()
    if not guild then return 0 end
    local since, n = T.DB:WeekStart(), 0
    for _, entry in pairs(guild.keys) do
        if entry.level and (entry.seenAt or 0) >= since then n = n + 1 end
    end
    return n
end

local function prune()
    local since = T.DB:WeekStart()
    for _, guild in pairs(T.DB:Data().guilds) do
        for who, entry in pairs(guild.keys) do
            if (entry.seenAt or 0) < since then guild.keys[who] = nil end
        end
    end
end

function Exchange:Start()
    prune()
    lks = LibStub and LibStub("LibKeystone", true)
    if lks then
        lks.Register(Exchange, function(level, mapId, rating, sender, channel)
            received(Plain(level), Plain(mapId), Plain(rating), Plain(sender), channel)
        end)
        if not T.DB:Settings().shareWithGuild and lks.SetGuildHidden then
            lks.SetGuildHidden(true)
        end
    else
        C_ChatInfo.RegisterAddonMessagePrefix(PREFIX)
        Addon:On("CHAT_MSG_ADDON", onAddonMessage)
    end

    Addon:On("GROUP_ROSTER_UPDATE", function()
        Addon:Debounce("party", 2, function() Exchange:Ask("PARTY") end)
    end)
    Addon:On("GROUP_LEFT", function() wipe(party) end)

    C_Timer.After(15, function() Exchange:Ask("GUILD") end)
    C_Timer.NewTicker(GUILD_INTERVAL, function() Exchange:Ask("GUILD") end)
end

function Exchange:ShareChanged(share)
    if lks and lks.SetGuildHidden then lks.SetGuildHidden(not share) end
end
