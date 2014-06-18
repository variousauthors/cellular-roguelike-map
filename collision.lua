
return (function ()
    local component = "Collision"

    local resolveCollision = function (entity)
        local world = entity["Collision"].world
        local x, y  = entity["Positioned"].x + 1, entity["Positioned"].y + 1

        if world[y] then print(world[y][x]) end

        return world[x] == nil or world[x][y] == nil or world[x][y] == 1
    end

    local update_collisions = function (dt, entities)
        -- for each entity that "tried to move" test it against
        -- all the other entities' solid points
        for i, e in ipairs(entities) do
            if e["Collision"].tried_to_move then
                e["Collision"].tried_to_move = false

                if resolveCollision(e) then
                    e["Positioned"].x = e["Positioned"].old_x
                    e["Positioned"].y = e["Positioned"].old_y
                end
            end
        end
    end

    local update = function (dt)
        local entities = {}

        for index, entity in pairs(Entities) do
            properties = entity["Collision"]

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
