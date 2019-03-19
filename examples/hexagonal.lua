--we define some variables
--A small map to be used

tile_map = {
        {21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21},
        {21, 21, 21, 21, 21, 21, 22, 22, 22, 21, 21, 21, 21, 21, 21, 21, 21, 21},
        {21, 21, 21, 21, 21, 21, 22, 22, 22, 22, 22, 21, 21, 21, 21, 21, 21, 21},
        {21, 21, 21, 21, 21, 21, 22, 26, 26, 22, 22, 22, 21, 21, 21, 21, 21, 21},
        {21, 21, 21, 21, 21, 21, 21, 26, 21, 26, 26, 22, 21, 21, 21, 21, 21, 21},
        {21, 21, 26, 21, 21, 21, 21, 21, 21, 26, 26, 22, 22, 21, 21, 21, 21, 21},
        {21, 21, 26, 23, 23, 24, 21, 21, 21, 21, 26, 22, 22, 22, 21, 21, 21, 21},
        {21, 21, 26, 23, 23, 24, 21, 21, 21, 21, 26, 22, 22, 21, 21, 21, 21, 21},
        {21, 21, 21, 21, 23, 23, 24, 21, 21, 21, 26, 22, 22, 21, 21, 21, 21, 21},
        {21, 21, 21, 23, 23, 23, 24, 26, 26, 26, 25, 22, 22, 21, 21, 21, 21, 21},
        {21, 21, 21, 21, 23, 23, 23, 21, 21, 22, 25, 25, 21, 21, 21, 21, 21, 21},
        {21, 21, 21, 21, 23, 23, 23, 21, 21, 22, 25, 21, 21, 21, 21, 21, 21, 21},
        {21, 21, 21, 21, 21, 21, 21, 26, 21, 21, 21, 21, 26, 21, 21, 21, 21, 21},
        {21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21},
        {21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21}
      }
--]]

--size of the map
local tile_map_width = #tile_map[1]
local tile_map_height= #tile_map

--to store the converted form screen mouse position to tile map cords
local m_ix = 0
local m_iy = 0

--variables used to store the pos once a mouse click on map happened
--we init they on the middle of the tile map
local saved_x = math.floor(tile_map_width/2)
local saved_y = math.floor(tile_map_height/2)

--a value to see if the border should be show
local show_border = true

--tileset contains the spritebatch we will create from a source image
local tileset = nil

--tileset_list, a list of the quads used to draw the map
local tileset_list = nil

--a slider to set the range
local range_slider = nil

--and also, a chronometer 
local timer = Chrono()


--[[ 
    ***The code in one way or another related directly to Pajarito*** 
]]

--First, we load the Pathfinder
local pap = require("pajarito")

--Init the pathfinder using the tilemap and their dimensions
pap.init(tile_map, tile_map_width, tile_map_height)

--we say that the map is hexagonal
pap.setHexagonal(true)

--we create a variable to store the path
local generated_path = {}

table_of_weights = {}
table_of_weights[21] = 1
table_of_weights[22] = 3
table_of_weights[23] = 3
table_of_weights[24] = 1
table_of_weights[25] = 0
table_of_weights[26] = 0
table_of_weights[27] = 2

pap.setWeigthTable(table_of_weights)

--we clear all the previously marked nodes
--pap.clearNodeInfo() 
--because is the first run, is not necessary

--Generate a range of nodes stating at the given point
pap.getNodesOnRange(saved_x,saved_y,2) 

--[[
    There are two ways to access to the marked/border nodes.
    
    1) Ask to the lib for a list of the marked ones and iterate it.
    2) In the loop used to draw the tile map, check in a one by one.
   
   The following functions are examples of that. 
--]]

--print the values or "deep of range" of the nodes
function printNodeValues()
    local t = pap.getMarkedNodes() --here we ask
    
    for _,node in pairs(t) do
        local off = 0
        if math.fmod(node.y,2) == 0 then off = 1 end
        local px = node.x*32+off*16
        local py = node.y*16
        love.graphics.print(node.d,px+12,py+8)
    end
    
    if show_border then
        t = pap.getBorderNodes() 
        love.graphics.setColor(0,0,0)
        for _,node in pairs(t) do
            local off = 0
            if math.fmod(node.y,2) == 0 then off = 1 end
            local px = node.x*32+off*16
            local py = node.y*16
            love.graphics.print(node.d,px+12,py+8)
        end
    end

