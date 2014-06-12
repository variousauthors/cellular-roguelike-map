return (function ()
    local component = "CellularAutomata"
    local needs = { "Cells" }
    local threshold = 4

    local update_automata = function (key, entity)
        local cells  = entity["Cells"]
        local player = Systems["PlayerControlled"].get("player")
        local p_x, p_y = player["Positioned"].y + 1, player["Positioned"].x + 1
        cells[p_y][p_x] = 1
        local _next  = {}

        for i = 1, #cells do
            _next[i] = {}

            for j = 1, #cells do
                local neighbours = 0

                -- visit its neighbours
                for k = 0, 8 do
                    local row = i + math.floor(k/3) -1
                    local col = j + k%3 -1

                    if cells[row] ~= nil and cells[row][col] ~= nil then
                        if row ~= i or col ~= j then
                            neighbours = neighbours + cells[row][col]
                        end
                    end
                end

                if neighbours > threshold + 3 then
                    _next[i][j] = 1
                elseif neighbours < threshold - 3 then
                    _next[i][j] = 1
                else
                    _next[i][j] = 0
                end
            end
        end

        _next[p_y][p_x] = 0
        entity["Cells"] = _next
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
