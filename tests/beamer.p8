pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- beamer
-- by neil popham

particle={
 create=function(self,params)
  params=params or {}
  params.life=params.life or {60,120}
  local o=params
  o.x=params.x
  o.y=params.y
  o.life=mrnd(params.life)
  o.complete=false
  --o=extend(o,{x=params.x,y=params.y,life=mrnd(params.life),complete=false}) 2 tokens more
  setmetatable(o,self)
  self.__index=self
  return o
 end,
 draw=function(self,fn)
  if self.life==0 then return true end
  self:_draw()
  self.life=self.life-1
  if self.life==0 then self.complete=true end
 end
}

spark={
 _draw=function(self)
  pset(self.x,round(self.y),self.col)
 end
} setmetatable(spark,{__index=particle})

affector={
 beamer=function(self)
  self.y-=self.dy
  if self.y<0 then
   self.complete=true
  elseif self.dy>1 then
   self.dy*=0.98
  end
 end
}

local beam={
 create=function(self,x,y,cols,count)
  for i=1,count do
   local s=spark:create(
    {
     x=x+rnd(7),
     y=y,
     col=cols[mrnd({1,#cols})],
     dy=mrnd({1,20},false),
     life={30,60}
    }
   )
   s.update=affector.beamer
   particles:add(s)
  end
 end
}

collection={
 create=function(self)
  local o={items={},count=0}
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
 end,
 reset=function(self)
  self.items={}
  self.count=0
 end
}

particle_collection={
 create=function(self)
  local o=collection.create(self)
  o.reset(self)
  return o
 end,
 reset=function(self)
  collection.reset(self)
  self:clear()
 end,
 clear=function(self)
  -- partial reset...
  -- we only need this object if we are using clear() ! otherwise just use collection
 end
} setmetatable(particle_collection,{__index=collection})

--local particles

function _init()
 particles=collection:create()
end

function _update60()
 if btnp(0) then
  --particles:add(beam:create(rnd(127),127,{1,2,3},20))
  beam:create(rnd(120),127,{7,3,11},20)
 end
 particles:update()
end

function _draw()
 cls()
 particles:draw()
end

function mrnd(x,f)
 if f==nil then f=true end
 local v=(rnd()*(x[2]-x[1]+(f and 1 or 0.0001)))+x[1]
 return f and flr(v) or flr(v*1000)/1000
end

function extend(t1,t2)
 for k,v in pairs(t2) do t1[k]=v end
 return t1
end

function round(x)
 return flr(x+0.5)
end