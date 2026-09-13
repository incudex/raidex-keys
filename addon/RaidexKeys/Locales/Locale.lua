local _, T = ...

T.Locales = {}

local active

T.L = setmetatable({}, {
    __index = function(_, key)
        active = active or T.Locales[GetLocale()]
        local translated = active and active[key]
        if translated ~= nil then return translated end
        return key
    end,
})
