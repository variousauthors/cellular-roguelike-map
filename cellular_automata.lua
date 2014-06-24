
return (function ()
    local component = "CellularAutomata"
    local needs = { "Cells" }

    local Rules         = require("rules")
    local Visualization = require("visualization")

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
                local neighbourhood = { 0, 0, 0, 0, 0, 0 }
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
                    _next[i][j] = Rules[cells[i][j]](neighbourhood)
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
        keypressed = keypressed,
        visualize  = Visualization
    }
end)()
