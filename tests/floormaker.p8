pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- floormaker
-- by neil popham

delay=1

--[[

map:    128x32 8-bit cels (+128x32 shared)
tic 80: 240x136

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

canvas={width=128,height=32,x2=127,y2=31,ratio=4}
--canvas={width=240,height=136,x2=239,y2=135,ratio=2}
--canvas={width=128,height=16,x2=127,y2=15,ratio=8}



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
 o.x2=params.x2 or 0.2
 o.x3=params.x3 or 0.1
 o.limit=params.limit or 6
 o.new=params.new or 0.1
 o.life=params.life or 0.02
 o.angle=params.angle or 0
 o.x=params.x or flr(canvas.width/2)
 o.y=params.y or flr(canvas.height/2)
 o.total=params.total or 512
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
  --printh("floormaker update")
  for key,value in pairs(self.makers) do
   local done=value:update(self)
   if done then
    if #self.makers==1 then self:spawn() end
    del(self.makers,value)
   end
  end
 end
 o.draw=function(self)
  if self.complete then return true end
  --printh("floormaker draw")
  --[[
  for key,value in pairs(self.makers) do
   value:draw(self)
  end
  ]]
  for i,m in pairs(self.makers) do
   for _,tile in pairs(m.tiles) do
    local x=m.x+tile[1]
    local y=m.y+tile[2]
    pset(x,y,9)
    --spr(1,(8+x)*8,(8+y)*8)
    --rectfill(64+x*4,64+y*4,66+x*4,66+y*4,9) --7+i)

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

     if (self.closed[x+1]~=nill and self.closed[x+1][y])
      or (self.closed[x-1]~=nill and self.closed[x-1][y])
      or (self.closed[x][y+1])
      or (self.closed[x][y-1]) then
     -- ok
     else
      assert(true,"oh crap")
     end
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
 canvas.pow={
  x=max(3,flr(canvas.width/20)),
  y=max(3,flr(canvas.height/20))
 }
 return o
end

function create_maker(params)
 params=params or {}
 local o=floormaker_defaults(params)
 o.tiles={{0,0}}
 o.lx=1
 o.ly=1
 o.update=function(self,parent)
  --printh("maker update")

  local done=false
  local t90=self.t90
  local da=0.25
  local m=0.5
  local n=0
  local t=0

  self.tiles={{0,0}}
  self.lx=cos(self.angle)
  self.ly=-sin(self.angle)

  -- #1 if we're moving up or down then
  -- increase the chance (t90) to turn 90º
  -- as we need to stay wider than higher
  -- #2 if we're close to the edge of the canvas
  -- increase the chance (t90) to turn 90º
  -- and increase the chance (m)
  -- that the correct turn (da) is chosen
  if self.angle==0.25 or self.angle==0.75 then
   t90=t90*canvas.ratio
   n=min(self.y,canvas.y2-self.y)
   if n==0 then t=1 else t=2/n end
   t90=max(t90,t)
   m=max(0.5,(1-n/canvas.y2)^canvas.pow.y)
   if self.x<canvas.width/2 then
    da=self.angle-0.5
   else
    da=0.5-self.angle
   end
  else
   n=min(self.x,canvas.x2-self.x)
   if n==0 then t=1 else t=2/n end
   t90=max(t90,t)
   m=max(0.5,(1-n/canvas.x2)^canvas.pow.x)
   if self.y<canvas.height/2 then
    da=0.25-self.angle
   else
    da=self.angle-0.25
   end
  end

  printh(self.angle..","..t..","..t90..","..n..","..m..","..da..","..self.x..","..self.y,"floormaker.csv")

  -- #####################################################
  if m>0.5 or t90>0.1 then
   if self.x<3 or self.x>124 or self.y<3 or self.y>29 then
    printh("a:"..self.angle.." t90:"..t90.." m:"..m.." da:"..da.." x:"..self.x.." y:"..self.y)
   end
  end
  -- #####################################################

  local r=rnd()
  if r<t90 then
   if rnd()<m then
    self.angle=self.angle+da
   else
    self.angle=self.angle-da
   end
  elseif r<t90+self.t180 then
   self.angle=self.angle+0.5
  end

  local ox=self.x -- ##################
  local oy=self.y -- ##################

  self.angle=self.angle%1
  self.x=self.x+cos(self.angle)
  self.y=self.y-sin(self.angle)

  local dx=abs(self.x-ox) -- ##################
  local dy=abs(self.y-oy) -- ##################
  assert(dx+dy<=1,"we jumped") -- ##################

  r=rnd()
  if r<self.x2 then
   self.tiles=self:get_room(2)
  elseif r<self.x2+self.x3 then
   self.tiles=self:get_room(3)
  end

  if #parent.makers<parent.limit then
   r=rnd()
   if r<self.new then
    local angle=self:get_angle()
    local m=parent:spawn({x=self.x,y=self.y,angle=angle})
   end
  end

  r=rnd()
  if r<#parent.makers*self.life then
   done=true
  end

  if self.x<=0 then
   self.x=0
   done=true
   self.tiles={}
  elseif self.x>=canvas.x2 then
   self.x=canvas.x2
   done=true
   self.tiles={}
  end
  if self.y<=0 then
   self.y=0
   done=true
   self.tiles={}
  elseif self.y>=canvas.y2 then
   self.y=canvas.y2
   done=true
   self.tiles={}
  end

  return done
 end
 o.get_room=function(self,size)
  local dx=-self.lx
  local dy=-self.ly
  if self.x<size+4
   then dx=1
  elseif self.x>canvas.x2-size-4 then
   dx=-1
  end
  if self.y<size+4 then
   dy=1
  elseif self.y>canvas.y2-size-4 then
   dy=-1
  end
  local r={}
  for x=0,size-1 do
   for y=0,size-1 do
    add(r,{x*dx,y*dy})
   end
  end
  return r
 end
 o.get_angle=function(self)
  --[[
  local b={}
  if self.x<4 then
   add(b,0.5)
  elseif self.x>canvas.x2-4 then
   add(b,0)
  end
  if self.y<4 then
   add(b,0.75)
  elseif self.y>canvas.y2-4 then
   add(b,0.25)
  end
  local a
  local f
  repeat
   f=false
   a=flr(rnd(4))*0.25
   for _,ba in pairs(b) do
    if ba==a then f=true break end
   end
  until f==false
  ]]
  local a=flr(rnd(4))*0.25
  return a
 end
 o.draw=function(self,parent)
  --printh("maker draw")
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

function _update60()
 t=t+1
 --if t%delay==0 then maker:update() end
 maker:update()
 if btn(4) then reset() end
end

function _draw()
 line(0,32,127,32,2)
 --if t%delay==0 then
 	local done=maker:draw()
 	if done then
 		printh("done")
   --[[
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
   ]]
 		reset()
 	end
 --end
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
