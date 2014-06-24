return function (self, cells)
    local r, g, b       = love.graphics.getColor()
    local cell_size     = self.cell_size
    local background    = self.background
    local color         = self.color
    local length        = #cells * cell_size
    local grid_h        = #cells
    local grid_w        = #(cells[1])

    local ftx, fty = 0, 0
    love.graphics.push()
    love.graphics.scale(1)
    love.graphics.translate(ftx, fty)

    love.graphics.setColor(background)
    for i = 0, grid_h do
        love.graphics.line(i*cell_size, 0, i*cell_size, length)
        love.graphics.line(0, i*cell_size, length, i*cell_size)

        if i > 0 then
            for j = 1, grid_w do
                if cells[i][j] ~= EMPTY then
                    love.graphics.setColor(color[cells[i][j]])
                    love.graphics.rectangle("fill", (i - 1)*cell_size + 1, (j - 1)*cell_size + 1, cell_size - 2, cell_size - 2)
                end
            end
            love.graphics.setColor(background)
        end
    end
    love.graphics.setColor({ r, g, b })

    love.graphics.pop()
end
