pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--
-- by neil popham

function extend(...)
 local o,arg={},{...}
 for _,a in pairs(arg) do
  for k,v in pairs(a) do o[k]=v end
 end
 return o
end

floormaker={
 create=function(self,params)
  params=params or {}
  local o={}
  o.t90=params.t90 or 0.1
  o.t180=params.t180 or 0.05
  o.x2=params.x2 or 0.01
  o.x3=params.x3 or 0.0075
  o.limit=params.limit or 6
  o.new=params.new or 0.25
  o.life=params.life or 0.02
  o.angle=params.angle or 0
  o.x=params.x or 0
  o.y=params.y or 0
  o.total=params.total or 128
  o.complete=false
  o.params=extend(o)
  o.threads={}
  o.cells={}
  o.count=0

  setmetatable(o,self)
  self.__index=self
  return o
 end,
 run=function(self)
  self:spawn()
  repeat
   for _,thread in pairs(self.threads) do
    local tiles=thread:update(self)
    self.count=self.count+tiles
   end
  until self.count>=self.total
 end
 spawn=function(self,params)
  add(self.threads,self:thread(params))
 end,
 thread=function(self,params)
  params=params or {}
  local o=extend(self.params,params)
  o.update=function(self,parent)
   printh("thread update")
  end
  o.draw=function(self,parent)
   printh("thread draw")
  end
  return o
 end
}

function _init()
 printh("==================")
 maker=floormaker:create()
 maker:run()
 t=0
 cls(1)
end

function _update()
 t=t+1
 if t%20==0 then maker:update() end
end

function _draw()
 if t%20==0 then maker:draw() end
end
