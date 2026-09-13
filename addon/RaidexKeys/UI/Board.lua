local _, T = ...
local L = T.L

local BoardPane = {}
T.BoardPane = BoardPane

local STEP_MINUTES = 15
local DAYS_AHEAD = 13
local ROLE_NAMES = { T = "TANK", H = "HEALER", D = "DAMAGER" }
local ROLE_FALLBACK = { T = "Tank", H = "Healer", D = "Damage" }
local WEEKDAYS = { "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" }

local pane
local mode, postId
local form = { day = 0, minutes = 19 * 60, note = "" }
local W, C

function BoardPane.DayText(at)
    local index = tonumber(date("%w", at)) + 1
    local names = CALENDAR_WEEKDAY_NAMES
    local weekday = names and names[index] or L[WEEKDAYS[index]]
    return ("%s, %s"):format(weekday, date(L["%m/%d"], at))
end

function BoardPane.TimeText(at)
    return date("%H:%M", at)
end

function BoardPane.RoleName(letter)
    return _G[ROLE_NAMES[letter] or "DAMAGER"] or L[ROLE_FALLBACK[letter] or "Damage"]
end

function BoardPane.FormTime(day, minutes)
    local t = date("*t", GetServerTime())
    t.hour, t.min, t.sec = 0, 0, 0
    t.day = t.day + (day or 0)
    return time(t) + (minutes or 0) * 60
end

local function formDefaults()
    local now = date("*t", GetServerTime() + 3600)
    local minutes = now.hour * 60 + now.min
    minutes = math.ceil(minutes / STEP_MINUTES) * STEP_MINUTES
    form.day = 0
    if minutes >= 24 * 60 then
        minutes = minutes - 24 * 60
        form.day = 1
    end
    form.minutes = minutes
    form.note = ""
end

local function whisper(name)
    local tell = (ChatFrameUtil and ChatFrameUtil.SendTell) or ChatFrame_SendTell
    if tell and name then tell(name) end
end

local function hex(color)
    return ("|cff%02x%02x%02x"):format(math.floor(color[1] * 255 + 0.5),
        math.floor(color[2] * 255 + 0.5), math.floor(color[3] * 255 + 0.5))
end

local function named(name, classFile)
    local color = W.ClassColor(nil, classFile) or C.text
    return hex(color) .. (name or "?") .. "|r"
end

local function button(label, onClick)
    return W.Button(pane, label, onClick)
end

function BoardPane:Create(frame, list)
    W, C = T.Window, T.Window.C
    pane = CreateFrame("Frame", nil, frame)
    pane:SetFrameLevel(frame:GetFrameLevel() + 3)
    pane:SetAllPoints(list)
    pane:EnableMouse(true)
    local background = W.Fill(pane, C.bg, 1)
    background:SetAllPoints()

    pane.title = W.Text(pane, 16, C.text)
    pane.sub = W.Text(pane, 12, C.muted)
    pane.note = W.Text(pane, 12, C.body)
    pane.note:SetWordWrap(true)
    pane.back = button(L["Back"], function() BoardPane:Close() end)
    pane.holder = button("", function() whisper(pane.holderName) end)
    pane.message = W.Text(pane, 12, C.muted)

    pane.lines = {}
    for i = 1, T.Board.MAX_APPLICANTS do
        local line = CreateFrame("Button", nil, pane)
        line.label = W.Text(line, 12, C.body)
        line.label:SetPoint("LEFT")
        line:SetScript("OnClick", function() whisper(line.who) end)
        line:SetScript("OnEnter", function() line.label:SetAlpha(0.75) end)
        line:SetScript("OnLeave", function() line.label:SetAlpha(1) end)
        pane.lines[i] = line
    end

    pane.roles = {}
    for _, letter in ipairs({ "T", "H", "D" }) do
        pane.roles[letter] = button("", function()
            if not T.Board:SignUp(postId, letter) then
                pane.message:SetText(L["The key is full."])
            end
        end)
    end
    pane.withdraw = button(L["Take back sign-up"], function() T.Board:Withdraw(postId) end)
    pane.remove = button(L["Take posting down"], function()
        T.Board:Remove(postId)
        BoardPane:Close()
    end)

    pane.dayLabel = W.Text(pane, 12, C.text, "CENTER")
    pane.dayPrev = button("<", function() form.day = math.max(0, form.day - 1) BoardPane:Refresh() end)
    pane.dayNext = button(">", function() form.day = math.min(DAYS_AHEAD, form.day + 1) BoardPane:Refresh() end)
    pane.timeLabel = W.Text(pane, 12, C.text, "CENTER")
    pane.timePrev = button("<", function()
        form.minutes = (form.minutes - STEP_MINUTES) % (24 * 60)
        BoardPane:Refresh()
    end)
    pane.timeNext = button(">", function()
        form.minutes = (form.minutes + STEP_MINUTES) % (24 * 60)
        BoardPane:Refresh()
    end)
    pane.noteLabel = W.Text(pane, 11, C.muted)
    pane.noteBox = CreateFrame("EditBox", nil, pane, "InputBoxTemplate")
    pane.noteBox:SetAutoFocus(false)
    if pane.noteBox.SetMaxBytes then pane.noteBox:SetMaxBytes(T.Board.NOTE_MAX + 1) end
    pane.noteBox:SetScript("OnEscapePressed", function(box) box:ClearFocus() end)
    pane.noteBox:SetScript("OnEnterPressed", function() BoardPane:Submit() end)
    pane.submit = button(L["Post"], function() BoardPane:Submit() end)
    pane.cancel = button(L["Cancel"], function() BoardPane:Close() end)

    pane:Hide()
