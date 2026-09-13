local _, T = ...
local L = T.L

local Preview = {}
T.Preview = Preview

local active = false
local tooltip

local function tooltipFrame()
    if tooltip then return tooltip end
    tooltip = CreateFrame("GameTooltip", "RaidexKeysPreviewTooltip", UIParent, "GameTooltipTemplate")
    return tooltip
end

local function showTooltip()
    local frame = tooltipFrame()
    frame:SetOwner(UIParent, "ANCHOR_NONE")
    frame:ClearAllPoints()
    frame:SetPoint("TOPRIGHT", Minimap, "TOPLEFT", -8, 0)
    frame:ClearLines()
    T.MinimapButton.FillTooltip(frame, T.Sample.Tooltip())
    frame:Show()
end

function Preview:Active()
    return active
end

function Preview:Stop()
    if not active then return end
    active = false
    if tooltip then tooltip:Hide() end
    T.Timer:SetPreview(false)
    T.Window:SetPreview(false)
    T.Addon:Print(L["Preview closed."])
end

function Preview:Start()
    if active then return end
    active = true
    T.Window:SetPreview(true)
    T.Timer:SetPreview(true)
    showTooltip()
    T.Addon:Print(L["Preview: sample values in the window, the tooltip and the timer. Drag them into place, then type /rk preview again."])
    T.SayTimerHint()
end

function Preview:Toggle()
    if active then self:Stop() else self:Start() end
end
