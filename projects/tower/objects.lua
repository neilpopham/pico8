vec2={
 create=function(self,x,y)
  local o=setmetatable({x=x,y=y},self)
  self.__index=self
  return o
 end,
 distance=function(self,target)
  local dx=(target.x+4)/1000-(self.x+4)/1000
  local dy=(target.y+4)/1000-(self.y+4)/1000
  return sqrt(dx^2+dy^2)*1000
 end,
 index=function(self)
  return self.y*25+self.x
 end
}
