local _, T = ...
local L = T.L

local RaidPane = {}
T.RaidPane = RaidPane

local ROLES = { "T", "H", "D" }
local ROLE_LABELS = { T = "Tank", H = "Healer", D = "DPS" }
local ROLE_W, LEVEL_W = 110, 120
local NOTE_W = 360

local pane, raidKey
local offset = 0
local selected
local hovered
local discarding = false
local W, C

function RaidPane.RoleName(letter)
    return L[ROLE_LABELS[letter] or "DPS"]
end

local ROLE_ATLAS = { T = "UI-LFG-RoleIcon-Tank-Micro", H = "UI-LFG-RoleIcon-Healer-Micro", D = "UI-LFG-RoleIcon-DPS-Micro" }

local function pickRole(letter)
    if selected then
        T.Raids:SetRole(raidKey, selected, letter)
        selected = nil
        RaidPane:Refresh()
    else
        T.Raids:SignUp(raidKey, letter, pane.noteBox:GetText())
    end
end

local function keepNote()
    if raidKey and not discarding then T.Raids:SetNote(raidKey, pane.noteBox:GetText()) end
end

local function showNote(item)
    hovered = item
    T.Window.SetHint(item and item.note and ("%s: %s"):format(item.nameText or "?", item.note) or "")
end

function RaidPane:Create(frame, list)
    W, C = T.Window, T.Window.C
    pane = CreateFrame("Frame", nil, frame)
    pane:SetFrameLevel(frame:GetFrameLevel() + 3)
    pane:SetAllPoints(list)
    pane:EnableMouse(true)
    pane:EnableMouseWheel(true)
    pane:SetScript("OnMouseWheel", function(_, delta)
        offset = math.max(0, offset - delta)
        RaidPane:Refresh()
    end)
    local background = W.Fill(pane, C.bg, 1)
    background:SetAllPoints()

    pane.title = W.Text(pane, 16, C.text)
    pane.title:SetWordWrap(false)
    pane.instance = W.Text(pane, 12, C.body)
    pane.instance:SetWordWrap(false)
    pane.sub = W.Text(pane, 12, C.muted)
    pane.calendarNote = W.Text(pane, 12, C.body)
    pane.calendarNote:SetWordWrap(true)
    if pane.calendarNote.SetMaxLines then pane.calendarNote:SetMaxLines(2) end
    pane.back = W.Button(pane, L["Back"], function() RaidPane:Close() end)
    pane.counts = W.Text(pane, 12, C.body)
    pane.range = W.Text(pane, 11, C.muted, "RIGHT")
    pane.heads = { name = W.Text(pane, 10, C.muted), role = W.Text(pane, 10, C.muted),
        level = W.Text(pane, 10, C.muted, "RIGHT") }
    pane.headRule = W.Fill(pane, C.divider, 1, "BORDER")
    pane.headRule:SetHeight(1)
    pane.none = W.Text(pane, 12, C.muted)
    pane.message = W.Text(pane, 12, C.muted)

    pane.noteLabel = W.Text(pane, 12, C.muted)
    pane.noteBox = CreateFrame("EditBox", nil, pane, "InputBoxTemplate")
    pane.noteBox:SetAutoFocus(false)
    if pane.noteBox.SetMaxBytes then pane.noteBox:SetMaxBytes(T.Raids.NOTE_MAX + 1) end
    pane.noteBox:SetScript("OnEnterPressed", function(box)
        keepNote()
        box:ClearFocus()
    end)
    pane.noteBox:SetScript("OnEscapePressed", function(box)
        discarding = true
        box:ClearFocus()
        discarding = false
        RaidPane:Refresh()
    end)
    pane.noteBox:SetScript("OnEditFocusLost", keepNote)

    pane.roles = {}
    for _, letter in ipairs(ROLES) do
        pane.roles[letter] = W.Button(pane, "", function() pickRole(letter) end)
    end
    pane.withdraw = W.Button(pane, L["Take back sign-up"], function() T.Raids:Withdraw(raidKey) end)
    pane.whisper = W.Button(pane, L["Whisper"], function() T.BoardPane.Whisper(selected) end)
    pane.cancel = W.Button(pane, L["Cancel"], function()
        selected = nil
        RaidPane:Refresh()
    end)
    pane.rows = {}
    pane:Hide()
