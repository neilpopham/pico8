vec2={
 create=function(self,x,y)
  local o=setmetatable({x=x,y=y},self)
  self.__index=self
  return o
 end,
 distance=function(self,target)
  local dx=target.x-self.x
  local dy=target.y-self.y
  return sqrt(dx^2+dy^2)
 end,
 index=function(self)
  return self.y*25+self.x
 end
}
