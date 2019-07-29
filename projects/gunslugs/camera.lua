cam={
 create=function(self,item,width,height)
  local o={
   target=item,
   x=item.x,
   y=item.y,
   buffer=16,
   min=8*flr(screen.width/16),
   force=0,
   decay=0,
   sx=0,
   sy=0
  }
  o.max=width-o.min
  setmetatable(o,self)
  self.__index=self
  return o
 end,
 update=function(self)
  local min_x = self.x-self.buffer
  local max_x = self.x+self.buffer
  if min_x>self.target.x then
   self.x=self.x+min(self.target.x-min_x,2)
  end
  if max_x<self.target.x then
   self.x=self.x+min(self.target.x-max_x,2)
  end
  --restrict to limits
  if self.x<self.min then
   self.x=self.min
  elseif self.x>self.max then
   self.x=self.max
  end
  --shake
  if self.force>0 then
   self.angle=self.angle and self.angle+0.34 or 0  
   self.sx+=cos(self.angle)*self.force
   self.sy+=sin(self.angle)*self.force
   self.force=self.force*self.decay
   if self.force<0.1 then
    self.force,self.decay,self.sx,self.sy=0,0,0,0
   end
  end
 end,
 position=function(self)
  return self.x-self.min
 end,
 map=function(self)
  camera(self:position()+self.sx,self.sy)
  map(0,0)
 end,
 shake=function(self,force,decay)
  self.force=min(self.force+force,5)
  self.decay=min(self.decay+decay,0.9)
 end,
}
