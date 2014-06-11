
return (function ()
    local component = "PlayerControlled"

    local update_player = function (key, entity)
        local position = entity["Positioned"]

        if     key == "up"    then position.y = position.y - global.tile_size
        elseif key == "down"  then position.y = position.y + global.tile_size
        elseif key == "right" then position.x = position.x + global.tile_size
        elseif key == "left"  then position.x = position.x - global.tile_size
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
            end
        end
    end

    return {
        keypressed = keypressed
    }
end)()
