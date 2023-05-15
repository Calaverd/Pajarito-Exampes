local Pajarito = require('pajarito')
local GraphicsBase = require('libs/graphics')



-- Wall coords are given with this for human readable
-- Walls are given as a string, were each char means a
-- direction were there is a wall
-- [Q][W][E] 
-- [A]   [D]
-- [Z][X][C]
-- note that S is also equivalent to X
-- Pajarito uses integer to understand the walls, where each bit is a flag
-- each bit must be arrange like this
-- QECZ WDXA
-- So a string like 'WX' or 'XW' is translated to binary as
-- 0000 1010 
-- and that is transformet to the integer '10' on decimal

-- note that you can also add the walls usign the integer instead of the string
-- so 146 and 'QAZ', are equally valid. 


local function Main()
    local self = GraphicsBase();

    self.title = 'Walls'
    self.gui.setDescriptionText(
        'This example uses a set of walls to illustrate '..
        'how they work and their differences.\n'..
        'On one side, walls what block the horizontal but '..
        'not diagonal, and in the other, walls that block both.')

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

    -- Note that the basic directions are:
    --  [UP_LEFT]   [UP]   [UP_RIGHT]
    --    [LEFT]            [RIGHT]
    -- [DOWN_LEFT] [DOWN] [DOWN_RIGHT]
    --
    -- We can get the direction constants enum
    -- or make use of the string names, but
    -- here, for didactic purposes are mixed.
    -- You can use the style that you like most.

    local dir = Pajarito.directions.values

    local mergeDirections = Pajarito.directions.mergeDirections
    -- If you think that the names are long, or want
    -- to use your own nomenclature, you can create alias.
    local setAlias = Pajarito.directions.setDirectionAlias
    -- For single directions
    setAlias('R0', dir.RIGHT)
    setAlias('R', 'RIGHT')
    setAlias('L', 'LEFT')
    -- and also for the merge of directions
    setAlias('RD', mergeDirections(dir.RIGHT, dir.DOWN))
    setAlias('LR', mergeDirections('RIGHT', 'LEFT'))
    setAlias('LU', mergeDirections('LEFT', dir.UP))
    setAlias('UD', mergeDirections('UP', 'DOWN'))
    -- You can even use symbols as alias...
    setAlias('==', mergeDirections('UP_LEFT', 'UP', 'UP_RIGHT', 'DOWN_LEFT', 'DOWN', 'DOWN_RIGHT'))
    setAlias('|<', mergeDirections('UP_LEFT','LEFT','DOWN_LEFT'))
    setAlias('>|', mergeDirections('UP_RIGHT','RIGHT','DOWN_RIGHT'))
    --- and merge the previously defined alias
    setAlias('∩', mergeDirections('|<','UP','>|'))

    -- This creates the walls, it needs a list with
    -- the position followed by the the directions
    -- that is facing
    self.map_graph:buildWalls(
        {
            { { 22, 5 }, 'UP', 'DOWN' }, -- We can use the default directions
            { { 21, 5 }, dir.UP, dir.DOWN }, -- the numerical constants
            { { 20, 5 }, 'LU' }, -- or the alias we defined.

            { { 20, 6 }, 'LR' }, { { 20, 7 }, 'LR' }, { { 20, 8 }, 'RD' },
            { { 19, 8 }, 'UD' }, { { 18, 7 }, 'R' }, { { 18, 9 }, 'R' },
            { { 18, 6 }, 'R','UP' }, { { 18, 10 },'RD' },
            { {17,5}, 'R' }, { {17,4}, 'R' }, { {17,3}, 'R' },
            { {17,2}, 'R' }, { {17,1}, 'R' }, { {17,11}, 'R' },
            { {17,12}, 'R' }, { {17,13}, 'R' }, { {17,14}, 'R' },
            { {17,15}, 'R' }, { {17,6}, 'R' }, { {17,7}, 'R' },
            { {17,8}, 'R' }, { {8,5}, '=='},  { {9,5}, '=='},
            { {10,5}, 'UP_LEFT','UP','>|','DOWN_LEFT' },
            { {10,6}, '|<','>|' }, { {10,7}, '|<','>|' }, { {10,8}, '|<','DOWN', 'DOWN_RIGHT', 'UP_RIGHT' },
            { {11,8}, '=='}, { {12,7}, '|<' }, { {12,9}, '|<' },
            { {12,6}, '|<','UP','UP_RIGHT' }, { {12,10}, '|<','DOWN','DOWN_RIGHT' },
            { {13,6}, 'UP_LEFT' },
            { {13,5}, '|<' }, { {13,4}, '|<' }, { {13,3}, '|<' },
            { {13,2}, '|<' }, { {13,1}, '|<' }, { {13,10}, 'DOWN_LEFT' },
            { {13,11}, '|<' }, { {13,12}, '|<' }, { {13,13}, '|<' },
            { {13,14}, '|<' }, { {13,15}, '|<' }, { {12,6}, '∩' },
            { {12,7}, '|<','>|'}, { {12,8}, '>|', 'UP_LEFT', 'DOWN_LEFT' }
        }
    )

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
    self.table_of_weights[1] = 1 --grass    tile 1 -> 1
    self.table_of_weights[2] = 3 --sand     tile 2 -> 2
    self.table_of_weights[3] = 0 --mountain tile 3 -> 0
    self.table_of_weights[4] = 2 --woods    tile 4 -> 2
    self.table_of_weights[5] = 0 --piramid  tile 5 -> 0
    self.table_of_weights[7] = 1 --dirt     tile 7 -> 1
    self.table_of_weights[8] = 0 --lava     tile 8 -> 0
    self.table_of_weights[9] = 0 --water    tile 9 -> 0
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
                -- All 'hasPoint' methods do checks in linear time.

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

        --- To draw the walls

        local tileset_walls = self.getTilesetWalls()
        local list_of_wall_tiles = self.getListOfWallTiles()
        tileset_walls:clear()
        local dir_enum = Pajarito.directions.values
        -- We define a map were each direction is
        -- maped to one specific tile in the tileset
        local direction_to_tile = {
            [ dir_enum.UP_LEFT ] = 1,
            [ dir_enum.UP ] = 2,
            [ dir_enum.UP_RIGHT ] = 3,
            [ dir_enum.LEFT ] = 4,
            [ dir_enum.RIGHT ] = 6,
            [ dir_enum.DOWN_LEFT ] = 7,
            [ dir_enum.DOWN ] = 8,
            [ dir_enum.DOWN_RIGHT ] = 9,
        }
        for position, wall_value in self.map_graph:iterWalls() do
            local x,y = unpack(position)
            local directions = Pajarito.directions.splitDirections(wall_value)
            -- draw the tile to their corresponding direction
            for _,direction in ipairs(directions) do
                local tile = direction_to_tile[direction]
                tileset_walls:add( list_of_wall_tiles[tile], x*17, y*17)
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

    -- This is called every time the slider of 'Range' is updated
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