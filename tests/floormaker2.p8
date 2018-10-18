pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--
-- by neil popham

canvas={width=128,height=32,x2=127,y2=31,ratio=4}
--canvas={width=240,height=136,x2=239,y2=135,ratio=2}

function extend(...)
 local o,arg={},{...}
 for _,a in pairs(arg) do
  for k,v in pairs(a) do o[k]=v end
 end
 return o
end

floormaker={
 create=function(self,params)
  params=params or {}
  local o={}
  o.t90=params.t90 or 0.1
  o.t180=params.t180 or 0.05
  o.x2=params.x2 or 0.2
  o.x3=params.x3 or 0.1
  o.limit=params.limit or 6
  o.new=params.new or 0.05
  o.life=params.life or 0.02
  o.angle=params.angle or 0
  o.x=params.x or flr(canvas.width/2)
  o.y=params.y or flr(canvas.height/2)
  o.total=params.total or 128
  o.params=extend(o)
  setmetatable(o,self)
  self.__index=self
  canvas.pow={
   x=max(3,flr(canvas.width/20)),
   y=max(3,flr(canvas.height/20))
  }
  return o
 end,
 run=function(self)
  self.complete=false
  self.threads={}
  self.cells={}
  self.count=0
  self.min={x=self.x,y=self.y}
  self.max={x=self.x,y=self.y}
  self:spawn()
  repeat
   for _,thread in pairs(self.threads) do
    local done=thread:update(self)
    if done then
     if #self.threads==1 then self:spawn() end
     del(self.threads,thread)
    end
   end
  until self.count>=self.total
  self.complete=true
  printh(self.min.x.."-"..self.max.x)
  printh(self.min.y.."-"..self.max.y)
  return self.cells
 end,
 spawn=function(self,params)
  add(self.threads,self:thread(params))
 end,
 thread=function(self,params)
  params=params or {}
  local o=extend(self.params,params)
  o.lx=1
  o.ly=1
  o.update=function(self,parent)
   self.lx=cos(self.angle)
   self.ly=-sin(self.angle)
   local cells={{0,0}}
   local added=0
   local done=false
   local t90=self.t90
   local da=0.25
   local m=0.5
   local n=0
   local t=0
   -- #1 if we're moving up or down then
   -- increase the chance (t90) to turn 90º
   -- as we need to stay wider than higher
   -- #2 if we're close to the edge of the canvas
   -- increase the chance (t90) to turn 90º
   -- and increase the chance (m)
   -- that the correct turn (da) is chosen
   if self.angle==0.25 or self.angle==0.75 then
    t90=t90*canvas.ratio
    n=min(self.y,canvas.y2-self.y)
    if n==0 then t=1 else t=2/n end
    t90=max(t90,t)
    m=max(0.5,(1-n/canvas.y2)^canvas.pow.y)
    if self.x<canvas.width/2 then
     da=self.angle-0.5
    else
     da=0.5-self.angle
    end
   else
    n=min(self.x,canvas.x2-self.x)
    if n==0 then t=1 else t=2/n end
    t90=max(t90,t)
    m=max(0.5,(1-n/canvas.x2)^canvas.pow.x)
    if self.y<canvas.height/2 then
     da=0.25-self.angle
    else
     da=self.angle-0.25
    end
   end
   -- change direction
   local r=rnd()
   if r<t90 then
    if rnd()<m then
     self.angle=self.angle+da
    else
     self.angle=self.angle-da
    end
   elseif r<t90+self.t180 then
    self.angle=self.angle+0.5
   end
   -- set new position
   self.angle=self.angle%1
   self.x=self.x+cos(self.angle)
   self.y=self.y-sin(self.angle)
   -- add room
   r=rnd()
   if r<self.x2 then
    cells=self:get_room(2)
   elseif r<self.x2+self.x3 then
    cells=self:get_room(3)
   end
   -- spawn new thread
   if #parent.threads<parent.limit then
    r=rnd()
    if r<self.new then
     local angle=self:get_angle()
     local m=parent:spawn({x=self.x,y=self.y,angle=angle})
    end
   end
   -- kill this thread
   r=rnd()
   if r<#parent.threads*self.life then
    done=true
   end
   -- kill this thread if we've strayed off canvas
   if self.x<0 or self.x>canvas.x2
    or self.y<0 or self.y>canvas.y2 then
    done=true
    cells={}
   end
   -- add the cells to the collection
   for _,cell in pairs(cells) do
    cell={self.x+cell[1],self.y+cell[2]}
    local index=self:get_index(cell)
    if parent.cells[index]==nil then
     parent.cells[index]=cell
     parent.count=parent.count+1
     if cell[1]<parent.min.x then
      parent.min.x = cell[1]
     elseif cell[1]>parent.max.x then
      parent.max.x = cell[1]
     end
     if cell[2]<parent.min.y then
      parent.min.y = cell[2]
     elseif cell[2]>parent.max.y then
      parent.max.y = cell[2]
     end
    end
   end
   -- return the thread's status
   return done
  end
  o.get_index=function(self,cell)
   return cell[2]*canvas.width+cell[1]
  end
  o.get_room=function(self,size)
   local dx=-self.lx
   local dy=-self.ly
   if self.x<size+4
    then dx=1
   elseif self.x>canvas.x2-size-4 then
    dx=-1
   end
   if self.y<size+4 then
    dy=1
   elseif self.y>canvas.y2-size-4 then
    dy=-1
   end
   local r={}
   for x=0,size-1 do
    for y=0,size-1 do
     add(r,{x*dx,y*dy})
    end
   end
   return r
  end
  o.get_angle=function(self)
   local a=flr(rnd(4))*0.25
   return a
  end
  return o
 end
}

function reset()
 maker=floormaker:create()
 cells=maker:run()
end

function _init()
 printh("==================")
 t=0
 reset()
end

function _update()
 t=t+1
 if t%60==0 then reset() end
end

function _draw()
 cls(1)
 line(0,32,127,32,2)
 line(0,16,16,16,3)
 line(16,0,16,16,3)
 dx=maker.max.x-maker.min.x
 dy=maker.max.y-maker.min.y
 if dx<14 then ox=flr(8-dx/2) else ox=1 end
 if dy<14 then oy=flr(8-dy/2) else oy=1 end
 for index,cell in pairs(cells) do
  pset(cell[1]-maker.min.x+ox,cell[2]-maker.min.y+oy,7)
  --pset(cell[1]+ox,cell[2]+oy,6)
 end
end
