pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- hunting camera
-- by neil popham

function round(x) return flr(x+0.5) end

local pad={left=0,right=1,up=2,down=3,btn1=4,btn2=5}
local screen={width=128,height=128}

cam={
 create=function(self,item)
  local o={target=item,x=item.x,y=item.y,force=0,angle=0,distance=0,da=0.1,max={force=64}}
  o.min={x=8*flr(screen.width/16),y=8*flr(screen.height/16)}
  setmetatable(o,self)
  self.__index=self
  return o
 end,
 get_distance=function(self)
  local dx=self.target.x/1000-self.x/1000
  local dy=self.target.y/1000-self.y/1000
  --[[
  local dsq=dx^2+dy^2
  if dsq>0 then
   return sqrt(dsq)*1000
  elseif dsq==0 then
   return 0
  else
   return 32727
  end
  ]]
  return sqrt(dx^2+dy^2)*1000
 end,
 update=function(self)

  -- find out the vector between current position and target
  local dx=round(self.target.x-self.x)
  local dy=round(self.target.y-self.y)

  -- if we are at the target clear all values
  if dx==0 and dy==0 then
   self.x=self.target.x
   self.y=self.target.y
   self.force=0
   self.distance=0
   return
  end

  -- calculate straight line distance to the target
  local distance=self:get_distance()
  -- and the angle
  local angle=atan2(dx,-dy)

  -- if we are starting up then set the initial angle
  if self.force==0 then
   self.angle=angle--+(rnd()/10)
  end

  --accelerate
  self.force=self.force+0.1

  -- add our momentum to our current position
  self.x=self.x+cos(self.angle)*self.force
  self.y=self.y-sin(self.angle)*self.force

  -- if we are close to the target or getting further away also move toward it and decrease force
  if (distance<self.max.force and self.force>0.3) or (distance>self.distance) then
   self.x=self.x+cos(angle)*0.2
   self.y=self.y-sin(angle)*0.2
   self.force=self.force-0.2
  end

  -- if the angle to the traget is different to our current angle start turning toward the target
  local ea=1-self.angle -- difference between our angle and 0
  local ra=(ea+angle)%1 -- difference between our angle and the angle we need
  local da=abs(ra)
  if da<self.da then
   self.angle=angle
  elseif ra<0.5 then
   self.angle=self.angle+self.da
  else
   self.angle=self.angle-self.da
  end
  self.angle=self.angle%1

  self.force=min(self.max.force,max(0.1,self.force))
  self.distance=distance

  self.x=self.x+cos(self.angle)*self.force
  self.y=self.y-sin(self.angle)*self.force
 end,
 position=function(self)
  return self.x-self.min.x,self.y-self.min.y
 end,
 map=function(self)
  camera(self:position())
  map(0,0)
 end
}

function _init()

 printh("============")

 p={x=10,y=10}
 p.camera=cam:create(p)

 --create map
 for y=0,31 do
  for x=0,127 do
   mset(x,y,1)
   if x%8==0 then
    if y%8==0 then
     mset(x,y,3)
    elseif y%2==0 then
     mset(x,y,2)
    end
   end
  end
 end

end

function _update60()
 if btnp(pad.btn1) then
  p.x=flr(rnd(1024))
  p.y=flr(rnd(256))
  --p.x=flr(rnd(128))
  --p.y=flr(rnd(128))
 end

 p.camera:update()
end

--[[
camera hunting

camera has acceleration

start
finds difference between current pos and player pos
increases x/y using dx/dy which increases over time until a max

should try to decellerate at some point near the player so as not to be too silly
    this point will be dictated by the max speed and can be tweaked to make it more/less bouncy

]]

function _draw()
 cls()
 p.camera:map()
 spr(4,p.x,p.y)
 camera(0,0)
 print(p.x..","..p.y)
 --print(p.camera.min.x..","..p.camera.min.y)
 --print(p.camera.max.x..","..p.camera.max.y)
 print(p.camera.x..","..p.camera.y)
 print(p.camera.angle)
end

__gfx__
00000000111111111111111111111111eeeeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000100000001000000010000000eeeeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700100000001000200010003000eeeeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000100000001000200010003000eeeeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000100000001022222010333330eeeeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700100000001000200010003000eeeeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000100000001000200010003000eeeeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000100000001000000010000000eeeeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
