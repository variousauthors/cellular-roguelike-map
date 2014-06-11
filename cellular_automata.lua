
return (function ()
    local component = "CellularAutomata"
    local threshold = 4

    local keypressed = function (key, entity)
        if key ~= " " then return end

        local cells = entity["CellularAutomata"].cells
        local _next = {}

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

                if neighbours > threshold then
                    _next[i][j] = 1
                elseif neighbours < threshold then
                    _next[i][j] = 0
                else
                    _next[i][j] = cells[i][j]
                end
            end
        end

        entity["CellularAutomata"].cells = _next
    end

    return {
        keypressed = keypressed
    }
end)()
