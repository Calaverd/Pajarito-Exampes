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

        return (fns[table.concat(signature, ",")] or self.default)(...)
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
local function lerp(a,b,t) return (1-t)*a + t*b end

--[[
a 2D Vector class 
]]
function vector2D(x,y)
    local self = {x = x or 0,y= y or 0}

    function self.magnitud()
      return math.sqrt(self.x*self.x+self.y*self.y) or 0
    end

    function self.magnitudCuadrada()
      return ((self.x*self.x)+(self.y*self.y)) or 0
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

    function self.start()
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
        self.start()
        return time
    end

    function self.hasPassed(segundos)
        if self.getDeltaTime() >=  segundos then
            self.start()
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