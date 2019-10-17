pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--
-- by Neil Popham

--[[
a={x=1,y=2,z=3}
b={m=10,n=20,o=30}
a.__index=a
setmetatable(b, a)
c={g=100,h=200,i=300}
b.__index=b
setmetatable(c, b)
print(b.x)
print(b.m)
print(c.y)
print(c.n)
print(c.h)
]]

parent={
 create=function(self,o)
  o=o or {}
  o.baz=12
  setmetatable(o,self)
  self.__index=self
  return o
 end,
 foo=function(self)
  return "foo "..self.x
 end,
 bar=function(self)
  return "bar"
 end
}

child={
 create=function(self,o)
  o=parent.create(self,o)
  setmetatable(o,self)
  self.__index=self
  return o
 end,
 bar=function(self)
  return parent:bar().." bar black sheep"
 end
} setmetatable(child,{__index=parent})

p=parent:create({x=1,y=2})
c=child:create({x=10,z=30})

printh(p:foo())
printh(c:foo())
printh(p:bar())
printh(c:bar())

printh(p.x)
printh(c.x)
printh(p.y)
printh(c.y)
printh(p.z)
printh(c.z)
printh(p.baz)
printh(c.baz)

--[[ output
INFO: foo 1
INFO: foo 10
INFO: bar
INFO: bar bar black sheep
INFO: 1
INFO: 10
INFO: 2
INFO: [nil]
INFO: [nil]
INFO: 30
INFO: 12
INFO: 12
]]
