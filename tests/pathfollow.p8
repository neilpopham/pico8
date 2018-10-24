pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- path follow
-- by neil popham

screen={width=128,height=128,x2=127,y2=127}
pad={left=0,right=1,up=2,down=3,btn1=4,btn2=5}

vec2={
 create=function(self,x,y)
  local o={x=x,y=y}
  setmetatable(o,self)
  self.__index=self
  return o
 end,
 distance=function(self,cell)
  local dx=cell.x-self.x
  local dy=cell.y-self.y
  local d=sqrt(dx^2+dy^2)
  return d>0 and d or 32727
 end,
 manhattan=function(self,cell)
  return abs(cell.x-self.x)+abs(cell.y-self.y)
 end,
 index=function(self)
  return self.y*16+self.x
 end
}

create_path={
 init=function(self)
  p={
   x=flr(screen.width/2),
   y=flr(screen.height/2),
   points={},
   radius=8
  }
 end,
 update=function(self)
  if btn(pad.left) then
   p.x=p.x-1
  elseif btn(pad.right) then
   p.x=p.x+1
  end
  if btn(pad.up) then
   p.y=p.y-1
  elseif btn(pad.down) then
   p.y=p.y+1
  end
  if btnp(pad.btn1) then
   add(p.points,vec2:create(p.x,p.y))
  end
  if btnp(pad.btn2) then
   if #p.points>1 then
    stage=follow_path
    stage:init()
   end
  end
 end,
 draw=function(self)
  circ(64,64,56,1)
  line(p.x-4,p.y,p.x+4,p.y,6)
  line(p.x,p.y-4,p.x,p.y+4,6)
  for i,pos in pairs(p.points) do
   line(pos.x-2,pos.y,pos.x+2,pos.y,5)
   line(pos.x,pos.y-2,pos.x,pos.y+2,5)
  end
 end
}

follow_path={
 t=0,
 b=true,
 init=function(self)
  self.t=0
  e={
   x=flr(rnd(screen.width)),
   y=flr(rnd(screen.height)),
   dx=0,
   dy=0,
   angle=0,
   force=0.5,
   current=1
  }
 end,
 update=function(self)
  local dx=p.points[e.current].x-e.x
  local dy=p.points[e.current].y-e.y
  e.angle=atan2(dx,-dy)

  e.dx=e.dx+cos(e.angle)*e.force
  e.dy=e.dy-sin(e.angle)*e.force
  e.dx=mid(-2,e.dx,2)
  e.dy=mid(-2,e.dy,2)
  e.force=min(2,sqrt((e.dx/4)^2+(e.dy/4)^2))
  printh(e.force)
  e.x=e.x+e.dx
  e.y=e.y+e.dy
  local pos=vec2:create(e.x,e.y)
  local d=pos:distance(p.points[e.current])
  if d<p.radius then
   printh("point")
   if e.current==#p.points then
    e.current=1
   else
    e.current=e.current+1
   end
  end
  if btnp(pad.btn1) then
   self.b=not self.b
  end
  if self.t>30 and btn(pad.btn2) then
   stage=create_path
   stage:init()
  end
  self.t=self.t+1
 end,
 draw=function(self)
  if self.b then
   for i=1,#p.points-1 do
    line(p.points[i].x,p.points[i].y,p.points[i+1].x,p.points[i+1].y,2)
   end
   for i,pos in pairs(p.points) do
    circ(pos.x,pos.y,p.radius,3)
   end
   local ax=e.x+cos(e.angle)*16
   local ay=e.y-sin(e.angle)*16
   line(e.x,e.y,ax,ay,9)
  end
  circ(e.x,e.y,3,8)
 end
}

function _init()
 stage=create_path
 stage:init()
end

function _update60()
 stage:update()
end

function _draw()
 cls()
 stage:draw()
end
