function GUIBuilder(tileset_image, tileset_list)
    local self = {}

    local getImaOfTile = function(tile)
        local can = love.graphics.newCanvas(16,16)
        love.graphics.setCanvas(can)
        love.graphics.draw(tileset_image,tileset_list[tile])
        love.graphics.setCanvas()
        return love.graphics.newImage(can:newImageData( ))
    end

    self.is_mouse_pressed = false
    self.active_draw_tile = 1
    self.str_description_text = ''
    self.is_on_draw_mode = false

    local saved_x = 1
    local saved_y = 1
    local table_of_weights = {}
    local stored_range = 15
    local root_panel = nil
    local description_text = nil
    local button_go_back = nil
    local button_toggle_drawmode = nil
    local range_slider_text = nil
    local range_slider = nil
    local sliderCallback = function (x,y,r) end
    local checkbox_show_border = nil
    local checkbox_show_border_value = false;

    local checkbox_show_range = nil
    local checkbox_show_range_value = true;

    local checkbox_range_numbers = nil
    local checkbox_range_numbers_value = false

    local checkbox_border_numbers = nil
    local checkbox_border_numbers_value = false

    local checkbox_toggle_diagonal = nil
    local checkbox_toggle_diagonal_value = false

    local checkbox_warranty_sortest = nil
    local checkbox_warranty_sortest_value = false

    local sub_container = nil
    local rebuild = function ()  end

    function self.buildWeightEditorPanel()
        local editor_title = loveframes.Create("text",sub_container)
        editor_title:SetPos(5,5)
        editor_title:SetWidth(410)
        editor_title:SetText(
          'Click on any part of the map to mark a new starting point.\n'..
          'Put the mouse inside the range, if a path exist, will be draw.\n'..
          "Modify the weights of the tiles (a value of '0' means impassable)")
        editor_title:SetShadowColor(.8, .8, .8, 1)
        editor_title:SetShadow(true)

        button_toggle_drawmode = loveframes.Create("button", sub_container)
        button_toggle_drawmode:SetWidth(120)
        button_toggle_drawmode:SetPos(10,122)
        button_toggle_drawmode:SetText("Draw On Map")
        button_toggle_drawmode.OnClick = function(object, x, y)
            self.is_on_draw_mode = not self.is_on_draw_mode
            rebuild()
        end

        local i = 0
        local j = 0
        for k,v in pairs(table_of_weights) do
            local nb = loveframes.Create("image", sub_container)
            local x = 5+(j*200)
            local y = 49+(17*i)
            nb:SetSize(16,16)
            nb:SetPos(x+8,y)
            nb:SetImage(getImaOfTile(k))

            local text = loveframes.Create("text", sub_container)
            text:SetPos(x+32,y)
            text:SetWidth(280)
            text:SetText('w: '..tostring(v))

            local sldr = loveframes.Create("slider",sub_container)
            sldr:SetPos(x+65,y)
            sldr:SetWidth(130)
            sldr:SetMinMax(0,5)
            sldr:SetDecimals(0)
            sldr:SetValue(v)

            text.Update = function(object, dt)
                object:SetText('w: '..tostring(sldr:GetValue()))
            end

            sldr.OnValueChanged = function(object)
                table_of_weights[k] = object:GetValue()
                sliderCallback(saved_x,saved_y,stored_range)
            end

            i=i+1
            if i>3 then
                j = j+1
                i = 0
            end
        end
    end

    function self.buildMapPaintEditorPanel()
        local editor_title = loveframes.Create("text",sub_container)
        editor_title:SetPos(10,5)
        editor_title:SetWidth(400)
        editor_title:SetText("Choose a tile to draw")
        editor_title:SetShadowColor(.8, .8, .8, 1)
        editor_title:SetShadow(true)

        button_toggle_drawmode = loveframes.Create("button", sub_container)
        button_toggle_drawmode:SetWidth(120)
        button_toggle_drawmode:SetPos(10,95)
        button_toggle_drawmode:SetText("Edit Map Weights")
        button_toggle_drawmode.OnClick = function(object, x, y)
            self.is_on_draw_mode = not self.is_on_draw_mode
            rebuild()
        end

        local ima = loveframes.Create("image",sub_container)
        ima:SetPos(20,24)

        local i = 0
        local j = 0
        for k,v in pairs(table_of_weights) do
            local nb = loveframes.Create("imagebutton",sub_container)
            local x = 105+(i*22)
            local y = 24+(22*j)
            --nb:SetSize(24,24)
            nb:SetText('')
            nb:SetPos(x,y)
            nb:SetImage(getImaOfTile(k))
            nb:SizeToImage()
            nb.OnClick = function(object)
                --object:SetText("The mouse entered the button.")
                self.active_draw_tile = k
                ima:SetImage(object.image)
            end

            i=i+1
            if i>2 then
                j = j+1
                i = 0
            end
        end

        ima:SetImage(getImaOfTile(self.active_draw_tile))
        ima:SetScale(4,4)
    end

    rebuild = function()
        loveframes.RemoveAll()
        root_panel = loveframes.Create('panel')
        if self.is_on_draw_mode then
            root_panel:SetSize(700,148)
            root_panel:SetPos(152,0)
        else
            root_panel:SetSize(920,148)
            root_panel:SetPos(152,0)
        end

        local description_panel = loveframes.Create('panel', root_panel)
        description_panel:SetSize(270,148);
        description_text = loveframes.Create('text', description_panel)
        description_text:SetPos(10,7)
        description_text:SetWidth(250)
        description_text:SetText(self.str_description_text)

        button_go_back = loveframes.Create("button", description_panel)
        button_go_back:SetWidth(200)
        button_go_back:SetPos(40,110)
        button_go_back:SetText("Go back to main menu")
        button_go_back.OnClick = function(object, x, y)
            loveframes.RemoveAll()
            SCENA_MANAGER.pop()
        end

        local instructions = loveframes.Create("text",root_panel)
        instructions:SetPos(10,112)
        instructions:SetWidth(480)
        instructions:SetShadowColor(.8, .8, .8, 1)
        instructions:SetShadow(true)

        range_slider_text = loveframes.Create('text', root_panel)
        range_slider_text:SetPos(280,15)
        range_slider_text:SetWidth(280)
        range_slider_text:SetText('Range '..tostring(stored_range))
        range_slider_text.Update = function(object, dt)
            stored_range = range_slider:GetValue()
            object:SetText('Range '..tostring(stored_range))
        end

        range_slider = loveframes.Create("slider", root_panel)
        range_slider:SetPos(340,13)
        range_slider:SetWidth(225)
        range_slider:SetMinMax(2,15)
        range_slider:SetValue(stored_range)
        range_slider:SetDecimals(0)
        range_slider.OnValueChanged = function(object)
            stored_range = object:GetValue()
            sliderCallback(saved_x,saved_y,object:GetValue())
        end

        checkbox_show_range = loveframes.Create("checkbox", root_panel)
        checkbox_show_range:SetText("Mark Range Nodes")
        checkbox_show_range:SetPos(280, 40)
        checkbox_show_range:SetChecked(checkbox_show_range_value)
        checkbox_show_range.onChange = function ()
            checkbox_show_range_value = not checkbox_show_range_value
        end

        checkbox_show_border = loveframes.Create("checkbox", root_panel)
        checkbox_show_border:SetText("Mark Border Nodes")
        checkbox_show_border:SetPos(430, 40)
        checkbox_show_border:SetChecked(checkbox_show_border_value)
        checkbox_show_border.onChange = function ()
            checkbox_show_border_value = not checkbox_show_border_value
        end

        -- Same line
        checkbox_range_numbers = loveframes.Create("checkbox", root_panel)
        checkbox_range_numbers:SetText("Show Range Cost")
        checkbox_range_numbers:SetPos(280, 65)
        checkbox_range_numbers:SetChecked(checkbox_range_numbers_value)
        checkbox_range_numbers.onChange = function ()
            checkbox_range_numbers_value = not checkbox_range_numbers_value
        end

        checkbox_border_numbers = loveframes.Create("checkbox", root_panel)
        checkbox_border_numbers:SetText("Show Border Cost")
        checkbox_border_numbers:SetPos(430, 65)
        checkbox_border_numbers:SetChecked(checkbox_border_numbers_value)
        checkbox_border_numbers.onChange = function ()
            checkbox_border_numbers_value = not checkbox_border_numbers_value
        end

        checkbox_toggle_diagonal = loveframes.Create("checkbox", root_panel)
        checkbox_toggle_diagonal:SetText("Diagonal movement")
        checkbox_toggle_diagonal:SetPos(280, 90)
        checkbox_toggle_diagonal:SetChecked(checkbox_toggle_diagonal_value)
        checkbox_toggle_diagonal.onChange = function ()
            checkbox_toggle_diagonal_value = not checkbox_toggle_diagonal_value
        end

        checkbox_warranty_sortest = loveframes.Create("checkbox", root_panel)
        checkbox_warranty_sortest:SetText("Warranty Shortest Path, usually not required")
        checkbox_warranty_sortest:SetPos(280, 115)
        checkbox_warranty_sortest:SetChecked(checkbox_warranty_sortest_value)
        checkbox_warranty_sortest.onChange = function ()
            checkbox_warranty_sortest_value = not checkbox_warranty_sortest_value
        end

        sub_container = loveframes.Create("panel",root_panel)
        if self.is_on_draw_mode then
            sub_container:SetSize(180,148)
        else
            sub_container:SetSize(405,148)
        end
        sub_container:SetPos(575)

        if self.is_on_draw_mode then
            self.buildMapPaintEditorPanel()
        else
            self.buildWeightEditorPanel()
        end
    end

    ---@param callback function
    function self.setSliderCallback(callback)
        sliderCallback = callback
        rebuild()
    end

    function self.setRangeSliderValue(new_value)
        stored_range = new_value
        rebuild()
    end

    function self.getRangeSliderValue()
        return stored_range;
    end

    function self.setDescriptionText(text)
        self.str_description_text = text
        description_text:SetText(self.str_description_text)
    end

    function self.bindTableWeights( ref_table_of_weights )
        table_of_weights = ref_table_of_weights
        rebuild()
    end

    function self.hasMosueOver()
        local x, y = love.mouse.getPosition()
        return (x >= root_panel.x and  (x < (root_panel.x+root_panel.width)))
        and (y >= root_panel.y and (y < (root_panel.y+root_panel.height)))
    end

    function self.setRangePosition(x,y)
        saved_x = x
        saved_y = y
    end

    function self.canShowRangeNodes()
        return checkbox_show_range:GetChecked()
    end

    function self.canShowRangeValues()
        return checkbox_range_numbers:GetChecked()
    end

    function self.canShowBorderValues()
        return checkbox_border_numbers:GetChecked()
    end

    function self.canShowRangeBorder()
        return checkbox_show_border:GetChecked()
    end

    function self.canGoDiagonal()
        return checkbox_toggle_diagonal:GetChecked()
    end

    function self.canWarrantyShortest()
        return checkbox_warranty_sortest:GetChecked()
    end

    rebuild()
    return self
