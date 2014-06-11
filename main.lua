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
rng = love.math.newRandomGenerator(os.time())

Entities = {
    {   -- player
        Drawable = {
            w     = 10,
            h     = 10,
            color = { 255, 255, 255 },
            needs = { "Positioned" },
            draw  = function (self, p)
                local r, g, b     = love.graphics.getColor()
                local x, y        = p.x, p.y
                local w, h, color = self.w, self.h, self.color

                love.graphics.setColor(color)
                love.graphics.rectangle("fill", x, y, w, h)
                love.graphics.setColor({ r, g, b })
            end
        },
        PlayerControlled = {

        },
        Positioned = { x = 100, y = 100 }
    },
    (function ()
        local cells = {}

        for i = 1, 100 do
            cells[i] = {}

            for j = 1, 50 do
                cells[i][j] = rng:random(0, 1)
            end
        end

        return {
            CellularAutomata = {
                cells = cells
            },
            -- TODO need to find a way to make draw logic a first class system
            -- it just isn't cool to have big ugly functions hanging out in here
            Drawable = {
                color     = { 0, 0, 0 },
                cell_size = 4,
                needs     = { "CellularAutomata" },
                draw      = function (self, c)
                    local r, g, b          = love.graphics.getColor()
                    local cells            = c.cells
                    local cell_size, color = self.cell_size, self.color
                    local length           = #cells * cell_size

                    local ftx, fty = 100, 100
                    love.graphics.push()
                    love.graphics.scale(1)
                    love.graphics.translate(ftx, fty)

                    love.graphics.setColor(color)
                    for i = 0, #cells do
                        love.graphics.line(i*cell_size, 0, i*cell_size, length)
                        love.graphics.line(0, i*cell_size, length, i*cell_size)

                        if i > 0 then
                            love.graphics.setColor({ 255, 0, 0 })
                            for j = 1, #cells do
                                if cells[i][j] == 1 then
                                    love.graphics.rectangle("fill", (i - 1)*cell_size + 1, (j - 1)*cell_size + 1, cell_size - 2, cell_size - 2)
                                end
                            end
                            love.graphics.setColor(color)
                        end
                    end
                    love.graphics.setColor({ r, g, b })

                    love.graphics.pop()
                end
            }
        }
    end)()
}

Systems = {
    PlayerControlled = require("player_controlled"),
    Drawable         = require("drawable"),
    CellularAutomata = require("cellular_automata")
}

function love.focus(f) gameIsPaused = not f end

function love.load()
    love.graphics.setBackgroundColor(0, 0, 0)

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

