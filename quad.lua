local quad = {}

function quad:generateNums()
    spritesheet = love.graphics.newImage("texture.png")
    sheetW = spritesheet:getWidth()
    sheetH = spritesheet:getHeight()


    quad.nums = {}
    for i = 0, 3 do
        quad.nums[i + 1] = love.graphics.newQuad(i * 16, i * 16, 16, sheetW, sheetH)
    end
end

function quad:drawNums()
    for i, v in ipairs(GRID.cells) do
        for j, cell in ipairs(v) do
            if not cell.mine then
                
            end
        end
    end
end