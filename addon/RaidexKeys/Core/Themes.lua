local _, T = ...

local Themes = {}
T.Themes = Themes
Themes.DEFAULT = "slate"
Themes.List = {
    { key = "raidex", name = "Raidex" },
    { key = "polar-night", name = "Nord — Polar Night" },
    { key = "ember", name = "Ember" },
    { key = "verdant", name = "Verdant" },
    { key = "slate", name = "Slate" },
}

local classic = {
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

local CLASSIC_TIMER_BACK = { 0.035, 0.043, 0.094 }
local WHITE = { 1, 1, 1 }

local function rgb(hex)
    return { tonumber(hex:sub(1, 2), 16) / 255,
        tonumber(hex:sub(3, 4), 16) / 255, tonumber(hex:sub(5, 6), 16) / 255 }
end

local function mix(a, b, t)
    return { a[1] + (b[1] - a[1]) * t, a[2] + (b[2] - a[2]) * t, a[3] + (b[3] - a[3]) * t }
end
Themes.Mix = mix

local function palette(bg, header, tab, edge, text, body, muted, accent, gold)
    bg, header, tab, edge = rgb(bg), rgb(header), rgb(tab), rgb(edge)
    text, body, muted, accent, gold = rgb(text), rgb(body), rgb(muted), rgb(accent), rgb(gold)
    return {
        bg = bg, header = header, tab = tab, divider = tab, edge = edge,
        info = mix(bg, header, 0.5), rowLine = mix(bg, header, 0.7),
        text = text, body = body, options = body, muted = muted,
        faint = mix(muted, bg, 0.25), dim = mix(muted, bg, 0.53),
        glow = accent, tabText = mix(accent, WHITE, 0.35),
        gold = gold, vault = mix(gold, bg, 0.45),
    }
end

Themes.Palettes = {
    raidex = classic,
    ["polar-night"] = palette("2E3440", "3B4252", "434C5E", "4C566A",
        "ECEFF4", "E5E9F0", "D8DEE9", "88C0D0", "EBCB8B"),
    ember = palette("211715", "30201C", "422C25", "705046",
        "FFF2E8", "E6CBBF", "C09F92", "FFAB70", "F2CC8F"),
    verdant = palette("101F1C", "192D27", "244036", "416454",
        "ECF5ED", "C7DFCE", "96B6A2", "7ED9A6", "E5C77F"),
    slate = palette("181C23", "232A34", "303A47", "4B5B70",
        "F0F3F8", "CBD5E1", "A0AEC0", "93B9F5", "E8C77D"),
}
Themes.Colors = {}
for key, color in pairs(classic) do
    Themes.Colors[key] = { color[1], color[2], color[3] }
end

function Themes.Current()
    local key = T.DB:Settings().theme
    return Themes.Palettes[key] and key or Themes.DEFAULT
end

function Themes.TimerDefaults()
    local current = Themes.Current()
    local c = Themes.Palettes[current]
    return current == "raidex" and CLASSIC_TIMER_BACK or c.bg, c.text
end

function Themes.Apply()
    local settings = T.DB:Settings()
    settings.theme = Themes.Current()
    for key, color in pairs(Themes.Palettes[settings.theme]) do
        local target = Themes.Colors[key]
        target[1], target[2], target[3] = color[1], color[2], color[3]
    end
end

function Themes.Select(key)
    if not Themes.Palettes[key] then return false end
    T.DB:Settings().theme = key
    Themes.Apply()
    local back, text = Themes.TimerDefaults()
    local timer = T.DB:Settings().timer
    timer.background = { back[1], back[2], back[3] }
    timer.text = { text[1], text[2], text[3] }
    T.Window:Restyle()
    T.Timer:Restyle()
    return true
end
