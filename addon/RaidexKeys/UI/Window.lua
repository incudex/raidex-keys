local _, T = ...
local L = T.L

local Window = {}
T.Window = Window

local C = {
    bg       = { 0.055, 0.055, 0.125 },
    edge     = { 0.227, 0.196, 0.322 },
    header   = { 0.090, 0.071, 0.200 },
    info     = { 0.071, 0.063, 0.165 },
    divider  = { 0.102, 0.082, 0.251 },
    rowLine  = { 0.078, 0.071, 0.180 },
    tab      = { 0.102, 0.082, 0.251 },
    tabText  = { 0.780, 0.714, 1.000 },
    glow     = { 0.655, 0.545, 1.000 },
    text     = { 0.910, 0.918, 0.965 },
    body     = { 0.725, 0.741, 0.831 },
    options  = { 0.714, 0.729, 0.820 },
    muted    = { 0.557, 0.580, 0.722 },
    faint    = { 0.435, 0.455, 0.584 },
    dim      = { 0.290, 0.302, 0.400 },
    vault    = { 0.459, 0.373, 0.141 },
    gold     = { 0.788, 0.635, 0.153 },
}

local BASE_SIZE = 13
Window.SIZE_MIN, Window.SIZE_MAX, Window.DEFAULT_SIZE = 10, 18, BASE_SIZE

local BASE = {
    W = 620,
    HEADER = 40, INFO = 24, TABS_H = 26, HEAD_H = 20, ROW_H = 22, GROUP_H = 26, FOOTER_H = 26,
    PAD = 14, ACCENT = 7, COL_L = 16, COL_R = 16, GAP = 7,
    TAB_W = 84, ICON = 20, OPTIONS_H = 18, ARROW = 8, GRIP = 16,
    DOT = 6, DOT_GAP = 2, SLOT = 9, SLOT_GAP = 4,
    NAME_MAX = 210,
    BAR_W = 4, BAR_HIT = 10, THUMB_MIN = 16,
    EMPTY_HINT = 300, EMPTY_ACTION = 240,
}

local BASE_COLW = { name = 140, dungeon = 122, key = 34, week = 54, vault = 62, sync = 60, rating = 52 }

local ROWS, MIN_ROWS = 12, 4
local DOTS = 7
local ICON = "Interface\\AddOns\\RaidexKeys\\Media\\Icon"
local SORTABLE = { name = true, dungeon = true, key = true, rating = true }

local TABS = { "guild", "chars", "party", "goal", "board" }
local SORTED = { guild = true, chars = true, party = true }

local HEADING_FOR = {
    goal = { name = "Key holder", rating = "Gain" },
    board = { sync = "Time", name = "Holder", rating = "Signed up" },
}

local M, factor = { COLW = {} }, nil
local dims = { w = 0, h = 0 }

local function fontSize()
    local size = T.DB:Settings().window.fontSize or BASE_SIZE
    return math.max(Window.SIZE_MIN, math.min(Window.SIZE_MAX, size))
end

local function round(value)
    return math.floor(value + 0.5)
end

local function metrics()
    local f = fontSize() / BASE_SIZE
    if f == factor then return f end
    factor = f
    for key, value in pairs(BASE) do M[key] = round(value * f) end
    for key, value in pairs(BASE_COLW) do M.COLW[key] = round(value * f) end
    return f
end

local function chromeHeight()
    return M.HEADER + M.INFO + M.TABS_H + M.HEAD_H + M.FOOTER_H
end

local function minSize()
    local fixed, count = 0, 0
    for _, width in pairs(M.COLW) do
        fixed, count = fixed + width, count + 1
    end
    return M.COL_L + M.COL_R + fixed + M.GAP * (count - 1), chromeHeight() + MIN_ROWS * M.ROW_H
end

local function stored()
    local f = metrics()
    local settings = T.DB:Settings().window
    local w, h = M.W, chromeHeight() + ROWS * M.ROW_H
    if settings.w and settings.h then w, h = settings.w * f, settings.h * f end
    local minW, minH = minSize()
    local maxW = UIParent.GetWidth and UIParent:GetWidth() or 4096
    local maxH = UIParent.GetHeight and UIParent:GetHeight() or 4096
    return round(math.max(minW, math.min(math.max(minW, maxW), w))),
        round(math.max(minH, math.min(math.max(minH, maxH), h)))
end

local function measure()
    dims.w, dims.h = stored()
end

function Window.Size()
    return stored()
end

local function mapName(mapId)
    if not mapId then return nil end
    local map = T.DB:Data().maps[mapId]
    if map and map.name then return map.name end
    return C_ChallengeMode and C_ChallengeMode.GetMapUIInfo and C_ChallengeMode.GetMapUIInfo(mapId)
end

local function byRating(a, b)
    if (a.level or 0) ~= (b.level or 0) then return (a.level or 0) > (b.level or 0) end
    return (a.rating or 0) > (b.rating or 0)
end

function Window.View()
    local db = T.DB:Data()
    local guid = T.Plain(UnitGUID("player"))
    local player = T.Plain(UnitName("player"))
    local view = { chars = {}, party = T.Exchange:PartyKeys(), guild = T.Exchange:GuildView() }

    for charGuid, char in pairs(db.chars) do
        local key = char.key
        view.chars[#view.chars + 1] = {
            name = char.name, realm = char.realm, classId = char.classId,
            rating = char.rating or 0,
            mapId = key and key.mapId, level = key and key.level,
            dungeon = mapName(key and key.mapId),
            vault = char.vault, week = char.week, runs = char.week and #char.week or 0,
            seenAt = char.updatedAt,
            own = charGuid == guid,
        }
    end
    local seen = {}
    for _, row in ipairs(view.chars) do seen[row.name] = (seen[row.name] or 0) + 1 end
    for _, row in ipairs(view.chars) do
        if (seen[row.name] or 0) > 1 and row.realm then row.name = row.name .. "-" .. row.realm end
    end

    table.sort(view.chars, byRating)
    for i, entry in ipairs(view.party) do
        entry.dungeon = mapName(entry.mapId)
        entry.own = i == 1
    end
    table.sort(view.party, byRating)
    local guildKeys = view.guild and view.guild.keys or {}
    for _, entry in ipairs(guildKeys) do
        entry.dungeon = mapName(entry.mapId)
        entry.own = player ~= nil and entry.name == player
    end
    table.sort(guildKeys, byRating)

    local own = guid and db.chars[guid]
    if own and own.best and next(db.maps) and (next(own.best) or (own.rating or 0) == 0) then
        local bests = {}
        for mapId in pairs(db.maps) do
            local run = own.best[mapId]
            bests[mapId] = run and run.score or 0
        end
        view.goalRating = math.floor((own.rating or 0) + 0.5)
        view.goals = Window.Goals(view, view.goalRating, bests, T.Rating.LevelCap(own.best))
    end
    view.board = T.Board:View()
    return view
