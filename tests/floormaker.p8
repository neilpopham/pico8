pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- floormaker
-- by neil popham

floormaker={
 makers={},
 tiles={},
 complete=false,
 drawn=0,
 create=function(self,params)
  params=params or {}
  local o={}
  o.t90=params.t90 or 0.2
  o.t180=params.t180 or 0.1
  o.x2=params.x2 or 0.05
  o.x3=params.x3 or 0.05
  o.max=params.max or 5
  o.new=params.new or 0.1
  o.angle=params.angle or 0
  o.x=params.x or 8
  o.y=params.y or 8
  o.total=params.total or 100
  o.processed=false
  setmetatable(o,self)
  self.__index=self
  return o
 end,
 spawn=function(self,x,y)
  add(self.makers,self:create({x=x,y=y}))

 end,
 process=function(self)
  --printh("process")
  local done=false
  local r=rnd()
  self.tiles={{0,0}}
  if r<self.t90 then
   if rnd()<0.5 then
    self.angle=self.angle-0.25
   else
    self.angle=self.angle+0.25
   end
  elseif r<self.t90+self.t180 then
   self.angle=self.angle+0.5
  end
  printh(self.x..","..self.y.." ->")
  self.angle=self.angle%1
  self.x=self.x+cos(self.angle)
  self.y=self.y-sin(self.angle)
  printh("<- "..self.x..","..self.y)
  r=rnd()
  if r<self.x2 then
   self.tiles={{0,0},{-1,0},{0,1},{-1,1}}
  elseif r<self.x2+self.x3 then
   self.tiles={{0,0},{-1,0},{-2,0},{0,1},{-1,1},{-2,1},{0,2},{-1,2},{-2,2}}
  end
  if #self.makers<self.max then
   r=rnd()
   if r<self.new then
    self:spawn(self.x,self.y)
   end
  end
  r=rnd()
  if r<#self.makers*0.05 then
   done=true
  end
  self.processed=true
  return done
 end,
 update=function(self)
  --printh("update:makers:"..#self.makers)
  if self.complete then return end
  --printh("here")
  for _,maker in pairs(self.makers) do
   local done=maker:process()
   if done then
    if not self.complete and #self.makers==1 then
     self:spawn(maker.x,maker.y)
    end
    del(self.makers,maker)
   end
  end
 end,
 draw=function(self)
  if self.complete then return end
  for m,maker in pairs(self.makers) do
   if maker.processed then
    printh("draw:tiles:"..#maker.tiles)
    for _,tile in pairs(maker.tiles) do
     printh(m..":"..(maker.x+tile[1])..","..(maker.y+tile[2]))
     spr(1,(maker.x+tile[1])*8,(maker.y+tile[2])*8)
     self.drawn=self.drawn+1
     --printh("drawn:"..self.drawn.." "..tile[1]..","..tile[2])
     if self.drawn==self.total then
      --printh("all drawn "..self.total)
      self.complete=true
      break
     end
    end
   end
  end
 end
}

function _init()
 maker=floormaker:create()
 maker:spawn()
 t=0
 cls()
end

function _update()
 t=t+1
 if t%10==0 then maker:update() end
end

function _draw()
 if t%10==0 then maker:draw() end
end

--[[
floormaker

% 90 -90 180

% 2x2

% 3x3

% spawn another
    # existing
    area

more floormakers more chance to die

whenever a floormaker turns 180 degrees, it spawns a weapon chest. whenever a floormaker destroys itself, it spawns an ammo chest. whenever the level is reaching its final size, floormakers spawn experience canisters.
after the level generation is done all but the furthest (with a bit of a random offset) chests of each type are removed.

max floors/tiles
--]]

__gfx__
00000000888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
