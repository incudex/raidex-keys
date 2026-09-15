local _, T = ...

local Fonts = {}
T.Fonts = Fonts
local MEDIA = "Interface\\AddOns\\RaidexKeys\\Media\\"
Fonts.List = {
    { key = "marcellus", name = "Marcellus", path = MEDIA .. "Marcellus.ttf" },
    { key = "frizqt", name = "Friz Quadrata", path = STANDARD_TEXT_FONT },
    { key = "arialn", name = "Arial Narrow", path = "Fonts\\ARIALN.TTF" },
    { key = "expressway", name = "Expressway", shared = "Expressway" },
    { key = "ptsansnarrow", name = "PT Sans Narrow", path = MEDIA .. "PTSansNarrow.ttf" },
    { key = "homespun", name = "Homespun", shared = "Homespun" },
    { key = "continuum", name = "Continuum Medium", shared = "Continuum Medium" },
    { key = "diediedie", name = "Die Die Die!", shared = "Die Die Die!" },
    { key = "actionman", name = "Action Man", shared = "Action Man" },
    { key = "skurri", name = "Skurri", path = "Fonts\\SKURRI.TTF" },
    { key = "morpheus", name = "Morpheus", path = "Fonts\\MORPHEUS.TTF" },
    { key = "design", name = "Friz Quadrata & Morpheus" },
}

local function sharedMedia()
    return LibStub and LibStub("LibSharedMedia-3.0", true)
end

local function path(font)
    if font.path then return font.path end
    local media = font.shared and sharedMedia()
    return media and media:Fetch("font", font.shared, true) or nil
end

function Fonts.Available(selected)
    local list = {}
    for _, font in ipairs(Fonts.List) do
        if font.key == "design" or path(font) then
            list[#list + 1] = { key = font.key, name = font.name }
        elseif font.key == selected then
            list[#list + 1] = { key = font.key,
                name = font.name .. " " .. T.L["(unavailable)"] }
        end
    end
    return list
end

function Fonts.Resolve(key, display, fallback)
    if key == "design" then
        return display and "Fonts\\MORPHEUS.TTF" or STANDARD_TEXT_FONT
    end
    for _, font in ipairs(Fonts.List) do
        if font.key == key then
            local chosen = path(font)
            if chosen then return chosen end
            break
        end
    end
    if fallback and fallback ~= key then return Fonts.Resolve(fallback, display) end
    return STANDARD_TEXT_FONT
end

function Fonts.Set(region, key, size, flags, display, fallback)
    local chosen = Fonts.Resolve(key, display, fallback)
    local ok, result = pcall(region.SetFont, region, chosen, size, flags or "")
    if not ok or result == false then
        region:SetFont(STANDARD_TEXT_FONT, size, flags or "")
    end
end

T.Addon:On("ADDON_LOADED", function()
    if not (T.DB and T.DB.db and T.Window and T.Timer and sharedMedia()) then return end
    T.Addon:Debounce("fonts", 0.1, function()
        T.Window:Restyle()
        T.Timer:Restyle()
    end)
end)
