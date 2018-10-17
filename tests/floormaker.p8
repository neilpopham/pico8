pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- floormaker
-- by neil popham

function floormaker_defaults(params)
 params=params or {}
 local o={}
 o.t90=params.t90 or 0.2
 o.t180=params.t180 or 0.1
 o.x2=params.x2 or 0.1
 o.x3=params.x3 or 0.075
 o.max=params.max or 8
 o.new=params.new or 0.25
 o.angle=params.angle or 0
 o.x=params.x or 64
 o.y=params.y or 64
 o.total=params.total or 128
 o.complete=false
 return o
end

function create_floormaker(params)
 params=params or {}
 local o=floormaker_defaults(params)
 o.makers={}
 o.update=function(self)
  printh("floormaker update")
  for key,value in pairs(self.makers) do
   value:update(self)
  end
 end
 o.draw=function(self)
  printh("floormaker draw")
  for key,value in pairs(self.makers) do
   value:draw(self)
  end
 end
 o.spawn=function(self,params)
  add(self.makers,create_maker(params))
 end
 o:spawn(params)
 return o
end

function create_maker(params)
 params=params or {}
 local o=floormaker_defaults(params)
 o.update=function(self,parent)
  printh("maker update")
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
  if self.x<=48 then self.angle=0 end
  if self.x>=80 then self.angle=0.5 end
  if self.y<=48 then self.angle=0.25 end
  if self.y>=80 then self.angle=0.75 end      
  --printh(self.x..","..self.y.." ->")
  --self.angle=self.angle%1
  self.x=self.x+cos(self.angle)
  self.y=self.y-sin(self.angle)
  if self.x<48 then self.x=48 end
  if self.x>80 then self.x=80 end
  if self.y<48 then self.y=48 end
  if self.y<44 then self.y=80 end
  --printh("<- "..self.x..","..self.y)
  r=rnd()
  if self.x>52 and self.x<76 and self.y>52 and self.y<76 then
   if r<self.x2 then
    self.tiles={{0,0},{-1,0},{0,1},{-1,1}}
   elseif r<self.x2+self.x3 then
    self.tiles={{0,0},{-1,0},{-2,0},{0,1},{-1,1},{-2,1},{0,2},{-1,2},{-2,2}}
   end
  end
  if #parent.makers<parent.max then
   r=rnd()
   if r<self.new then
    parent:spawn({
     x=self.x,
     x=self.y,
     angle=self.angle+0.5
    })
   end
  end
  r=rnd()
  if r<#parent.makers*0.02 then
   done=true
  end
  self.processed=true
  return done
 end
 o.draw=function(self,parent)
  printh("maker draw")
 end
 return o
end

floormaker={
 get_defaults=function(self,params)
  local o={}
  o.t90=params.t90 or 0.2
  o.t180=params.t180 or 0.1
  o.x2=params.x2 or 0.1
  o.x3=params.x3 or 0.075
  o.max=params.max or 8
  o.new=params.new or 0.5
  o.angle=params.angle or 0
  o.x=params.x or 64
  o.y=params.y or 64
  o.total=params.total or 128
  o.complete=false
  return o
 end,
 create=function(self,params)
  params=params or {}
  local o=self:get_defaults(params)
  o.makers={}
  setmetatable(o,self)
  self.__index=self
  return o
 end,
 spawn=function(self)
  add(self.makers,maker:create())
 end,
 update=function(self)
  if self.complete then return end
  for _,m in pairs(self.makers) do
   printh("here2")
   local done=m:update(self)
   if done and #self.makers>1 then
    del(self.makers,m)
   end
  end
 end,
 draw=function(self)
  if self.complete then return end
  for _,m in pairs(self.makers) do
  printh(type(m))
  	printh(type(m.tiles))
   for _,tile in pairs(m.tiles) do
    local x=m.x+tile[1]
    local y=m.y+tile[2]
    pset(x,y,8)
    if self.closed[x]==nil or not self.closed[x][y] then
     self.drawn=self.drawn+1
     if self.closed[x]==nil then
      self.closed[x]={}
     end
     self.closed[x][y]=true
    end
    if self.drawn==self.total then
     self.complete=true
     break
    end
   end
  end
 end
}

