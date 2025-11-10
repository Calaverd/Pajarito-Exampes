local Pajarito = require("pajarito")
local GraphicsBase = require('libs/graphics')
local BaseEntity = require('libs/base_entity')

function Angel(x,y)
    local self = BaseEntity(4)
    local angel_table_of_weights = {}
    angel_table_of_weights[1] = 1 --grass
    angel_table_of_weights[2] = 2 --sand
    angel_table_of_weights[3] = 2 --mountain
    angel_table_of_weights[4] = 2 --woods
    angel_table_of_weights[5] = 1 --piramid
    angel_table_of_weights[7] = 1 --dirt
    angel_table_of_weights[8] = 2 --lava
    angel_table_of_weights[9] = 1 --water
    self.x = x
    self.y = y
    self.range = 8
    self.group = 'Angels'
    self.collitions = {'Demons', 'Knights'}
    self.move_type = 'diagonal'
    self.weight_constrains = angel_table_of_weights
    return self
end


function Demon(x,y)
    local self = BaseEntity(8)
    local demon_table_of_weights = {}
    demon_table_of_weights[1] = 1 --grass
    demon_table_of_weights[2] = 1 --sand
    demon_table_of_weights[3] = 2 --mountain
    demon_table_of_weights[4] = 1 --woods
    demon_table_of_weights[5] = 0 --piramid
    demon_table_of_weights[7] = 1 --dirt
    demon_table_of_weights[8] = 1 --lava
    demon_table_of_weights[9] = 2 --water
    self.x = x
    self.y = y
    self.range = 10
    self.weight_constrains = demon_table_of_weights
    self.group = 'Demons'
    self.collitions = {'Angels', 'Knights'}
    return self
end


function Knight(x,y)
    local self = BaseEntity(0)
    local knight_table_of_weights = {}
    knight_table_of_weights[1] = 1 --grass
    knight_table_of_weights[2] = 3 --sand
    knight_table_of_weights[3] = 0 --mountain
    knight_table_of_weights[4] = 3 --woods
    knight_table_of_weights[5] = 0 --piramid
    knight_table_of_weights[7] = 1 --dirt
    knight_table_of_weights[8] = 0 --lava
    knight_table_of_weights[9] = 0 --water
    self.x = x
    self.y = y
    self.range = 8
    self.weight_constrains = knight_table_of_weights
    self.group = 'Knights'
    self.collitions = {'Demons', 'Angels'}
    return self
end

function Banner(x,y)
    local self = BaseEntity(12)
    self.x = x
    self.y = y
    self.group = 'Banners'
    return self
end

