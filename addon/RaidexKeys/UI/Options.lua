local ADDON, T = ...
local L = T.L

local category, layout

RaidexKeysAboutMixin = {}

function RaidexKeysAboutMixin:Init(initializer)
    self.Text:SetText(initializer:GetData().text)
end

local function metadata(field)
    local value = C_AddOns.GetAddOnMetadata(ADDON, field)
    if value == "" then return nil end
    return value
end

local ISSUES = "github.com/incudex/raidex-keys/issues"
local GREY = "|cff808080"

local function aboutText()
    local lines = {}
    local author = metadata("Author")
    if author then lines[#lines + 1] = L["Author: %s"]:format(author) end
    local website = metadata("X-Website")
    if website then lines[#lines + 1] = L["More: %s"]:format((website:gsub("^%a+://", ""):gsub("/$", ""))) end
    local version = metadata("Version")
    if version then
        lines[#lines + 1] = L["Version: %s (build %s)"]:format(version, metadata("X-Build") or "dev")
    end
    lines[#lines + 1] = GREY .. L["© 2026 incudex · GNU GPL 3 or later, without any warranty"] .. "|r"
    lines[#lines + 1] = GREY .. L["Report bugs: %s"]:format(ISSUES) .. "|r"
    return table.concat(lines, "\n")
end

local ABOUT_BOTTOM_PAD = 8
local measure
local function textHeight(text)
    if not measure then
        measure = UIParent:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        measure:SetJustifyH("LEFT")
        measure:Hide()
    end
    measure:SetText(text)
    return measure:GetStringHeight()
end

local function addAbout()
    if not Settings.CreateElementInitializer then return end
    local text = aboutText()
    local initializer = Settings.CreateElementInitializer("RaidexKeysAboutTemplate", { text = text })
    local extent = math.ceil(textHeight(text)) + ABOUT_BOTTOM_PAD
    initializer.GetExtent = function() return extent end
    layout:AddInitializer(initializer)
end

function T.SetupOptions()
    if category or not Settings or not Settings.RegisterVerticalLayoutCategory then return end
    local settings = T.DB:Settings()

    category, layout = Settings.RegisterVerticalLayoutCategory(L["Raidex Keys"])
    addAbout()

    do
        local setting = Settings.RegisterAddOnSetting(category, ADDON .. "_shareWithGuild", "shareWithGuild",
            settings, Settings.VarType.Boolean, L["Share key with guild"], true)
        setting:SetValueChangedCallback(function(_, value) T.Exchange:ShareChanged(value) end)
        Settings.CreateCheckbox(category, setting,
            L["Guild members see your keystone through the LibKeystone protocol, as with BigWigs."])
    end

    do
        local setting = Settings.RegisterProxySetting(category, ADDON .. "_showMinimap",
            Settings.VarType.Boolean, L["Show minimap button"], true,
            function() return not settings.minimap.hide end,
            function(value) T.MinimapButton:SetShown(value) end)
        Settings.CreateCheckbox(category, setting)
    end

    Settings.RegisterAddOnCategory(category)
end

function T.OpenOptions()
    if category then Settings.OpenToCategory(category:GetID()) end
end
