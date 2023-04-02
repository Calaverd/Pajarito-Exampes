local Pajarito = require("pajarito")
local GraphicsBase = require('libs/graphics')

local function Main()
    local self = GraphicsBase();

    self.title = 'No Boilerplate Test'

    self.tile_map = {
        { 1, 3, 2, 3, 1, 1, 1 },
        { 1, 3, 2, 2, 2, 1, 1 },
        { 2, 1, 1, 2, 2, 1, 1 },
        { 1, 2, 3, 1, 1, 3, 3 },
        { 1, 2, 2, 2, 1, 3, 2 },
        { 1, 1, 1, 3, 3, 3, 2 },
        { 1, 1, 2, 2, 2, 3, 2 }
    }
    self.tile_map_width = #self.tile_map
    self.tile_map_height = #self.tile_map[1]

    self.map_graph = Pajarito.Graph:new{ type= '2D', map= self.tile_map}
    self.map_graph:build()
    self.node_range = self.map_graph:constructNodeRange({1,1},1)

    -- This method used to update the tiles to draw
    -- and is called only once an update has been made.
    -- Is left here because it shows how you can get
    -- info from an specific point.
    function self.updateTilesToDraw()
        local tileset = self.getTileset()
        local list_of_tiles = self.getListOfTiles()
        local tile_for_range = list_of_tiles[29]
        local tile_for_border = list_of_tiles[29]

        tileset:clear()
        for y=1, self.tile_map_height do
            for x=1, self.tile_map_width do
                local map_tile = self.tile_map[y][x]
                -- A tile is added to the be draw.
                -- this is the map layer
                tileset:add(list_of_tiles[map_tile],x*17,y*17)

                -- Here we ask if on that position
                -- the range has node of that kind
                -- Fear not nested loops!
                -- All "hasPoint" methods do checks in linear time.

                if self.node_range:hasPoint({x,y}) then
                    tileset:add(tile_for_range, x*17, y*17)
                end

                if self.show_border
                    and self.node_range:borderHasPoint({x,y}) then
                    tileset:add(tile_for_border, x*17, y*17)
                end

                tileset:setColor(1,1,1,1)
            end
        end
    end

    return self;
end


return Main()