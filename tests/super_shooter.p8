pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- super_shooter
-- by neil popham

local screen={width=128,height=128}
local pad={left=0,right=1,up=2,down=3,btn1=4,btn2=5}

local collection={
 create=function(self)
  local o={
   items={},
   count=0,
  }
  o.update=function(self)
   printh(#self.items)
   for _,i in pairs(self.items) do
    if not i:update() then
     del(self.items,i)
    end
   end
  end
  o.draw=function(self)
   for _,i in pairs(self.items) do
    i:draw()
   end
  end
  o.add=function(self,object)
   add(self.items,object)
   self.count=self.count+1
  end
  o.del=function(self,object)
   del(self.items,object)
   self.count=self.count-1
  end
  setmetatable(o,self)
  self.__index=self
  return o
 end,

}

local bullets={
 create=function(self)
  local o=collection.create(self)
  return o
 end
} setmetatable(bullets,{__index=collection})

local enemies={
 create=function(self)
  local o=collection.create(self)
  return o
 end
} setmetatable(bullets,{__index=collection})

local explosions={
 create=function(self)
  local o=collection.create(self)
  return o
 end
} setmetatable(bullets,{__index=collection})

local particles={
 create=function(self)
  local o=collection.create(self)
  return o
 end
} setmetatable(particles,{__index=collection})

local object={
 create=function(self,x,y)
  local o={x=x,y=y}
  o.update=function(self,ps)
   -- do nothing
  end
  setmetatable(o,self)
  self.__index=self
  return o
 end,
 add_hitbox=function(self,w,h,x,y)
  x=x or 0
  y=y or 0
  self.hitbox={x=x,y=y,w=w,h=h,x2=x+w-1,y2=y+h-1}
 end
}

local movable={
 create=function(self,x,y,ax,ay)
  local o=object.create(self,x,y)
  o.ax=ax
  o.ay=ay
  o.dx=0
  o.dy=0
  o.min={dx=0.05,dy=0.05}
  o.max={dx=2,dy=2}
  return o
 end
} setmetatable(movable,{__index=object})

local controllable={
 create=function(self,x,y,ax,ay)
  local o=movable.create(self,x,y,ax,ay)
  return o
 end
} setmetatable(controllable,{__index=movable})

local cam={
 x=0,
 y=0,
 t=0,
 force=0,
 decay=0,
 shake=function(self,force,decay)
  self.force=force
  self.decay=decay
 end,
 update=function(self)
  if self.force==0 then return end
  self.angle=rnd()
  self.x=cos(self.angle)*self.force
  self.y=sin(self.angle)*self.force
  self.force=self.force*self.decay
  if self.force<0.1 then self.force=0 end
 end,
 position=function(self)
  return self.x,self.y
 end
}

function _init()
 b=bullets:create()
 e=enemies:create()
 x=explosions:create()
 p=controllable:create(64,100,0.2,0.2)
end

function _update60()
 cam:update()
 p:update() -- update player
 b:update() -- update bullets
 e:update() -- update enemies
 x:update() -- update explosions
 if rnd(20)>19.8 then cam:shake(rnd(5)+3,0.9) end
end

function _draw()
 cls()
 camera(cam:position())
 spr(1,64,64)
end


__gfx__
00000000888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
