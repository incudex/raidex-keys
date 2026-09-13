local _, T = ...

local Rating = {}
T.Rating = Rating

Rating.MIN_LEVEL, Rating.MAX_LEVEL = 2, 30

Rating.GOALS = { 2500, 3000, 3500 }

local AFFIX_LEVELS = { 5, 7, 10, 12 }
local UNTIMED_CAP = 11

function Rating.Base(level)
    level = math.max(Rating.MIN_LEVEL, level)
    local score = 155 + 15 * (level - Rating.MIN_LEVEL)
    for _, affix in ipairs(AFFIX_LEVELS) do
        if level >= affix then score = score + 15 end
    end
    return score
end

function Rating.Score(level, duration, limit)
    if not limit or limit <= 0 then return Rating.Base(level) end
    local share = math.min(1, math.abs(limit - duration) / (0.4 * limit))
    if duration <= limit then return Rating.Base(level) + 15 * share end
    return Rating.Base(math.min(level, UNTIMED_CAP)) - 15 - 15 * share
end

function Rating.LevelCap(best)
    local top = 0
    for _, run in pairs(best or {}) do
        if not run.overTime and (run.level or 0) > top then top = run.level end
    end
    return math.max(Rating.MIN_LEVEL, top + 1)
end

local function gainOf(run, bests)
    return Rating.Base(run.level) - (bests[run.mapId] or 0)
end

local function total(runs, bests)
    local sum = 0
    for _, run in ipairs(runs) do sum = sum + math.max(0, gainOf(run, bests)) end
    return sum
end

local function lower(runs, bests, need)
    local lowered = true
    while lowered do
        lowered = false
        local order = {}
        for i in ipairs(runs) do order[i] = i end
        table.sort(order, function(a, b)
            if runs[a].level ~= runs[b].level then return runs[a].level > runs[b].level end
            return a < b
        end)
        for _, i in ipairs(order) do
            local run = runs[i]
            if run.level > Rating.MIN_LEVEL then
                run.level = run.level - 1
                if total(runs, bests) >= need then
                    lowered = true
                    break
                end
                run.level = run.level + 1
            end
        end
    end

    local plan = {}
    for _, run in ipairs(runs) do
        if gainOf(run, bests) > 0 then
            plan[#plan + 1] = { mapId = run.mapId, level = run.level,
                gain = math.floor(gainOf(run, bests) + 0.5) }
        end
    end
    table.sort(plan, function(a, b)
        if a.level ~= b.level then return a.level > b.level end
        if a.gain ~= b.gain then return a.gain > b.gain end
        return a.mapId < b.mapId
    end)
    return plan
end

function Rating.Plan(rating, target, bests, cap)
    local need = target - rating
    if need <= 0 then return {} end
    local ids = {}
    for mapId in pairs(bests) do ids[#ids + 1] = mapId end
    for level = math.max(Rating.MIN_LEVEL, cap or Rating.MIN_LEVEL), Rating.MAX_LEVEL do
        local base = Rating.Base(level)
        table.sort(ids, function(a, b)
            if bests[a] ~= bests[b] then return bests[a] < bests[b] end
            return a < b
        end)
        local picked, sum = {}, 0
        for _, mapId in ipairs(ids) do
            local gain = base - bests[mapId]
            if gain <= 0 then break end
            picked[#picked + 1] = { mapId = mapId, level = level }
            sum = sum + gain
            if sum >= need then return lower(picked, bests, need) end
        end
    end
    return nil
end
