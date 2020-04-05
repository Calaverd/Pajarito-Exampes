--we define some variables
--A small map to be used
tile_map = {
    {3,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,3},
    {5,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,5},
    {5,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,5},
    {5,1,1,1,1,1,1,1,1,1,1,1,1,1,5,4,1,1,1,1,5,5,5,5,5,1,1,1,1,5},
    {5,1,1,1,1,1,1,1,1,1,1,5,1,4,5,5,5,1,1,1,5,2,1,1,1,1,1,1,1,5},
    {5,1,1,1,1,1,1,1,1,1,4,1,5,4,5,1,4,1,1,4,5,2,1,1,1,1,1,1,1,5},
    {5,1,1,1,1,1,1,1,1,5,4,4,4,4,5,4,4,5,5,4,5,2,1,1,1,1,1,1,1,5},
    {5,1,1,1,1,1,1,1,1,4,4,5,4,4,4,4,4,2,5,2,2,1,1,1,1,1,1,1,1,5},
    {5,1,1,1,1,1,1,1,5,1,4,5,4,4,4,4,4,2,5,4,4,1,1,1,1,1,1,1,1,5},
    {5,1,1,1,1,1,1,1,1,1,1,5,5,5,1,4,4,2,5,4,1,1,1,1,1,1,1,1,1,5},
    {5,1,1,1,1,1,1,1,1,1,1,1,4,5,1,1,1,2,5,1,1,1,1,1,1,1,1,1,1,5},
    {5,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,1,1,1,1,1,1,1,1,1,1,5},
    {5,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,5},
    {5,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,5},
    {3,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,3},
}

--size of the map
local tile_map_width = #tile_map[1]
local tile_map_height= #tile_map

--to store the converted form screen mouse position to tile map cords
local m_ix = 0
local m_iy = 0


--we init a start point on the middle of the tile map
local start_x = 25 --math.floor(tile_map_width/2)
local start_y = 7  --math.floor(tile_map_height/2)

--we also do a destiny point in the superior-left corner 
local dest_x = 5
local dest_y = 7


--a value to see if the border should be show
local show_border = true

--tileset contains the spritebatch we will create from a source image
local tileset = nil

--tileset_list, a list of the quads used to draw the map
local tileset_list = nil


--
local tile_to_draw = 1
--
local show_marks = false

local show_path = true

--we created a list to add the points...

local gui_list = nil 
--[[ 
    ***The code in one way or another related directly to Pajarito*** 
]]

--First, we load the Pathfinder
local pajarito = require("pajarito")

--Init the pathfinder using the tilemap and their dimensions
pajarito.init(tile_map, tile_map_width, tile_map_height)


--we create a variable to store the path
local generated_path = {}

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
pajarito.setWeigthTable(table_of_weights)

--we clear all the previously marked nodes
--pajarito.clearNodeInfo() 
--because is the first run, is not necessary

--Generate a path
generated_path = pajarito.pathfinder(start_x,start_y,dest_x,dest_y) 

