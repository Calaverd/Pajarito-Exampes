
function EscenaManager()
    local self = {}
    self.pila_escenas = {}
    
    function self.push(escena, parameters)
        self.pila_escenas[#self.pila_escenas+1] = escena
        self.pila_escenas[#self.pila_escenas].load(parameters)
    end
    
    function self.replace(escena,parameters)
        self.pop()
        self.push(escena, parameters)
    end

    function self.clearAll()
        while self.pila_escenas[1] do
            table.remove(self.pila_escenas,1)
        end
        collectgarbage()
    end
    
    function self.pop()
        if #self.pila_escenas > 0 then
            table.remove(self.pila_escenas,#self.pila_escenas)
            collectgarbage()
            self.pila_escenas[#self.pila_escenas].onPop()
        end
    end
    
    function self.update(dt) 
        self.pila_escenas[#self.pila_escenas].update(dt)
        if self.pila_escenas[#self.pila_escenas].EXIT then
            self.pop(#self.pila_escenas)
        end
    end
    
    function self.getUseShaders()
        return self.pila_escenas[#self.pila_escenas].useShaders
    end
    
    function self.draw()
        self.pila_escenas[#self.pila_escenas].draw()
    end
    
    function self.keyreleased( key, scancode )
        self.pila_escenas[#self.pila_escenas].keyreleased( key, scancode )
    end
    
    function self.keypressed(key,scancode)
        self.pila_escenas[#self.pila_escenas].keypressed(key,scancode)
    end
    
    function self.mousemoved(x, y, dx, dy, istouch)
        self.pila_escenas[#self.pila_escenas].mousemoved(x, y)
    end
    
    function self.mousepressed(x, y, button)
        self.pila_escenas[#self.pila_escenas].mousepressed(x, y, button)
    end

    function self.mousereleased(x, y, button)
        self.pila_escenas[#self.pila_escenas].mousereleased(x, y, button)
    end
    
    function self.wheelmoved( dx, dy )
        self.pila_escenas[#self.pila_escenas].wheelmoved(dx,dy)
    end
    
   return self
end

function Escena()
    local self = {}
    self.EXIT = false
    self.useShaders = true
    
    function self.update()
    end
    
    function self.draw()
    end

    function self.load()
    end
    
    function self.onPop()
    end

    function self.keyreleased( key, scancode )
    end
    
    function self.keypressed(key,scancode)
    end
    
    function self.mousemoved(x, y, dx, dy, istouch)
    end
    
    
    function self.mousepressed(x, y, button)
    end

    function self.mousereleased(x, y, button)
    end
    
    
    function self.wheelmoved( dx, dy )
    end
    
    return self
end

