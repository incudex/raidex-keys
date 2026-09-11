local _, T = ...

local SCHEMA = 1

local defaults = {
    chars = {},
    guilds = {},
    maps = {},
    affixes = {},
    settings = {
        shareWithGuild = true,
        minimap = { hide = false, angle = 225 },
    },
}

local function fill(target, source)
    for key, value in pairs(source) do
        if type(value) == "table" then
            if type(target[key]) ~= "table" then target[key] = {} end
            fill(target[key], value)
        elseif target[key] == nil then
            target[key] = value
        end
    end
end

local DB = {}
T.DB = DB

function DB:Initialize()
    if type(RaidexKeysDB) ~= "table" then RaidexKeysDB = {} end
    local db = RaidexKeysDB
    fill(db, defaults)
    db.schema = SCHEMA
    self.db = db
end

function DB:Data() return self.db end
function DB:Settings() return self.db.settings end

function DB:CountCharacters()
    local n = 0
    for _ in pairs(self.db.chars) do n = n + 1 end
    return n
end

function DB:Guild(name, realm)
    local key = name .. "-" .. realm
    local guild = self.db.guilds[key]
    if not guild then
        guild = { name = name, realm = realm, keys = {} }
        self.db.guilds[key] = guild
    end
    return guild
end

function DB:WeekStart()
    local untilReset = C_DateAndTime.GetSecondsUntilWeeklyReset() or 0
    return GetServerTime() + untilReset - 7 * 24 * 60 * 60
end
