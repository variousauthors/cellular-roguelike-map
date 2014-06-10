
return (function ()
    local component = "Drawable"

    local draw = function (drawable, entity)
        local args = {}

        for i, k in ipairs(drawable.needs) do
            table.insert(args, entity[k])
        end

        drawable.draw(unpack(args))
    end

    return {
        draw = draw
    }
end)()
