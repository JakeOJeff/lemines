local quad = {}

function quad:generateNums()
    spritesheet = love.graphics.newImage("texture.png")
    sheetW = spritesheet:getWidth()
    sheetH = spritesheet:getHeight()


    quad.nums = {}
    quad.bombs = {
        love.graphics.newQuad(2 * 16, 3 * 16, 16, 16, sheetW, sheetH),
        love.graphics.newQuad(3 * 16, 3 * 16, 16, 16, sheetW, sheetH)
    }
    for i = 1, 4 do -- 1 - 4
        quad.nums[i] = love.graphics.newQuad((i - 1) * 16, 0, 16,16, sheetW, sheetH)
    end
    for i = 1, 4 do -- 5 - 8
        quad.nums[i + 4] = love.graphics.newQuad((i - 1) * 16, 16, 16,16, sheetW, sheetH)
    end
    quad.nums[9] = love.graphics.newQuad(0, 2 * 16, 16, 16, sheetW, sheetH) -- 0
end


return quad