maker={
 create=function(self,params)
  params=params or {}
  local o=floormaker:get_defaults(params)
  o.tiles={}
  setmetatable(o,self)
  self.__index=self
  return o
 end,
 update=function(self,parent)
 printh("update")
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
  if self.x<=48 then self.angle=0 end
  if self.x>=80 then self.angle=0.5 end
  if self.y<=48 then self.angle=0.25 end
  if self.y>=80 then self.angle=0.75 end      
  --printh(self.x..","..self.y.." ->")
  --self.angle=self.angle%1
  self.x=self.x+cos(self.angle)
  self.y=self.y-sin(self.angle)
  if self.x<48 then self.x=48 end
  if self.x>80 then self.x=80 end
  if self.y<48 then self.y=48 end
  if self.y<44 then self.y=80 end
  --printh("<- "..self.x..","..self.y)
  r=rnd()
  if self.x>52 and self.x<76 and self.y>52 and self.y<76 then
   if r<self.x2 then
    self.tiles={{0,0},{-1,0},{0,1},{-1,1}}
   elseif r<self.x2+self.x3 then
    self.tiles={{0,0},{-1,0},{-2,0},{0,1},{-1,1},{-2,1},{0,2},{-1,2},{-2,2}}
   end
  end
  if #parent.makers<parent.max then
   r=rnd()
   if r<self.new then
    parent:spawn({
     x=self.x,
     x=self.y,
     angle=self.angle+0.5
    })
   end
  end
  r=rnd()
  if r<#parent.makers*0.02 then
   done=true
  end
  self.processed=true
  return done
 end,
 draw=function(self,parent)
 end
} setmetatable(maker,{__index=floormaker})

--[[
floormaker={
	makers={},
 create=function(self,params)
  params=params or {}
  local o={}
  o.t90=params.t90 or 0.2
  o.t180=params.t180 or 0.1
  o.x2=params.x2 or 0.1
  o.x3=params.x3 or 0.075
  o.max=params.max or 8
  o.new=params.new or 0.5
  o.angle=params.angle or 0
  o.x=params.x or 64
  o.y=params.y or 64
  o.total=params.total or 128
		--o.makers={}
 	o.tiles={}
 	o.closed={}
 	o.complete=false
 	o.drawn=0
  o.processed=false
  setmetatable(o,self)
  self.__index=self
  return o
 end,
 spawn=function(self,params)
  add(self.makers,self:create(params))
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
  if self.x<=48 then self.angle=0 end
  if self.x>=80 then self.angle=0.5 end
  if self.y<=48 then self.angle=0.25 end
  if self.y>=80 then self.angle=0.75 end      
  --printh(self.x..","..self.y.." ->")
  --self.angle=self.angle%1
  self.x=self.x+cos(self.angle)
  self.y=self.y-sin(self.angle)
  if self.x<48 then self.x=48 end
  if self.x>80 then self.x=80 end
  if self.y<48 then self.y=48 end
  if self.y<44 then self.y=80 end
  --printh("<- "..self.x..","..self.y)
  r=rnd()
  if self.x>52 and self.x<76 and self.y>52 and self.y<76 then
 	 if r<self.x2 then
  	 self.tiles={{0,0},{-1,0},{0,1},{-1,1}}
  	elseif r<self.x2+self.x3 then
   	self.tiles={{0,0},{-1,0},{-2,0},{0,1},{-1,1},{-2,1},{0,2},{-1,2},{-2,2}}
  	end
  end
  if #self.makers<self.max then
   r=rnd()
   if r<self.new then
    self:spawn({
    	x=self.x,
    	x=self.y,
    	angle=self.angle+0.5
    })
   end
  end
  r=rnd()
  if r<#self.makers*0.02 then
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
   if done and #self.makers>1 then
    del(self.makers,maker)
   end
  end
 end,
 draw=function(self)
  if self.complete then return true end
  for m,maker in pairs(self.makers) do
   if maker.processed then
    --printh("draw:tiles:"..#maker.tiles)
    for _,tile in pairs(maker.tiles) do
     --printh(m..":"..(maker.x+tile[1])..","..(maker.y+tile[2]))
     --spr(1,(maker.x+tile[1])*8,(maker.y+tile[2])*8)
     local x=maker.x+tile[1]
     local y=maker.y+tile[2]
     pset(x,y,8)
     if self.closed[x]==nil or not self.closed[x][y] then
     	self.drawn=self.drawn+1
     	if self.closed[x]==nil then
     		self.closed[x]={}
     	end
     	self.closed[x][y]=true
     end
     --printh("drawn:"..self.drawn.." "..tile[1]..","..tile[2])
     if self.drawn==self.total then
      --printh("all drawn "..self.total)
      self.complete=true
      break
     end
    end
   end
  end
  return false
 end
}
]]

function _init()
	t=0
	reset()
end

function reset()
 maker=create_floormaker()
 --maker:spawn()
 cls()
end

function _update()
 t=t+1
 if t%30==0 then maker:update() end
end

function _draw()
 rect(47,47,81,81,1)
 if t%30==0 then
 	local done=maker:draw()
 	if done then
 		--print("done",0,0,9)
 		--reset()
 	end
 end
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
