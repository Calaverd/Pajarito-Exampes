local cronoAnimation = Chrono()
local animationFrame = 1
cronoAnimation.start()
local sprite_entities = love.graphics.newImage('/rsc/entities.png')
local quads_entities = makeQuads(64,80,16,16)

---A base class to draw all the entities to use.
---@param type any
---@return table
return function(type)
    local self = {}
    self.x = 1
    self.y = 1

    function self.getPos()
        return {self.x, self.y}
    end

    function self.drawAtPos(x,y)
        if cronoAnimation.hasPassed(0.15) then
            animationFrame = math.fmod(animationFrame,4)+1
        end
        love.graphics.draw(sprite_entities, quads_entities[type+animationFrame], x,y )
    end

    function self.draw()
        self.drawAtPos(self.x*17, self.y*17)
    end
    return self
end
