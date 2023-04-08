local Pajarito = require("pajarito")
local GraphicsBase = require('libs/graphics')

local function Main()
    local self = GraphicsBase();

    self.title = 'No Boilerplate Test'
    self.gui.setDescriptionText('A simple no boilerplate test')

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

    self.map_graph = Pajarito.Graph:new({type= '2D', map= self.tile_map})

    -- This initializes all the nodes and their conections in the graph.
    -- This operation can be a little bit expensive depending on the map size
    -- Call it once before starting to use the methods of the graph object.
    self.map_graph:build()

    self.node_range = self.map_graph:constructNodeRange({1,1},10)
    self.gui.setRangeSliderValue(10)

    self.table_of_weights = {}
    self.table_of_weights[1] = 1  --grass    tile 1 -> 1
    self.table_of_weights[2] = 3  --sand     tile 2 -> 2
    self.table_of_weights[3] = 0  --mountain tile 3 -> 0
    self.table_of_weights[4] = 2  --woods    tile 4 -> 2
    self.table_of_weights[5] = 0  --walls    tile 5 -> 0
    self.table_of_weights[8] = 1  --dirt     tile 8 -> 1
    self.table_of_weights[9] = 0  --lava     tile 9 -> 0
    self.table_of_weights[10] = 0 --water   tile 10 -> 0

    --set the table to the tilemap
    self.map_graph:setWeightMap(self.table_of_weights);

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

    function self.updateMapTile(x,y,new_value)
        print('X '..x..','..' Y '..y..' draw tile: '..new_value)
        if self.map_graph and self.map_graph:hasPoint({x,y}) then
            -- We use this table to draw the map
            -- so we have to update it
            self.tile_map[y][x] = new_value

            -- Update the node tile in the graph
            self.map_graph:updateNodeTile({x,y},new_value)

            -- Update the range with the new map info.
            local start_node = self.node_range:getStartNode()
            local range = self.node_range.range
            if start_node then
                local position = start_node.position
                self.node_range = self.map_graph:constructNodeRange(position, range )
            end

            self.updateTilesToDraw()
        end
    end

    -- This is called every time the slider of "Range" is updated
    -- or when the start position of the range has been changed
    function self.updateRange(x,y,range)
        if self.node_range and self.map_graph:hasPoint({x,y}) then
            self.node_range = self.map_graph:constructNodeRange({x,y}, range )
            self.updateTilesToDraw()
        end
    end

    self.gui.setSliderCallback(self.updateRange)
    self.gui.bindTableWeights(self.table_of_weights)

    return self;
end


return Main()