--we define some variables
--A small map to be used
tile_map = {
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

--size of the map
local tile_map_width = #tile_map[1]
local tile_map_height= #tile_map

--to store the converted form screen mouse position to tile map cords
local m_ix = 0
local m_iy = 0

--variables used to store the pos once a mouse click on map happened
--we initialize they on the middle of the tile map
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


--[[ 
    ***The code in one way or another related directly to Pajarito*** 
]]

--First, we load the Pathfinder
local pajarito = require("pajarito")

--Initialize the pathfinder using the tilemap and their dimensions
pajarito.init(tile_map, tile_map_width, tile_map_height)

--we clear all the previously marked nodes
--pajarito.clearNodeInfo() 
--because is the first run, is not necessary

--Generate a range of nodes stating at the given point
pajarito.buildRange(saved_x,saved_y,2) 

--[[
    There are two ways to access to the marked/border nodes.
    
    1) Ask to the lib for a list of nodes in range and iterate it.
    2) In the loop used to draw the tile map, check in a one by one.
   
   The following functions are examples of that. 
--]]

--print the values or "deep of range" of the nodes
function printNodeValues()
    local t = pajarito.getInRangeNodes() --here we ask
    
    for _,node in pairs(t) do
        love.graphics.print(node.d, node.x*17, node.y*17)
    end
    
    if show_border then
        t = pajarito.getBorderNodes() 
        for _,node in pairs(t) do
            love.graphics.print(node.d, node.x*17, node.y*17)
        end
    end

end

--add the tiles of the map to a spritebath to draw it. 
function updateTileSet()
    tileset:clear()
        
    local y = 1
    while tile_map[y] do
        local x = 1
        while tile_map[y][x] do
            tile = tile_map[y][x]
            --a tile is added to the be draw... 
            tileset:add(tileset_list[tile],x*17,y*17)
            
            -- Here we ask if on that position exist a node marked
            -- Fear not nested loops!, there is no one in "isNodeMarked"
            
            if pajarito.isPointInRange(x,y) then
                --the next tile will be a "dark blue tone"
                tileset:setColor(0,0.1,1) 
                --is added a semitransparent tile over this one. 
                tileset:add(tileset_list[29],x*17,y*17)
            end
            
            --mark the border in a red hue
            if show_border and pajarito.isPointInRangeBorder(x,y) then 
                tileset:setColor(1,0,0,1)
                tileset:add(tileset_list[29],x*17,y*17)
            end
            
            tileset:setColor(1,1,1,1)
            x=x+1
        end
        y=y+1
    end
end

--this is the function called every time the slider of "Range" changes.
function updateRange(x,y,range)
    pajarito.buildRange(x,y,range) --we do a new range stating on pos x,y
    updateTileSet()
end

--This is the function called each time you click on the map.
function saveNewStartPos()
    if pajarito.isNodeOnGrid(m_ix,m_iy) then 
        pajarito.buildRange(m_ix,m_iy,range_slider:GetValue())
        saved_x = m_ix
        saved_y = m_iy
    end
end

--and this function, is called to allow the diagonal movement
function setDiagonal(diagonal)
    if pajarito.getDiagonal() ~= diagonal then
        pajarito.useDiagonal(diagonal)
        updateRange(saved_x,saved_y,range_slider:GetValue())
    end
end

--[[
    *** And that's all!! ***
    Now bellow starts the code unrelated to Pajarito. 
--]]

--this save the pos of the mouse when the click is pressed and is released
--used to drag and drop the camera  - sorry, not in this example :) -
local pres_m = vector2D(0,0)
local relas_m = vector2D(0,0)

local is_mouse_pressed = false

--a camera is created and placed on the center of the map
local cam = Camera(
    -(320)+((tile_map_width/2+1)*17),
    -(180)+(tile_map_height*8))

--load a tileset image
local tileset_image= love.graphics.newImage('tileset.png')

--tileset contains the spritebatch we create from the source image
tileset = love.graphics.newSpriteBatch(tileset_image,2000)

--tileset_list containst the quads used to draw the map
tileset_list = makeQuads(320,320,16,16)



--here, the gui is build using loveframes-

local container = nil
container = loveframes.Create("panel")
container:SetSize(580,120)

local text = loveframes.Create("text", container)
text:SetPos(20,10)
text:SetWidth(260)
text:SetText(
[[
This is the most simple of the examples.

Click on any part of the map to mark a new starting point.
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
range_slider:SetMinMax(2,15)
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

local checkbox3 = loveframes.Create("checkbox", container)
checkbox3:SetText("Allow diagonal")
checkbox3:SetPos(340, 95)

local button = loveframes.Create("button", container)
button:SetWidth(200)
button:SetPos(40,80)
button:SetText("Go back to main menu")
button.OnClick = function(object, x, y)
    loveframes.RemoveAll()
    pajarito.clearNodeInfo()
    SCENA_MANAGER.pop()
end

--check if the mouse is over a element of the gui.
function mouseOnGUI(gui_obj)
    local x, y = love.mouse.getPosition()
    return (x >= gui_obj.x and  (x < (gui_obj.x+gui_obj.width)))
    and (y >= gui_obj.y and (y < (gui_obj.y+gui_obj.height)))
end

function Main()
    local self = Escena()
    love.window.setTitle("Pajarito Pathfinder Example: Elemental")
    updateTileSet()
    
    
    function self.draw()
        love.graphics.clear(0.1,0.1,0.1)
        love.graphics.setColor(1,1,1)
        
        love.graphics.push()
        love.graphics.translate(math.floor(-cam.getPosX()),math.floor(-cam.getPosY()))
        
        local x, y = getMouseOnCanvas()
        x,y = love.graphics.inverseTransformPoint(x,y)
        
        if not mouseOnGUI(container) then 
            m_ix = math.floor(x/17)
            m_iy = math.floor(y/17)
        end
        
        love.graphics.draw(tileset)
        love.graphics.draw(tileset_image,tileset_list[13],m_ix*17,m_iy*17)
        
        if checkbox1:GetChecked() then
            printNodeValues()
        end
        
        love.graphics.setColor(1,1,1)
        
        love.graphics.pop()
    end
    
    function self.update(dt)
        cam.update(dt)
        --if you ask, loveframes is updated on the main.
        if show_border ~= checkbox2:GetChecked() then
            show_border = checkbox2:GetChecked()
            updateTileSet()
        end
        setDiagonal(checkbox3:GetChecked())
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
                    updateTileSet()
                end
            end
            is_mouse_pressed = false
        end
    end
    
    return self
end

return Main()