end

local function keyHolder(view, mapId, level)
    local found
    local function consider(row)
        if row.mapId == mapId and row.level and row.level >= level
            and (not found or row.level < found.level) then
            found = row
        end
    end
    for _, row in ipairs(view.chars or {}) do consider(row) end
    for _, row in ipairs(view.party or {}) do
        if not row.own then consider(row) end
    end
    for _, row in ipairs(view.guild and view.guild.keys or {}) do
        if not row.own then consider(row) end
    end
    return found
end

function Window.Goals(view, rating, bests, cap, names)
    local entries = {}
    for _, goal in ipairs(T.Rating.GOALS) do
        local plan = T.Rating.Plan(rating, goal, bests, cap)
        local note
        if not plan then note = L["out of reach"]
        elseif #plan == 0 then note = L["reached"]
        else note = #plan == 1 and L["1 run"] or L["%d runs"]:format(#plan) end
        entries[#entries + 1] = { group = true, title = tostring(goal), note = note }
        for _, run in ipairs(plan or {}) do
            local holder = keyHolder(view, run.mapId, run.level)
            local label = holder and holder.name
            if holder and holder.level ~= run.level then
                label = ("%s (+%d)"):format(holder.name, holder.level)
            end
            entries[#entries + 1] = {
                plan = true, mapId = run.mapId, level = run.level,
                dungeon = (names and names[run.mapId]) or mapName(run.mapId) or "?",
                rating = run.gain, ratingText = ("+%d"):format(run.gain),
                name = label, classId = holder and holder.classId, classFile = holder and holder.classFile,
            }
        end
    end
    return entries
end

function Window.BoardEntries(posts)
    local count = {}
    for _, post in ipairs(posts or {}) do
        local day = T.BoardPane.DayKey(post.at)
        count[day] = (count[day] or 0) + 1
    end
    local entries, current = {}, nil
    for _, post in ipairs(posts or {}) do
        local day = T.BoardPane.DayKey(post.at)
        if day ~= current then
            current = day
            entries[#entries + 1] = { group = true, title = T.BoardPane.DayText(post.at),
                note = count[day] == 1 and L["1 key"] or L["%d keys"]:format(count[day]) }
        end
        entries[#entries + 1] = {
            board = true, id = post.id, name = post.name, classFile = post.classFile,
            mapId = post.mapId, level = post.level, dungeon = mapName(post.mapId),
            syncText = T.BoardPane.TimeText(post.at),
            rating = #post.applicants,
            ratingText = T.Board.CountText(#post.applicants),
            own = post.own,
        }
    end
    return entries
end

function Window.Rows(view, tab)
    local rows
    if tab == "chars" then rows = view.chars
    elseif tab == "party" then rows = view.party
    elseif tab == "goal" then rows = view.goals or {}
    elseif tab == "board" then rows = Window.BoardEntries(view.board)
    else rows = view.guild and view.guild.keys or {} end
    return rows, view.sample == true
end

function Window.Grouped(tab, sort)
    if not SORTED[tab] then return true end
    return tab == "guild" and sort.col == "dungeon"
end

function Window.Columns(tab, grouped)
    if tab == "goal" then return { "dungeon", "key", "name", "rating" } end
    if tab == "board" then return { "sync", "name", "dungeon", "key", "rating" } end
    local cols = { "name" }
    if not grouped then cols[#cols + 1] = "dungeon" end
    cols[#cols + 1] = "key"
    if tab == "chars" then
        cols[#cols + 1] = "week"
        cols[#cols + 1] = "vault"
    end
    cols[#cols + 1] = "sync"
    cols[#cols + 1] = "rating"
    return cols
end

function Window.Layout(cols, width)
    metrics()
    width = width or (dims.w > 0 and dims.w) or stored()
    local fixed, hasDungeon = 0, false
    for _, col in ipairs(cols) do
        fixed = fixed + M.COLW[col]
        if col == "dungeon" then hasDungeon = true end
    end
    local slack = math.max(0, width - M.COL_L - M.COL_R - fixed - M.GAP * (#cols - 1))
    local extra = {}
    if hasDungeon then
        extra.name = math.min(math.floor(slack / 2), M.NAME_MAX - M.COLW.name)
        extra.dungeon = slack - extra.name
    else
        extra.name = slack
    end
    local pos, x = {}, M.COL_L
    for _, col in ipairs(cols) do
        local w = M.COLW[col] + (extra[col] or 0)
        pos[col] = { x = x, w = w }
        x = x + w + M.GAP
    end
    return pos
end

local function sortValue(row, col)
    if col == "name" then return (row.name or ""):lower() end
    if col == "dungeon" then return (row.dungeon or ""):lower() end
    if col == "key" then return row.level or -1 end
    return row.rating or -1
end

local function sorter(sort)
    local col, up = sort.col, sort.dir == "asc"
    return function(a, b)
        local left, right = sortValue(a, col), sortValue(b, col)
        if left ~= right then
            if up then return left < right end
            return left > right
        end
        if (a.rating or 0) ~= (b.rating or 0) then return (a.rating or 0) > (b.rating or 0) end
        return (a.name or ""):lower() < (b.name or ""):lower()
    end
end

function Window.Entries(rows, tab, sort)
    if not SORTED[tab] then return rows end
    local list = {}
    for i, row in ipairs(rows) do list[i] = row end
    table.sort(list, sorter(sort))

    if tab ~= "guild" then
        local own, rest = {}, {}
        for _, row in ipairs(list) do
            if row.own then own[#own + 1] = row else rest[#rest + 1] = row end
        end
        for _, row in ipairs(rest) do own[#own + 1] = row end
        list = own
    end

    if not Window.Grouped(tab, sort) then return list end

    local count = {}
    for _, row in ipairs(list) do
        local dungeon = row.dungeon or "-"
        count[dungeon] = (count[dungeon] or 0) + 1
    end
    local entries, current = {}, nil
    for _, row in ipairs(list) do
        local dungeon = row.dungeon or "-"
        if dungeon ~= current then
            current = dungeon
            entries[#entries + 1] = { group = true, dungeon = dungeon, count = count[dungeon] }
        end
        entries[#entries + 1] = row
    end
    return entries
end

function Window.IsEmpty(view, tab, entries)
    if tab == "chars" then return #view.chars <= 1 end
    if tab == "goal" then return view.goals == nil end
    return #entries == 0
end

function Window.EmptyState(view, tab)
    if tab == "chars" then
        return {
            title = L["No other characters"],
            hint = L["Only this character is stored. Log in with an alt, or type /reload, and it stands here."],
            action = "/reload",
        }
    end
    if tab == "party" then
        return {
            title = L["not in a group"],
            hint = L["Once you are in a group, the addon asks the others for their keys."],
        }
    end
    if tab == "goal" then
        return {
            title = L["No runs known yet"],
            hint = L["The goals are planned on this character's best runs of the season. The game hands them out a few seconds after login."],
        }
    end
    if tab == "board" then
        if not view.board then
            return { title = L["not in a guild"], hint = L["The key board is shared with your guild."] }
        end
        return {
            title = L["No keys on the board"],
            hint = L["Pin your key for a day and a time, and guild members sign up for it."],
            action = L["Post your key"],
            form = true,
        }
    end
    return {
        title = view.guild and L["No keys yet this week"] or L["not in a guild"],
        hint = L["Guild keys come through the LibKeystone protocol, as with BigWigs."],
        action = L["Share key with guild · Options"],
        options = true,
    }
end

function Window.FooterLeft(view, which)
    if which == "chars" then
        if #view.chars == 0 then return L["no characters stored yet"] end
        return L["%d characters"]:format(#view.chars)
    end
    if which == "party" then
        if #view.party == 0 then return L["not in a group"] end
        local known = 0
        for _, row in ipairs(view.party) do if row.level then known = known + 1 end end
        return ("%s · %s"):format(L["%d in the group"]:format(#view.party),
            L["%d / %d keys known"]:format(known, #view.party))
    end
    if which == "goal" then
        if not view.goals then return L["no runs known yet"] end
        return L["M+ rating %d · every run in time"]:format(view.goalRating or 0)
    end
    if which == "board" then
        if not view.board then return L["not in a guild"] end
        return #view.board == 1 and L["1 key on the board"] or L["%d keys on the board"]:format(#view.board)
    end
    if not view.guild then return L["not in a guild"] end
    local keys = #(view.guild.keys or {})
    return ("%s · %s"):format(view.guild.name,
        keys == 1 and L["1 key this week"] or L["%d keys this week"]:format(keys))
end

function Window.AffixText(view)
    if view.sample then
        return ("%s · %s"):format(L["Example affix"], L["Second example affix"])
    end
    local names = {}
    for _, id in ipairs(T.DB:Data().affixes or {}) do
        local name = C_ChallengeMode and C_ChallengeMode.GetAffixInfo
            and T.Plain(C_ChallengeMode.GetAffixInfo(id))
        if name then names[#names + 1] = name end
    end
    return table.concat(names, " · ")
end

function Window.ResetText()
    local seconds = C_DateAndTime and C_DateAndTime.GetSecondsUntilWeeklyReset
        and T.Plain(C_DateAndTime.GetSecondsUntilWeeklyReset())
    if not seconds or seconds <= 0 then return "" end
    local days = math.floor(seconds / 86400)
    local hours = math.floor((seconds % 86400) / 3600)
    if days > 0 then return L["%dd %dh"]:format(days, hours) end
    return L["%dh"]:format(math.max(1, hours))
end

function Window.Since(stamp)
    if not stamp then return "" end
    local seconds = GetServerTime() - stamp
    if seconds < 90 then return L["now"] end
    if seconds < 3600 then return L["%d min"]:format(math.floor(seconds / 60)) end
    if seconds < 86400 then return L["%d h"]:format(math.floor(seconds / 3600)) end
    if seconds < 2 * 86400 then return L["yesterday"] end
    return L["%d d"]:format(math.floor(seconds / 86400))
end

local function vaultItemLevel(slots)
    local best
    for _, slot in ipairs(slots or {}) do
        if (slot.progress or 0) >= (slot.threshold or 0) and slot.itemLevel then
            best = math.max(best or 0, slot.itemLevel)
        end
    end
    return best
end

local function vaultSlots(row)
    local slots = {}
    for i = 1, 3 do
        local slot = row.vault and row.vault[i]
        slots[i] = slot and (slot.progress or 0) >= (slot.threshold or 0) or false
    end
    return slots
end

local function fileColor(file)
    if not file then return nil end
    if C_ClassColor and C_ClassColor.GetClassColor then
        local color = C_ClassColor.GetClassColor(file)
        if color then return { color.r, color.g, color.b } end
    end
    local color = RAID_CLASS_COLORS and RAID_CLASS_COLORS[file]
    if color then return { color.r, color.g, color.b } end
    return nil
end

local function classColor(classId, classFile)
    local info = classId and C_CreatureInfo and C_CreatureInfo.GetClassInfo
        and C_CreatureInfo.GetClassInfo(classId)
    return fileColor(info and info.classFile) or fileColor(classFile)
end

local frame, list, tabButtons, headings, sortArrow, entryFrames, empty, info, footer, optionsButton
local tab, offset, preview, hovered = "chars", 0, false, nil
local R = { listTop = 0, listH = 0 }

local function defaultSort(name)
    if name == "guild" then return { col = "dungeon", dir = "asc" } end
    if not SORTED[name] then return { col = "none", dir = "asc" } end
    return { col = "rating", dir = "desc" }
end

local sorts = {}
for _, name in ipairs(TABS) do sorts[name] = defaultSort(name) end

local leaving = false

Window.FONTS = {
    { key = "marcellus", path = "Interface\\AddOns\\RaidexKeys\\Media\\Marcellus.ttf" },
    { key = "frizqt",    path = STANDARD_TEXT_FONT },
    { key = "arialn",    path = "Fonts\\ARIALN.TTF" },
}
Window.DEFAULT_FONT = "marcellus"

local function fontPath()
    local chosen = T.DB:Settings().window.font
    for _, font in ipairs(Window.FONTS) do
        if font.key == chosen then return font.path end
    end
    return Window.FONTS[1].path
end

local fontStrings = {}

local function setFont(fs, size)
    local scaled = round(size * metrics())
    if fs:SetFont(fontPath(), scaled) == false then fs:SetFont(STANDARD_TEXT_FONT, scaled) end
end

local function text(parent, size, color, justify)
    local fs = parent:CreateFontString(nil, "OVERLAY")
    setFont(fs, size)
    fs:SetTextColor(color[1], color[2], color[3])
    fs:SetJustifyH(justify or "LEFT")
    fontStrings[#fontStrings + 1] = { fs = fs, size = size }
    return fs
end

local function fill(parent, color, alpha, layer)
    local texture = parent:CreateTexture(nil, layer or "BACKGROUND")
    texture:SetColorTexture(color[1], color[2], color[3], alpha or 1)
    return texture
end

local function tint(region, color)
    region:SetTextColor(color[1], color[2], color[3])
end

Window.C = C
Window.Text = text
Window.Fill = fill
Window.Tint = tint
Window.ClassColor = classColor

function Window.Metrics()
    local f = metrics()
    return M, f
end

function Window.Button(parent, label, onClick)
    local button = CreateFrame("Button", nil, parent)
    button.label = text(button, 12, C.gold, "CENTER")
    button.label:SetPoint("CENTER")
    button:SetScript("OnClick", onClick)
    button:SetScript("OnEnter", function() tint(button.label, C.text) end)
    button:SetScript("OnLeave", function() tint(button.label, C.gold) end)
    button.SetLabel = function(self, value)
        local f = metrics()
        self.label:SetText(value or "")
        self:SetSize(math.max(self.label:GetStringWidth(), 8) + round(12 * f), M.OPTIONS_H)
    end
    button:SetLabel(label)
    return button
end

local function rule(parent, color)
    local texture = fill(parent, color, 1, "BORDER")
    texture:SetHeight(1)
    return texture
end

local function setRule(texture, y)
    texture:ClearAllPoints()
    texture:SetPoint("TOPLEFT", 1, -y)
    texture:SetPoint("TOPRIGHT", -1, -y)
end

local function edges(parent)
    local function line(point, otherPoint, width, height)
        local texture = parent:CreateTexture(nil, "BORDER")
        texture:SetColorTexture(C.edge[1], C.edge[2], C.edge[3], 1)
        texture:SetPoint(point)
        texture:SetPoint(otherPoint)
        if width then texture:SetWidth(width) else texture:SetHeight(height) end
    end
    line("TOPLEFT", "TOPRIGHT", nil, 1)
    line("BOTTOMLEFT", "BOTTOMRIGHT", nil, 1)
    line("TOPLEFT", "BOTTOMLEFT", 1)
    line("TOPRIGHT", "BOTTOMRIGHT", 1)
end

local function place()
    local settings = T.DB:Settings().window
    frame:ClearAllPoints()
    if settings.x and settings.y then
        frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", settings.x, settings.y)
    else
        frame:SetPoint("CENTER", UIParent, "CENTER", 0, 40)
    end
end

local function remember()
    local left, top = frame:GetLeft(), frame:GetTop()
    if left and top then
        local settings = T.DB:Settings().window
        settings.x, settings.y = left, top
    end
end

local function createHeader()
    R.headerBar = fill(frame, C.header)
    R.headerBar:SetPoint("TOPLEFT", 1, -1)
    R.headerBar:SetPoint("TOPRIGHT", -1, -1)

    R.drag = CreateFrame("Frame", nil, frame)
    R.drag:SetFrameLevel(frame:GetFrameLevel() + 1)
    R.drag:SetPoint("TOPLEFT")
    R.drag:SetPoint("TOPRIGHT")
    R.drag:EnableMouse(true)
    R.drag:RegisterForDrag("LeftButton")
    R.drag:SetScript("OnDragStart", function() T.BeginDrag(frame) end)
    R.drag:SetScript("OnDragStop", function()
        T.EndDrag(frame)
        remember()
        place()
    end)

    R.icon = frame:CreateTexture(nil, "ARTWORK")
    R.icon:SetTexture(ICON, "CLAMP", "CLAMP", "TRILINEAR")

    local title = text(frame, 14, C.text)
    title:SetPoint("LEFT", R.icon, "RIGHT", 8, 0)
    title:SetText(L["Raidex Keys"]:upper())

    local options = CreateFrame("Button", nil, frame)
    options.label = text(options, 12, C.options, "CENTER")
    options.label:SetPoint("CENTER")
    options.label:SetText(L["Options"])
    options:SetFrameLevel(frame:GetFrameLevel() + 4)
    optionsButton = options
    options:SetScript("OnClick", function() T.OpenOptions() end)
    options:SetScript("OnEnter", function() tint(options.label, C.text) end)
    options:SetScript("OnLeave", function() tint(options.label, C.options) end)

    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetFrameLevel(frame:GetFrameLevel() + 4)
    close:SetPoint("TOPRIGHT", 2, 2)
    close:SetScript("OnClick", function() Window:Close() end)
end

local function createInfo()
    R.infoBar = fill(frame, C.info)
    R.infoRule = rule(frame, C.divider)

    info = {}
    info.reset = text(frame, 12, C.gold, "RIGHT")
    info.resetLabel = text(frame, 10, C.muted, "RIGHT")
    info.resetLabel:SetPoint("RIGHT", info.reset, "LEFT", -8, 0)
    info.resetLabel:SetText(L["Reset in"]:upper())

    info.affixLabel = text(frame, 10, C.muted)
    info.affixLabel:SetText(L["Affixes"]:upper())

    info.affixes = text(frame, 10, C.tabText)
    info.affixes:SetPoint("LEFT", info.affixLabel, "RIGHT", 8, 0)
    info.affixes:SetPoint("RIGHT", info.resetLabel, "LEFT", -12, 0)
    info.affixes:SetWordWrap(false)
end

local function createTabs()
    tabButtons = {}
    for _, name in ipairs(TABS) do
        local button = CreateFrame("Button", nil, frame)
        button.background = fill(button, C.tab)
        button.background:SetAllPoints()
        button.underline = fill(button, C.glow, 1, "ARTWORK")
        button.underline:SetPoint("BOTTOMLEFT")
        button.underline:SetPoint("BOTTOMRIGHT")
        button.underline:SetHeight(2)
        button.label = text(button, 12, C.muted, "CENTER")
        button.label:SetPoint("CENTER")
        button:SetScript("OnClick", function()
            tab, offset = name, 0
            sorts[name] = defaultSort(name)
            T.DB:Settings().window.tab = name
            T.BoardPane:Close()
            Window:Refresh()
        end)
        tabButtons[name] = button
    end
    R.postButton = Window.Button(frame, L["Post your key"], function() T.BoardPane:OpenForm() end)
    R.postButton:Hide()
end

local function createHeadings()
    headings = {}
    for column in pairs(BASE_COLW) do
        local button = CreateFrame("Button", nil, frame)
        local justify = column == "rating" and "RIGHT" or "LEFT"
        button.label = text(button, 10, C.muted, justify)
        button.label:SetPoint(justify)
        button.label:SetWordWrap(false)
        button:SetScript("OnClick", function()
            if not SORTED[tab] then return end
            local sort = sorts[tab]
            if sort.col == column then
                sort.dir = sort.dir == "desc" and "asc" or "desc"
            else
                sort.col, sort.dir = column, column == "rating" and "desc" or "asc"
            end
            offset = 0
            Window:Refresh()
        end)
        button:SetScript("OnEnter", function()
            if SORTED[tab] and SORTABLE[column] then tint(button.label, C.tabText) end
        end)
        button:SetScript("OnLeave", function()
            tint(button.label, sorts[tab].col == column and C.tabText or C.muted)
        end)
        headings[column] = button
    end
    R.headRule = rule(frame, C.divider)

    sortArrow = frame:CreateTexture(nil, "OVERLAY")
    sortArrow:SetTexture("Interface\\ChatFrame\\ChatFrameExpandArrow")
    sortArrow:SetVertexColor(C.tabText[1], C.tabText[2], C.tabText[3])
    sortArrow:Hide()
end

local function column(region, pos, name, justify)
    local box = pos[name]
    if not box then region:Hide() return nil end
    region:ClearAllPoints()
    if justify == "RIGHT" then
        region:SetPoint("RIGHT", box.x + box.w - dims.w + 1, 0)
    else
        region:SetPoint("LEFT", box.x - 1, 0)
    end
    if region.SetWidth then region:SetWidth(box.w) end
    region:Show()
    return box
end

local function linkKey(row)
    if not row.level then return end
    if row.own then
        local link = T.MinimapButton.KeystoneLink()
        if link then T.MinimapButton.LinkInChat(link) return end
    end
    T.MinimapButton.LinkInChat(("%s: %s +%d"):format(row.name or "?", row.dungeon or "?", row.level))
end

local function createEntry()
    local entry = CreateFrame("Frame", nil, list)
    entry:SetWidth(dims.w - 2)
    entry:EnableMouse(true)

    entry.hover = fill(entry, C.glow, 0.06)
    entry.hover:SetAllPoints()
    entry.accent = fill(entry, C.glow, 1, "ARTWORK")
    entry.accent:SetWidth(2)
    entry.line = fill(entry, C.rowLine, 1, "BORDER")
    entry.line:SetPoint("BOTTOMLEFT")
    entry.line:SetPoint("BOTTOMRIGHT")
    entry.line:SetHeight(1)

    entry.name = text(entry, 13, C.text)
    entry.name:SetWordWrap(false)
    entry.dungeon = text(entry, 13, C.body)
    entry.dungeon:SetWordWrap(false)
    entry.key = text(entry, 13, C.glow)
    entry.rating = text(entry, 13, C.text, "RIGHT")
    entry.sync = text(entry, 11, C.faint)
    entry.ilvl = text(entry, 11, C.muted, "RIGHT")

    entry.dots = {}
    for i = 1, DOTS do entry.dots[i] = entry:CreateTexture(nil, "ARTWORK") end

    entry.slots = {}
    for i = 1, 3 do entry.slots[i] = entry:CreateTexture(nil, "ARTWORK") end

    entry.groupName = text(entry, 12, C.body)
    entry.groupCount = text(entry, 11, C.muted, "RIGHT")
    entry.groupLine = fill(entry, C.divider, 1, "ARTWORK")
    entry.groupLine:SetHeight(1)

    entry:SetScript("OnEnter", function()
        local row = entry.row
        if not row then return end
        hovered = entry
        entry.hover:Show()
        local hint = ""
        if row.board then
            hint = L["Click: details and sign-up"]
        elseif row.level and not row.plan then
            hint = L["Right-click: link key in chat"]
        end
        footer.hint:SetText(hint)
    end)
    entry:SetScript("OnLeave", function()
        if hovered == entry then hovered = nil end
        entry.hover:Hide()
        footer.hint:SetText("")
    end)
    entry:SetScript("OnMouseUp", function(_, button)
        local row = entry.row
        if not row or entry.sample then return end
        if row.board then
            if button == "LeftButton" then T.BoardPane:Open(row.id) end
        elseif button == "RightButton" and not row.plan then
            linkKey(row)
        end
    end)
    return entry
end

local function hideRow(entry)
    entry.dungeon:Hide()
    entry.key:Hide()
    entry.rating:Hide()
    entry.sync:Hide()
    entry.ilvl:Hide()
    for _, dot in ipairs(entry.dots) do dot:Hide() end
    for _, slot in ipairs(entry.slots) do slot:Hide() end
end

local function drawGroup(entry, group)
    entry:SetHeight(M.GROUP_H)
    entry.row, entry.sample = nil, false
    entry.hover:Hide()
    entry.accent:Hide()
    entry.line:Hide()
    hideRow(entry)

    entry.name:Hide()
    entry.groupName:Show()
    entry.groupName:ClearAllPoints()
    entry.groupName:SetPoint("BOTTOMLEFT", M.COL_L - 1, round(5 * factor))
    entry.groupName:SetText(group.title or group.dungeon)

    entry.groupCount:Show()
    entry.groupCount:ClearAllPoints()
    entry.groupCount:SetPoint("BOTTOMRIGHT", -(M.COL_R - 1), round(6 * factor))
    entry.groupCount:SetText(group.note
        or (group.count == 1 and L["1 key"] or L["%d keys"]:format(group.count)))

    entry.groupLine:Show()
    entry.groupLine:ClearAllPoints()
    entry.groupLine:SetPoint("LEFT", entry.groupName, "RIGHT", 8, 1)
    entry.groupLine:SetPoint("RIGHT", entry.groupCount, "LEFT", -8, 1)
end

local function drawRow(entry, row, pos, sample)
    entry:SetHeight(M.ROW_H)
    entry.row, entry.sample = row, sample
    entry.line:Show()
    entry.groupName:Hide()
    entry.groupCount:Hide()
    entry.groupLine:Hide()
    entry.hover:SetShown(hovered == entry)
    entry.accent:ClearAllPoints()
    entry.accent:SetPoint("TOPLEFT", M.ACCENT, 0)
    entry.accent:SetPoint("BOTTOMLEFT", M.ACCENT, 0)
    entry.accent:SetShown(row.own == true)

    column(entry.name, pos, "name")
    entry.name:SetText(row.name or (row.plan and "-" or "?"))
    local color = classColor(row.classId, row.classFile) or (row.plan and not row.name and C.dim) or C.text
    tint(entry.name, color)

    if column(entry.dungeon, pos, "dungeon") then
        entry.dungeon:SetText(row.dungeon or "-")
    end

    if column(entry.key, pos, "key") then
        entry.key:SetText(row.level and ("+%d"):format(row.level) or "-")
        tint(entry.key, row.level and C.glow or C.dim)
    end

    local box = pos.week
    for i, dot in ipairs(entry.dots) do
        local run = box and row.week and row.week[i]
        if run then
            dot:SetSize(M.DOT, M.DOT)
            dot:ClearAllPoints()
            dot:SetPoint("LEFT", box.x - 1 + (i - 1) * (M.DOT + M.DOT_GAP), 0)
            if run.timed then
                dot:SetColorTexture(C.glow[1], C.glow[2], C.glow[3], 1)
            else
                dot:SetColorTexture(C.muted[1], C.muted[2], C.muted[3], 0.30)
            end
            dot:Show()
        else
            dot:Hide()
        end
    end

    box = pos.vault
    local slots = box and vaultSlots(row)
    for i, slot in ipairs(entry.slots) do
        if slots then
            slot:SetSize(M.SLOT, M.SLOT)
            slot:ClearAllPoints()
            slot:SetPoint("LEFT", box.x - 1 + (i - 1) * (M.SLOT + M.SLOT_GAP), 0)
            if slots[i] then
                slot:SetColorTexture(C.vault[1], C.vault[2], C.vault[3], 1)
            else
                slot:SetColorTexture(C.muted[1], C.muted[2], C.muted[3], 0.12)
            end
            slot:Show()
        else
            slot:Hide()
        end
    end
    if box then
        local itemLevel = vaultItemLevel(row.vault)
        entry.ilvl:ClearAllPoints()
        entry.ilvl:SetPoint("RIGHT", box.x + box.w - dims.w + 1, 0)
        entry.ilvl:SetText(itemLevel and tostring(itemLevel) or "")
        entry.ilvl:Show()
    else
        entry.ilvl:Hide()
    end

    if column(entry.sync, pos, "sync") then
        entry.sync:SetText(row.syncText or Window.Since(row.seenAt))
    end

    if column(entry.rating, pos, "rating", "RIGHT") then
        entry.rating:SetText(row.ratingText or (row.rating and math.floor(row.rating + 0.5)) or "-")
    end

    entry:SetAlpha(sample and 0.55 or 1)
end

local function createList()
    list = CreateFrame("Frame", nil, frame)
    if list.SetClipsChildren then list:SetClipsChildren(true) end
    entryFrames = {}

    empty = CreateFrame("Frame", nil, list)
    empty:SetAllPoints()
    empty.title = text(empty, 14, C.body, "CENTER")
    empty.hint = text(empty, 12, C.muted, "CENTER")
    empty.hint:SetPoint("TOP", empty.title, "BOTTOM", 0, -10)
    empty.hint:SetSpacing(3)

    empty.action = CreateFrame("Button", nil, empty)
    empty.action.label = text(empty.action, 12, C.gold, "CENTER")
    empty.action.label:SetPoint("CENTER")
    empty.action:SetPoint("TOP", empty.hint, "BOTTOM", 0, -10)
    empty.action:SetScript("OnClick", function()
        if empty.action.opens == "options" then
            T.OpenOptions()
        elseif empty.action.opens == "form" then
            T.BoardPane:OpenForm()
        end
    end)
    empty:Hide()

    T.BoardPane:Create(frame, list)
end

local function createFooter()
    R.footerRule = rule(frame, C.divider)

    footer = {}
    footer.left = text(frame, 12, C.muted)
    footer.hint = text(frame, 11, C.faint)
    footer.hint:SetPoint("LEFT", footer.left, "RIGHT", 12, 0)
    footer.right = text(frame, 12, C.gold, "RIGHT")
end

local function maxOffset(entries)
    local used = 0
    for i = #entries, 1, -1 do
        used = used + (entries[i].group and M.GROUP_H or M.ROW_H)
        if used > R.listH then return i end
    end
    return 0
end

local function visibleRows()
    return math.max(1, math.floor(R.listH / M.ROW_H))
end

local scrollBar, thumb
local maxScroll, scrollRoom = 0, 0

local function scrollTo(value)
    value = math.max(0, math.min(maxScroll, value))
    if value == offset then return end
    offset = value
    Window:Refresh()
end

local function cursorY(region)
    local _, y = GetCursorPosition()
    return y / region:GetEffectiveScale()
end

local function createScrollBar()
    scrollBar = CreateFrame("Frame", nil, frame)
    scrollBar:SetFrameLevel(frame:GetFrameLevel() + 5)
    scrollBar:SetPoint("TOPRIGHT", list, "TOPRIGHT", -3, -2)
    scrollBar:SetPoint("BOTTOMRIGHT", list, "BOTTOMRIGHT", -3, 2)
    scrollBar:EnableMouse(true)
    scrollBar:SetScript("OnMouseDown", function(_, button)
        if button ~= "LeftButton" then return end
        local y, top, bottom = cursorY(scrollBar), thumb:GetTop(), thumb:GetBottom()
        if top and y > top then
            scrollTo(offset - visibleRows())
        elseif bottom and y < bottom then
            scrollTo(offset + visibleRows())
        end
    end)

    thumb = CreateFrame("Frame", nil, scrollBar)
    thumb:EnableMouse(true)
    thumb.fill = fill(thumb, C.edge, 1, "ARTWORK")
    thumb.fill:SetPoint("TOP")
    thumb.fill:SetPoint("BOTTOM")

    local function shade(color)
        thumb.fill:SetColorTexture(color[1], color[2], color[3], 1)
    end
    thumb:SetScript("OnEnter", function() shade(C.faint) end)
    thumb:SetScript("OnLeave", function() if not thumb.dragging then shade(C.edge) end end)
    thumb:SetScript("OnMouseDown", function(_, button)
        if button ~= "LeftButton" then return end
        thumb.dragging = { y = cursorY(thumb), offset = offset }
        thumb:SetScript("OnUpdate", function()
            if scrollRoom <= 0 then return end
            local moved = thumb.dragging.y - cursorY(thumb)
            scrollTo(thumb.dragging.offset + math.floor(moved / scrollRoom * maxScroll + 0.5))
        end)
    end)
    thumb:SetScript("OnMouseUp", function()
        thumb.dragging = nil
        thumb:SetScript("OnUpdate", nil)
        if not thumb:IsMouseOver() then shade(C.edge) end
    end)
    scrollBar:Hide()
end

local function drawScrollBar(entries)
    maxScroll = maxOffset(entries)
    if maxScroll == 0 then
        scrollRoom = 0
        scrollBar:Hide()
        return
    end
    local total = 0
    for _, item in ipairs(entries) do total = total + (item.group and M.GROUP_H or M.ROW_H) end
    local track = R.listH - 4
    local height = math.max(M.THUMB_MIN, math.floor(track * R.listH / total))
    scrollRoom = track - height
    thumb:SetHeight(height)
    thumb:ClearAllPoints()
    thumb:SetPoint("TOP", scrollBar, "TOP", 0, -math.floor(scrollRoom * offset / maxScroll + 0.5))
    scrollBar:Show()
end

local function createGrip()
    R.grip = CreateFrame("Button", nil, frame)
    R.grip:SetFrameLevel(frame:GetFrameLevel() + 6)
    R.grip:SetPoint("BOTTOMRIGHT", -1, 1)
    R.grip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    R.grip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    R.grip:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    R.grip:SetScript("OnMouseDown", function(_, button)
        if button ~= "LeftButton" then return end
        remember()
        place()
        frame:StartSizing("BOTTOMRIGHT")
    end)
    R.grip:SetScript("OnMouseUp", function()
        frame:StopMovingOrSizing()
        Window:KeepSize()
        remember()
        place()
    end)
end

local function applyBounds()
    local minW, minH = minSize()
    local maxW = UIParent.GetWidth and UIParent:GetWidth() or 4096
    local maxH = UIParent.GetHeight and UIParent:GetHeight() or 4096
    if frame.SetResizeBounds then
        frame:SetResizeBounds(minW, minH, math.max(minW, maxW), math.max(minH, maxH))
    elseif frame.SetMinResize then
        frame:SetMinResize(minW, minH)
    end
end

local function arrange()
    R.listTop = M.HEADER + M.INFO + M.TABS_H + M.HEAD_H
    R.listH = math.max(M.ROW_H, dims.h - R.listTop - M.FOOTER_H)

    R.headerBar:SetHeight(M.HEADER - 1)
    R.drag:SetHeight(M.HEADER)
    R.icon:SetSize(M.ICON, M.ICON)
    R.icon:ClearAllPoints()
    R.icon:SetPoint("TOPLEFT", M.PAD, -math.floor((M.HEADER - M.ICON) / 2))
    optionsButton:SetSize(math.max(optionsButton.label:GetStringWidth(), 10) + 8, M.OPTIONS_H)
    optionsButton:ClearAllPoints()
    optionsButton:SetPoint("TOPRIGHT", -28, -math.floor((M.HEADER - M.OPTIONS_H) / 2))

    R.infoBar:ClearAllPoints()
    R.infoBar:SetPoint("TOPLEFT", 1, -M.HEADER)
    R.infoBar:SetPoint("TOPRIGHT", -1, -M.HEADER)
    R.infoBar:SetHeight(M.INFO)
    setRule(R.infoRule, M.HEADER + M.INFO - 1)
    info.reset:ClearAllPoints()
    info.reset:SetPoint("RIGHT", R.infoBar, "RIGHT", -M.PAD, 0)
    info.affixLabel:ClearAllPoints()
    info.affixLabel:SetPoint("LEFT", R.infoBar, "LEFT", M.PAD, 0)

    for i, name in ipairs(TABS) do
        local button = tabButtons[name]
        button:SetSize(M.TAB_W, M.TABS_H)
        button:ClearAllPoints()
        button:SetPoint("TOPLEFT", M.PAD + (i - 1) * M.TAB_W, -(M.HEADER + M.INFO))
    end
    R.postButton:ClearAllPoints()
    R.postButton:SetPoint("RIGHT", frame, "TOPRIGHT", -M.PAD, -(M.HEADER + M.INFO + math.floor(M.TABS_H / 2)))

    for _, button in pairs(headings) do button:SetHeight(M.HEAD_H) end
    setRule(R.headRule, R.listTop - 1)
    sortArrow:SetSize(M.ARROW, M.ARROW)

    list:ClearAllPoints()
    list:SetPoint("TOPLEFT", 1, -R.listTop)
    list:SetSize(dims.w - 2, R.listH)
    for _, entry in ipairs(entryFrames) do entry:SetWidth(dims.w - 2) end

    empty.title:ClearAllPoints()
    empty.title:SetPoint("TOP", 0, -math.max(0, math.floor(R.listH / 2) - round(34 * factor)))
    empty.title:SetWidth(math.max(0, dims.w - 80))
    empty.hint:SetWidth(M.EMPTY_HINT)
    empty.action:SetSize(M.EMPTY_ACTION, M.OPTIONS_H)

    scrollBar:SetWidth(M.BAR_HIT)
    thumb:SetWidth(M.BAR_HIT)
    thumb.fill:SetWidth(M.BAR_W)

    setRule(R.footerRule, dims.h - M.FOOTER_H)
    local lift = round(8 * factor)
    footer.left:ClearAllPoints()
    footer.left:SetPoint("BOTTOMLEFT", M.PAD, lift)
    footer.right:ClearAllPoints()
    footer.right:SetPoint("BOTTOMRIGHT", -(M.PAD + M.GRIP), lift)

    R.grip:SetSize(M.GRIP, M.GRIP)
end

local function applySize()
    frame:SetSize(dims.w, dims.h)
    applyBounds()
    arrange()
    Window:Refresh()
end

local function create()
    measure()
    frame = CreateFrame("Frame", "RaidexKeysWindow", UIParent)
    frame:SetFrameStrata("HIGH")
    frame:SetToplevel(true)
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:SetResizable(true)
    frame:EnableMouse(true)
    frame:EnableMouseWheel(true)
    frame:SetScript("OnMouseWheel", function(_, delta)
        local view = Window.view or Window.View()
        local rows = Window.Rows(view, tab)
        local entries = Window.Entries(rows, tab, sorts[tab])
        offset = math.min(maxOffset(entries), math.max(0, offset - delta))
        Window:Refresh()
    end)
    frame:SetScript("OnSizeChanged", function(_, width, height)
        width, height = round(width), round(height)
        if width == dims.w and height == dims.h then return end
        dims.w, dims.h = width, height
        arrange()
        Window:Refresh()
    end)

    frame:SetScript("OnHide", function()
        if not leaving then T.DB:Settings().window.open = false end
    end)
    local kept = T.DB:Settings().window.tab
    for _, name in ipairs(TABS) do
        if name == kept then tab = name end
    end

    local background = fill(frame, C.bg, 0.95)
    background:SetAllPoints()
    edges(frame)

    createHeader()
    createInfo()
    createTabs()
    createHeadings()
    createList()
    createScrollBar()
    createFooter()
    createGrip()
    frame:SetSize(dims.w, dims.h)
    applyBounds()
    arrange()
    place()
    frame:Hide()

    if UISpecialFrames then UISpecialFrames[#UISpecialFrames + 1] = "RaidexKeysWindow" end
end

local function tabLabel(name)
    if name == "chars" then return L["Alts"] end
    if name == "party" then return L["Group"] end
    if name == "goal" then return L["Rating goals"] end
    if name == "board" then return L["Board"] end
    return L["Guild"]
end

local HEADING = {
    name = "Character", dungeon = "Dungeon", key = "Key",
    week = "Week", vault = "Vault", sync = "Updated", rating = "Rating",
}

Window.TABS = TABS
Window.DefaultSort = defaultSort
Window.TabLabel = tabLabel

function Window.Sorted(which)
    return SORTED[which] == true
end

function Window.HeadingLabel(which, col)
    local label = HEADING_FOR[which] and HEADING_FOR[which][col] or HEADING[col]
    return L[label]:upper()
end

local function drawHeadings(pos, sort, which)
    local sorted = SORTED[which] == true
    for name, button in pairs(headings) do
        local box = pos[name]
        if box then
            local label = HEADING_FOR[which] and HEADING_FOR[which][name] or HEADING[name]
            button:ClearAllPoints()
            button:SetPoint("TOPLEFT", box.x, -(R.listTop - M.HEAD_H))
            button:SetWidth(box.w)
            button.label:SetWidth(box.w)
            button.label:SetText(L[label]:upper())
            tint(button.label, sorted and sort.col == name and C.tabText or C.muted)
            button:SetEnabled(sorted and SORTABLE[name] == true)
            button:Show()
        else
            button:Hide()
        end
    end

    local box = pos[sort.col]
    if not (sorted and box) then sortArrow:Hide() return end
    sortArrow:ClearAllPoints()
    if sort.col == "rating" then
        sortArrow:SetPoint("RIGHT", headings.rating.label, "LEFT", -3, 0)
    else
        sortArrow:SetPoint("LEFT", headings[sort.col].label, "LEFT",
            math.min(headings[sort.col].label:GetStringWidth() + 4, box.w), 0)
    end
    sortArrow:SetRotation(sort.dir == "desc" and -math.pi / 2 or math.pi / 2)
    sortArrow:Show()
end

local function drawEntries(entries, pos, sample)
    local used, shown = 0, 0
    for index = offset + 1, #entries do
        if used >= R.listH then break end
        shown = shown + 1
        local entry = entryFrames[shown]
        if not entry then
            entry = createEntry()
            entryFrames[shown] = entry
        end
        entry:ClearAllPoints()
        entry:SetPoint("TOPLEFT", 0, -used)
        local item = entries[index]
        if item.group then drawGroup(entry, item) else drawRow(entry, item, pos, sample) end
        entry:Show()
        used = used + (item.group and M.GROUP_H or M.ROW_H)
    end
    for i = shown + 1, #entryFrames do
        entryFrames[i].row = nil
        entryFrames[i]:Hide()
    end
end

local function drawEmpty(state)
    empty.title:SetText(state.title)
    empty.hint:SetText(state.hint)
    empty.action.opens = (state.options and "options") or (state.form and "form") or nil
    empty.action:EnableMouse(empty.action.opens ~= nil)
    empty.action.label:SetText(state.action or "")
    empty.action:SetShown(state.action ~= nil)
    empty:Show()
end

function Window:Refresh()
    if not frame or not frame:IsShown() then return end
    local view = preview and T.Sample.View() or Window.View()
    Window.view = view
    local rows, sample = Window.Rows(view, tab)
    local sort = sorts[tab]
    local entries = Window.Entries(rows, tab, sort)

    for _, name in ipairs(TABS) do
        local button = tabButtons[name]
        local active = name == tab
        button.label:SetText(tabLabel(name))
        button.background:SetShown(active)
        button.underline:SetShown(active)
        tint(button.label, active and C.tabText or C.muted)
    end

    info.affixes:SetText(Window.AffixText(view))
    info.reset:SetText(Window.ResetText())

    local pos = Window.Layout(Window.Columns(tab, Window.Grouped(tab, sort)), dims.w)
    R.postButton:SetShown(tab == "board" and not sample and view.board ~= nil)

    local paneOpen = T.BoardPane:IsOpen()
    if paneOpen and (tab ~= "board" or sample) then
        T.BoardPane:Close()
        return
    end

    offset = math.max(0, math.min(offset, maxOffset(entries)))
    if paneOpen then
        for _, button in pairs(headings) do button:Hide() end
        sortArrow:Hide()
        hovered = nil
        for _, entry in ipairs(entryFrames) do entry.row = nil entry:Hide() end
        footer.hint:SetText("")
        scrollBar:Hide()
        empty:Hide()
        T.BoardPane:Refresh()
    elseif Window.IsEmpty(view, tab, entries) then
        drawHeadings(pos, sort, tab)
        hovered = nil
        for _, entry in ipairs(entryFrames) do entry.row = nil entry:Hide() end
        footer.hint:SetText("")
        scrollBar:Hide()
        drawEmpty(Window.EmptyState(view, tab))
    else
        drawHeadings(pos, sort, tab)
        empty:Hide()
        drawEntries(entries, pos, sample)
        drawScrollBar(entries)
    end

    footer.left:SetText(Window.FooterLeft(view, tab))
    footer.right:SetText(sample and L["Sample values"] or "")
end

function Window:Restyle()
    measure()
    if not frame then return end
    for _, entry in ipairs(fontStrings) do setFont(entry.fs, entry.size) end
    applySize()
end

local ticker

function Window:Open(which)
    if not frame then create() end
    if which then tab, offset = which, 0 end
    local settings = T.DB:Settings().window
    settings.open, settings.tab = true, tab
    frame:Show()
    self:Refresh()
    T.Exchange:RefreshParty()
    T.Exchange:RefreshGuild()
    if not ticker then ticker = C_Timer.NewTicker(5, function() Window:Refresh() end) end
end

function Window:Close()
    T.DB:Settings().window.open = false
    if frame then frame:Hide() end
    if ticker then ticker:Cancel() ticker = nil end
    hovered = nil
    if preview and T.Preview then T.Preview:Stop() end
end

function Window:KeepSize()
    if not frame then return end
    local settings = T.DB:Settings().window
    settings.w = (frame:GetWidth() or dims.w) / factor
    settings.h = (frame:GetHeight() or dims.h) / factor
end

function Window:ResetPosition()
    local settings = T.DB:Settings().window
    settings.x, settings.y = nil, nil
    if frame then place() end
end

function Window:Toggle()
    if frame and frame:IsShown() then self:Close() else self:Open() end
end

function Window:IsShown()
    return frame ~= nil and frame:IsShown()
end

function Window:SetPreview(on)
    preview = on
    offset = 0
    if on then self:Open() else self:Refresh() end
end

function Window:Start()
    local function restore()
        if T.DB:Settings().window.open and not self:IsShown() then self:Open() end
    end
    T.Addon:On("PLAYER_LEAVING_WORLD", function() leaving = true end)
    T.Addon:On("LOADING_SCREEN_ENABLED", function() leaving = true end)
    T.Addon:On("LOADING_SCREEN_DISABLED", function()
        leaving = false
        restore()
    end)
    T.Addon:On("PLAYER_ENTERING_WORLD", restore)
end
