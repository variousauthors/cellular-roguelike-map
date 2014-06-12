Matrix = function (n, m, generator)

        local cells = {}

        for i = 1, n do
            cells[i] = {}

            for j = 1, m do
                cells[i][j] = generator(i, j)
            end
        end

        return cells
end

Generators = {
    random = function (lower, upper)
        return function (row, col)
            return rng:random(lower, upper)
        end
    end
}

