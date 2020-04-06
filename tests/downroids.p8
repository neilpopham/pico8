pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--
-- by Neil Popham

screen={width=128,height=128,x2=127,y2=127}
pad={left=0,right=1,up=2,down=3,btn1=4,btn2=5}

stars={}
p={}

collection={
 create=function(self)
  local o={
   items={},
   count=0,
  }
  setmetatable(o,self)
  self.__index=self
  return o
 end,
 update=function(self)
  if self.count==0 then return end
  for _,i in pairs(self.items) do
   i:update()
   if i.complete then self:del(i) end
  end
 end,
 draw=function(self)
  if self.count==0 then return end
  for _,i in pairs(self.items) do
   i:draw()
  end
 end,
 add=function(self,object)
  add(self.items,object)
  self.count+=1
 end,
 del=function(self,object)
  del(self.items,object)
  self.count-=1
 end,
 reset=function(self)
  self.items={}
  self.count=0
 end
}

bullet={
 create=function(self,x,y,angle)
  local o={
   x=x,
   y=y,
   angle=angle,
   force=3,
   dx=0,
   dy=0
  }
  setmetatable(o,self)
  self.__index=self
  return o
 end,
 update=function(self)
  self.dx=cos(self.angle)*self.force
  self.dy=-sin(self.angle)*self.force
  self.x=self.x+self.dx
  self.y=self.y+self.dy
 end,
 draw=function(self)
  circ(self.x,self.y,3,2)
 end
}

function _init()
 local depths={1,0.7,0.5,0.3}
 local colours={7,13,5,1}
 local fades={13,1,0,0}
 srand(0.2074)
 for x=0,79 do
  local i=1+flr(x/20)
  add(
   stars,
   {
    x=rnd(screen.x2),
    y=rnd(screen.y2),
    col=colours[i],
    depth=depths[i],
    col2=fades[i]
   }
  )
 end
 srand()
 bullets=collection:create()
 p={x=flr(screen.width/2),y=flr(screen.height/2),angle=0,force=0,dx=0,dy=0,da=0.02,df=0,af=0.0125}
end

function _update60()
 -- rotation
 if btn(pad.left) then
  p.angle=p.angle-p.da
 elseif btn(pad.right) then
  p.angle=p.angle+p.da
 end
 p.angle=p.angle%1
 -- thrust


 if btn(pad.btn1) then
  p.angle=0
 end
 if btn(pad.btn2) then
  p.df=p.df+4
  bullets:add(bullet:create(p.x,p.y,(p.angle+0.5)%1))
 end

 bullets:update()


 if btn(pad.btn1) or btn(pad.up) then
   p.df=p.df+p.af
 elseif btn(pad.btn2) or btn(pad.down) then
   p.df=p.df-p.af
 else
  p.df=0
  p.force=p.force*0.95
 end
 p.force=p.force+p.df
 if abs(p.force)<0.04 then p.force=0 end
 p.force=mid(-6,p.force,6)
 -- set ship movement
 p.dx=cos(p.angle)*p.force
 p.dy=-sin(p.angle)*p.force
 --move stars according to ship speed and their depth
 for _,star in pairs(stars) do
  star.x=star.x-p.dx*star.depth
  if star.x<0 then
   star.x=screen.x2+star.x
  end
  if star.x>screen.x2 then
   star.x=star.x-screen.x2
  end
  star.y=star.y-p.dy*star.depth
  if star.y<0 then
   star.y=screen.y2+star.y
  end
  if star.y>screen.y2 then
   star.y=star.y-screen.y2
  end
 end
end

function _draw()
 cls()
 bullets:draw()
 -- if we're going fast draw a trail
 if abs(p.force)>3 then
  local i=1
  while stars[i].depth>0.5 do
   line(
    stars[i].x,
    stars[i].y,
    stars[i].x+p.dx*abs(p.force)/3*stars[i].depth,
    stars[i].y+p.dy*abs(p.force)/3*stars[i].depth,
    stars[i].col2
   )
   i=i+1
  end
 end
 -- draw the stars
 for _,star in pairs(stars) do
  pset(star.x,star.y,star.col)
 end
 -- draw the ship trail
 line(p.x,p.y,p.x-p.dx,p.y-p.dy,9)
 pset(p.x,p.y,8)
 -- draw the ship
 --[[
 local len=5
 local ang=0.37
 local col=2
 local tx=p.x+cos(p.angle)*len
 local ty=p.y-sin(p.angle)*len
 local lx=p.x+cos(p.angle-ang)*len
 local ly=p.y-sin(p.angle-ang)*len
 local rx=p.x+cos(p.angle+ang)*len
 local ry=p.y-sin(p.angle+ang)*len
 line(tx,ty,lx,ly,col)
 line(tx,ty,rx,ry,col)
 line(rx,ry,lx,ly,col)
 ]]
 circ(p.x,p.y,2,3)
end
