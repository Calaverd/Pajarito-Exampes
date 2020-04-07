local example_list = {}
example_list[1] = {'graphical_main','Pajarito main.lua'}
example_list[2] = {'elemental','Elemental'}
example_list[3] = {'weights','Using Weights'}
example_list[4] = {'path_in_range','Path In Range'}
example_list[5] = {'pathfinder','Standar Pathfinder'}
--example_list[5] = {'hexagonal','Hexagonal'}
--example_list[6] = {'level','Minigame'}

local function createGUI()
    local list = loveframes.Create("list")
    list:SetSize(240, 130)
    list:SetPadding(5)
    list:SetSpacing(5)
    list:CenterX()
    list:CenterY()
    --button:SetText("Elemental")
    --[[
    button.OnClick = function(object, x, y)
        loveframes.RemoveAll()
        SCENA_MANAGER.push(love.filesystem.load("examples/elemental.lua")())
        --object:SetText("You clicked the button!")
    end
    --]]
    local i = 1
    while example_list[i] do
		local button = loveframes.Create("button")
		local url = example_list[i][1]
        local name = example_list[i][2]
        button:SetText(name)
		button.OnClick = function()
            loveframes.RemoveAll()
            SCENA_MANAGER.push(love.filesystem.load("examples/"..url..".lua")())
            --object:SetText("You clicked the button!")
        end
        
        list:AddItem(button)
        
        i=i+1
	end
    --weights
end
--check if the mouse is over a element of the gui.
function mouseOnGUI(gui_obj)
    local x, y = love.mouse.getPosition()
    return (x >= gui_obj.x and  (x < (gui_obj.x+gui_obj.width)))
    and (y >= gui_obj.y and (y < (gui_obj.y+gui_obj.height)))
end

function Main()
    local self = Escena()
    
    function self.load()
        love.window.setTitle("Pajarito Pathfinder Examples")
        createGUI()
    end
    
    function self.onPop()
        love.window.setTitle("Pajarito Pathfinder Examples")
        createGUI()
    end
    
    function self.draw()
        love.graphics.clear(0.5,0.5,0.5)
        love.graphics.setColor(0,0,0)
        love.graphics.print('Pajarito Pathfinder Examples',231,101)
        
        love.graphics.setColor(1,1,1)
        love.graphics.print('Pajarito Pathfinder Examples',230,100)
    end
    
    function self.update(dt)
        
    end
    
    
    return self
end

return Main()