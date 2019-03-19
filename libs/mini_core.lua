--oveloaded functions
function Overloaded()
    local fns = {}
    local mt = {}
    
    local function oerror()
        return error("Invalid argument types to overloaded function")
    end
    
    function mt:__call(...)
        local arg = {...}
        local default = self.default
        
        local signature = {}
        for i,arg in ipairs {...} do
            signature[i] = type(arg)
        end
        
        signature = table.concat(signature, ",")
        
        return (fns[signature] or self.default)(...)
    end
    
    function mt:__index(key)
        local signature = {}
        local function __newindex(self, key, value)
            print(key, type(key), value, type(value))
            signature[#signature+1] = key
            fns[table.concat(signature, ",")] = value
            print("bind", table.concat(signature, ", "))
        end
        local function __index(self, key)
            print("I", key, type(key))
            signature[#signature+1] = key
            return setmetatable({}, { __index = __index, __newindex = __newindex })
        end
        return __index(self, key)
    end
    
    function mt:__newindex(key, value)
        fns[key] = value
    end
    
    return setmetatable({ default = oerror }, mt)
end

--linear interpolation.
function lerp(a,b,t) return (1-t)*a + t*b end

--[[
a 2D Vector class 
]]
function vector2D(x,y)
    local self = {x = x or 0,y= y or 0}
    
    function self.magnitud()
      return math.sqrt(self.x*self.x+self.y*self.y) or 0
    end
    
    function self.magnitudCuadrada()
      return self.x*self.x+self.y*self.y or 0
    end
    
    function self.productoPunto(vec)
      --print(self.x,self.y)
      --print(vec.x,vec.y)
      return self.x*vec.x + self.y*vec.y
    end
    
    function self.productoCruz(vec)
      --print(self.x,self.y)
      --print(vec.x,vec.y)
      return self.x*vec.y - self.y*vec.x
    end
    
    function self.lerpVector(vec,t)
        local t = t or 0.5
        self.x = lerp(vec.x,self.x,t)
        self.y = lerp(vec.y,self.y,t)
    end
    
    function self.normalizar(min)
      local min = min or 0
      local mag = self.magnitud()
      if mag > min  then
        return self/mag
      end
      return vector2D(0,0)
    end
    --sobrecarga de operadores...
    local mt = {
    __add = function (lhs, rhs) 
        x = lhs.x + rhs.x
        y = lhs.y + rhs.y
        return vector2D(x,y) 
        end,
    __sub = function (lhs, rhs) 
        x = lhs.x - rhs.x
        y = lhs.y - rhs.y
        return vector2D(x,y) 
        end,
    __div = function (lhs, rhs) 
         if type(rhs) == 'number' then 
            x = lhs.x/rhs
            y = lhs.y/rhs
            return vector2D(x,y)
          end    
        x = lhs.x/rhs.x
        y = lhs.y/rhs.y
        return vector2D(x,y) 
        end,
    __mul = function (lhs,rhs)
        if type(rhs) == 'number' then 
            x = lhs.x*rhs
            y = lhs.y*rhs
            return vector2D(x,y)
          end
        x = lhs.x*rhs.x
        y = lhs.y*rhs.y
        return vector2D(x,y) 
        end,
    __call = function(a, op)
        if op == '.' then 
            return function(b) return self.productoPunto(b) end
        elseif op == 'x' then
            return function(b) return self.productoCruz(b) end
            end
        
        end
        
    }
    
    setmetatable(self, mt) -- use "mt" as the metatable
    
    self.type = 'vector2D'
    
    return self
end

function Chrono()
    local self = {}
    local start_time = 0 
    local pause_time = 0
    local iniciado = false
    local pausado = false
    local detenido = false
    
    function self.estaDetenido()
        return detenido
    end
    
    function self.estaPausado()
        return pausado
    end
    
    function self.estaIniciado()
        return iniciado
    end
    
    function self.iniciar()
        iniciado = true
        pausado = false
        detenido = false
        start_time = love.timer.getTime()
        pause_time = 0
    end
    
    function self.getDeltaTime()
        if iniciado then
            if pausado then
                return pause_time
            else
                return (love.timer.getTime()-start_time)
            end
        end
        return 0
    end
    
    function self.getDeltaTimeFrame(max_fps)
        local time = self.getDeltaTime()
        self.iniciar()
        return time
    end
    
    function self.hanPasado(segundos)
        if self.getDeltaTime() >=  segundos then
            self.iniciar()
            return true
        end
        return false
    end
    
    function self.pausar()
        if iniciado and (not pausado) then
            pausado = true
            pause_time = love.timer.getTime()-start_time
        end
    end
    
    function self.despausar()
        if iniciado and pausado then
            pausado = false
            start_time = love.timer.getTime()-pause_time
            pause_time = 0
        end
    end
    
    function self.detener()
       detenido = true
       iniciado = false
       pausado = false
    end
    
    return self
end


function makeQuads(ancho_ima,alto_ima,ancho_r,alto_r)
    local lista = {}
    local filas = math.floor(alto_ima/alto_r)
    local columnas = math.floor(ancho_ima/ancho_r)
    
    offset_x = offset_x or 0
    offset_y = offset_y or 0

    --print(filas,columnas)
    local count = 1
    local i = 0
    while i < filas do
        local j = 0
        while j < columnas do
            local x = (ancho_r*j)+offset_x
            local y = (alto_r*i)+offset_y
            lista[count] = love.graphics.newQuad(x,y,ancho_r,alto_r,ancho_ima, alto_ima)
            count = count+1
            --io.write('*')
            j = j+1
        end
        i=i+1
        --io.write('\n')
    end
    return lista
end


function Camera(x,y)
    local self = {}
    self.x = x
    self.y = y
    
    self.drag_x = 0
    self.drag_y = 0
    self.drag_ended = true
    
    self.move_tween = nil
    self.move_ended = true
    
    self.easing = "linear"
    
    function self.getPos()
        return self.x, self.y
    end
    
    function self.getPosX() return self.x-self.drag_x end
    function self.getPosY() return self.y-self.drag_y end
    
    function self.move(time,nx,ny) 
        if self.move_ended then
            self.move_tween = tween.new(time,self, { y = ny, x = nx }, self.easing)
        end
    end
    
    function self.setTweenEasing(nes)
        self.easing = nes
    end

    function self.moveCenterTo(time,nx,ny) 
        if self.move_ended then
            self.move(time,nx-320,ny-180)
        end
    end
    
    function self.isMoving()
        return not(self.move_ended)
    end
    
    function self.draw()
        love.graphics.setColor(1,0,1,0.5)
        love.graphics.circle('fill', self.getPosX(),self.getPosY(), 10)
        love.graphics.line(self.getPosX(),self.getPosY()+180,self.getPosX()+640,self.getPosY()+180)
        love.graphics.line(self.getPosX()+320,self.getPosY(),self.getPosX()+320,self.getPosY()+360)
        love.graphics.setColor(1,1,1,1)
    end
    
    function self.update(dt)
        if self.move_tween then
            self.move_ended = (self.move_tween:update(dt))
        end
    end
    
    --esta arrastrando la camara
    function self.drag(dx,dy)
        if self.move_ended then
            self.drag_x = dx
            self.drag_y = dy
            self.drag_ended = false
        end
    end
    
    function self.setPos(nx,ny)
        self.move_tween = tween.new( 0.01,self, { y = ny, x = nx }, 'linear')
    end
    
    --la camara deja de arrastrarse...
    function self.drop(dx,dy)
        if self.move_ended then
            self.drag_ended = true
            self.setPos(self.x-self.drag_x,self.y-self.drag_y)
            self.drag_x = 0
            self.drag_y = 0
        end
    end
    
    return self
end