end

--add the tiles of the map to a spritebath to draw it. 
function drawTileMap()
    tileset:clear()
        
    local y = 1
    while tile_map[y] do
        local x = 1
        while tile_map[y][x] do
            tile = tile_map[y][x]
            --a tile is added to the be draw... 
            local off = 0
            if math.fmod(y,2) == 0 then off = 1 end
            local px = x*32+off*16
            local py = y*16
            tileset:add(tileset_list[tile],px,py)
            
            -- Here we ask if on that position exist a node marked
            -- Fear not nested loops!, there is no one in "isNodeMarked"
            
            if pap.isNodeMarked(x,y) then
                --the next tile will be a "dark blue tone"
                tileset:setColor(0,0.1,1) 
                --is added a semitransparent tile over this one. 
                tileset:add(tileset_list[29],px,py)
                
                --once a path is generated, pajarito also creates a
                --dictionary for quick look up
                if pap.isNodeOnPath(x,y) then
                    tileset:setColor(1,1,1,1) 
                    tileset:add(tileset_list[31],px,py)
                end
            end
            
            --mark the border in a red hue
            if show_border and pap.isNodeBorder(x,y) then 
                tileset:setColor(1,0,0,1)
                tileset:add(tileset_list[29],px,py)
            end
            
            --use the mouse position to put a marker on the map
            if x == m_ix and y == m_iy then
                tileset:setColor(0,0,0,1)
                tileset:add(tileset_list[30],px,py)
            end
            
            tileset:setColor(1,1,1,1)
            x=x+1
        end
        y=y+1
    end
    
    love.graphics.draw(tileset)
end

--this is the function called every time the slider of "Range" changes.
function updateRange(x,y,range)
    pap.clearNodeInfo() --clear all the previously marked nodes
    pap.getNodesOnRange(x,y,range) --we do a new range stating on pos x,y
end

--This is the function called each time you click on the map.
function saveNewStartPos()
    if pap.isNodeOnGrid(m_ix,m_iy) then 
        pap.clearNodeInfo()
        pap.getNodesOnRange(m_ix,m_iy,range_slider:GetValue())
        saved_x = m_ix
        saved_y = m_iy
    end
end

function printPath()
    local i = 1
    while generated_path[i] do
        local node = generated_path[i]
        --this part draws a line between the center of this node an the next
        love.graphics.setColor(0.2,0.8,0.8)
        if generated_path[i+1] then
            local next_node = generated_path[i+1]
            
            local off = 0
            if math.fmod(node.y,2) == 0 then off = 1 end
            local px = (node.x+0.5)*32+off*16
            local py = (node.y+1.25)*16
            
            off = 0
            if math.fmod(next_node.y,2) == 0 then off = 1 end
            local px2 = (next_node.x+0.5)*32+off*16
            local py2 = (next_node.y+1.25)*16
            
            love.graphics.line(px,py,px2,py2)
        end
        love.graphics.setColor(1,1,1)
        i=i+1
    end
end

--We request a new path every second
function updatePath(x,y)
    
    --if timer has passed already 0.15 seconds
    if timer.hanPasado(0.15) then
    --[[
    Get path inside range, assume exist already a 
    range of nodes. Then ask if the requested destination 
    point is in that list. returns a table listing nodes
    from the starting point and ends on the destination
    --]]
        generated_path = pap.getPathInsideRange(x,y)
    end
end

--[[
    *** And that's all!! ***
    Now bellow starts the code unrelated to Pajarito. 
--]]

--this save the pos of the mouse when the click is pressed and is relassed
--used to drag and drop the camera  - sorry, not in this example :) -
local pres_m = vector2D(0,0)
local relas_m = vector2D(0,0)

local is_mouse_pressed = false

--a camera is created and placed on the center of the map
local cam = Camera(
    -(320)+((tile_map_width/2+1)*32),
    -(180)+(tile_map_height*8))

--load a tileset image
local ima = love.graphics.newImage('tileset.png')

--tileset contains the spritebatch we create from the source image
tileset = love.graphics.newSpriteBatch(ima,2000)

--tileset_list containst the quads used to draw the map
tileset_list = makeQuads(320,320,32,32)



