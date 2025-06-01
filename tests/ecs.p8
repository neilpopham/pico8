pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- ecs
-- by neil popham

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

w=world:create()
c1=component:create(function(self,x,y) self.x=x self.y=y end)
c2=component:create(function(self,dx,dy,ax,ay) self.dx=dx self.dy=dy self.ax=ax self.ay=ay end)
e=entity:create()
--e:add(c1,10,10)
--e:add(c2,20,20,1,2)
e
 :add(c1,10,10)
 :add(c2,20,20,1,2)
 --:add(c1,100,100)
w:add_entity(e)

function _init()

end

function _update60()

end

function _draw()
 cls()
 local c1a=e:get(c1)
 local c2a=e:get(c2)
 print(c1a.x)
 print(c1a.y)
 print(c2a.dx)
 print(c2a.dy)
 print(c2a.ax)
 print(c2a.ay)
 print(w.entities.count)
end
