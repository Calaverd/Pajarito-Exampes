local Directions = require "pajarito.directions"
local Heap = require "pajarito.heap";
local Node = require "pajarito.Node";
local NodeRange = require "pajarito.NodeRange";


---@diagnostic disable-next-line: deprecated
local unpack = unpack or table.unpack

--- takes an object an returns a number to
--- use as id.
---@param object table
---@return ObjectID
local function getObjectID(object)
    return tonumber( tostring(object):gsub('table: 0x',''), 16)
end

local Node_getPointId = Node.getPointId

--- A class for the representation of
--- maps as a Graph. \
--- Is composed of nodes and allows for
--- operations on them
---@class Graph
---@field node_map {numeber:Node} A list of all the nodes on this graph
---@field weight_map table<number,number> A map for the weight of tiles
---@field walls table<number, number> A map for node id and wall
---@field objects { ObjectID:NodeID } A map for objects and their position usefull to handle entities that move around the map.
---@field object_groups { string:{ObjectID:boolean} } to store the groups of the objects
---@field settings table A map for that contains contextual info to build the graph
local Graph = {}


--- Graph object constructor
---@param settings table instructions about how to create this graph
---@return Graph
function Graph:new(settings)
    local obj = {}
    obj.node_map = {} --- A list with all the nodes
    obj.weight_map = {}
    obj.walls = {}
    obj.settings = settings
    obj.objects = {}
    obj.object_groups = {}

    setmetatable(obj, self)
    self.__index = self
    return obj
end

--- Returns the node with that id if exist
--- in the graph, otherwise nil.
---@param id_node integer
---@return Node | nil
function Graph:getNode(id_node)
    return self.node_map[id_node]
end

---Adds a node to this graph.
---@param node Node
function Graph:addNode(node)
    self.node_map[node.id] = node;
end

--- Takes the postion of a node in the graph
--- and updates their contained tile value.
---@param position number[]
---@param tile number|string
function Graph:updateNodeTile(position, tile)
    local id = self:positionToMapId(position)
    local node = self:getNode(id)
    if node then
        node:setTile(tile)
    end
end

--- Adds a node to the graph and conects
--- it to their neighbourds if they exist
--- or there is no wall between.\
--- Needs some contextual info about node position
--- and the graph dimentions.
---@param new_node Node
---@param x number
---@param y number
---@param z number
---@param width number
---@param height number
---@param deep number
function Graph:connectNodeToNeighbors(new_node, x,y,z,width,height,deep)
    -- Connect the node to their neighbourds
    local all_2d_directions = Directions["2D"].diagonal;
    for _, direction in pairs( all_2d_directions ) do
        local move = Directions.movements[direction]
        local n_x, n_y, n_z = x+move.x, y+move.y, z+move.z
        local neighbour_id = Node_getPointId(n_x, n_y, n_z, width, height, deep)
        local neighbour = self:getNode(neighbour_id)
        if neighbour then
            new_node:makeTwoWayLinkWith(neighbour, direction)
        end
    end
end

--- Sets the given table as the weight_map
---@param new_weight_map table<number,number> 
function Graph:setWeightMap(new_weight_map)
    self.weight_map = new_weight_map
end

---@param point number[]
---@return boolean
function Graph:hasPoint(point)
    local node_id = self:positionToMapId(point)
    return self.node_map[node_id] ~= nil
end

--- Adds a new object.\
--- Objects are entities that
--- can move around the map\
--- **This function does not cares to check
--- if the new position is a valid one.**
---@param object table And object to add.
---@param position number[] Position of the node were this object will be added.
---@param groups ?string[] A set of custom groups to the ones this object bellows see Graph:setObjectRules
---@return ObjectID object_id
function Graph:addObject(object, position, groups)
    local object_id = getObjectID(object)
    local node_id = self:positionToMapId(position)
    local node = self:getNode(node_id)
    if node then
        node:addObject(object_id)
    end
    self.objects[object_id] = node_id

    if groups then
        for _, group in ipairs(groups) do
            if not self.object_groups[group] then
                self.object_groups[group] = {}
            end
            self.object_groups[group][object_id] = true;
        end
    end
    return object_id
end

--- Moves an object from their current position
--- on the graph to a new one.\
---@param object_to_move ObjectID|table -- the object to move itself or their id.
---@param new_position number[]
---@return boolean result if the translation could be fullfiled
function Graph:translasteObject(object_to_move, new_position)
    local old_node = nil
    local object_id = object_to_move --[[@as ObjectID]]
    if self.objects[object_to_move] then
        print('given ObjectID')
        old_node = self:getNode(self.objects[object_to_move])
    else
        object_id = getObjectID(object_to_move --[[@as table]])
        if self.objects[object_id] then
            print('given as table')
            old_node = self:getNode(self.objects[object_to_move])
        else
            return false
        end
    end
    local new_node = self:getNode(self:positionToMapId(new_position))
    if old_node then
        print('old node is '..old_node.id)
        old_node:removeObject(object_id)
    end
    if new_node then
        print('new node is '..new_node.id)
        new_node:addObject(object_id)
        self.objects[object_id] = new_node.id
        return true
    end
    return false
