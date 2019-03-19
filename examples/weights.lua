--we define some variables
--A small map to be used
tile_map = {
    {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
    {1,1,1,1,1,1,1,1,1,8,8,8,8,8,8,8,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
    {1,1,1,1,1,1,1,1,1,8,5,5,5,5,5,8,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
    {1,1,1,1,1,1,1,1,1,8,5,8,8,8,5,8,1,3,3,1,1,1,1,1,1,1,1,1,1,1},
    {1,1,1,1,1,1,1,1,1,8,5,5,8,5,5,8,1,3,3,1,1,1,1,1,1,1,1,1,1,1},
    {1,1,1,1,1,1,1,1,1,8,8,8,8,8,8,8,1,3,3,3,1,1,1,1,1,1,1,1,1,1},
    {1,1,1,1,1,2,2,2,2,1,1,1,1,1,1,1,1,3,3,3,3,1,1,1,1,1,1,1,1,1},
    {1,1,1,1,1,2,2,2,2,2,1,1,1,1,1,1,1,3,3,3,10,10,1,1,1,1,1,1,1,1},
    {1,1,1,1,1,2,2,2,2,2,1,1,1,1,1,1,1,4,3,10,10,10,1,1,1,1,1,1,1,1},
    {1,1,1,1,1,2,2,2,2,2,2,1,1,1,1,1,1,4,3,10,10,10,1,1,1,1,1,1,1,1},
    {1,1,1,1,1,2,9,9,9,2,2,1,1,1,1,1,1,1,4,4,4,10,1,1,1,1,1,1,1,1},
    {1,1,1,1,1,2,9,9,9,2,2,1,1,1,1,1,1,4,4,4,1,1,1,1,1,1,1,1,1,1},
    {1,1,1,1,1,2,2,2,2,2,1,1,1,1,4,4,4,4,4,1,1,1,1,1,1,1,1,1,1,1},
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

--we added a draw/edit mode
local draw_mode = false 
local tile_to_draw = 1

--[[ 
    ***The code in one way or another related directly to Pajarito*** 
]]

--First, we load the Pathfinder
local pap = require("pajarito")

--Init the pathfinder using the tilemap and their dimensions
pap.init(tile_map, tile_map_width, tile_map_height, true)

--now, we define a table of weights and the default weights cost
--note, values equal or less than 0, are considered impassable terrain
local table_of_weights = {}
table_of_weights[1] = 1  --grass    tile 1 -> 1
table_of_weights[2] = 2  --sand     tile 2 -> 2
table_of_weights[3] = 0  --mountain tile 3 -> 0  
table_of_weights[4] = 2  --woods    tile 4 -> 2
table_of_weights[5] = 0  --walls    tile 5 -> 0
table_of_weights[8] = 1  --dirt     tile 8 -> 1
table_of_weights[9] = 0  --lava     tile 9 -> 0
table_of_weights[10] = 0 --water   tile 10 -> 0

--set the table to the tilemap
pap.setWeigthTable(table_of_weights)
--[[
You can change the values on the table directly and because the table is referenced,
you do not have the need to resend the table.
]]

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
        love.graphics.print(node.d, node.x*17, node.y*17)
    end
    
    if show_border then
        t = pap.getBorderNodes() 
        for _,node in pairs(t) do
            love.graphics.print(node.d, node.x*17, node.y*17)
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
            tileset:add(tileset_list[tile],x*17,y*17)
            
            --if not draw_mode then 
                -- Here we ask if on that position exist a node marked
                -- Fear not nested loops!, there is no one in "isNodeMarked"
                
                if pap.isNodeMarked(x,y) then
                    --the next tile will be a "dark blue tone"
                    tileset:setColor(0,0.1,1) 
                    --is added a semitransparent tile over this one. 
                    tileset:add(tileset_list[29],x*17,y*17)
                end
                
                --mark the border in a red hue
                if show_border and pap.isNodeBorder(x,y) then 
                    tileset:setColor(1,0,0,1)
                    tileset:add(tileset_list[29],x*17,y*17)
                end
            --end
            --use the mouse position to put a marker on the map
            if x == m_ix and y == m_iy then
                if draw_mode then
                    tileset:setColor(1,1,1,1)
                    tileset:add(tileset_list[tile_to_draw],x*17,y*17)
                end
                tileset:setColor(0,0,0,1)
                tileset:add(tileset_list[13],x*17,y*17)
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
        updateRange(m_ix,m_iy,range_slider:GetValue())
        saved_x = m_ix
        saved_y = m_iy
    end
end

--and this function, is called to allow the diagonal movement
function setDiagonal(diagonal)
    if pap.getDiagonal() ~= diagonal then
        pap.useDiagonal(diagonal)
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
local ima = love.graphics.newImage('tileset.png')

--tileset contains the spritebatch we create from the source image
tileset = love.graphics.newSpriteBatch(ima,2000)

--tileset_list contains the quads used to draw the map
tileset_list = makeQuads(320,320,16,16)


--here, the gui is build using loveframes-

local container = nil
container = loveframes.Create("panel")
container:SetSize(980,130)

local text = loveframes.Create("text", container)
text:SetPos(20,5)
text:SetWidth(260)
text:SetText(
[[
This is the example of weights.
Click on any part of the map to mark a new starting point.
]])
text:SetShadowColor(.8, .8, .8, 1)
text:SetShadow(true)

--Range SLiDer LaBel
local rsld_lb = loveframes.Create("text", container)
rsld_lb:SetPos(310,15)
rsld_lb:SetWidth(280)
rsld_lb:SetText('Range')

local stored_range = 2

range_slider = loveframes.Create("slider",container)
range_slider:SetPos(370,13)
range_slider:SetWidth(200)
range_slider:SetMinMax(2,15)
range_slider:SetDecimals(0)
range_slider.OnValueChanged = function(object)
    updateRange(saved_x,saved_y,object:GetValue())
end

rsld_lb.Update = function(object, dt)
    stored_range = range_slider:GetValue()
    object:SetText('Range '..tostring(stored_range))
end

local checkbox1 = loveframes.Create("checkbox", container)
checkbox1:SetText("Show 'Deep of Range' numbers")
checkbox1:SetPos(340, 40)

local checkbox2 = loveframes.Create("checkbox", container)
checkbox2:SetText("Show border outside range")
checkbox2:SetPos(340, 65)

local button = loveframes.Create("button", container)
button:SetWidth(200)
button:SetPos(40,90)
button:SetText("Go back to main menu")
button.OnClick = function(object, x, y)
    loveframes.RemoveAll()
    pap.clearNodeInfo()
    SCENA_MANAGER.pop()
end

local sub_container = loveframes.Create("panel",container)
sub_container:SetSize(405,130)
sub_container:SetPos(575)

local button2 = loveframes.Create("button", container)

button2:SetWidth(120)
button2:SetPos(330,90)
button2:SetText("Enter Draw Mode")
button2.OnClick = function(object, x, y)
    draw_mode = not draw_mode
    object:SetText("Enter Draw Mode")
    
    sub_container.children = {}
    sub_container.internals = {}
    
    if draw_mode then
        object:SetText("Exit Draw Mode")
        addDrawMapGUI()
        text:SetText([[
This is the example of weights.
Pick a tile and then click on any part of the map to draw it.
The range will be updated once you release the mouse.
]])
    else
        addWeightGUI()
        text:SetText([[
This is the example of weights.
Click on any part of the map to mark a new starting point.
]])
    end
    --loveframes.RemoveAll()
    --SCENA_MANAGER.pop()
end

local checkbox3 = loveframes.Create("checkbox", container)
checkbox3:SetText("Allow diagonal")
checkbox3:SetPos(460, 95)

function getImaOfTile(tile)
    local can = love.graphics.newCanvas(16,16)
    love.graphics.setCanvas(can)
    love.graphics.draw(ima,tileset_list[tile])
    love.graphics.setCanvas()
    return love.graphics.newImage(can:newImageData( ))
end

function addWeightGUI()
    local text2 = loveframes.Create("text",sub_container)
    text2:SetPos(5,5)
    text2:SetWidth(400)
    text2:SetText("Modify the weights of the tiles (a value of '0' means impassable)")
    text2:SetShadowColor(.8, .8, .8, 1)
    text2:SetShadow(true)

    local i = 0
    local j = 0
    for k,v in pairs(table_of_weights) do
        local nb = loveframes.Create("image", sub_container)
        local x = 5+j*200
        local y = 24*i+25
        nb:SetSize(16,16)
        nb:SetPos(x,y)
        nb:SetImage(getImaOfTile(k))
        
        local text = loveframes.Create("text", sub_container)
        text:SetPos(x+32,y)
        text:SetWidth(280)
        text:SetText('w: '..tostring(v))
        
        local sldr = loveframes.Create("slider",sub_container)
        sldr:SetPos(x+65,y-3)
        sldr:SetWidth(130)
        sldr:SetMinMax(0,5)
        sldr:SetDecimals(0)
        sldr:SetValue(v)
        
        text.Update = function(object, dt)
            object:SetText('w: '..tostring(sldr:GetValue()))
        end
        
        sldr.OnValueChanged = function(object)
            table_of_weights[k] = object:GetValue()
            updateRange(saved_x,saved_y,stored_range)
        end
        
        i=i+1
        if i>3 then 
            j = j+1
            i = 0
        end
    end
end

function addDrawMapGUI()
    local text2 = loveframes.Create("text",sub_container)
    text2:SetPos(5,5)
    text2:SetWidth(400)
    text2:SetText("Chose a tile to draw")
    text2:SetShadowColor(.8, .8, .8, 1)
    text2:SetShadow(true)
    
    local text3 = loveframes.Create("text",sub_container)
    text3:SetPos(200,5)
    text3:SetWidth(200)
    text3:SetText("Current tile")
    text3:SetShadowColor(.8, .8, .8, 1)
    text3:SetShadow(true)
    
    
    local ima = loveframes.Create("image",sub_container)
    ima:SetPos(205,20)
    
    local i = 0
    local j = 0
    for k,v in pairs(table_of_weights) do
        local nb = loveframes.Create("imagebutton",sub_container)
        local x = 25+i*24
        local y = 24*j+25
        --nb:SetSize(24,24)
        nb:SetText('')
        nb:SetPos(x,y)
        nb:SetImage(getImaOfTile(k))
        nb:SizeToImage()
        nb.OnClick = function(object)
            --object:SetText("The mouse entered the button.")
            tile_to_draw = k
            ima:SetImage(object.image)
        end
        
        i=i+1
        if i>2 then 
            j = j+1
            i = 0
        end
    end
    
    ima:SetImage(getImaOfTile(tile_to_draw))
    ima:SetScale(4,4)
end

addWeightGUI()
--addDrawMapGUI()


--check if the mouse is over a element of the gui.
function mouseOnGUI(gui_obj)
    local x, y = love.mouse.getPosition()
    return (x >= gui_obj.x and  (x < (gui_obj.x+gui_obj.width)))
    and (y >= gui_obj.y and (y < (gui_obj.y+gui_obj.height)))
end

function Main()
    local self = Escena()
    love.window.setTitle("Pajarito Pathfinder Example: Weights")
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
        
        drawTileMap()
        
        if checkbox1:GetChecked() then
            printNodeValues()
        end
        
        if checkbox3:GetChecked() then
            love.graphics.print('Diagonal Allowed')
        end
        
        
        love.graphics.setColor(1,1,1)
        
        love.graphics.pop()
    end
    
    function self.update(dt)
        cam.update(dt)
        --if you ask, loveframes is updated on the main.
        show_border = checkbox2:GetChecked() 
        setDiagonal(checkbox3:GetChecked())
    end
    
    function self.mousemoved(x, y, dx, dy, istouch)
        if is_mouse_pressed and not mouseOnGUI(container) then
            local x, y = getMouseOnCanvas()
            relas_m.x = x
            relas_m.y = y
            local d = (pres_m-relas_m).magnitud()
            if d > 8 then
                local a = (relas_m-pres_m)
                --cam.drag(a.x,a.y)
                if draw_mode and draw_mode and pap.isNodeOnGrid(m_ix,m_iy) then
                    tile_map[m_iy][m_ix] = tile_to_draw
                end
            end
        end
    end
    
    function self.mousepressed(x, y, button)
        if button == 1 then
            if not is_mouse_pressed and not mouseOnGUI(container) then
                local x, y = getMouseOnCanvas()
                pres_m.x = x
                pres_m.y = y
                relas_m.x = x
                relas_m.y = y
                is_mouse_pressed = true
                if draw_mode and pap.isNodeOnGrid(m_ix,m_iy) then
                    tile_map[m_iy][m_ix] = tile_to_draw
                end
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
                    if not draw_mode then
                        saveNewStartPos()
                    end
                end
            end
            if draw_mode and pap.isNodeOnGrid(m_ix,m_iy) and not mouseOnGUI(container) then
                tile_map[m_iy][m_ix] = tile_to_draw
                updateRange(saved_x,saved_y,range_slider:GetValue())
            end
            is_mouse_pressed = false
        end
    end
    
    return self
end

return Main()