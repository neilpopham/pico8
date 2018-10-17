pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- floormaker
-- by neil popham

delay=2

--[[

map: 128x32 8-bit cels (+128x32 shared)

cell up from floor needs to be a wall
floor below wall needs shadow
if wall need to know area around to work out wall tile
 - if one cell wide
 - if corner of rectangle

 walls
  - if there's a floor below and above then i'm a special 1 height wall
  - if there's a floor left and right then i'm a special 1 width wall
  - if there is no wall to my left then i'm the bottom left corner
  - if there is no wall to my right then i'm the bottom right corner
  - if there's floor to my right

]]

function extend(...)
 local o,arg={},{...}
 for _,a in pairs(arg) do
  for k,v in pairs(a) do o[k]=v end
 end
 return o
end

function floormaker_defaults(params)
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
 return o
end

function create_floormaker(params)
 params=params or {}
 local o=floormaker_defaults(params)
 o.params=params
 o.makers={}
 o.closed={}
 o.drawn=0
 o.min={x=32727,y=32727}
 o.max={x=0,y=0}
 o.update=function(self)
  if self.complete then return true end
  printh("floormaker update")
  for key,value in pairs(self.makers) do
   local done=value:update(self)
   if done and #self.makers>1 then
    del(self.makers,value)
   end
  end
 end
 o.draw=function(self)
  if self.complete then return true end
  printh("floormaker draw")
  --[[
  for key,value in pairs(self.makers) do
   value:draw(self)
  end
  ]]
  for i,m in pairs(self.makers) do
   for _,tile in pairs(m.tiles) do
    local x=m.x+tile[1]
    local y=m.y+tile[2]
    --pset(64+x,64+y,8)
    --spr(1,(8+x)*8,(8+y)*8)
    rectfill(64+x*4,64+y*4,66+x*4,66+y*4,9) --7+i)
    if self.closed[x]==nil or not self.closed[x][y] then
     self.drawn=self.drawn+1
     if self.closed[x]==nil then
      self.closed[x]={}
     end
     self.closed[x][y]=true
     if x<self.min.x then self.min.x=x end
     if x>self.max.x then self.max.x=x end
     if y<self.min.y then self.min.y=y end
     if y>self.max.y then self.max.y=y end
    end
    if self.drawn==self.total then
     self.complete=true
     break
    end
   end
  end
 end
 o.spawn=function(self,params)
  params=params or {}
  local p=extend(self.params,params)
  local m=create_maker(p)
  add(self.makers,m)
  return m
 end
 o:spawn()
 return o
end

function create_maker(params)
 params=params or {}
 local o=floormaker_defaults(params)
 o.tiles={{0,0}}
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
  if self.x==-12 then self.angle=0 end
  if self.x==12 then self.angle=0.5 end
  if self.y==-12 then self.angle=0.25 end
  if self.y==12 then self.angle=0.75 end
  self.angle=self.angle%1
  self.x=self.x+cos(self.angle)
  self.y=self.y-sin(self.angle)
  r=rnd()
  if r<self.x2 then
   self.tiles={{0,0},{-1,0},{0,1},{-1,1}}
  elseif r<self.x2+self.x3 then
   self.tiles={{0,0},{-1,0},{-2,0},{0,1},{-1,1},{-2,1},{0,2},{-1,2},{-2,2}}
  end
  if #parent.makers<parent.limit then
   r=rnd()
   if r<self.new then
    local m=parent:spawn({x=self.x,y=self.y,angle=self.angle+0.5})
   end
  end
  r=rnd()
  if r<#parent.makers*self.life then
   done=true
  end
  return done
 end
 o.draw=function(self,parent)
  printh("maker draw")
 end
 return o
end

function _init()
 t=0
	reset()
end

function reset()
 printh("========================")
 maker=create_floormaker()
 cls(1)
end

function _update()
 t=t+1
 if t%delay==0 then maker:update() end
 if btn(4) then reset() end
end

function _draw()
 --rect(47,47,81,81,1)
 if t%delay==0 then
 	local done=maker:draw()
 	if done then
 		printh("done")
   for x=0,32 do
    for y=0,32 do
     --rectfill(x*4,y*4,2+x*4,2+y*4,8) --7+i)
     rectfill(x*4,y*4,4+x*4,3+y*4,8)
    end
   end
   for x,column in pairs(maker.closed) do
    for y,_ in pairs(column) do
     if type(maker.closed[x])=="table" and maker.closed[x][y-1] then
      --rectfill(64+x*4,64+y*4,66+x*4,66+y*4,6) --7+i)
      if maker.closed[x][y-2] then
       rectfill(64+x*4,64+y*4,67+x*4,67+y*4,6)
      else
       rectfill(64+x*4,64+y*4,67+x*4,65+y*4,13)
       rectfill(64+x*4,66+y*4,67+x*4,67+y*4,6)
      end
     else
      --rectfill(64+x*4,64+y*4,66+x*4,66+y*4,13) --7+i)
      --rectfill(64+x*4,64+y*4,66+x*4,65+y*4,2) --7+i)
      rectfill(64+x*4,64+y*4,67+x*4,65+y*4,2)
      rectfill(64+x*4,66+y*4,67+x*4,67+y*4,13)
     end
    end
   end
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

whenever a floormaker turns 180 degrees, it spawns a weapon chest.
whenever a floormaker destroys itself, it spawns an ammo chest.
whenever the level is reaching its final size, floormakers spawn experience canisters.
after the level generation is done all but the furthest (with a bit of a random offset) chests of each type are removed.

max floors/tiles
--]]

__gfx__
00000000888888886666666622222222dddddddd6666666600000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000888888886666666622222222dddddddd8666666600000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000888888886666666622222222dddddddd8666666600000000000000000000000000000000000000000000000000000000000000000000000000000000
000000008888888866666666222222226d6d6d6d8666666600000000000000000000000000000000000000000000000000000000000000000000000000000000
000000008888888866666666dddddddd666666668666666600000000000000000000000000000000000000000000000000000000000000000000000000000000
000000008888888866666666dddddddd666666668666666600000000000000000000000000000000000000000000000000000000000000000000000000000000
000000008888888866666666dddddddd666666668666666600000000000000000000000000000000000000000000000000000000000000000000000000000000
000000008888888866666666dddddddd666666666666666600000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001010101010102010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001030303030302030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001010101010102040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001030303030302020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001040404040402020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001010101010102020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001030303030302020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001040404040401010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
