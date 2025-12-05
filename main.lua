wW, wH = love.graphics.getDimensions()

function love.load()
    GRID = require("grid")
    GEN = require("gen")
    QUAD = require("quad")
    gridInstance = GRID:new(20, 20)
    GEN:create(100)
end

function love.draw()
    GRID:draw()
end

function love.mousepressed(x, y, button)
    GRID:mousepressed(x, y, button)
end