pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--
-- by Neil Popham

#include collection.lua
#include functions.lua

particle={
 create=function(self,params)
  params=params or {}
  params.life=params.life or {60,120}
  params.angle=mrnd(params.angle,false)
  params.force=mrnd(params.force,false)
  local o=params
  o=extend(o,{x=params.x,y=params.y,life=mrnd(params.life),complete=false,dx=0,dy=0})
  setmetatable(o,self)
  self.__index=self
  return o
 end,
 update=function(self)
  self.x+=self.dx
  self.y+=self.dy
 end,
 draw=function(self)
  self.life=self.life-1
  if self.life==0 then self.complete=true end
 end
}

pixel={
 draw=function(self)
  pset(self.x,self.y,self.col)
  particle.draw(self)
 end
} setmetatable(pixel,{__index=particle})

circle={
 draw=function(self)
  circfill(self.x,self.y,self.size,self.col)
  particle.draw(self)
 end
} setmetatable(circle,{__index=particle})

bullet={
 update=function(self)
  self.dx+=0.1
  particle.update(self)
 end
} setmetatable(bullet,{__index=pixel})

smoke={
 update=function(self)
  self.size=self.size*.99
  particle.update(self)
 end
} setmetatable(smoke,{__index=circle})

function _init()
 particles=collection:create()
end

function _update60()
 particles:update()
 if btnp(4) then
  particles:add(
   bullet:create({
    x=mrnd({0,127}),
    y=mrnd({0,127}),
    angle={0,1},
    force={2,2},
    col=mrnd({1,15})
   })
  )
 end
 if btnp(5) then
  particles:add(
   smoke:create({
    x=mrnd({0,127}),
    y=mrnd({0,127}),
    angle={0,1},
    force={2,2},
    col=mrnd({1,15}),
    size=mrnd({10,20})
   })
  )
 end
end

function _draw()
 cls()
 particles:draw()
end
