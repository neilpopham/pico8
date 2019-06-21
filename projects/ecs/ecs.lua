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

component={
 create=function(self,populate)
  local o=setmetatable(
   {
    _populate=populate
   },
   self
  )
  self.__index=self
  return o
 end,
 init=function(self,...)
  local c=setmetatable({},self.__mt)
  self._populate(c,...)
  return c
 end
}

entity={
 create=function(self)
  local o=setmetatable(
   {
    components={}
   },
   self
  )
  self.__index=self
  return o
 end,
 add=function(self,component,...)
  local c=component:init(...)
  self.components[component]=c
  return self
 end,
 get=function(self,component)
  return self.components[component]
 end
}

system={
 create=function(self)
  local o=setmetatable(
   {

   },
   self
  )
  self.__index=self
  return o
 end
}

world={
 create=function(self)
  local o=setmetatable(
   {
    entities=collection:create(),
    systems=collection:create()
   },
   self
  )
  self.__index=self
  return o
 end,
 add_entity=function(self,entity)
  self.entities:add(entity)
  return self
 end,
 add_system=function(self,system)
  self.systems:add(system)
  return self
 end,
}
