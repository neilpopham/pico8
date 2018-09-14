pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--
-- by neil popham

--[[
function extends(b)
 local c={}
 local c_mt={__index=c}
 function c:create()
  local i={}
  setmetatable(i,c_mt)
  return i
 end
 function c:class() return c end
 function c:super() return b end
 if b then setmetatable(c,{__index=b}) end
 return c
end

particle=extends(nil)
--[[
particle_mt={__index=particle}
function particle:create(x,y,colour,life)
 local i={}
 setmetatable(i,particle_mt)
 return i
end

function particle.create(self,x,y,colour,life)
 locali={
  x=x
  y=y
  colour=colour
  life=life
  max={life=life}
 }
 return i
end

spark=extends(particle)
function spark.create(self,x,y,colour,life,foo)
 self:super():create(self,x,y,colour,life)
 self.foo=foo
end
]]

--[[
function rand(min,max,floor)
  if floor==nil then floor=true end
  local value=(rnd()*(max-min))+min
  return floor and flr(value) or value
 end

particle={}
particle.__index=particle
function particle:create(x,y,ttl,col)
 local i={x=x,y=y,ttl=ttl,col=col,life=ttl}
 i.inx=function(self)
  self.x=self.x+1
 end
 setmetatable(i,self)
 self.__index = self
 return i
end
function particle:get_type()
 return "particle"
end
function particle:get_foo()
 return "bar"
end
function particle:incx()
 printh(self)
 self.x=self.x+1
end

spark={}
spark.__index=spark
setmetatable(spark,{__index=particle})
function spark:create(x,y,z)
 local i=particle:create(x,y)
 setmetatable(i,spark)
 i.z=z
 i.inx=function(self)
  self.x=self.x+1
 end
 return i
end
function spark:get_type()
 return "spark "..particle:get_type()
end
function spark.incx(self)
 particle:incx()
 self.x=self.x+1
end
]]


--[[
particle={}
particle.prototype={x=0,y=0,life=30,col=7}
setmetatable(particle, {__index=particle.prototype})
]]


particle={
 create=function(self,x,y)
  o={x=x,y=y}
  setmetatable(o,self)
  self.__index=self
  return o
 end,
 incx=function(self) -- called by both particle and spark (as super)
  self.x=self.x+1
  self.y=self.y+1
 end,
 get_type=function(self)
  return "particle" -- this will be overridden by spark
 end,
 get_foo=function(self)
  return "foo" -- spark doesn't have this function so this will be used
 end
}
--[[ could use this way
function particle:new(x,y)
  o={x=x,y=y}
  setmetatable(o,self)
  self.__index=self
  return o
end
]]
spark={
 create=function(self,x,y,z)
  o=particle.create(self,x,y)
  o.z=z
  return o
 end,
 incx=function(self)
  particle.incx(self)
  self.x=self.x+1
 end,
 get_type=function(self)
  return "spark"
 end
}
setmetatable(spark,{__index=particle})

function _init()
 p=particle:create(0,0)
 s=spark:create(0,0,20)
 s2=spark:create(0,0,30)
end

function _update()
 s:incx()
 p:incx()
 s2:incx()
end

function _draw()
 cls()
 print(s.x,0,0)
 print(s.y,0,10)
 print(s.z,0,20)
 print(s:get_type(),0,30)
 print(s:get_foo(),0,40)

 print(p.x,60,0)
 print(p.y,60,10)
 print(p.z,60,20)
 print(p:get_type(),60,30)
 print(p:get_foo(),60,40)

 print(s2.x,60,70)
 print(s2.y,60,80)
 print(s2.z,60,90)
 print(s2:get_type(),60,100)
 print(s2:get_foo(),60,110)

end
