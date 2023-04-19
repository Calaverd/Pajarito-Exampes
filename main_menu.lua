local example_list = {}
table.insert(example_list, {'graphical_main','Pajarito main.lua'})
table.insert(example_list, {'clean_canvas','Clean canvas'})
table.insert(example_list, {'elemental_walls','Basic Walls'})
table.insert(example_list, {'weights','Using Weights'})
table.insert(example_list, {'path_in_range','Path In Range'})
table.insert(example_list, {'pathfinder','Standar Pathfinder'})
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
            local new_scene = love.filesystem.load("examples/"..url..".lua")()
            new_scene.build()
            SCENA_MANAGER.push(new_scene)
            --object:SetText("You clicked the button!")
        end

        list:AddItem(button)

        i=i+1
	end
    --weights
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