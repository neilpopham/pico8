cam={
 create=function(self,item,width,height)
  local o={
   --map={w=width,h=height},
   target=item,
   x=item.x,
   y=item.y,
   buffer=16,
   min=8*flr(screen.width/16)
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
  if self.x<self.min then
   self.x=self.min
  elseif self.x>self.max then
   self.x=self.max
  end
 end,
 position=function(self)
  return self.x-self.min
 end,
 map=function(self)
  camera(self:position(),0)
  map(0,0)
 end
}
