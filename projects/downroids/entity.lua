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
   df=0,
   health=10
  }
  setmetatable(o,self)
  self.__index=self
  return o
 end,
 update=function(self,pos)
  self.force=self.force+self.df
  if abs(self.force)<0.2 then self.force=0 end
  self.force=mid(-3,self.force,3)
  self.dx=cos(self.angle)*self.force
  self.dy=-sin(self.angle)*self.force
  if pos then
   self.dx=self.dx-p.dx
   self.dy=self.dy-p.dy
   self.x=self.x+self.dx
   self.y=self.y+self.dy
  end
 end,
 draw=function(self)
  circ(self.x,self.y,3,2)
 end,
 --[[
 check_visibility=function(self)
  if self.x<8 or self.x>screen.width+8 or self.y<8 or self.y>screen.width+8 then
    self.complete=true
  end
 end,
 ]]
 distance=function(self,target)
  local dx=(target.x+4)/1000-(self.x+4)/1000
  local dy=(target.y+4)/1000-(self.y+4)/1000
  return sqrt(dx^2+dy^2)*1000
 end,
 adiff=function(self,angle)
  local da=self.angle-angle
  if da<0 then da=1+da end
  if da>0.5 then da=1-da end
  return da
 end,
 damage=function(self,value)
  self.health=self.health-value
  if self.health<1 then self.health=0 self:destroy() end
 end,
 destroy=function(self)
  self.complete=true
 end,
}
