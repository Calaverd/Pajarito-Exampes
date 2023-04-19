local Pajarito = require("pajarito")
local GraphicsBase = require('libs/graphics')

local function Main()
    local self = GraphicsBase();

    self.title = 'Clean Canvas'
    self.gui.setDescriptionText(
        'A map using a single weight tile.\n'..
        'Use it to toy around an create custom test with the draw mode')

    self.tile_map = {
        {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
        {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
        {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
        {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
        {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
        {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
        {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
        {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
        {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
        {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
        {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
        {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
        {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
        {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
        {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
    }
    self.tile_map_width = #self.tile_map[1]
    self.tile_map_height = #self.tile_map

    self.map_graph = Pajarito.Graph:new({type= '2D', map= self.tile_map})

    -- This initializes all the nodes and their conections in the graph.
    -- This operation can be a little bit expensive depending on the map size
    -- Call it once before starting to use the methods of the graph object.
    self.map_graph:build()

    -- Creates an special kind of object that contains all nodes
    -- in the given reach from within the given node position
    local max_allowed_cost = 15
    local initial_x = math.floor(self.tile_map_width/2)
    local initial_y = math.floor(self.tile_map_height/2)

    self.node_range =
        self.map_graph:constructNodeRange(
            {initial_x, initial_y},
            max_allowed_cost)

    -- We define a set of weights or traversal cost
    -- for the posible tiles on the map
    self.table_of_weights = {}
    self.table_of_weights[1] = 1  --grass    tile 1 -> 1
    self.table_of_weights[2] = 3  --sand     tile 2 -> 2
    self.table_of_weights[3] = 0  --mountain tile 3 -> 0
    self.table_of_weights[4] = 2  --woods    tile 4 -> 2
    self.table_of_weights[5] = 0  --piramid  tile 5 -> 0
    self.table_of_weights[6] = 1  --dirt     tile 8 -> 1
    self.table_of_weights[7] = 0  --lava     tile 9 -> 0
    self.table_of_weights[8] = 0 --water   tile 10 -> 0
    -- Inform to the graph to take the weights into acount
    self.map_graph:setWeightMap(self.table_of_weights)

    self.generated_path = nil -- define this for a later use.

    -- This method used to update the tiles to draw
    -- and is called only once an update has been made.
    -- Is left here because it shows how you can get
    -- info from an specific point.
    function self.updateTilesToDraw()
        local tileset = self.getTileset()
        local list_of_tiles = self.getListOfTiles()
        local tile_for_range_start = list_of_tiles[12]
        local tile_for_range = list_of_tiles[13]
        local tile_for_border = list_of_tiles[14]
        local tile_for_border_unpassable = list_of_tiles[15]

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

                if self.gui.canShowRangeNodes() then
                    if self.node_range:hasPoint({x,y}) then
                        if self.node_range:isStartNodePosition({x,y}) then
                            tileset:add(tile_for_range_start, x*17, y*17)
                        else
                            tileset:add(tile_for_range, x*17, y*17)
                        end
                    end
                end

                if self.gui.canShowRangeBorder() then
                    local node_id = self.node_range:borderHasPoint({x,y})
                    if node_id then
                        local cost = self.node_range:getBorderWeight(node_id --[[@as integer]])
                        if cost == -1 then
                            tileset:add(tile_for_border_unpassable, x*17, y*17)
                        else
                            tileset:add(tile_for_border, x*17, y*17)
                        end
                    end
                end

                tileset:setColor(1,1,1,1)
            end
        end
    end

    function self.drawNodeRangeValues()
        local nodes_in_range = self.node_range:getAllNodes()
        for _,node in ipairs(nodes_in_range) do
            local x,y = node.position[1], node.position[2]
            local movement_cost = tostring(self.node_range:getReachCostAt(node.id))
            self.drawCost(x*17,y*17,movement_cost)
        end
    end

    function self.drawNodeBorderValues()
        local nodes_in_border = self.node_range:getAllBoderNodes()
        for _,node in ipairs(nodes_in_border) do
            local x,y = node.position[1], node.position[2]
            local cost = self.node_range:getBorderWeight(node.id)
            if cost then
                self.drawCost(x*17,y*17,cost)
            end
        end
    end

    --We request a new path every time that the GUI updates
    function self.requestNewPath()
        -- Ask if the requested destination point is contained
        -- in the range, and returns a table listing nodes
        -- from the starting point to the destination
        self.generated_path =
            self.node_range:getPathTo(
                {self.m_ix,self.m_iy},
                self.gui.canWarrantyShortest()
            )
    end

    function self.drawPath()
        if not self.generated_path then
            return
        end

        love.graphics.setColor(0.9,0.9,1)
        love.graphics.setLineWidth(2)
        for steep,node in self.generated_path:iterNodes() do
            local x, y = node.position[1], node.position[2]

            --this part draws a line between the center of this node an the next
            local next_node = self.generated_path:getNodeAtSteep(steep+1)
            if next_node then
                local nx, ny = next_node.position[1], next_node.position[2]
                love.graphics.line((x+0.5)*17, (y+0.5)*17,
                                    (nx+0.5)*17, (ny+0.5)*17)
            end
        end
        love.graphics.setLineWidth(1)
        love.graphics.setColor(1,1,1)
    end

    --- Changes the tile value of the given point in
    -- the graph and on the tile map.
    function self.updateMapTile(x,y,new_value)
        if self.map_graph and self.map_graph:hasPoint({x,y}) then
            -- We use this table to draw the map
            -- so we have to update it
            self.tile_map[y][x] = new_value

            -- Update the node tile in the graph
            self.map_graph:updateNodeTile({x,y},new_value)

            -- Update the range with the new map info.
            local position = self.node_range:getStartNodePosition()
            local range = self.node_range.range
            if position then
                self.updateRange(position[1], position[2], range)
            end
        end
    end

    -- This is called every time the slider of "Range" is updated
    -- or when the start position of the range has been changed
    function self.updateRange(x,y,range)
        if self.node_range and self.map_graph:hasPoint({x,y}) then
            local movement = nil -- use default movement
            if self.gui.canGoDiagonal() then
                movement = 'diagonal'
            end
            self.node_range =
                self.map_graph:constructNodeRange({x,y}, range, movement)
            self.updateTilesToDraw()
        end
    end

    -- This is to conect the GUI to this functions,
    -- so the changes in the GUI can take effect.
    self.gui.setSliderCallback(self.updateRange)
    self.gui.bindTableWeights(self.table_of_weights)
    self.gui.setRangePosition(initial_x, initial_y)
    self.gui.setRangeSliderValue(max_allowed_cost)
    self.m_ix = initial_x
    self.m_iy = initial_y

    return self;
end

return Main()