--[[
    There are two ways to access to the marked/border nodes.
    
    1) Ask to the lib for a list of the marked ones and iterate it.
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
            
            if pajarito.isPointInRange(x,y) and show_marks then
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

--this is the function called every time the start or destiny point change
function updatePath()
    generated_path = pajarito.pathfinder(start_x,start_y,dest_x,dest_y) 
    updateListPath()
    updateTileSet()
end

--and this funtion, is called to allow the diagonal movement
function setDiagonal(diagonal)
    if pajarito.getDiagonal() ~= diagonal then
        pajarito.useDiagonal(diagonal)
        updatePath()
    end
end

function updateListPath()
    --clear the gui list
    if gui_list then
        gui_list:Remove()
    end
    gui_list = loveframes.Create("list", container)
    gui_list:SetPos(280,55)
    gui_list:SetSize(140, 125-65)
    gui_list:SetPadding(5)
    gui_list:SetSpacing(5)
    local i = 1
    while generated_path[i] do
        local node = generated_path[i]
        local str = string.format('[%3d] (%2d,%2d)',i,node.x,node.y)
        
        local text = loveframes.Create("text", container)
        text:SetWidth(100)
        text:SetText(str)
        gui_list:AddItem(text)
        i=i+1
    end
end


local tileset_image =nil

function printPath()
    local i = 1
    while generated_path[i] do
        local node = generated_path[i]
        
        --this part draws a line between the center of this node an the next
        love.graphics.setColor(0.2,0.8,0.8)
        if generated_path[i+1] then
            local next_node = generated_path[i+1]
            love.graphics.line((node.x+0.5)*17,(node.y+0.5)*17,
                                (next_node.x+0.5)*17,(next_node.y+0.5)*17)
        end
        
        love.graphics.setColor(1,1,1)
        love.graphics.draw(tileset_image,tileset_list[14],node.x*17,node.y*17)
        i=i+1
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
tileset_image = love.graphics.newImage('tileset.png')

--tileset contains the spritebatch we create from the source image
tileset = love.graphics.newSpriteBatch(tileset_image,2000)

--tileset_list contains the quads used to draw the map
tileset_list = makeQuads(320,320,16,16)



--here, the gui is build using loveframes-

local container = nil
container = loveframes.Create("panel")
container:SetSize(980,125)

local text = loveframes.Create("text", container)
text:SetPos(20,10)
text:SetWidth(260)
text:SetText(
[[
This is the pahtfinder example.
Pajarito can be used like a rudimentary pathfinder library.
Try click and drop the cross or the knigth
]])
text:SetShadowColor(.8, .8, .8, 1)
text:SetShadow(true)


local checkbox3 = loveframes.Create("checkbox", container)
checkbox3:SetText("Allow diagonal")
checkbox3:SetPos(280, 15)

local checkbox2 = loveframes.Create("checkbox", container)
checkbox2:SetText("Show explored tiles")
checkbox2:SetPos(280, 35)



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

function getImaOfTile(tile)
    local can = love.graphics.newCanvas(16,16)
    love.graphics.setCanvas(can)
    love.graphics.draw(tileset_image,tileset_list[tile])
    love.graphics.setCanvas()
    return love.graphics.newImage(can:newImageData( ))
end

function addWeightGUI()
    local text2 = loveframes.Create("text",container)
    text2:SetPos(5+425,5)
    text2:SetWidth(330)
    text2:SetText("Modify the weights of the tiles ('0' means impassable)")
    text2:SetShadowColor(.8, .8, .8, 1)
    text2:SetShadow(true)

    local i = 0
    local j = 0
    for k,v in pairs(table_of_weights) do
        local nb = loveframes.Create("image",container)
        local x = 425+5+j*180
        local y = 24*i+30
        nb:SetSize(18,18)
        nb:SetPos(x,y)
        nb:SetImage(getImaOfTile(k))
        
        local text = loveframes.Create("text",container)
        text:SetPos(x+32,y)
        text:SetWidth(280)
        text:SetText('w: '..tostring(v))
        
        local sldr = loveframes.Create("slider",container)
        sldr:SetPos(x+65,y-3)
        sldr:SetWidth(60)
        sldr:SetMinMax(0,10)
        sldr:SetDecimals(0)
        sldr:SetValue(v)
        
        text.Update = function(object, dt)
            object:SetText('w: '..tostring(sldr:GetValue()))
        end
        
        sldr.OnValueChanged = function(object)
            table_of_weights[k] = object:GetValue()
            updatePath()
        end
        
        i=i+1
        if i>3 then 
            j = j+1
            i = 0
        end
    end
end


function addDrawMapGUI()
    local text2 = loveframes.Create("text",container)
    text2:SetPos(760+5,5)
    text2:SetWidth(400)
    text2:SetText("Chose a tile to draw")
    text2:SetShadowColor(.8, .8, .8, 1)
    text2:SetShadow(true)
    
    local text3 = loveframes.Create("text",container)
    text3:SetPos(760+130,5)
    text3:SetWidth(200)
    text3:SetText("Current tile")
    text3:SetShadowColor(.8, .8, .8, 1)
    text3:SetShadow(true)
    
    
    local ima = loveframes.Create("image",container)
    ima:SetPos(760+135,20)
    
    local i = 0
    local j = 0
    for k,v in pairs(table_of_weights) do
        local nb = loveframes.Create("imagebutton",container)
        local x = 760+25+i*24
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
addDrawMapGUI()
updateListPath()

function Main()
    local self = Escena()
    love.window.setTitle("Pajarito Pathfinder Example: PathFinder")
    local moving_start = false
    local moving_dest = false
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
        
        
        if ((not moving_dest) and (not moving_start)) then
            printPath()
        end
        if not moving_start then
            love.graphics.draw(tileset_image,tileset_list[22],start_x*17,start_y*17)
        else
            love.graphics.draw(tileset_image,tileset_list[22],x-8,y-8)
        end
        
        if not moving_dest then
            love.graphics.draw(tileset_image,tileset_list[16],dest_x*17,dest_y*17)
        else
            love.graphics.draw(tileset_image,tileset_list[16],x-8,y-8)
        end
      
        love.graphics.setColor(1,1,1)
        
        love.graphics.pop()
    end
    
    function self.update(dt)
        cam.update(dt)
        --if you ask, loveframes is updated on the main.
        setDiagonal(checkbox3:GetChecked())
        if show_marks ~= checkbox2:GetChecked() and ((not moving_dest) and (not moving_start)) then
            show_marks = checkbox2:GetChecked()
            updateTileSet()
        end
        --
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
            if pajarito.isNodeOnGrid(m_ix,m_iy) then
                if moving_start then
                    start_x = m_ix
                    start_y = m_iy
                elseif moving_dest then
                    dest_x = m_ix
                    dest_y = m_iy
                else
                    tile_map[m_iy][m_ix] = tile_to_draw
                end
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
                if m_ix == start_x and m_iy == start_y then
                    moving_start = true
                    show_path = false
                elseif m_ix == dest_x and m_iy == dest_y then
                    moving_dest = true
                    show_path = false
                elseif (show_path or show_marks) and not mouseOnGUI(container) and
                    pajarito.isNodeOnGrid(m_ix,m_iy) 
                    then
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
            end
            is_mouse_pressed = false
            
            if pajarito.isNodeOnGrid(m_ix,m_iy) then
                if moving_start then
                    start_x = m_ix
                    start_y = m_iy
                    moving_start = false
                end
                if moving_dest then
                    dest_x = m_ix
                    dest_y = m_iy
                    moving_dest = false
                end
                if (show_path or show_marks) and not mouseOnGUI(container) then
                    tile_map[m_iy][m_ix] = tile_to_draw
                end
                --updateRange(saved_x,saved_y,range_slider:GetValue())
                updatePath()
            end
            show_path = true
        end
    end
    
    return self
end

return Main()