EMPTY     = 0
SOLID     = 1
MONSTER   = 2
TREASURE  = 3
WATER     = 4
POOL      = 5
STRUCTURE = 6

local Rules = {}

-- returns a function that returns the given value
local identity = function (value)
    return function (...)
        return value
    end
end

Rules[EMPTY] = function (neighbourhood)
    local solid      = neighbourhood[SOLID]
    local monster    = neighbourhood[MONSTER]
    local structure  = neighbourhood[STRUCTURE]
    local neighbours = solid + monster
    local water      = neighbourhood[WATER]
    local threshold  = 4
    local result = EMPTY

    if solid > threshold then
        result = 1
    elseif solid < threshold then
        result = 0
    end

    -- if 9 squares are empty, magic happens!
    if neighbours == 0 then
        local random = rng:random()
        -- a small percent of the time, features will appear
        if random < 0.0001 then
            result = TREASURE
        elseif random < 0.001 then
            result = MONSTER
        end
    end

    if monster > 0 then
        local random = rng:random()

        if random < (0.2 * math.pow(monster/4, 2)) then
            result = STRUCTURE
        end

        if structure == 3 then
            result = STRUCTURE
        elseif structure > 3 then
            result = EMPTY
        end
    end

    if water > 0 then
        local random = rng:random()
        -- a small percent of the time, features will appear
        if water == 1 and random < 0.2 then
            result = WATER
        else
            result = POOL
        end
    end

    -- this is cool: the structure spreads and then
    -- becomes rocks
    if structure == 3 then
        result = EMPTY
    elseif structure == 2 then
        result = STRUCTURE
    elseif structure > 3 then
        result = EMPTY
    end

    return result
end

Rules[SOLID] = function (neighbourhood)
    local solid     = neighbourhood[SOLID]
    local water     = neighbourhood[WATER] + neighbourhood[POOL]
    local threshold = 4
    local result = SOLID

    if solid == 8 then
        local random = rng:random()
        -- a small percent of the time, features will appear
        if random < 0.001 then
            result = WATER
        end
    elseif solid > threshold then
        result = SOLID
    elseif solid < threshold then
        result = EMPTY
    end

    if water > 0 then
        result = EMPTY
    end

    return result
end

Rules[MONSTER]  = function (neighbourhood)
    local structure = neighbourhood[STRUCTURE]
    local solid = neighbourhood[SOLID]
    local result    = MONSTER

    if structure == 8 or solid == 8 then
        result = EMPTY
    end

    return result
end
Rules[STRUCTURE]  = function (neighbourhood)
    local monster   = neighbourhood[MONSTER]
    local solid     = neighbourhood[SOLID]
    local structure = neighbourhood[STRUCTURE]
    local result    = STRUCTURE

    if solid > 0 then
        result = SOLID
    end

    return result
end
Rules[TREASURE] = identity(TREASURE)
Rules[POOL]     = function (neighbourhood)
    local pool = neighbourhood[POOL]
    local result = POOL

    if pool == 0 or pool == 1 or pool == 3 then
        result = EMPTY
    end

    return result
end
Rules[WATER]    = function (neighbourhood)
    local result = WATER

    local random = rng:random()
    -- a small percent of the time, features will appear
    if random < 0.7 then
        result = POOL
    end

    return result
end

return Rules