end

function BoardPane:Arrange()
    if not pane then return end
    local M, factor = W.Metrics()
    local function gap(value) return math.floor(value * factor + 0.5) end
    local pad = M.PAD

    pane.back:ClearAllPoints()
    pane.back:SetPoint("TOPRIGHT", -pad, -gap(10))
    pane.title:ClearAllPoints()
    pane.title:SetPoint("TOPLEFT", pad, -gap(12))
    pane.title:SetPoint("RIGHT", pane.back, "LEFT", -gap(8), 0)
    pane.sub:ClearAllPoints()
    pane.sub:SetPoint("TOPLEFT", pane.title, "BOTTOMLEFT", 0, -gap(6))

    if mode == "form" then
        pane.dayPrev:ClearAllPoints()
        pane.dayPrev:SetPoint("TOPLEFT", pane.sub, "BOTTOMLEFT", 0, -gap(16))
        pane.dayLabel:ClearAllPoints()
        pane.dayLabel:SetPoint("LEFT", pane.dayPrev, "RIGHT", gap(6), 0)
        pane.dayLabel:SetWidth(gap(170))
        pane.dayNext:ClearAllPoints()
        pane.dayNext:SetPoint("LEFT", pane.dayLabel, "RIGHT", gap(6), 0)
        pane.timePrev:ClearAllPoints()
        pane.timePrev:SetPoint("LEFT", pane.dayNext, "RIGHT", gap(24), 0)
        pane.timeLabel:ClearAllPoints()
        pane.timeLabel:SetPoint("LEFT", pane.timePrev, "RIGHT", gap(6), 0)
        pane.timeLabel:SetWidth(gap(60))
        pane.timeNext:ClearAllPoints()
        pane.timeNext:SetPoint("LEFT", pane.timeLabel, "RIGHT", gap(6), 0)
        pane.noteLabel:ClearAllPoints()
        pane.noteLabel:SetPoint("TOPLEFT", pane.dayPrev, "BOTTOMLEFT", 0, -gap(16))
        pane.noteBox:ClearAllPoints()
        pane.noteBox:SetPoint("TOPLEFT", pane.noteLabel, "BOTTOMLEFT", gap(6), -gap(4))
        pane.noteBox:SetPoint("RIGHT", pane, "RIGHT", -pad, 0)
        pane.noteBox:SetHeight(gap(24))
        pane.submit:ClearAllPoints()
        pane.submit:SetPoint("TOPLEFT", pane.noteBox, "BOTTOMLEFT", -gap(6), -gap(14))
        pane.cancel:ClearAllPoints()
        pane.cancel:SetPoint("LEFT", pane.submit, "RIGHT", gap(16), 0)
        pane.message:ClearAllPoints()
        pane.message:SetPoint("TOPLEFT", pane.submit, "BOTTOMLEFT", 0, -gap(10))
        pane.message:SetPoint("RIGHT", pane, "RIGHT", -pad, 0)
        return
    end

    pane.holder:ClearAllPoints()
    pane.holder:SetPoint("LEFT", pane.sub, "RIGHT", gap(6), 0)
    pane.note:ClearAllPoints()
    pane.note:SetPoint("TOPLEFT", pane.sub, "BOTTOMLEFT", 0, -gap(8))
    pane.note:SetPoint("RIGHT", pane, "RIGHT", -pad, 0)
    local lineH = gap(18)
    for i, line in ipairs(pane.lines) do
        line:ClearAllPoints()
        line:SetPoint("TOPLEFT", pane.note, "BOTTOMLEFT", 0, -gap(12) - (i - 1) * lineH)
        line:SetPoint("RIGHT", pane, "RIGHT", -pad, 0)
        line:SetHeight(lineH)
    end
    local first
    for _, name in ipairs({ "T", "H", "D" }) do
        local role = pane.roles[name]
        role:ClearAllPoints()
        if first then role:SetPoint("LEFT", first, "RIGHT", gap(16), 0)
        else role:SetPoint("BOTTOMLEFT", pad, gap(10)) end
        first = role
    end
    pane.withdraw:ClearAllPoints()
    pane.withdraw:SetPoint("BOTTOMLEFT", pad, gap(10))
    pane.remove:ClearAllPoints()
    pane.remove:SetPoint("BOTTOMLEFT", pad, gap(10))
    pane.message:ClearAllPoints()
    pane.message:SetPoint("BOTTOMRIGHT", -pad, gap(12))
end

local POST_PARTS = { "holder", "note", "withdraw", "remove" }
local FORM_PARTS = { "dayLabel", "dayPrev", "dayNext", "timeLabel", "timePrev", "timeNext",
    "noteLabel", "noteBox", "submit", "cancel" }

