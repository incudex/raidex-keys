local _, T = ...
local L = T.L

local Sample = {}
T.Sample = Sample

local CHARS = {
    { name = "Raidex",     classId = 6,  level = 12, rating = 2648, runs = 5 },
    { name = "Frostbann",  classId = 8,  level = 10, rating = 2301, runs = 4 },
    { name = "Tarnkralle", classId = 3,  level = 8,  rating = 1974, runs = 2 },
    { name = "Donnerhuf",  classId = 11, level = 0,  rating = 1580, runs = 0 },
}

local GUILD = {
    { name = "Eisenbart",  level = 14, rating = 2810 },
    { name = "Silbermond", level = 12, rating = 2544 },
    { name = "Frostbann",  level = 10, rating = 2301 },
    { name = "Grollhuf",   level = 9,  rating = 2088 },
    { name = "Tarnkralle", level = 8,  rating = 1974 },
    { name = "Morgenstern", level = 7, rating = 1902 },
}

local PARTY = {
    { name = "Raidex",     level = 12, rating = 2648, classId = 6 },
    { name = "Eisenbart",  level = 14, rating = 2810 },
    { name = "Silbermond", level = 11, rating = 2544 },
    { name = "Tarnkralle", level = 8,  rating = 1974 },
    { name = "Wellenreiter", level = 0, rating = 1240 },
}

local THRESHOLDS = { 1, 4, 8 }
local ITEM_LEVELS = { 610, 616, 623 }

local function vault(runs)
    local slots = {}
    for i, threshold in ipairs(THRESHOLDS) do
        local unlocked = runs >= threshold
        slots[i] = {
            threshold = threshold, progress = runs,
            level = unlocked and 10 or 0,
            itemLevel = unlocked and ITEM_LEVELS[i] or nil,
        }
    end
    return slots
end

local function week(runs)
    local list = {}
    for i = 1, runs do list[i] = { timed = i % 4 ~= 0 } end
    return list
end

local AGES = { 120, 3600, 86400, 3 * 86400 }

local function age(i)
    return GetServerTime() - AGES[(i - 1) % #AGES + 1]
end

local function dungeons()
    local list = {}
    for mapId, map in pairs(T.DB:Data().maps or {}) do
        list[#list + 1] = { mapId = mapId, name = map.name }
    end
    table.sort(list, function(a, b) return a.mapId < b.mapId end)
    return list
end

local function dungeon(list, index)
    local map = list[(index - 1) % math.max(#list, 1) + 1]
    if map then return map.mapId, map.name end
    return nil, L["Example Dungeon %d"]:format(index)
end

local BEST_SCORES = { 345, 340, 335, 330, 330, 325, 325, 318 }
local BEST_CAP = 13

local BOARD = {
    { name = "Eisenbart",  classFile = "WARRIOR", level = 14, day = 0, minutes = 19 * 60,
      note = "A few more keys afterwards", applicants = 4 },
    { name = "Silbermond", classFile = "PRIEST",  level = 12, day = 1, minutes = 20 * 60 + 30,
      note = "", applicants = 10 },
    { name = "Frostbann",  classFile = "MAGE",    level = 10, day = 2, minutes = 18 * 60,
      note = "A calm run, questions welcome", applicants = 1 },
}
local ROLES = { "T", "H", "D", "D", "D" }
local APPLICANT_CLASSES = { "PALADIN", "DRUID", "HUNTER", "ROGUE", "SHAMAN" }

local function board(maps)
    local list = {}
    for i, entry in ipairs(BOARD) do
        local mapId = dungeon(maps, i + 2)
        local applicants = {}
        for n = 1, entry.applicants do
            local who = GUILD[(n - 1) % #GUILD + 1].name
            applicants[n] = { who = who .. (n > #GUILD and tostring(n) or ""),
                role = ROLES[(n - 1) % #ROLES + 1], classFile = APPLICANT_CLASSES[(n - 1) % #APPLICANT_CLASSES + 1],
                rating = 2400 - n * 37 }
        end
        list[i] = {
            id = "sample" .. i, holder = entry.name, name = entry.name, classFile = entry.classFile,
            mapId = mapId, level = entry.level,
            at = T.BoardPane.FormTime(entry.day, entry.minutes),
            note = L[entry.note], applicants = applicants,
            own = false, signedUp = false,
        }
    end
    return list
end

function Sample.View()
    local maps = dungeons()
    local view = { sample = true, chars = {}, party = {}, guild = { name = L["Example Guild"], keys = {} } }

    for i, char in ipairs(CHARS) do
        local mapId, name = dungeon(maps, i)
        view.chars[i] = {
            name = char.name, classId = char.classId, rating = char.rating,
            mapId = char.level > 0 and mapId or nil,
            dungeon = char.level > 0 and name or nil,
            level = char.level > 0 and char.level or nil,
            vault = vault(char.runs), runs = char.runs, week = week(char.runs),
            seenAt = age(i), own = i == 1,
        }
    end

    for i, entry in ipairs(PARTY) do
        local mapId, name = dungeon(maps, i + 1)
        view.party[i] = {
            name = entry.name, classId = entry.classId, rating = entry.rating,
            mapId = entry.level > 0 and mapId or nil,
            dungeon = entry.level > 0 and name or nil,
            level = entry.level > 0 and entry.level or nil,
            seenAt = age(i), own = i == 1,
        }
    end

    for i, entry in ipairs(GUILD) do
        local mapId, name = dungeon(maps, math.floor((i - 1) / 2) + 1)
        view.guild.keys[i] = {
            name = entry.name, rating = entry.rating,
            mapId = mapId, dungeon = name, level = entry.level,
            seenAt = age(i),
        }
    end

    local names, bests = {}, {}
    for i, score in ipairs(BEST_SCORES) do
        local mapId, name = dungeon(maps, i)
        mapId = mapId or -i
        if bests[mapId] == nil then
            bests[mapId], names[mapId] = score, name
        end
    end
    view.goalRating = CHARS[1].rating
    view.goals = T.Window.Goals(view, CHARS[1].rating, bests, BEST_CAP, names)
    view.board = board(maps)
    return view
end

function Sample.Tooltip()
    local maps = dungeons()
    local mapId, name = dungeon(maps, 1)
    return {
        mapId = mapId, dungeon = name, level = CHARS[1].level,
        known = 4, size = 5, guildKeys = #GUILD,
    }
end