--here, the gui is build using loveframes-

local container = nil
container = loveframes.Create("panel")
container:SetSize(580,120)

local text = loveframes.Create("text", container)
text:SetPos(20,10)
text:SetWidth(260)
text:SetText(
[[
This is the hexagonal example.
Hexagonal supports almost all the same functions of the normal map at exception for the standard pathfinder.
]])
text:SetShadowColor(.8, .8, .8, 1)
text:SetShadow(true)

--Range SLiDer LaBel
local rsld_lb = loveframes.Create("text", container)
rsld_lb:SetPos(310,20)
rsld_lb:SetWidth(280)
rsld_lb:SetText('Range')

range_slider = loveframes.Create("slider",container)
range_slider:SetPos(370,18)
range_slider:SetWidth(200)
range_slider:SetMinMax(2,10)
range_slider:SetDecimals(0)
range_slider.OnValueChanged = function(object)
    updateRange(saved_x,saved_y,object:GetValue())
end

rsld_lb.Update = function(object, dt)
    object:SetText('Range '..range_slider:GetValue())
end

local checkbox1 = loveframes.Create("checkbox", container)
checkbox1:SetText("Show 'Deep of Range' numbers")
checkbox1:SetPos(340, 45)

local checkbox2 = loveframes.Create("checkbox", container)
checkbox2:SetText("Show border outside range")
checkbox2:SetPos(340, 70)


local button = loveframes.Create("button", container)
button:SetWidth(200)
button:SetPos(40,80)
button:SetText("Go back to main menu")
button.OnClick = function(object, x, y)
    loveframes.RemoveAll()
    pap.clearNodeInfo()
    SCENA_MANAGER.pop()
end

--check if the mouse is over a element of the gui.
function mouseOnGUI(gui_obj)
    local x, y = love.mouse.getPosition()
    return (x >= gui_obj.x and  (x < (gui_obj.x+gui_obj.width)))
    and (y >= gui_obj.y and (y < (gui_obj.y+gui_obj.height)))
end

--we start the timer
timer.iniciar()

function Main()
    local self = Escena()
    love.window.setTitle("Pajarito Pathfinder Example: Hexagonal map")
    function self.draw()
        love.graphics.clear(0.1,0.1,0.1)
        love.graphics.setColor(1,1,1)
        
        love.graphics.push()
        love.graphics.translate(math.floor(-cam.getPosX()),math.floor(-cam.getPosY()))
        
        local x, y = getMouseOnCanvas()
        x,y = love.graphics.inverseTransformPoint(x,y)
        
        if not mouseOnGUI(container) then 
            m_ix = math.floor(x/32)
            m_iy = math.floor(y/16)
            if math.fmod(m_iy,2) == 0 then m_ix = math.floor((x-16)/32) end
        end
        
        drawTileMap()
        
        printPath()
        
        if checkbox1:GetChecked() then
            printNodeValues()
        end
        
        love.graphics.setColor(1,1,1)
        
        love.graphics.pop()
    end
    
    function self.update(dt)
        cam.update(dt)
        --if you ask, loveframes is updated on the main.
        show_border = checkbox2:GetChecked()
        updatePath(m_ix,m_iy)
    end
    
    function self.mousemoved(x, y, dx, dy, istouch)
        if is_mouse_pressed and not mouseOnGUI(container) then
            local x, y = getMouseOnCanvas()
            relas_m.x = x
            relas_m.y = y
            local d = (pres_m-relas_m).magnitud()
            if d > 16 then
                local a = (relas_m-pres_m)
                --cam.drag(a.x,a.y)
            end
        end
    end
    
    function self.mousepressed(x, y, button)
        if button == 1 then
            if not is_mouse_pressed then
                local x, y = getMouseOnCanvas()
                pres_m.x = x
                pres_m.y = y
                relas_m.x = x
                relas_m.y = y
                is_mouse_pressed = true
            end
        end
    end

    function self.mousereleased(x, y, button)
        if button == 1 then
            local d = (relas_m-pres_m).magnitud()
            if d > 16 then
                local a = (relas_m-pres_m)
                --cam.drop(a.x,a.y)
            else
                if not mouseOnGUI(container) then
                    saveNewStartPos()
                end
            end
            is_mouse_pressed = false
        end
    end
    
    return self
end

return Main()