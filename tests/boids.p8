pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- boids
-- by Neil Popham

function round(x)
 return flr(x+0.5)
end

separation={distance=8,strength=100}
alignment={distance=12,strength=100}
cohesion={distance=20,strength=100}

boid={
 create=function(self,x,y)
  local o=setmetatable(
   {
    x=x,
    y=y,
    angle=rnd()
   },
   self
  )
  self.__index=self
  return o
 end,
 distance=function(self,target)
  return abs(self.x-target.x)+abs(self.y-target.y)
  --if target==self then return 0 end
  --local dx=(target.x)/1000-(self.x)/1000
  --local dy=(target.y)/1000-(self.y)/1000
  --return sqrt(dx^2+dy^2)*1000
 end,
 adiff=function(self,target)
  --0.5-MOD(A26+0.5-$B$25,1)
  return 0.5-(self.angle+0.5-target.angle)%1
 end,
 update=function(self)
  local s,a,c={},{},{}

  for i,b in pairs(boids) do
   local d=self:distance(b)

   if d>0 and d<separation.distance then
    add(s,b)
   end
   if d>0 and d<alignment.distance then
    add(a,b)
   end
   if d>0 and d<cohesion.distance then
    add(c,b)
   end
  end

  local sdx,sdy=0,0
  local adx,ady=0,0
  local cdx,cdy=0,0

---[[
  if #s>0 then
   local dx,dy=0,0
   for _,b in pairs(s) do
    dx=dx+self.x-b.x
    dy=dy+self.y-b.y
   end
   da=atan2(dx,dy)
   sdx=cos(da) -- *separation.strength
   sdy=sin(da) -- *separation.strength
  end
--]]

---[[
  if #a>0 then
   local da=0
   for _,b in pairs(a) do
    da=da+b.angle
   end
   da=da/#a
   adx=cos(da)
   ady=sin(da)
  end
--]]

---[[
  if #c>0 then
   local dx,dy=0,0
   for _,b in pairs(a) do
    dx=dx+self.x-b.x
    dy=dy+self.y-b.y
   end
   da=atan2(-dx,-dy)
   cdx=cos(da)
   cdy=sin(da)
  end
--]]

  dx=sdx+adx+cdx+cos(self.angle)*1
  dy=sdy+ady+cdy-sin(self.angle)*1

  self.angle=atan2(dx,-dy)

  self.x=round(self.x+cos(self.angle)*1)
  self.y=round(self.y-sin(self.angle)*1)

  self.x=self.x%128
  self.y=self.y%128

  --if self.x<0 then self.x=128+self.x end
  --if self.x>127 then self.x=128-self.x end
  --if self.y<0 then self.y=128+self.y end
  --if self.y>127 then self.y=128-self.y end
 end,
 draw=function(self)
  circ(self.x,self.y,2,3)
  line(self.x,self.y,self.x+(cos(self.angle)*5),self.y-(sin(self.angle)*3),2)
  --print(flr(self.angle*100),self.x,self.y,12)
 end,
}


function _init()
 boids={}
 for i=1,40 do
  add(boids,boid:create(rnd(128),rnd(128)))
 end
end

function _update60()
 for _,b in pairs(boids) do
  b:update()
 end
end

function _draw()
 cls()
 for _,b in pairs(boids) do
  b:draw()
 end
 print(stat(0),0,0,7)
 print(stat(1),0,10,7)
end