local function Main()
    local self = GraphicsBase();

    self.title = 'Entities'
    self.gui.setDescriptionText(
        'This example illustrates how to handle entities, '..
        'You can click on any of the entities to select it.\n'..
        'Notice how the Knight, the Angel and the Demon can'..
        'not collide with each other, but can traverse the banners.')
    self.gui.setMinimal(true)

    self.tile_map = {
        {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
        {1,1,1,1,1,1,1,1,7,7,7,7,7,7,7,1,1,1,1,1,1,1,1,1,1},
        {1,1,1,1,1,1,1,1,7,5,5,5,5,5,7,1,1,1,1,1,1,1,1,1,1},
        {1,1,1,1,1,1,1,1,7,5,7,7,7,5,7,1,3,3,1,1,1,1,1,1,1},
        {1,1,1,1,1,1,1,1,7,5,5,7,5,5,7,1,3,3,1,1,1,1,1,1,1},
        {1,1,1,1,1,1,1,1,7,7,7,7,7,7,7,1,3,3,3,1,1,1,1,1,1},
        {1,1,1,1,2,2,2,2,1,1,1,1,1,1,1,1,3,3,3,3,1,1,1,1,1},
        {1,1,1,1,2,2,2,2,2,1,1,1,1,1,1,1,3,3,3,9,9,1,1,1,1},
        {1,1,1,1,2,2,2,2,2,1,1,1,1,1,1,1,4,3,9,9,9,1,1,1,1},
        {1,1,1,1,2,2,2,2,2,2,1,1,1,1,1,1,4,3,9,9,9,1,1,1,1},
        {1,1,1,1,2,8,8,8,2,2,1,1,1,1,1,1,1,4,4,4,9,1,1,1,1},
        {1,1,1,1,2,8,8,8,2,2,1,1,1,1,1,1,4,4,4,1,1,1,1,1,1},
        {1,1,1,1,2,2,2,2,2,1,1,1,1,4,4,4,4,4,1,1,1,1,1,1,1},
        {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
        {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
    }
    self.tile_map_width = #self.tile_map[1]
    self.tile_map_height = #self.tile_map


    self.map_graph = Pajarito.Graph:new({type= '2D', map= self.tile_map})

    -- This initializes all the nodes and their conections in the graph.
    -- This operation can be a little bit expensive depending on the map size
    -- Call it once before starting to use the methods of the graph object.
    self.map_graph:build()

    --- We define some entities
    local list_of_entities = {}
    table.insert(list_of_entities, Banner(15,10))
    table.insert(list_of_entities, Banner(8,7))
    table.insert(list_of_entities, Banner(10,12))
    table.insert(list_of_entities, Banner(12,8))
    table.insert(list_of_entities, Banner(12,5))
    table.insert(list_of_entities, Banner(16,7))
    table.insert(list_of_entities, Banner(13,12))

    table.insert(list_of_entities, Angel(16,6))
    table.insert(list_of_entities, Demon(11,8))
    table.insert(list_of_entities, Knight(13,7))

    -- add they to a function to be draw later
    self.drawEntities = function ()
        for _,entity in pairs(list_of_entities) do
            entity.draw()
        end
    end

    --- Add to the graph
    for _,entity in pairs(list_of_entities) do
        local x,y = entity.x, entity.y
        self.map_graph:addObject(entity, {x, y}, {entity.group})
    end

    -- Creates an special kind of object that contains all nodes
    -- in the given reach from within the given node position
    local current_entity = list_of_entities[#list_of_entities]
    local max_allowed_cost = current_entity.range
    local initial_x = current_entity.x
    local initial_y = current_entity.y

    self.node_range =
        self.map_graph:constructNodeRange(
            {initial_x, initial_y},
            max_allowed_cost)

    -- We take the weights from the current entity
    self.table_of_weights = current_entity.weight_constrains
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

                -- We do not draw the ranges if the animation is running
                if not self.animate_translation then
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
                end

                tileset:setColor(1,1,1,1)
            end
        end
    end

    function self.drawNodeRangeValues()
        -- We do not draw the values if the animation is running
        if self.animate_translation then
            return
        end
        local nodes_in_range = self.node_range:getAllNodes()
        for _,node in ipairs(nodes_in_range) do
            local x,y = node.position[1], node.position[2]
            local movement_cost = tostring(self.node_range:getReachCostAt(node.id))
            self.drawCost(x*17,y*17,movement_cost)
        end
    end

    function self.drawNodeBorderValues()
        -- We do not draw the values if the animation is running
        if self.animate_translation then
            return
        end
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
            self.node_range:getPathTo( {self.m_ix,self.m_iy} )
    end

    function self.drawPath()
        -- If there is no path or the animation is running, we do not draw it.
        if not self.generated_path or self.animate_translation then
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

    local function recalcPaths(entity,x,y)
        local movement = entity.move_type
        local range = entity.range
        local can_not_collide = entity.collitions or {}
        self.map_graph:setWeightMap(entity.weight_constrains)
        self.node_range =
            self.map_graph:constructNodeRange({x,y}, range, movement, can_not_collide)
        self.updateTilesToDraw()
        self.requestNewPath() -- clean the path
    end

    -- This function will be called on the click position
    function self.updateRange(x,y)
        -- block the updates if the animation for the entitie moving is running
        if self.animate_translation then
            return
        end

        --- Now check the click position
        if self.node_range and self.map_graph:hasPoint({x,y}) then
            local entities_in_point = self.map_graph:getObjectsAt({x,y})
            -- the click was over one of the objects
            if entities_in_point then
                -- if there is more than one object in the point,
                -- select the one that is not a banner
                for _, object in ipairs(entities_in_point) do
                    if object.group ~= 'Banners' then
                        current_entity = object
                        -- if the object not a flag, it can be moved
                        recalcPaths(current_entity, current_entity.x, current_entity.y)
                        return
                    end
                end
            end
            -- check if the click was inside the generated range.
            if self.node_range:hasPoint({x,y}) then
                -- move the object final position with in the graph
                self.map_graph:translateObject(current_entity,{x,y})
                -- move the object drawing position using flux
                for _,node in self.generated_path:iterNodes() do
                    local steep_x, steep_y = node.position[1], node.position[2]
                    if not self.animate_translation then
                        -- this is the first steep, define the animation
                        self.animate_translation = flux.to(current_entity, 0.2, {x=steep_x, y=steep_y})
                    else
                        -- chain animation to the next step
                        self.animate_translation =
                          self.animate_translation:after(current_entity, 0.2, {x=steep_x, y=steep_y})
                    end
                end
                self.updateTilesToDraw() -- clean the tiles for the range.
                self.animate_translation:oncomplete(
                    --- once the animation is complete...
                    function ()
                        self.animate_translation = nil -- clear the animation
                        recalcPaths(current_entity, current_entity.x, current_entity.y)
                    end)
            end
        end
    end

    self.m_ix = initial_x
    self.m_iy = initial_y

    return self;
end

return Main()