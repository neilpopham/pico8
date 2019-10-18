pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- boids
-- by Neil Popham

function round(x)
 return flr(x+0.5)
end

separation={distance=5,strength=10}
alignment={distance=30,strength=100}
cohesion={distance=10,strength=100}

boid={
 create=function(self,x,y)
  local o=setmetatable(
   {
    x=x,
    y=y,
    angle=rnd(),
    strength=1+rnd()
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
 adiff=function(self,angle)
  return 0.5-(self.angle+0.5-angle)%1
 end,
 separation=function(self,s)
  local bdx,bdy=0,0
  for _,b in pairs(s) do
   local dx=b.x-self.x
   local dy=b.y-self.y
   local a=atan2(dx,-dy)
   local power=(separation.distance/b.d)*separation.strength
   bdx=bdx-cos(atan2(dx,-dy))*power
   bdy=bdy+sin(atan2(dx,-dy))*power
  end
  return atan2(bdx,bdy)
 end,
 alignment=function(self,a)
  local da=0
  for i,b in pairs(a) do
   da=da+self:adiff(b.angle)
  end
  da=da/#a
  return (self.angle+da)%1
 end,
 cohesion=function(self,c)
  local dx,dy=0,0
  for _,b in pairs(c) do
   dx=dx+b.x
   dy=dy+b.y
  end
  local bdx=dx/#c
  local bdy=dy/#c
  return atan2(bdx-self.x,bdy-self.y)
 end,
 update=function(self)
  local s,a,c,angle={},{},{},2
  for i,b in pairs(boids) do
   b.d=self:distance(b)
   if b.d>0 and b.d<separation.distance then
    add(s,b)
   end
   if b.d>0 and b.d<alignment.distance then
    add(a,b)
   end
   if b.d>0 and b.d<cohesion.distance then
    add(c,b)
   end
  end
  if #s>0 then
   angle=self:separation(s)
  else
   if #a>0 then
    angle=self:alignment(a)
   end
   if #c>0 then
    angle=self:cohesion(c)
   end
  end
  local adiff=angle<2 and self:adiff(angle) or 0
  self.angle=self.angle+adiff*0.25
  self.x=self.x+round(cos(self.angle)*self.strength)
  self.y=self.y-round(sin(self.angle)*self.strength)
  --self.x=self.x%128
  --self.y=self.y%128
  if self.x>127 then self.x=0 end
  if self.y>127 then self.y=0 end
  if self.x<0 then self.x=127 end
  if self.y<0 then self.y=127 end
 end,
 draw=function(self)
  line(self.x,self.y,self.x+(cos(self.angle)*3),self.y-(sin(self.angle)*3),9)
  circfill(self.x,self.y,1,5)
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
 --print(stat(0),0,0,7)
 --print(stat(1),0,10,7)
end
