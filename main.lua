require "fsm"
require "system"
require "matrix"

local i = require("vendor/inspect/inspect")
inspect = function (a, b)
    print(i.inspect(a, b))
end

function math.round(val, decimal)
  local exp = decimal and 10^decimal or 1
  return math.ceil(val * exp - 0.5) / exp
end

W_WIDTH  = love.window.getWidth()
W_HEIGHT = love.window.getHeight()

global = {}
local state_machine
global.tile_size = 8
rng = love.math.newRandomGenerator(os.time())

local start_x = 100
local start_y = 75

local Cells = {
    cells = Matrix(start_x, start_y, Generators.random(0, 1))
}

Entities = {
    {   -- player
        Drawable = {
            w     = global.tile_size,
            h     = global.tile_size,
            color = { 255, 255, 255 },
            needs = { "Positioned" },
            draw  = function (self, p)
                local r, g, b     = love.graphics.getColor()
                local x, y        = p.x * global.tile_size, p.y * global.tile_size
                local w, h, color = self.w, self.h, self.color

                love.graphics.setColor(color)
                love.graphics.rectangle("fill", x, y, w, h)
                love.graphics.setColor({ r, g, b })
            end
        },
        PlayerControlled = {

        },
        Collision = {
            world = Cells.cells
        },
        Positioned = {
            x = start_x - 1, y = start_y - 1,
            old_x = start_x - 1, old_y = start_y - 1
        }
    },
    {
        Cells = Cells.cells,
        Drawable = {
            background     = { 0, 0, 0 },
            cell_size      = global.tile_size,
            color          = {
                { 50, 200, 50 },  -- SOLID
                { 200, 50, 50 },  -- MONSTER
                { 200, 200, 50 }, -- TREASURE
                { 50, 50, 200},   -- WATER
                { 50, 150, 200},  -- POOL
                { 100, 100, 100}, -- STRUCTURE
            },
            needs          = { "Cells" },
            draw       = function (self, cells)
                local r, g, b       = love.graphics.getColor()
                local cell_size     = self.cell_size
                local background    = self.background
                local color         = self.color
                local length        = #cells * cell_size
                local grid_h        = #cells
                local grid_w        = #(cells[1])

                local ftx, fty = 0, 0
                love.graphics.push()
                love.graphics.scale(1)
                love.graphics.translate(ftx, fty)

                love.graphics.setColor(background)
                for i = 0, grid_h do
                    love.graphics.line(i*cell_size, 0, i*cell_size, length)
                    love.graphics.line(0, i*cell_size, length, i*cell_size)

                    if i > 0 then
                        for j = 1, grid_w do
                            if cells[i][j] ~= EMPTY then
                                love.graphics.setColor(color[cells[i][j]])
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
}

Systems = {
    PlayerControlled = require("player_controlled"),
    Drawable         = require("drawable"),
    CellularAutomata = require("cellular_automata"),
    Collision        = require("collision"),
    TitleScreen      = require("title_screen")
}

function love.focus(f) gameIsPaused = not f end

function love.load()
    love.graphics.setBackgroundColor(0, 0, 0)

    state_machine = FSM()

    state_machine.addState({
        name       = "start",
        systems    = {
            "TitleScreen"
        }
    })

    state_machine.addState({
        name       = "run",
        systems    = {
            "PlayerControlled",
            "Drawable",
            "Collision",
            "CellularAutomata"
        }
    })

    state_machine.addTransition({
        from      = "start",
        to        = "run",
        condition = function ()
            return Systems["TitleScreen"].get("choice") ~= nil
        end
    })

    love.update     = state_machine.update
    love.keypressed = state_machine.keypressed
    love.draw       = state_machine.draw

    state_machine.start()
end

