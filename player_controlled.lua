
return (function ()
    local component = "PlayerControlled"
    local variables = {}

    local set = function (key, value)
        variables[key] = value
    end

    local get = function (key)
        return variables[key]
    end

    local update_player = function (key, entity)
        local position = entity["Positioned"]
        position.old_x = position.x
        position.old_y = position.y

        if     key == "up"    then position.y = position.y - 1
        elseif key == "down"  then position.y = position.y + 1
        elseif key == "right" then position.x = position.x + 1
        elseif key == "left"  then position.x = position.x - 1
        end

        if entity["Collision"] then
            entity["Collision"].tried_to_move = true
        end
    end

    local keypressed = function (key)
        for index, entity in pairs(Entities) do
            properties = entity[component]

            if properties then
                update_player(key, entity)
                set("player", entity)
            end
        end
    end

    return {
        keypressed = keypressed,
        set        = set,
        get        = get
    }
end)()
