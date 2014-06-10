
return (function ()
    local component = "PlayerControlled"

    local keypressed = function (key, entity)
        local position = entity["Positioned"]

        if key == "up" then
            position.y = position.y + 1
        end
    end

    return {
        keypressed = keypressed
    }
end)()
