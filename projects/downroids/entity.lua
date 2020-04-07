entity={
 create=function(self,x,y,angle,da,af)
  local o={
   x=x,
   y=y,
   da=da,
   af=af,
   angle=angle,
   force=0,
   dx=0,
   dy=0,
   df=0
  }
  setmetatable(o,self)
  self.__index=self
  return o
 end,
 update=function(self)
  self.force=self.force+self.df
  if abs(self.force)<0.04 then self.force=0 end
  self.force=mid(-3,self.force,3)
  self.dx=cos(self.angle)*self.force
  self.dy=-sin(self.angle)*self.force
 end,
 draw=function(self)
  circ(self.x,self.y,3,2)
 end,
 check_visibility=function(self)
  if self.x<8 or self.x>screen.width+8 or self.y<8 or self.y>screen.width+8 then
    self.complete=true
    printh("cv")
  end
 end
}