local function showParts(parts, on)
    for _, name in ipairs(parts) do pane[name]:SetShown(on) end
end

local function mapName(mapId)
    local map = mapId and T.DB:Data().maps[mapId]
    return map and map.name or (mapId and C_ChallengeMode.GetMapUIInfo(mapId)) or "?"
end

local KEY_COLOR = "|cffa78bff"

local function drawPost()
    local post = T.Board:Find(postId)
    if not post then
        BoardPane:Close()
        return
    end
    showParts(FORM_PARTS, false)
    pane.title:SetText(("%s+%d|r %s"):format(KEY_COLOR, post.level or 0, mapName(post.mapId)))
    pane.sub:SetText(("%s · %s · %s"):format(BoardPane.DayText(post.at), BoardPane.TimeText(post.at), L["Key holder:"]))
    pane.holderName = post.holder
    pane.holder:SetLabel(named(post.name, post.classFile))
    pane.holder:Show()
    pane.note:SetText(post.note ~= "" and post.note or L["No note."])
    pane.note:Show()

    for i, line in ipairs(pane.lines) do
        local s = post.applicants[i]
        if s then
            line.who = s.who
            line.label:SetText(("%d. %s · %s · %d"):format(i, named(T.Exchange.ShortName(s.who), s.classFile),
                BoardPane.RoleName(s.role), s.rating or 0))
            line:Show()
        else
            line.who = nil
            line:SetShown(i == 1)
            if i == 1 then line.label:SetText(L["Nobody has signed up yet."]) end
        end
    end

    local full = #post.applicants >= T.Board.MAX_APPLICANTS
    local canSign = not post.own and not post.signedUp and not full
    for letter, role in pairs(pane.roles) do
        role:SetLabel(L["Sign up as %s"]:format(BoardPane.RoleName(letter)))
        role:SetShown(canSign)
    end
    pane.withdraw:SetShown(post.signedUp)
    pane.remove:SetShown(post.own)
    pane.withdraw:SetLabel(L["Take back sign-up"])
    pane.remove:SetLabel(L["Take posting down"])

    local message = T.Board.CountText(#post.applicants)
    if full and not post.own and not post.signedUp then
        message = L["Full - whisper %s to talk it over."]:format(post.name or "?")
    elseif post.own then
        message = L["Click a name to whisper."]
    end
    pane.message:SetText(message)
end

local function drawForm()
    showParts(POST_PARTS, false)
    for _, line in ipairs(pane.lines) do line:Hide() end
    for _, role in pairs(pane.roles) do role:Hide() end
    showParts(FORM_PARTS, true)

    local mapId, level = T.Snapshot:OwnKey()
    pane.title:SetText(mapId and ("%s+%d|r %s"):format(KEY_COLOR, level, mapName(mapId)) or L["No keystone in your bags."])
    pane.sub:SetText(T.Board:OwnPost() and L["Posting it replaces your earlier posting."] or L["Pin your key for a day and a time."])
    pane.dayLabel:SetText(BoardPane.DayText(BoardPane.FormTime(form.day, 0)))
    pane.timeLabel:SetText(("%02d:%02d"):format(math.floor(form.minutes / 60), form.minutes % 60))
    pane.noteLabel:SetText(L["Note, e.g. \"a few more keys afterwards\""])
    for _, name in ipairs({ "dayPrev", "timePrev" }) do pane[name]:SetLabel("<") end
    for _, name in ipairs({ "dayNext", "timeNext" }) do pane[name]:SetLabel(">") end
    pane.submit:SetLabel(L["Post"])
    pane.cancel:SetLabel(L["Cancel"])
    pane.submit:SetEnabled(mapId ~= nil)
end

function BoardPane:Refresh()
    if not pane then return end
    if not mode then
        pane:Hide()
        return
    end
    pane.back:SetLabel(L["Back"])
    if mode == "form" then drawForm() else drawPost() end
    if mode then
        self:Arrange()
        pane:Show()
    end
end

function BoardPane:IsOpen()
    return mode ~= nil
end

function BoardPane:Open(id)
    mode, postId = "post", id
    if pane then pane.message:SetText("") end
    T.Window:Refresh()
end

function BoardPane:OpenForm()
    mode, postId = "form", nil
    formDefaults()
    if pane then
        pane.noteBox:SetText("")
        pane.message:SetText("")
    end
    T.Window:Refresh()
end

function BoardPane:Close()
    mode, postId = nil, nil
    if pane then
        pane.noteBox:ClearFocus()
        pane:Hide()
    end
    if T.Window:IsShown() then T.Window:Refresh() end
end

function BoardPane:Submit()
    local at = BoardPane.FormTime(form.day, form.minutes)
    if at <= GetServerTime() then
        pane.message:SetText(L["That time has already passed."])
        return
    end
    local post = T.Board:Post(at, pane.noteBox:GetText())
    if not post then
        pane.message:SetText(L["No keystone in your bags."])
        return
    end
    pane.noteBox:ClearFocus()
    self:Open(post.id)
end
