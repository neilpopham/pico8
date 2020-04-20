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
 distance=function(self,target)
  local dx=(target.x+4)/1000-(self.x+4)/1000
  local dy=(target.y+4)/1000-(self.y+4)/1000
  return sqrt(dx^2+dy^2)*1000
 end,
 visible=function(self)
  local angle=atan2(self.x-64,64-self.y)
  if p.langle>p.rangle then
   return angle>=p.langle or angle<=p.rangle
  else
    return angle>=p.langle and angle<=p.rangle
  end
 end,
 damage=function(self,value)
  self.health=self.health-value
  if self.health<1 then self.health=0 self:destroy() end
 end,
 destroy=function(self)
  self.complete=true
 end,
}
