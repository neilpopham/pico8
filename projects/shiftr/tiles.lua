local pane={
 create=function(self,tx,ty,mx,my,sx,sy)
 local o={x=sx,y=sy,map={x=mx,y=my},tile={x=tx,y=ty},new={x=sx,y=sy},d=0.5}
  setmetatable(o,self)
  self.__index=self
  return o
 end,
 reset=function(self)
  self.d=0.5
  self.sliding=false
  self.tile.y=self.y==0 and 1 or 2
  self.tile.x=self.x==0 and 1 or 2
 end,
 update=function(self)
  if self.sliding==false then return false end
  local x=self.x
  local y=self.y
  self.d=self.d*1.25
  if self.dir==pad.up then
   self.y=self.y-self.d
   if self.y<=self.new.y then
    self.y=self.new.y<0 and 64 or 0
    self:reset()
   end
  elseif self.dir==pad.down then
   self.y=self.y+self.d
   if self.y>=self.new.y then
    self.y=self.new.y>64 and 0 or 64
    self:reset()
   end
  elseif self.dir==pad.left then
   self.x=self.x-self.d
   if self.x<=self.new.x then
    self.x=self.new.x<0 and 64 or 0
    self:reset()
   end
  elseif self.dir==pad.right then
   self.x=self.x+self.d
   if self.x>=self.new.x then
    self.x=self.new.x>64 and 0 or 64
    self:reset()
   end
  end
  return true
 end,
 draw=function(self)
  map(self.map.x,self.map.y,self.x,self.y,8,8)
  if self.y<0 then
   map(self.map.x,self.map.y,self.x,self.y+128,8,8)
  elseif self.y>64 then
   map(self.map.x,self.map.y,self.x,self.y-128,8,8)
  elseif self.x<0 then
   map(self.map.x,self.map.y,self.x+128,self.y,8,8)
  elseif self.x>64 then
   map(self.map.x,self.map.y,self.x-128,self.y,8,8)
  end
 end
}

local tile={
 panes={},
 sliding=false,
 active=true,
 dir=0,
 x=0,
 y=0,
 split=function(self,dir,index)
  if self:disabled() then return end
  self.dir=dir or self.dir
  self.index=index or self.index
  self.queued=true
  printh("===")
  printh("split "..self.dir.." "..self.index.." "..p.x..","..p.y)
  for _,entity in pairs(entities) do
    printh(entity.paused and "paused" or "not paused")
    if not entity.paused then return end
  end
  printh("start slide")
  self.queued=false
  self.sliding=true
  for _,pane in pairs(self.panes) do
   if self.dir==pad.left or self.dir==pad.right then
    if pane.tile.y==self.index then
     pane.sliding=true
     pane.dir=self.dir
     pane.new.x=self.dir==pad.left and pane.x-64 or pane.x+64
    end
   else
    if pane.tile.x==self.index then
     pane.sliding=true
     pane.dir=self.dir
     pane.new.y=self.dir==pad.up and pane.y-64 or pane.y+64
    end
   end
  end
  for _,entity in pairs(entities) do
    entity:split(self.dir,self.index)
  end
 end,
 disabled=function(self)
  return self.sliding or not self.active -- or self.queued or not self.active
 end,
 init=function(self)
  for y=0,1 do
   for x=0,1 do
    local pane=pane:create(x+1,y+1,x*8,y*8,x*64,y*64)
    add(self.panes,pane)
   end
  end
 end,
 update=function(self)
  if self.queued then self:split() end
  if not self.sliding then return end
  local sliding=false
  for _,pane in pairs(self.panes) do
   if pane.sliding then
    sliding=pane:update() or sliding
   end
  end
  if not sliding then
    self.sliding=false
    for _,entity in pairs(entities) do
      entity.sliding=false
      --entity.paused=false
    end
  end
 end,
 draw=function(self)
  for _,pane in pairs(self.panes) do
   pane:draw()
  end
 end
}
