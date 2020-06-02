collection={
 create=function(self)
  local o={
   items={},
   count=0,
  }
  setmetatable(o,self)
  self.__index=self
  return o
 end,
 update=function(self)
  if self.count==0 then return end
  for _,i in pairs(self.items) do
   i:update()
  end
 end,
 draw=function(self)
  if self.count==0 then return end
  for _,i in pairs(self.items) do
   i:draw()
   if i.complete then self:del(i) end
  end
 end,
 add=function(self,object)
  add(self.items,object)
  self.count=self.count+1
 end,
 del=function(self,object)
  del(self.items,object)
  self.count=self.count-1
  del(entities,object)
 end,
 reset=function(self)
  self.items={}
  self.count=0
 end
}