end


function Main()
    local self = Escena()
    --load a tileset image
    local tileset_image = love.graphics.newImage('/rsc/tileset.png')
    local walls_image = love.graphics.newImage('/rsc/walls.png')

    --tileset contains the spritebatch we create from the source image
    local tileset = love.graphics.newSpriteBatch(tileset_image,2000)
    local tileset_walls = love.graphics.newSpriteBatch(walls_image,2000)

    --tileset_list contains the quads used to draw the map
    local tileset_list = makeQuads(64,64,16,16)
    local tiles_walls_list = makeQuads(48,48,16,16)

    local defaultFont = love.graphics.getFont()
    local pixelFont = love.graphics.newFont( '/rsc/pixel_fonts/PXSansBold.ttf', 17)

    function self.updateMapTile(x,y,new_tile) end

    function self.updateTilesToDraw() end

    function self.drawWalls() end
    function self.drawNodeRangeValues() end
    function self.drawNodeBorderValues() end
    function self.drawPath() end

    function self.requestNewPath() end

    --this is the function called every time the slider of "Range" changes.
    function self.updateRange(x,y,range)  end

    --to store the converted form screen mouse position to tile map cords
    self.m_ix = 1
    self.m_iy = 1

    local store_mouse_position_x = self.m_ix
    local store_mouse_position_y = self.m_iy

    self.map_graph = nil
    self.node_range = nil

    self.tile_map_width = 0
    self.tile_map_height = 0

    self.gui = GUIBuilder(tileset_image, tileset_list);
    local stored_value_show_border = self.gui.canShowRangeBorder()
    local stored_value_show_range = self.gui.canShowRangeNodes()
    local stored_value_movement = self.gui.canGoDiagonal()

    function self.getTileset() return tileset end
    function self.getListOfTiles() return tileset_list end

    function self.getTilesetWalls() return tileset_walls end
    function self.getListOfWallTiles() return tiles_walls_list end

    --- Get the coordinates in the tilemap were
    --- the mouse is
    ---@return table
    function self.getMouseTile()
        return {self.m_ix, self.m_iy}
    end

    --- Were WE do configure this before the first run.
    function self.build()
        love.window.setTitle(self.title)

            --a camera is created and placed on the center of the map
        self.camera = Camera(
            -(320)+((self.tile_map_width/2+1)*17),
            -(180)+(self.tile_map_height*8))

        self.updateTilesToDraw()
    end

    function self.drawCost(x,y,cost)
        cost = tostring(cost)
        local padding = 0
        if #cost == 1 then
            padding = 4
        end
        x = x + padding
        love.graphics.setColor(0.2,0.1,0.0,0.8)
        love.graphics.print(cost, x+1, y)
        love.graphics.print(cost, x-1, y)
        love.graphics.print(cost, x, y+1)
        love.graphics.print(cost, x, y-1)
        love.graphics.setColor(1,1,1,1)
        love.graphics.print(cost, x, y)
    end


    function self.draw()
        love.graphics.clear(0.1,0.1,0.1)
        love.graphics.setColor(1,1,1)
        love.graphics.print('x: '..tostring(self.m_ix)..' y:'..tostring(self.m_iy))
        love.graphics.push()
            love.graphics.translate(
                math.floor(-self.camera.getPosX()),
                math.floor(-self.camera.getPosY())
            )

            local x, y = getMouseOnCanvas()
            x,y = love.graphics.inverseTransformPoint(x,y)

            if not self.gui.hasMosueOver() then
                self.m_ix = math.floor(x/17)
                self.m_iy = math.floor(y/17)
                
            end

            love.graphics.draw(tileset) -- draw the map
            love.graphics.draw(tileset_walls) -- draw the walls

            -- draw the cursor
            local default_cursor = tileset_list[12]
            if self.gui.is_on_draw_mode then
                default_cursor = tileset_list[self.gui.active_draw_tile]
            end
            love.graphics.draw(tileset_image, default_cursor ,self.m_ix*17,self.m_iy*17)

            self.drawPath()

            if self.gui.canShowRangeValues() then
                love.graphics.setFont(pixelFont)
                self.drawNodeRangeValues()
                love.graphics.setFont(defaultFont)
            end

            if self.gui.canShowBorderValues() then
                love.graphics.setFont(pixelFont)
                self.drawNodeBorderValues()
                love.graphics.setFont(defaultFont)
            end

            love.graphics.setColor(1,1,1)
        love.graphics.pop()
    end

    function self.update(dt)
        if stored_value_show_border ~= self.gui.canShowRangeBorder() then
            stored_value_show_border = self.gui.canShowRangeBorder()
            self.updateTilesToDraw()
        end
        if stored_value_show_range ~= self.gui.canShowRangeNodes() then
            stored_value_show_range = self.gui.canShowRangeNodes()
            self.updateTilesToDraw()
        end
        if stored_value_movement ~= self.gui.canGoDiagonal()
            and self.node_range then
            stored_value_movement = self.gui.canGoDiagonal()
            -- Update the range with the new map info.
            local position = self.node_range:getStartNodePosition()
            local range = self.node_range.range
            if position then
                self.updateRange(position[1], position[2], range)
            end
        end
        local changePosition = (store_mouse_position_x ~= self.m_ix
                or store_mouse_position_y ~= self.m_iy)
        if changePosition and self.node_range then
            self.requestNewPath()
            store_mouse_position_x = self.m_ix
            store_mouse_position_y = self.m_iy
        end
    end

    function self.mousereleased(x, y, button)
        if button == 1 and not self.gui.hasMosueOver() then
            local tile = self.gui.active_draw_tile
            if self.gui.is_on_draw_mode then
                self.updateMapTile(self.m_ix, self.m_iy, tile)
            else
                if self.map_graph:hasPoint({self.m_ix, self.m_iy}) then
                    self.gui.setRangePosition(self.m_ix, self.m_iy)
                    self.updateRange(self.m_ix, self.m_iy, self.gui.getRangeSliderValue())
                end
            end
        end
    end

    return self
end

return Main