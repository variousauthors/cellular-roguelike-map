
-- USEAGE
--
--  state_machine = FSM()

--  -- a state will inherit any method it did not
--  -- declare from the previous state
--  state_machine.addState({
--      name       = "start",
--      init       = function ()
--          game.init(score_band)
--      end,
--      draw       = function ()
--          game.draw()
--          score_band.draw()
--      end,
--      update     = game.update,
--      keypressed = game.keypressed
--  })

--  state_machine.addTransition({
--      from = "start",
--      to = "run",
--      condition = function ()
--          return true
--      end
--  })

FSM = function ()
    local states        = {}
    local current_state = { name = "nil" }

    local transitionTo = function (next_state)
        -- TODO currently no states have cleanup steps, and I'm debating whether they need'em
        -- most "cleanup steps" could be their own states with automatic transitions...
        -- but that is kind of wordy... I'll decide after a refactor
        if current_state.cleanup then current_state.cleanup() end

        current_state = states[next_state]
        current_state.variables = {}

        if current_state.init then current_state.init() end
    end

    local update = function (dt)

        -- iterate over the transitions for the current state
        local next_state = {}

        for i, transition in ipairs(current_state.transitions) do
            if transition.condition() then
                table.insert(next_state, transition.to)
            end
        end

        if #next_state == 1 then
            transitionTo(unpack(next_state))
        elseif #next_state > 1 then
            print("AMBIGUITY!")
            inspect(next_state)
            -- exception!
            -- ambiguous state transition
        end

        if current_state.update then current_state.update(dt) end

        for component, system in pairs(Systems)do
            if system.update then system.update(dt, entity) end
        end
    end

    local draw = function ()
        if current_state.draw then current_state.draw() end

        for component, system in pairs(Systems )do
            for index, entity in pairs(Entities) do
                properties = entity[component]

                if properties and system.draw then
                    system.draw(properties, entity)
                end
            end
        end
    end

    local set = function (key)
        current_state.variables[key] = true
    end

    local keypressed = function (key)
        if (key == "escape") then
            love.event.quit()
        end

        -- record the keypress for state transitions
        set(key)

        if current_state.keypressed then current_state.keypressed(key) end

        for component, system in pairs(Systems )do
            if system.keypressed then system.keypressed(key) end
        end
    end

    local addState = function(state)
        states[state.name] = {
            name        = state.name,
            init        = state.init,
            update      = state.update,
            draw        = state.draw,
            keypressed  = state.keypressed,
            transitions = {},
            variables   = {}
        }

        return self
    end

    local addTransition = function(transition)
        table.insert(states[transition.from].transitions, {
            to        = transition.to,
            condition = transition.condition,
        })
    end

    local start = function ()
        transitionTo("start")
    end

    local isSet = function (key)
        local result = false

        if current_state.variables[key] ~= nil then
            result = current_state.variables[key]
        end

        return result
    end

    return {
        start         = start,
        update        = update,
        keypressed    = keypressed,
        draw          = draw,
        addState      = addState,
        addTransition = addTransition,
        set           = set,
        isSet         = isSet
    }
end
