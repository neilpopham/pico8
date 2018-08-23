pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- create_item
-- by neil popham

local dir={left=1,right=2}
local drag={air=1,ground=0.8,gravity=0.15}

-- http://pico-8.wikia.com/wiki/btn
local pad={l=0,r=1,u=2,d=3,b1=4,b2=5}

-- pad_left=0 pad_right=1 pad_up=2 pad_down=3 pad_b1=4 pad_b2=5

-- https://github.com/nesbox/tic-80/wiki/key-map
-- local pad={l=2,r=3,u=0,d=1,b1=4,b2=5,b3=6,b4=7}

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
 i.min={dx=0.05,dy=0.05,btn=5} 
 i.max={dx=1,dy=2,btn=15}
 i.ax=ax
 i.ay=ay
 i.is={grounded=true}
 i.anim={
  init=function(self,stage,face)
   -- record frame count for each stage face
   for s in pairs(self.stage) do
    for f=1,2 do
     self.stage[s].face[f].fcount=#self.stage[s].face[f].frames
    end
   end
   -- init current values
   self.current:set(stage,face)
  end,
  stage={},
  current={ 
   reset=function(self)
    self.frame=1
    self.tick=0
    self.loop=true
   end,
   set=function(self,stage,face)
    self.reset(self)
    self.stage=stage
    self.face=face or self.face
   end
  },
  add_stage=function(self,name,ticks,loop,left,right,next)
   self.stage[name]=create_stage(ticks,loop,left,right,next)
  end
 }
 i.draw=function(self)
  sprite=self.animate(self)
  spr(sprite,self.x,self.y)
 end
 i.animate=function(self)
  local current=self.anim.current
  local stage=self.anim.stage[current.stage]
  local face=stage.face[current.face]
  if current.loop then
   current.tick=current.tick+1
   if current.tick==stage.ticks then
    current.tick=0
    current.frame=current.frame+1
    if current.frame>face.fcount then
     if stage.next then
      current:set(stage.next)
      face=self.anim.stage[current.stage].face[current.face]
     elseif stage.loop then
      current.frame=1
     else
      current.frame=face.fcount
      current.loop=false
     end
    end
   end 
  end
  return face.frames[current.frame]
 end 
 return i
end

function create_controllable_item(x,y,ax,ay)
 local i=create_moveable_item(x,y,ax,ay)
 i.update=function(self)
  local face=self.anim.current.face
  local stage=self.anim.current.stage

  local check=function(anim,stage,face)
   if face~=anim.current.face then
    if stage=="still" then stage="walk" end
    anim.current:set(stage.."_turn")
   elseif stage=="still" then
    anim.current:set("walk")
   end
  end

  -- horizontal movement
  if btn(pad.l) then
   self.anim.current.face=dir.left
   check(self.anim,stage,face)
   p.dx=p.dx-p.ax
  elseif btn(pad.r) then
   self.anim.current.face=dir.right
   check(self.anim,stage,face)
   p.dx=p.dx+p.ax
  else
   if p.is.grounded then
    self.anim.current:set("still")
    p.dx=p.dx*drag.ground
   else
    p.dx=p.dx*drag.air
   end   
  end
  p.dx=mid(-p.max.dx,p.dx,p.max.dx)
  if abs(p.dx)<p.min.dx then p.dx=0 end
  p.x=p.x+round(p.dx)

  -- vertical movement

 end
 return i
end

function create_stage(ticks,loop,left,right,next)
 local s={
  ticks=ticks,
  loop=loop,
  face={{frames=left},{frames=right}},
  next=next
 }
 return s
end

function _init()
 p=create_controllable_item(63,63,0.05,-1.75)
 p.anim:add_stage("still",1,false,{5},{11})
 p.anim:add_stage("walk",5,true,{0,1,2,3,4,5},{6,7,8,9,10,11})
 p.anim:add_stage("jump",1,false,{0},{6})
 p.anim:add_stage("fall",1,false,{0},{6})
 p.anim:add_stage("walk_turn",5,false,{19,17,20,5},{16,17,18,11},"walk")
 p.anim:add_stage("jump_turn",5,false,{24,25,26},{21,22,23},"jump")
 p.anim:add_stage("fall_turn",5,false,{24,25,26},{21,22,23},"fall")
 p.anim:init("still",dir.right)

 -- need a jump turn and a fall turn
 -- so, maybe turn shouldn't be a stage but a transition that any stage can have
 -- dir change in any stage moves to turn anim and then return to previous stage (not in opposite direction)
 -- record previous face/stage
 -- if face has changed 
 -- ??? somehow do turn anim then switch back to normal ...
 -- transition table
 -- table of sprites to transform from any sprite to any state
 -- (walking right to jumping left)
 -- negates use of turn
 -- lots of table data to store