end

local function row(i)
    if pane.rows[i] then return pane.rows[i] end
    local item = CreateFrame("Frame", nil, pane)
    item:EnableMouse(true)
    item:SetScript("OnEnter", function() showNote(item) end)
    item:SetScript("OnLeave", function() showNote(nil) end)
    item.mark = W.Fill(item, C.glow, 0.12)
    item.mark:SetAllPoints()
    item.mark:Hide()
    item.line = W.Fill(item, C.rowLine, 1, "BORDER")
    item.line:SetPoint("BOTTOMLEFT")
    item.line:SetPoint("BOTTOMRIGHT")
    item.line:SetHeight(1)

    item.name = CreateFrame("Button", nil, item)
    item.name.label = W.Text(item.name, 12, C.text)
    item.name.label:SetPoint("LEFT")
    item.name.label:SetPoint("RIGHT")
    item.name.label:SetWordWrap(false)
    item.crown = item:CreateTexture(nil, "OVERLAY")
    item.crown:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon")
    item.crown:Hide()
    item.name:SetScript("OnClick", function()
        if not item.who then return end
        if item.assignable then
            selected = selected ~= item.who and item.who or nil
            RaidPane:Refresh()
        else
            T.BoardPane.Whisper(item.who)
        end
    end)
    item.name:SetScript("OnEnter", function()
        item.name.label:SetAlpha(0.75)
        showNote(item)
        if not (item.assignable and GameTooltip) then return end
        GameTooltip:SetOwner(item.name, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["Click: pick the role"])
        GameTooltip:Show()
    end)
    item.name:SetScript("OnLeave", function()
        item.name.label:SetAlpha(1)
        showNote(nil)
        if GameTooltip then GameTooltip:Hide() end
    end)

    item.roleIcon = item:CreateTexture(nil, "ARTWORK")
    item.role = W.Text(item, 12, C.body)
    item.level = W.Text(item, 12, C.muted, "RIGHT")
    pane.rows[i] = item
    return item
end

