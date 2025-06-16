collection={
 create=function(self)
  local o=setmetatable(
   {
    items={},
    count=0
   },
   self
  )
  self.__index=self
  return o
 end,
 add=function(self,item)
  add(self.items,item)
  self.count+=1
 end,
 remove=function(self,item)
  del(self.items,item)
  self.count-=1
 end,
 reset=function(self)
  self.items,self.count={},0
 end
}