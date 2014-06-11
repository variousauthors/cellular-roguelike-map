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

global = {}
local state_machine
global.tile_size = 8
rng = love.math.newRandomGenerator(os.time())

Entities = {
    {   -- player
        Drawable = {
            w     = global.tile_size,
            h     = global.tile_size,
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
        Collision = {},
        Positioned = {
            x = 0, y = 0,
            old_x = 0, old_y = 0
        }
    },
    (function ()
        local cells = {}

        for i = 1, 100 do
            cells[i] = {}

            for j = 1, 75 do
                cells[i][j] = rng:random(0, 1)
            end
        end

        return {
            CellularAutomata = {
                cells = cells
            },
            Collision = {},
            -- TODO need to find a way to make draw logic a first class system
            -- it just isn't cool to have big ugly functions hanging out in here
            Drawable = {
                background = { 0, 0, 0 },
                cell_size  = global.tile_size,
                cell_color = { 50, 200, 50 },
                needs      = { "CellularAutomata" },
                draw       = function (self, c)
                    local r, g, b    = love.graphics.getColor()
                    local cells      = c.cells
                    local cell_size  = self.cell_size
                    local background = self.background
                    local cell_color = self.cell_color
                    local length     = #cells * cell_size

                    local ftx, fty = 0, 0
                    love.graphics.push()
                    love.graphics.scale(1)
                    love.graphics.translate(ftx, fty)

                    love.graphics.setColor(background)
                    for i = 0, #cells do
                        love.graphics.line(i*cell_size, 0, i*cell_size, length)
                        love.graphics.line(0, i*cell_size, length, i*cell_size)

                        if i > 0 then
                            love.graphics.setColor(cell_color)
                            for j = 1, #cells do
                                if cells[i][j] == 1 then
                                    love.graphics.rectangle("fill", (i - 1)*cell_size + 1, (j - 1)*cell_size + 1, cell_size - 2, cell_size - 2)
                                end
                            end
                            love.graphics.setColor(background)
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
    CellularAutomata = require("cellular_automata"),
    Collision        = require("collision")
}

function love.focus(f) gameIsPaused = not f end

function love.load()
    love.graphics.setBackgroundColor(0, 0, 0)

    state_machine = FSM()

    state_machine.addState({
        name       = "start",
        systems    = {
            "PlayerControlled",
            "Drawable",
            "Collision"
        }
    })

    love.update     = state_machine.update
    love.keypressed = state_machine.keypressed
    love.draw       = state_machine.draw

    state_machine.start()
end

