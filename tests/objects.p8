pico-8 cartridge // http://www.pico-8.com
version 8

__lua__

local gravity={
 dy=1,
 t=1,
 get=function(self)
  local g=self.dy*self.t
  return g
 end
}

function gravity:foo()
 local g=self.dy*self.t
 return g
end

function vector(x,y)
 return {
  x=x,
  y=y
 }
end

function _init()
	--
 a=1
end

function _update()
 --
 gravity.dy+=1
end

function _draw()
 cls()
 --print(gravity:foo(),0,0)
 print(gravity:get(),0,0)
end
