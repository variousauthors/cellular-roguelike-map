require "game"
require "fsm"
require "system"

local i = require("vendor/inspect/inspect")
inspect = function (a, b)
    print(i.inspect(a, b))
end

function math.round(val, decimal)
  local exp = decimal and 10^decimal or 1
  return math.ceil(val * exp - 0.5) / exp
end

local state_machine

Entities = {
    {   -- player
        Drawable = {
            w     = 10,
            h     = 10,
            color = { 255, 255, 255 },
            needs = { "Drawable", "Positioned" },
            draw  = function (d, p)
                local r, g, b     = love.graphics.getColor()
                local x, y        = p.x, p.y
                local w, h, color = d.w, d.h, d.color

                love.graphics.setColor(color)
                love.graphics.rectangle("fill", x, y, w, h)
                love.graphics.setColor({ r, g, b })
            end
        },
        PlayerControlled = {

        },
        Positioned = { x = 100, y = 100 }
    }
}

Systems = {
    PlayerControlled = require("player_controlled"),
    Drawable         = require("drawable")
}

function love.focus(f) gameIsPaused = not f end

function love.load()
    love.graphics.setBackgroundColor(0, 0, 0)

    game       = Game()

    state_machine = FSM()

    state_machine.addState({
        name       = "start",
        systems    = {
            "PlayerControlled",
            "Drawable"
        }
    })

    love.update     = state_machine.update
    love.keypressed = state_machine.keypressed
    love.draw       = state_machine.draw

    state_machine.start()
end

