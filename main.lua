-- If you are interesed only on the use of the Pajarito Pathfinder,
-- ignore this file and jump directly to the code on the examples folder.

io.stdout:setvbuf("no")

-- mini_core.lua contains:
--    a simple vector implementation (vector2D)
--    a camera (Camera) that, ironically uses tween
--    a chronometer (Chrono)
--    a funtion to split a image to form quads (makeQuads)
love.filesystem.load("libs/mini_core.lua")()

-- escena.lua is just a handler of scenes  
love.filesystem.load("libs/escena.lua")()

--Loveframes is the  library used to generate the gui 
loveframes = require("libs/loveframes")

--"tween.lua is a small library to perform tweening in Lua."
tween = require("libs/tween")

--setting the graphics mode 
love.window.setTitle("Pajarito Pathfinder Examples")
love.window.setMode(640*2,360*2,{resizable=true})
love.graphics.setDefaultFilter( 'nearest', 'nearest', 1 )

--just boring stuff to handle the resizable window
CANVAS = nil
SIZE_WIN_W = 640*2
SIZE_WIN_H = 360*2

IS_CHANGED_RESOLUTION = false
local old_factor = SIZE_WIN_H/(360)

function love.resize(w, h)
  SIZE_WIN_H = h
  SIZE_WIN_W = w
end

function getCanvasScaleFactor()
    return SIZE_WIN_H/(360)
end

function getCanvasPadding()
    return (SIZE_WIN_W-getCanvasScaleFactor()*640)/2
end

function getMouseOnWindowDrawArea()
    local mx, my = love.mouse.getPosition()
    local nx = mx-getCanvasPadding()
    return nx, my
end

function getMouseOnCanvas()
    local factor = SIZE_WIN_H/(360)
    local x,y = getMouseOnWindowDrawArea()
    return x/factor, y/factor
end


--this are chronometers 
GARBAGE_TIMER = Chrono() -- one is used to call the garbaje collector
DRAW_TIMER = Chrono()    --this one if for drawing the canvas ad a fixed rate

--this is a scena manager
--the main menu and each one of the examples is treated like a scene
SCENA_MANAGER = EscenaManager()

function love.load()
    --we start here chronometers
    --"iniciar" is spanish for "start" 
    --Why is on spanish? 
    GARBAGE_TIMER.iniciar()
    DRAW_TIMER.iniciar()
    
    --we set the canvas size to be a quarter of the size of the window
    CANVAS = love.graphics.newCanvas(640,360)
    
    --we load the first of the scenes, in this case, the main menu
    --local init_scene =  love.filesystem.load("examples/elemental.lua")()
    local init_scene =  love.filesystem.load("main_menu.lua")()
    --... and then is added to the manager
    SCENA_MANAGER.push(init_scene)

end

function love.update(dt)
    --this is used to handle the resolution. 
    IS_CHANGED_RESOLUTION = (old_factor ~= getCanvasScaleFactor())
    
    --[[
    Here is some dark magic used to keep a consistent
    update dt indepentend of the used hardware and framerate
    as possible 
    --]]
    local accum = dt
	while accum > 0 do
		local dt = math.min( 1/60, accum )	
		accum = accum - dt
		SCENA_MANAGER.update(dt) --we update the scenes
        loveframes.update(dt)    --update the gui
        --check for changes on the size of the window
        if IS_CHANGED_RESOLUTION then
            old_factor = getCanvasScaleFactor()
            IS_CHANGED_RESOLUTION = false
        end
    end
    
    --collencting the garbage each 5 seconds
    if GARBAGE_TIMER.hanPasado(5) then
        --print('recolector')
        collectgarbage()
    end
end


function love.draw()
    
    --we try to draw the canvas at 65 fps, 
    --if the machine is slower, the frame rate drops.
    if DRAW_TIMER.hanPasado(1/65) then
        
        love.graphics.setCanvas(CANVAS)
        SCENA_MANAGER.draw()
        love.graphics.setCanvas()
        
    end

    love.graphics.setColor(1,1,1)
    
    --we draw here the canvas scaled and draw 
    --to acount for the resize
    local factor = SIZE_WIN_H/(360)
    local x = (SIZE_WIN_W/2)-(320*factor)
    local y = (SIZE_WIN_H/2)-(180*factor)
    love.graphics.draw(CANVAS,x,y,0,factor,factor)
    
    --GUI is draw on top of everything
    love.graphics.setColor(1,1,1,1)
    loveframes.draw()
    
end

--[[
Input functions, we pass their values directly to the handler and gui. 
--]]
function love.mousepressed(x, y, button)
	loveframes.mousepressed(x, y, button)
    SCENA_MANAGER.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
	loveframes.mousereleased(x, y, button)
    SCENA_MANAGER.mousereleased(x, y, button)
end

function love.wheelmoved(x, y)
	loveframes.wheelmoved(x, y)
end

function love.keyreleased( key, scancode )
    loveframes.keyreleased(key)
    SCENA_MANAGER.keyreleased(key,scancode)
end

function love.keypressed(key,scancode, isrepeat)
    if key == "escape" then
        love.event.quit()
    end
    loveframes.keypressed(key, isrepeat)
    SCENA_MANAGER.keypressed(key,scancode)
end

function love.mousemoved(x, y, dx, dy, istouch)
    SCENA_MANAGER.mousemoved(x, y)
end

function love.wheelmoved( dx, dy )
    SCENA_MANAGER.wheelmoved( dx, dy )
end

function love.textinput(text)
	loveframes.textinput(text)
end