--[[
 transition={
  still={{walk={{},{}},jump={{},{}},fall={{},{}}}},
  walk={
   {still={{3,4,5},{9,10,11}},jump={{},{}},fall={{},{}}},
   {still={{3,4,5},{9,10,11}},jump={{},{}},fall={{},{}}},
   {still={{3,4,5},{9,10,11}},jump={{},{}},fall={{},{}}},
   {still={{4,5},{4,5}},jump={{4,5},{4,5}},fall={{4,5},{4,5}}},
   {still={{5},{5}},jump={{5},{5}},fall={{5},{5}}},
   {still={{},{}},jump={{},{}},fall={{},{}}},
  },
  jump={{still={{3,4,5},{9,10,11}},walk={{3,4,5},{9,10,11}},fall={{3,4,5},{9,10,11}}}},
  fall={{still={{3,4,5},{9,10,11}},walk={{3,4,5},{9,10,11}},fall={{3,4,5},{9,10,11}}}},
 } 
 -- how to transition from still facing left to walking left
 anim.transition.still.face[1].frane[3].walk.face[1] = {x,y,z}
 -- how to transition from frame 3 of walking right to jumping left
 anim.transition.walk.face[1].frane[3].jump.face[2] = {x,y,z}
]]

 -- or, maybe we just use wlak_turn, fall_turn and jump_turn instead of turn and stick with current system
 --  p.anim:add_stage("walk_turn",5,false,{21,19,22,16},{18,19,20,17},"walk")
 --  p.anim:add_stage("jump_turn",5,false,{21,19,22,16},{18,19,20,17},"jump")
 --  p.anim:add_stage("fall_turn",5,false,{21,19,22,16},{18,19,20,17},"fall")
end

function _update60()
 p:update()
end

function _draw()
 cls()
 p:draw()


 print("current.frame:"..p.anim.current.frame,0,10)
 print("face:"..p.anim.current.face,0,0)
 print("tick:"..p.anim.current.tick,0,20)
 print("dx:"..p.dx,0,30)
end

__gfx__
22288e8822288e8822288e8800000000000000000000000022288e8822288e8822288e8800000000000000000000000022288e8822288e8822288f8822288e88
33bb8e8833bb8e8833bb8e8822288e8800000000000000002288babb2288babb2288babb22288e88000000000000000033bb8e8833bbb98833b9777922bb979b
22888e8822888e8822888e8833bb8e8822288e8822288e8822888e8822888e8822888e882288babb22288e8822288e8822888e8822888e8822888f8822888e88
22288e8822288e8822288e8822888e8833bb8e8833bb8e8822288e8822288e8822288e8822888e882288babb2288babb22288e8822288e8822288e8822288e88
02222220022222200222222022288e8822888e8822888e8802222220022222200222222022288e8822888e8822888e8802222220022222200222222002222220
0002880000288000028880000222222022288e8822288e880028800000028800000028800222222022288e8822288e8828800000288000002880000002880000
00000000000288000000000002880000022222200222222000000000002880000000000000002880022222200222222028800000288000002880000028800000
00000288000000000000000028800000288800000028880028800000000000000000000000000288000028880028880000000000000000000000000000000000
22288e8822288f880000000022288e880000000022288e8822288f8822288e8822288e8822288e8822288e880000000022288e8822288e8822288f8822288e88
33bbb98833b9777922288e8822bb979b22288e8833bbb98833b9777922bb979b22bb979b33b9777933bbb988000000002288babb22bb979b33b9777933bbb988
22888e8822888f8822bb979b22888e8833bbbe8822888e8822888f8822888e8822888e8822888e8822888e880000000022888e8822888e8822888f8822888e88
22288e8822288e8822888e8822288e8822888e8822288e8822288e8822288e8822288e8822288e8822288e880000000022288e8822288e8822288e8822288e88
022222200222222022288e880222222022288e880222222002222220022222200222222002222220022222200000000002222220022222200222222002222220
02880000002828000222222000002880022222200000288000002800002880000288000000280000000288000000000000000288000002880000028800002880
00000000000000000028800000000000000288000000000000000000000000000000000000000000000000000000000000000288000002880000028800000288
00028800000000000000288000288000028800000028800000280000028800000002880000002800000028800000000000000000000000000000000000000000
ccc66766000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00111d11000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cc666766000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccc66766000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0cccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00c6c600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