end

---Removes the object references in the graph
---@param object_to_remove ObjectID|any -- the object to delete itself or their id.
function Graph:removeObject(object_to_remove)
    local old_node = nil
    local object_id = object_to_remove --[[@as ObjectID]]
    if self.objects[object_to_remove] then
        old_node = self:getNode(self.objects[object_to_remove])
    else
        object_id = getObjectID(object_to_remove --[[@as table]])
        if self.objects[object_id] then
            old_node = self:getNode(self.objects[object_to_remove])
        end
    end
    if old_node then
        old_node:removeObject(object_id)
    end
    for _, group in pairs(self.object_groups) do
        if self.object_groups[group][object_id] then
            self.object_groups[group][object_id] = nil
        end
    end
    self.objects[object_id] = nil
end

---Fills the node_map of the graph using the 
---2D map given by the user in the settings.
---@param map_2d table The 2D map to build the graph from
function Graph:buildFrom2DMap(map_2d)
    local y = 1
    local height = #map_2d
    local width = #map_2d[y]
    while map_2d[y] do
        local x = 1
        while map_2d[y][x] do
            local node_id = Node_getPointId(x, y, 0, width, height, 0)
            local node = Node:new(node_id, {x,y})
            node:setTile(map_2d[y][x])
            self:addNode(node)
            self:connectNodeToNeighbors(node,x,y,0,width,height,0)
            x = x+1
        end
        y = y+1
    end
end

--- Starts building the Graph from the
--- instructions given in the settings
function Graph:build()
    if self.settings.type == '2D' then
        self:buildFrom2DMap(self.settings.map)
    end
    self.weight_map = self.settings.weights or {}
end

--- Creates a new priority heap that will contain
--- Nodes and store them based on their weight.
---@return Heap
function Graph:newNodeHeap()
    ---@type Heap
    local heap = Heap:new();
    heap:setCompare( function (node_a, node_b)
        -- vale 1 is the Node, value 2 is the accumulated_weight!
        return node_a[2] < node_b[2]
    end )
    return heap
end

--- Converts a position given as a list the corresponding 
--- node ID in the map. 
--- The ID is constructed based on the graph's settings
--- (dimensions of the map). Returns the node ID.
---@param position number[] The position with the x, y, and z coordinates packed.
---@return NodeID id corresponding to the given position in the graph's map.
function Graph:positionToMapId(position)
    local width = 0
    local height = 0
    local depth = 0
    if self.settings.type == '2D' then
        height = #self.settings.map
        width = #self.settings.map[1]
    end
    local x,y,z = unpack(position)
    return Node_getPointId(x or 0, y or 0, z or 0, width, height, depth)
end

--- Returns the weight of this node in the current weight_map.\
--- If the node is not in the weight_map,
--- returns the tile of the node if is a number.\
--- If the tile of the node is not a number, returns
--- the weight as impassable
---@param node Node
---@return number
function Graph:getNodeWeight(node)
    if self.weight_map[node.tile] then
        return self.weight_map[node.tile]
    end
    if node:isTileNumber() then
        return node.tile --[[@as number]]
    end
    return 0
end

--- Do a check against the objects in the node.
--- and if one is on the collition groups, then
--- the node is considered bloked.
---@param node Node
---@param collition_groups ?string[]
---@return boolean
function Graph:isNotBlokedByObject(node, collition_groups)
    if not collition_groups or not Node:hasObjects() then
        return true
    end
    for object_id,_ in pairs(node.objects) do
        for _, group in ipairs(collition_groups) do
            -- the object in the node is in the group?
            if self.object_groups[group][object_id] then
                return false
            end
        end
    end
    return true
end

--- Check if there is posible to go
--- from a connected node to another.\
--- It returs false if the destiny node is
--- impassable terrain, or exist a wall in
--- between nodes.
---@param start Node
---@param destiny Node
---@param direction number
---@return boolean way_is_posible
function Graph:isWayPosible(start, destiny, direction)
    -- check if the destiny is impassable terrain.
    if self:getNodeWeight(destiny) == 0 then
        return false
    end
    -- chek if there is a wall from start to destiny
    local wall_in_start = self.walls[start.id]
    if Directions.isWallFacingDirection(wall_in_start, direction) then
        return false
    end
    local wall_in_destiny = self.walls[destiny.id]
    -- get the direction from destiny to start
    local direction_2 = Directions.flip(direction)
    -- chek if there is a wall from destiny to start
    if Directions.isWallFacingDirection(wall_in_destiny, direction_2) then
        return false
    end
    return true
