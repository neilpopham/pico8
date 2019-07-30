cam={
 create=function(self,item,width,height)
  local o={
   target=item,
   x=item.x,
   y=item.y,
   buffer=12,
   min=40,
   force=0,
   sx=0,
   sy=0
  }
  o.max=width-88
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
  --calculate shake
  if self.force>0 then
   printh("shake force:"..self.force)
   self.sx=4-rnd(8)
   self.sy=4-rnd(8)
   self.sx*=self.force
   self.sy*=self.force
   self.force*=0.9
   if self.force<0.1 then
    self.force,self.sx,self.sy=0,0,0
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
 shake=function(self,force)
  self.force=min(self.force+force,6)
 end,
}
