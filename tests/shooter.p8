pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- ping
-- by neil popham

local screen={width=128,height=128}

-- http://pico-8.wikia.com/wiki/btn
local pad={left=0,right=1,up=2,down=3,btn1=4,btn2=5}

-- https://github.com/nesbox/tic-80/wiki/key-map
-- local pad={left=2,right=3,up=0,down=1,btn1=4,btn2=5,btn3=6,btn4=7}

local dir={left=1,right=2,neutral=3}
local drag={air=0.75}

function round(x) return flr(x+0.5) end

function create_item(x,y)
 local i={
  x=x,
  y=y
 }
 return i
end

function create_moveable_item(x,y,ax,ay)
 local i=create_item(x,y)
 i.dx=0
 i.dy=0
 i.min={dx=0.05,dy=0.05}
 i.max={dx=2,dy=2}
 i.ax=ax
 i.ay=ay
 i.anim={
  init=function(self,stage,dir)
   -- record frame count for each stage dir
   for s in pairs(self.stage) do
    for d=1,3 do
     self.stage[s].dir[d].fcount=#self.stage[s].dir[d].frames
    end
   end
   -- init current values
   self.current:set(stage,dir)
  end,
  stage={},
  current={
   reset=function(self)
    self.frame=1
    self.tick=0
    self.loop=true
    self.transitioning=false
   end,
   set=function(self,stage,dir)
    if self.stage==stage then return end
    self.reset(self)
    self.stage=stage
    self.dir=dir or self.dir
   end
  },
  add_stage=function(self,name,ticks,loop,neutral,left,right,next)
   self.stage[name]=create_stage(ticks,loop,neutral,left,right,next)
  end
 }
 i.draw=function(self)
  sprite=self.animate(self)
  spr(sprite,self.x,self.y)
 end
 i.animate=function(self)
  local c=self.anim.current
  local s=self.anim.stage[c.stage]
  local d=s.dir[c.dir]
  if c.loop then
   c.tick=c.tick+1
   if c.tick==s.ticks then
    c.tick=0
    c.frame=c.frame+1
    if c.frame>d.fcount then
     if s.next then
      c:set(s.next)
      d=self.anim.stage[c.stage].dir[c.dir]
     elseif s.loop then
      c.frame=1
     else
      c.frame=d.fcount
      c.loop=false
     end
    end
   end
  end
  return s.dir[c.dir].frames[c.frame]
 end
 i.can_move_x=function(self,flag)
  local x=self.x+round(self.dx)
  if self.dx>0 then x=x+7 end
  for _,y in pairs({self.y,self.y+7}) do
   local tx=flr(x/8)
   local ty=flr(y/8)
   tile=mget(tx,ty)
   if fget(tile,0) or (flag and fget(tile,flag)) then
    return false
   end
  end
  return true
 end
 i.can_move_y=function(self)
  local y=self.y+round(self.dy)
  if self.dy>0 then y=y+7 end
  for _,x in pairs({self.x,self.x+7}) do
   local tx=flr(x/8)
   local ty=flr(y/8)
   tile=mget(tx,ty)
   if fget(tile,0) then
    return false
   end
  end
  return true
 end
 return i
end

function create_controllable_item(x,y,ax,ay)
 local i=create_moveable_item(x,y,ax,ay)
 i.update=function(self)
  -- horizontal movement
  if btn(pad.left) then
   self.anim.current.dir=dir.left
   self.dx=self.dx-self.ax
  elseif btn(pad.right) then
   self.anim.current.dir=dir.right
   self.dx=self.dx+self.ax
  else
   self.anim.current.dir=dir.neutral
   self.dx=self.dx*drag.air
  end
  self.dx=mid(-self.max.dx,self.dx,self.max.dx)
  if abs(self.dx)<self.min.dx then self.dx=0 end
  if self.dx~=0 then
   if self.can_move_x(self) then
    self.x=self.x+round(self.dx)
   end
  end
  -- vertical movement
  if btn(pad.up) then
   self.dy=self.dy-self.ay
  elseif btn(pad.down) then
   self.dy=self.dy+self.ay
  else
    self.dy=self.dy*drag.air
  end
  self.dy=mid(-self.max.dy,self.dy,self.max.dy)
  if abs(self.dy)<self.min.dy then self.dy=0 end
  if self.dy~=0 then
   if self.can_move_y(self) then
    self.y=self.y+round(self.dy)
   end
  end
 end
 return i
end

function create_stage(ticks,loop,neutral,left,right,next)
 local s={
  ticks=ticks,
  loop=loop,
  dir={{frames=left},{frames=right},{frames=neutral}},
  next=next
 }
 return s
end

function _init()
 p=create_controllable_item(64,100,0.2,0.2)
 p.fire=create_moveable_item(0,0,0,0)
 p.fire.anim:add_stage("core",5,true,{19},{19},{19})
 p.fire.anim:init("core",dir.neutral) 
 p.draw=function(self)
  sprite=self.animate(self)
  spr(sprite,self.x,self.y)
  if band(btn(),15)>0 then
   self.fire.x=self.x
   self.fire.y=self.y+8
   self.fire:draw()
  end
 end  
 p.anim:add_stage("core",1,false,{16},{17},{18})
 p.anim:init("core",dir.neutral)
end

function _update60()
	p:update()
end

function _draw()
	cls()
 p:draw()
 print("particle system",0,0)
 print("particle system",0,7)
 print("particle system",0,14)
 print("particle system",0,21)
 --circfill(64,64,26,5)
 circfill(64,64,25,4)
 circfill(64,64,24,9)
 circfill(63,63,20,10)
 circfill(62,62,15,7)
 --circfill(62,62,9,0)
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00056000000560000005600000a77a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
005dd600005dd66005ddd60009a77a90000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
505ddd06005ddd00005ddd00009a7a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
005bbd00053bd66005ddbbd00099a900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5053bd06003bdd6005ddbb0000099000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55533ddd0533dd6005dd3bd000090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5055550d05555d6005d555d000009000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5080080d05028dd0055820d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
