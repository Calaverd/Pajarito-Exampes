function Main()
    local self = Escena()
    --load a tileset image
    local tileset_image = love.graphics.newImage('tileset.png')

    --tileset contains the spritebatch we create from the source image
    local tileset = love.graphics.newSpriteBatch(tileset_image,2000)

    --tileset_list contains the quads used to draw the map
    local tileset_list = makeQuads(320,320,16,16)
    
    self.title = 'Pajarito Example'
    self.timer = Chrono()

    --we define some variables
    --to store the converted form screen mouse position to tile map cords
    self.m_ix = 0
    self.m_iy = 0

    --variables used to store the pos once a mouse click on map happened
    --we init they on the middle of the tile map
    self.saved_x = 4 --math.floor(tile_map_width/2)
    self.saved_y = 4 --math.floor(tile_map_height/2)

    --a value to see if the border should be show
    self.show_border = true

    --tileset contains the spritebatch we will create from a source image
    self.tileset = nil

    --tileset_list, a list of the quads used to draw the map
    self.tileset_list = nil

    --a slider to set the range
    self.range_slider = nil

    --we added a draw/edit mode
    self.draw_mode = false
    self.tile_to_draw = 1

    -- GUI variables

    function self.drawRange(show_numbers)
        
    end

    function self.drawPath(show_conected_steps)
        
    end

    function self.drawBorder(show_numbers)
        
    end


    function self.setup()
        
    end

    function self.build()
        love.window.setTitle(self.title)
        --we start the timer
        self.timer.start()
    end

    updateTileSet()
    updatePath(1,1)

    function self.draw()
        love.graphics.clear(0.1,0.1,0.1)
        love.graphics.setColor(1,1,1)

        love.graphics.push()
        love.graphics.translate(math.floor(-self.cam.getPosX()),math.floor(-self.cam.getPosY()))

        local x, y = getMouseOnCanvas()
        x,y = love.graphics.inverseTransformPoint(x,y)

        if not mouseOnGUI(self.container) then
            self.m_ix = math.floor(x/17)
            self.m_iy = math.floor(y/17)

        end

        love.graphics.draw(tileset)
        love.graphics.draw(tileset_image,tileset_list[13],self.m_ix*17,self.m_iy*17)

        printPath()

        if self.checkbox1:GetChecked() then
            printNodeValues()
        end

        love.graphics.setColor(1,1,1)

        love.graphics.pop()
    end

    function self.update(dt)
        self.cam.update(dt)
        --if you ask, loveframes is updated on the main.
        if self.show_border ~= self.checkbox2:GetChecked() then
            self.show_border = self.checkbox2:GetChecked()
            updateTileSet()
        end
        setDiagonal(self.checkbox3:GetChecked())
        updatePath(self.m_ix,self.m_iy)
    end

    function self.mousemoved(x, y, dx, dy, istouch)
        if is_mouse_pressed and not mouseOnGUI(container) then
            local x, y = getMouseOnCanvas()
            self.relas_m.x = x
            self.relas_m.y = y
            local d = (pres_m-relas_m).magnitud()
            if d > 8 then
                local a = (relas_m-pres_m)
                --cam.drag(a.x,a.y)
                if draw_mode and draw_mode and Pajarito.isNodeOnGrid(self.m_ix,self.m_iy) then
                    tile_map[self.m_iy][self.m_ix] = tile_to_draw
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
                if draw_mode and Pajarito.isNodeOnGrid(self.m_ix,self.m_iy) then
                    tile_map[self.m_iy][self.m_ix] = tile_to_draw
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
            if draw_mode and Pajarito.isNodeOnGrid(self.m_ix,self.m_iy) and not mouseOnGUI(container) then
                tile_map[self.m_iy][self.m_ix] = tile_to_draw
                updateRange(saved_x,saved_y,range_slider:GetValue())
            end
            is_mouse_pressed = false
        end
    end

    return self
end

return Main