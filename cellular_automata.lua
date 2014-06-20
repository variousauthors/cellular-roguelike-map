EMPTY    = 0
SOLID    = 1
MONSTER  = 2
TREASURE = 3
WATER    = 4
POOL     = 5

-- returns a function that returns the given value
local identity = function (value)
    return function (...)
        return value
    end
end

return (function ()
    local component = "CellularAutomata"
    local needs = { "Cells" }

    local maps = {}

    maps[EMPTY] = function (neighbourhood)
        local solid      = neighbourhood[SOLID]
        local neighbours = solid + neighbourhood[MONSTER]
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
            if random < 0.001 then
                result = TREASURE
            elseif random < 0.01 then
                result = MONSTER
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

        return result
    end

    maps[SOLID] = function (neighbourhood)
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

    maps[MONSTER]  = identity(MONSTER)
    maps[TREASURE] = identity(TREASURE)
    maps[POOL]     = function (neighbourhood)
        local pool = neighbourhood[POOL]
        local result = POOL

        if pool == 0 or pool == 1 or pool == 3 then
            result = EMPTY
        end

        return result
    end
    maps[WATER]    = function (neighbourhood)
        local result = WATER

        local random = rng:random()
        -- a small percent of the time, features will appear
        if random < 0.7 then
            result = POOL
        end

        return result
    end

    local states = {
        { -- empty
            { -- solid
            },
        },
        { -- solid

        },
        { -- treasure

        }
    }

    local update_automata = function (key, entity)
        local cells     = entity["Cells"]
        local player    = Systems["PlayerControlled"].get("player")
        local p_x, p_y  = player["Positioned"].y + 1, player["Positioned"].x + 1
        cells[p_y][p_x] = 2
        local _next     = {}
        local height    = #(cells)
        local width     = #(cells[1])

        for i = 1, #cells do
            _next[i] = {}

            for j = 1, #cells do
                _next[i][j] = cells[i][j]
                local neighbourhood = { 0, 0, 0, 0, 0 }
                neighbourhood[EMPTY] = 0

                -- visit its neighbours (it has 8 neighbours in 2 space)
                for k = 0, 8 do
                    local row = i + math.floor(k/3) - 1
                    local col = j + k%3 - 1

                    if cells[row] ~= nil and cells[row][col] ~= nil then
                        if row ~= i or col ~= j then
                            neighbourhood[cells[row][col]] = neighbourhood[cells[row][col]] + 1
                        end
                    end

                    -- count out of bounds as solid
                    if row < 1 or row > height or col < 1 or col > width then
                        if row ~= i or col ~= j then
                            neighbourhood[SOLID] = neighbourhood[SOLID] + 1
                        end
                    end
                end

                if cells[i][j] then
                    _next[i][j] = maps[cells[i][j]](neighbourhood)
                end
            end
        end

        cells[p_y][p_x] = 0
        _next[p_y][p_x] = 0
        for i = 1, #cells do
            for j = 1, #cells do
                cells[i][j] = _next[i][j]
            end
        end
    end

    local keypressed = function (key)
        if key ~= " " then return end

        -- update all cellular automata
        -- TODO maybe this should schedule a run of update,
        -- rather than calling a function... ?
        for index, entity in pairs(Entities) do
            -- TODO should iterate over all the needs
            properties = entity[needs[1]]

            if properties then
                update_automata(key, entity)
            end
        end
    end

    return {
        keypressed = keypressed
    }
end)()
