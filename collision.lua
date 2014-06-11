
return (function ()
    local component = "Collision"

    local update_collisions = function (dt, entities)
        -- for each entity that "tried to move" test it against
        -- all the other entities' solid points
    end

    local update = function (dt)
        local entities = {}

        for index, entity in pairs(Entities) do
            properties = entity[component]

            if properties then
                table.insert(entities, entity)
            end
        end

        update_collisions(dt, entities)
    end

    return {
        update = update
    }
end)()
