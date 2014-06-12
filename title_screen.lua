
return (function ()
    local component = "TitleScreen"
    local variables = {}

    local set = function (key, value)
        variables[key] = value
    end

    local get = function (key)
        return variables[key]
    end

    local draw = function ()
        local r, g, b     = love.graphics.getColor()

        love.graphics.setColor({ 255, 255, 255 })
        love.graphics.printf("TITLE SCREEN", -10, W_HEIGHT / 2 - global.tile_size * 5.5, W_WIDTH, "center")
        love.graphics.setColor({ r, g, b })
    end

    local keypressed = function (key)
        set("choice", true)
    end

    return {
        draw       = draw,
        keypressed = keypressed,
        set        = set,
        get        = get
    }
end)()