local function draw(raids)
    local raid
    if raids then
        for _, candidate in ipairs(raids) do
            if candidate.key == raidKey then raid = candidate end
        end
    else
        raid = T.Raids:Find(raidKey)
    end
    if not raid then
        RaidPane:Close()
        return false
    end
    local M, factor = W.Metrics()
    local function gap(value) return math.floor(value * factor + 0.5) end
    local pad = M.PAD
    local width, height = pane:GetWidth() or 0, pane:GetHeight() or 0

    local canAssign = T.Raids:CanAssign(raidKey)
    local picked
    for _, s in ipairs(raid.signups) do
        if canAssign and s.who == selected and not s.own then picked = s end
    end
    selected = picked and picked.who or nil

    pane.back:SetLabel(L["Back"])
    pane.back:ClearAllPoints()
    pane.back:SetPoint("TOPRIGHT", -pad, -gap(10))
    pane.title:ClearAllPoints()
    pane.title:SetPoint("TOPLEFT", pad, -gap(12))
    pane.title:SetPoint("RIGHT", pane.back, "LEFT", -gap(8), 0)
    pane.title:SetText(raid.title)
    local top = gap(12) + gap(16)
    local above = pane.title
    pane.instance:ClearAllPoints()
    pane.instance:SetShown(raid.instance ~= nil)
    if raid.instance then
        pane.instance:SetPoint("TOPLEFT", pane.title, "BOTTOMLEFT", 0, -gap(4))
        pane.instance:SetPoint("RIGHT", pane, "RIGHT", -pad, 0)
        pane.instance:SetText(raid.bosses and ("%s · %d/%d"):format(raid.instance, raid.killed, raid.bosses)
            or raid.instance)
        above, top = pane.instance, top + gap(4) + gap(12)
    end
    pane.sub:ClearAllPoints()
    pane.sub:SetPoint("TOPLEFT", above, "BOTTOMLEFT", 0, -gap(6))
    local when = ("%s · %s"):format(T.BoardPane.DayText(raid.at), T.BoardPane.TimeText(raid.at))
    pane.sub:SetText(raid.creator and ("%s · %s"):format(when, L["entered by %s"]:format(raid.creator)) or when)
    above, top = pane.sub, top + gap(6) + gap(12)
    pane.calendarNote:ClearAllPoints()
    pane.calendarNote:SetShown(raid.note ~= nil)
    if raid.note then
        pane.calendarNote:SetPoint("TOPLEFT", pane.sub, "BOTTOMLEFT", 0, -gap(6))
        pane.calendarNote:SetWidth(math.max(1, width - 2 * pad))
        pane.calendarNote:SetText(raid.note)
        local lines = math.max(1, math.min(2, pane.calendarNote.GetNumLines and pane.calendarNote:GetNumLines() or 1))
        above, top = pane.calendarNote, top + gap(6) + lines * gap(14)
    end

    local counts = {}
    for _, letter in ipairs(ROLES) do
        counts[#counts + 1] = ("%s %d"):format(RaidPane.RoleName(letter), raid.counts[letter])
    end
    pane.counts:ClearAllPoints()
    pane.counts:SetPoint("TOPLEFT", above, "BOTTOMLEFT", 0, -gap(10))
    pane.counts:SetText(table.concat(counts, " · "))

    local headTop = top + gap(10) + gap(14) + gap(12)
    local headH, lineH = gap(16), gap(20)
    local roleW, levelW = gap(ROLE_W), gap(LEVEL_W)
    local roleX = width - pad - levelW - roleW
    pane.heads.name:ClearAllPoints()
    pane.heads.name:SetPoint("TOPLEFT", pad, -headTop)
    pane.heads.name:SetText(L["Name"]:upper())
    pane.heads.role:ClearAllPoints()
    pane.heads.role:SetPoint("TOPLEFT", roleX, -headTop)
    pane.heads.role:SetText(L["Role"]:upper())
    pane.heads.level:ClearAllPoints()
    pane.heads.level:SetPoint("TOPRIGHT", -pad, -headTop)
    pane.heads.level:SetText(L["Item level"]:upper())
    pane.headRule:ClearAllPoints()
    pane.headRule:SetPoint("TOPLEFT", pad, -(headTop + headH))
    pane.headRule:SetPoint("TOPRIGHT", -pad, -(headTop + headH))

    local buttonH = M.OPTIONS_H + gap(6)
    local rowsTop = headTop + headH + gap(2)
    local bottom = gap(10) + buttonH + gap(8) + gap(24) + gap(10)
    local perPage = math.max(1, math.floor((height - rowsTop - bottom) / lineH))
    local total = #raid.signups
    offset = math.max(0, math.min(offset, total - perPage))
    local shown = math.min(perPage, total - offset)
    for i = 1, shown do
        local s, item = raid.signups[offset + i], row(i)
        item:ClearAllPoints()
        item:SetPoint("TOPLEFT", pad, -(rowsTop + (i - 1) * lineH))
        item:SetPoint("RIGHT", pane, "RIGHT", -pad, 0)
        item:SetHeight(lineH)
        item.who, item.nameText, item.note = s.who, s.name, s.note
        item.assignable = canAssign and not s.own or false
        item.mark:SetShown(s.who == selected)

        local nameW, crownSize = math.max(1, roleX - pad - gap(8)), gap(14)
        local crownRoom = s.creator and crownSize + gap(4) or 0
        item.name:ClearAllPoints()
        item.name:SetPoint("LEFT")
        item.name:SetSize(math.max(1, nameW - crownRoom), lineH)
        item.name.label:SetText(s.name)
        W.Tint(item.name.label, W.ClassColor(nil, s.classFile) or C.text)
        item.crown:SetSize(crownSize, crownSize)
        item.crown:ClearAllPoints()
        item.crown:SetPoint("LEFT", item.name, "LEFT",
            math.min(item.name.label:GetStringWidth() or 0, nameW - crownRoom) + gap(4), 0)
        item.crown:SetShown(s.creator == true)

        local atlas, iconSize = s.role and ROLE_ATLAS[s.role], gap(14)
        item.roleIcon:SetSize(iconSize, iconSize)
        item.roleIcon:ClearAllPoints()
        item.roleIcon:SetPoint("LEFT", roleX - pad, 0)
        if atlas then item.roleIcon:SetAtlas(atlas) end
        item.roleIcon:SetShown(atlas ~= nil)
        item.role:ClearAllPoints()
        item.role:SetPoint("LEFT", roleX - pad + (atlas and iconSize + gap(4) or 0), 0)
        item.role:SetText(s.role and RaidPane.RoleName(s.role) or "-")
        W.Tint(item.role, s.role and C.body or C.dim)

        item.level:ClearAllPoints()
        item.level:SetPoint("RIGHT")
        item.level:SetText(s.itemLevel and tostring(s.itemLevel) or "-")
        item:Show()
    end
    for i = shown + 1, #pane.rows do pane.rows[i]:Hide() end
    if hovered then showNote(hovered:IsShown() and hovered or nil) end
    pane.none:ClearAllPoints()
    pane.none:SetPoint("TOPLEFT", pad, -rowsTop - gap(4))
    pane.none:SetText(L["Nobody has signed up yet."])
    pane.none:SetShown(total == 0)
    pane.range:ClearAllPoints()
    pane.range:SetPoint("RIGHT", pane, "TOPRIGHT", -pad, -(headTop - gap(12)))
    pane.range:SetText(total > perPage and L["%d-%d of %d"]:format(offset + 1, offset + shown, total) or "")

    local current = picked and picked.role or (not picked and raid.mine and raid.mine.role)
    local previous
    for _, letter in ipairs(ROLES) do
        local button = pane.roles[letter]
        button:SetLabel(picked and RaidPane.RoleName(letter) or L["Sign up as %s"]:format(RaidPane.RoleName(letter)))
        button:SetEnabled(current ~= letter)
        button:ClearAllPoints()
        if previous then
            button:SetPoint("LEFT", previous, "RIGHT", gap(16), 0)
        else
            button:SetPoint("BOTTOMLEFT", pad, gap(10))
        end
        previous = button
    end
    pane.withdraw:SetLabel(L["Take back sign-up"])
    pane.withdraw:ClearAllPoints()
    pane.withdraw:SetPoint("LEFT", previous, "RIGHT", gap(16), 0)
    pane.withdraw:SetShown(not picked and raid.mine ~= nil)
    pane.whisper:SetLabel(L["Whisper"])
    pane.whisper:ClearAllPoints()
    pane.whisper:SetPoint("LEFT", previous, "RIGHT", gap(16), 0)
    pane.whisper:SetShown(picked ~= nil)
    pane.cancel:SetLabel(L["Cancel"])
    pane.cancel:ClearAllPoints()
    pane.cancel:SetPoint("LEFT", pane.whisper, "RIGHT", gap(16), 0)
    pane.cancel:SetShown(picked ~= nil)

    local lineY = gap(10) + buttonH + gap(8) + gap(12)
    pane.message:ClearAllPoints()
    pane.message:SetPoint("LEFT", pane, "BOTTOMLEFT", pad, lineY)
    pane.message:SetText(picked and L["Role for %s:"]:format(picked.name) or "")
    pane.message:SetShown(picked ~= nil)

    pane.noteLabel:ClearAllPoints()
    pane.noteLabel:SetPoint("LEFT", pane, "BOTTOMLEFT", pad, lineY)
    pane.noteLabel:SetText(L["Note:"])
    pane.noteBox:ClearAllPoints()
    pane.noteBox:SetPoint("LEFT", pane.noteLabel, "RIGHT", gap(12), 0)
    pane.noteBox:SetSize(gap(NOTE_W), gap(22))
    pane.noteBox:SetShown(not picked)
    pane.noteLabel:SetShown(not picked)
    if not (pane.noteBox.HasFocus and pane.noteBox:HasFocus()) then
        pane.noteBox:SetText(raid.mine and raid.mine.note or "")
    end
    return true
end

function RaidPane:Refresh(raids)
    if not pane then return end
    if not raidKey then
        pane:Hide()
        return
    end
    if draw(raids) then pane:Show() end
end

function RaidPane:IsOpen()
    return raidKey ~= nil
end

function RaidPane:Open(key)
    raidKey, offset, selected, hovered = key, 0, nil, nil
    if pane then pane.noteBox:SetText("") end
    T.Raids:ReadInvites(key)
    T.Window:Refresh()
end

function RaidPane:Close()
    if pane then pane.noteBox:ClearFocus() end
    raidKey, selected, hovered = nil, nil, nil
    if pane then pane:Hide() end
    if T.Window:IsShown() then T.Window:Refresh() end
end
