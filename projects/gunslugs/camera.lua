cam={
 create=function(self,item,width,height)
  local o={
   --map={w=width,h=height},
   target=item,
   x=item.x,
   y=item.y,
   buffer={x=16,y=16},
   min={x=8*flr(screen.width/16),y=8*flr(screen.height/16)}
  }
  o.max={x=width-o.min.x,y=height-o.min.y,shift=2}
  setmetatable(o,self)
  self.__index=self
  return o
 end,
 update=function(self)
  local min_x = self.x-self.buffer.x
  local max_x = self.x+self.buffer.x
  local min_y = self.y-self.buffer.y
  local max_y = self.y+self.buffer.y
  if min_x>self.target.x then
   self.x=self.x+min(self.target.x-min_x,self.max.shift)
  end
  if max_x<self.target.x then
   self.x=self.x+min(self.target.x-max_x,self.max.shift)
  end
  if min_y>self.target.y then
   self.y=self.y+min(self.target.y-min_y,self.max.shift)
  end
  if max_y<self.target.y then
   self.y=self.y+min(self.target.y-max_y,self.max.shift)
  end
  if self.x<self.min.x then
   self.x=self.min.x
  elseif self.x>self.max.x then
   self.x=self.max.x
  end
  if self.y<self.min.y then
   self.y=self.min.y
  elseif self.y>self.max.y then
   self.y=self.max.y
  end
 end,
 position=function(self)
  return self.x-self.min.x,self.y-self.min.y
 end,
 map=function(self)
  camera(self:position())
  map(0,0)
 end
}