end

--- Creates a range of nodes that contains all
--- possible paths with the specified maximum
--- movement cost from the starting point. 
---
---Example:
---> local start = {2,2}\
---> local max_cost = 5\
---> local node_range_a = my_graph:constructNodeRange(start, max_cost, 'manhattan')
---
---@param start number[] Starting point
---@param max_cost number max cost of the paths contained
---@param type_movement? string manhattan or diagonal
---@param collition_groups ?string[] a list of object groups to consider as impassable terrain
---@return NodeRange range
function Graph:constructNodeRange(start, max_cost, type_movement, collition_groups)
    local start_node = self:getNode( self:positionToMapId(start) )
    if not start_node then
        return {}
    end
    local start_weight =  0 -- self:getNodeWeight(start_node)
    local nodes_explored = {}
    local nodes_in_queue = {}
    local nodes_in_border = {}
    local node_queue = self:newNodeHeap()
    local allowed_directions = Directions[self.settings.type][type_movement or 'manhattan']

    nodes_explored[start_node.id] = start_weight;
    node_queue:push({start_node, start_weight});
    while node_queue:getSize() > 0 do

        local poped = node_queue:pop()
        local current = poped[1] --[[@as Node]]
        local weight = nodes_in_queue[current.id] or start_weight
        nodes_in_queue[current.id] = nil;

        for _,direction in ipairs( allowed_directions ) do
            local node = current.conections[direction] --[[@as Node]]

            if not node then
                goto continue
            end

            local node_id = node.id
            local node_weight = self:getNodeWeight(node)
            local accumulated_weight = node_weight+weight
            local is_way_posible = self:isWayPosible(current, node, direction)
            local is_not_bloked_by_object = self:isNotBlokedByObject(node, collition_groups)
            if  nodes_explored[node_id] == nil -- is not yet explored
                and nodes_in_queue[node_id] == nil -- is not yet in queue
                then
                if is_way_posible and
                    is_not_bloked_by_object and
                    not (max_cost <= accumulated_weight)  then -- is not beyond range
                    nodes_in_queue[node_id] = accumulated_weight
                    --- We save to the queue the node and their acumulated weight
                    node_queue:push({node, accumulated_weight})
                else
                    local border_weight = accumulated_weight
                    if not is_way_posible then
                        border_weight = -1
                    end
                    nodes_in_border[node_id] = border_weight
                end
            end

            ::continue::
        end
        nodes_explored[current.id] = weight
    end

    local width = 0
    local height = 0
    local depth = 0
    if self.settings.type == '2D' then
        height = #self.settings.map
        width = #self.settings.map[1]
    end

    local range = NodeRange:new({
        range = max_cost,
        start_id = start_node.id,
        node_traversal_weights = nodes_explored,
        border = nodes_in_border,
        type_movement  = type_movement or "manhattan",
        width = width, height = height, depth = depth,
        map_type = self.settings.type,
        graphGetNode = function (id) return self:getNode(id) end
    })
    return range
end

--[[
local graph1 = Graph:new({
    type = '2D',
    map = {
        {1,1,0},
        {1,0,1},
        {1,1,1}
      },
});
graph1:build();
print('Number of created nodes '..tostring(#graph1.node_map))
local center_node = graph1:getNode(5);
print('Center node conects to: ')
if center_node then
    for direction, node in pairs(center_node.conections) do
        print(' node '..node.id..' at '..Directions.names[direction])
    end
end
local node_range = graph1:constructNodeRange({1,1},5)
print('Nodes in range strating at x:1,y:1 = ')
print(' start node id: '..node_range.start_id)
print(' traverse type: '..node_range.type_movement)
for node_id,weight in pairs(node_range.node_traversal_weights) do
    local x,y = unpack(graph1:getNode(node_id).position)
    print(' node '..' ('..x..', '..y..')'..' -> weight: '..weight)
end
print('find path from [1,1] to [3,3]')
local path = node_range:getPathTo({3,3})
for steep, node in ipairs(path.node_list) do
    local x,y = unpack(node.position)
    print(''..steep..' , ('..x..', '..y..')')
end

print('Using a custom iterator')
print('Path weight is: '..path.weight)
for steep, node in path:getNodes() do
    local x,y = unpack(node.position)
    print(''..steep..' , ('..x..', '..y..')')
end

local player = { test = 0 }
player.id = graph1:addObject(player, {1,1})
for key,value in pairs(player) do
    print(key..': '..tostring(value))
end
print('On node '..tostring(graph1.objects[player.id]))
graph1:translasteObject(player, {3,3})
print('Now is on node '..tostring(graph1.objects[player.id]))
graph1:translasteObject(player.id, {1,3})
print('Now is on node '..tostring(graph1.objects[player.id]))
--]]

return Graph