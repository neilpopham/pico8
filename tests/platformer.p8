pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- platformer
-- by neil popham

local pad={left=0,right=1,up=2,down=3,btn1=4,btn2=5}
local screen={width=128,height=128}

local dir={left=1,right=2}
local drag={air=1,ground=0.25,gravity=0.75,wall=0.1}

cam={
 create=function(self,item,width,height)
  local o={
   --map={w=width,h=height},
   target=item,
   x=item.x,
   y=item.y,
   buffer={x=16,y=16},
   min={x=8*flr(screen.width/16),y=8*flr(screen.height/16)}
  }
  o.max={x=width-o.min.x,y=height-o.min.y,shift=2}
  setmetatable(o,self)
  self.__index=self
  return o
 end,
 update=function(self)
  local min_x = self.x-self.buffer.x
  local max_x = self.x+self.buffer.x
  local min_y = self.y-self.buffer.y
  local max_y = self.y+self.buffer.y
  if min_x>self.target.x then
   self.x=self.x+min(self.target.x-min_x,self.max.shift)
  end
  if max_x<self.target.x then
   self.x=self.x+min(self.target.x-max_x,self.max.shift)
  end
  if min_y>self.target.y then
   self.y=self.y+min(self.target.y-min_y,self.max.shift)
  end
  if max_y<self.target.y then
   self.y=self.y+min(self.target.y-max_y,self.max.shift)
  end
  if self.x<self.min.x then
   self.x=self.min.x
  elseif self.x>self.max.x then
   self.x=self.max.x
  end
  if self.y<self.min.y then
   self.y=self.min.y
  elseif self.y>self.max.y then
   self.y=self.max.y
  end
 end,
 position=function(self)
  return self.x-self.min.x,self.y-self.min.y
 end,
 map=function(self)
  camera(self:position())
  map(0,0)
 end
}

counter={
 create=function(self,min,max)
  local o={tick=0,min=min,max=max}
  setmetatable(o,self)
  self.__index=self
  return o
 end,
 increment=function(self)
  self.tick=self.tick+1
  if self.tick>self.max then
   self:reset()
   if type(self.on_max)=="function" then
    self:on_max()
   end
  end
 end,
 reset=function(self,value)
  value=value or 0
  self.tick=value
 end,
 valid=function(self)
  return self.tick>=self.min and self.tick<=self.max
 end
}

button={
 create=function(self,index)
  local o=counter.create(self,1,20)
  o.index=index
  o.released=true
  o.disabled=false
  return o
 end,
 check=function(self)
  if btn(self.index) then
   if self.disabled then return end
   if self.tick==0 and not self.released then return end
   self:increment()
   self.released=false
  else
   if not self.released then
    local tick=self.tick==0 and self.max or self.tick
    if type(self.on_release)=="function" then
     self:on_release(tick)
    end
    if tick>12 then
     if type(self.on_long)=="function" then
      self:on_long(tick)
     end
    else
     if type(self.on_short)=="function" then
      self:on_short(self.tick)
     end
    end
   end
   self:reset()
   self.released=true
  end
 end,
 pressed=function(self)
  self:check()
  return self:valid()
 end
} setmetatable(button,{__index=counter})

object={
 create=function(self,x,y)
  local o={x=x,y=y,hitbox={x=0,y=0,w=8,h=8,x2=7,y2=7}}
  setmetatable(o,self)
  self.__index=self
  return o
 end,
 add_hitbox=function(self,w,h,x,y)
  x=x or 0
  y=y or 0
  self.hitbox={x=x,y=y,w=w,h=h,x2=x+w-1,y2=y+h-1}
 end
}

movable={
 create=function(self,x,y,ax,ay,dx,dy)
  local o=object.create(self,x,y)
  o.ax=ax
  o.ay=ay
  o.dx=0
  o.dy=0
  o.min={dx=0.05,dy=0.05}
  o.max={dx=dx,dy=dy}
  o.complete=false
  o.health=0
  return o
 end,
 distance=function(self,target)
  local dx=self.target.x/1000-self.x/1000
  local dy=self.target.y/1000-self.y/1000
  return sqrt(dx^2+dy^2)*1000
 end,
 collide_object=function(self,object)
  if self.complete or object.complete then return false end
  local x=self.x
  local y=self.y
  local hitbox=self.hitbox
  return (x+hitbox.x<=object.x+object.hitbox.x2) and
   (object.x+object.hitbox.x<x+hitbox.w) and
   (y+hitbox.y<=object.y+object.hitbox.y2) and
   (object.y+object.hitbox.y<y+hitbox.h)
 end,
 can_move=function(self,points,flag)
  for _,p in pairs(points) do
   local tx=flr(p[1]/8)
   local ty=flr(p[2]/8)
   tile=mget(tx,ty)
   if flag and fget(tile,flag) then
    return {ok=false,flag=flag,tile=tile,tx=tx*8,ty=ty*8}
   elseif fget(tile,0) then
    return {ok=false,flag=0,tile=tile,tx=tx*8,ty=ty*8}
   end
  end
  return {ok=true}
 end,
 can_move_x=function(self)
  local x=self.x+round(self.dx)
  if self.dx>0 then x=x+7 end
  return self:can_move({{x,self.y},{x,self.y+7}},1)
 end,
 can_move_y=function(self)
  local y=self.y+round(self.dy)
  if self.dy>0 then y=y+7 end
  return self:can_move({{self.x,y},{self.x+7,y}})
 end,
 damage=function(self,health)
  self.health=self.health-health
  if self.health>0 then
   self:hit()
  else
   self:destroy()
  end
 end,
 hit=function(self)
  -- do nothing
 end,
 destroy=function(self)
  -- do nothing
 end,
 update=function(self)
  -- do nothing
 end,
 draw=function(self)
  -- do nothing
 end
} setmetatable(movable,{__index=object})

animatable={
 create=function(self,x,y,ax,ay,dx,dy)
  local o=movable.create(self,x,y,ax,ay,dx,dy)
  o.is={
   grounded=false,
   jumping=false,
   sliding=false,
   falling=false,
   invisible=false
  }
  o.slide=counter:create(1,20)
  o.slide.dir=0
  o.slide.on_max=function(self)
   printh("slide timeout") -- #####################################################
   -- we can use i here, like i.is.grounded
  end
  o.preslide=counter:create(1,10)
  o.preslide.on_max=function(self)
   printh("preslide timeout") -- #####################################################
   -- we can use i here, like i.is.grounded
  end
  o.cayote=counter:create(1,3)
  o.cayote.on_max=function(self)
   printh("cayote timeout") -- #####################################################
   -- we can use i here, like i.is.grounded
  end
  o.anim={
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
     self.transitioning=false
    end,
    set=function(self,stage,face)
     if self.stage==stage then return end
     printh("set:"..stage)
     self.reset(self)
     self.stage=stage
     self.face=face or self.face
    end
   },
   add_stage=function(self,name,ticks,loop,left,right,next)
    self.stage[name]={ticks=ticks,loop=loop,face={{frames=left},{frames=right}},next=next}
   end
  }
  o.set_state=function(self,state)
   for s in pairs(self.is) do
    self.is[s]=false
   end
   self.is[state]=true
  end
  return o
 end,
 animate=function(self)
  local current=self.anim.current
  local stage=self.anim.stage[current.stage]
  local face=stage.face[current.face]
  current.transitioning=stage.next~=nil
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
 end,
 update=function(self)
  -- do nothing
 end,
 draw=function(self)
  local sprite=self.animate(self)
  spr(sprite,self.x,self.y)
 end
} setmetatable(animatable,{__index=movable})

player={
 create=function(self,x,y)
  --local o=animatable.create(self,x,y,0.1,-1.75,1,2)
  local o=animatable.create(self,x,y,0.25,-3,2,4)
  o.anim:add_stage("still",1,false,{6},{12})
  o.anim:add_stage("walk",5,true,{1,2,3,4,5,6},{7,8,9,10,11,12})
  o.anim:add_stage("jump",1,false,{1},{7})
  o.anim:add_stage("fall",1,false,{13},{28})
  o.anim:add_stage("wall",1,false,{13},{28})
  o.anim:add_stage("walk_turn",5,false,{20,18,21,6},{17,18,19,12},"still")
  o.anim:add_stage("jump_turn",5,false,{25,26,27},{22,23,24},"jump")
  o.anim:add_stage("fall_turn",5,false,{25,26,27},{22,23,24},"fall")
  o.anim:add_stage("wall_turn",5,false,{25,26,27},{22,23,24},"fall")
  o.anim:add_stage("jump_fall",5,false,{2,3},{8,9},"fall")
  o.anim:init("still",dir.right)
  o.camera=cam:create(o,192,192)
  o.sx=x
  o.sy=y
  o:reset()
  o.max.health=o.health
  o.btn1=button:create(pad.btn1)
  o.btn1.on_short=function(self)
   printh("short press") -- ###########################
  end
  o.btn1.on_long=function(self)
   printh("long press") -- ###########################
  end
  o.btn2=button:create(pad.btn2)
  o.btn2.on_short=function(self)
   printh("btn2 short press") -- ###########################
  end
  o.btn2.on_long=function(self)
   printh("btn2 long press") -- ###########################
  end
  o.max.prejump=8 -- ticks allowed before hitting ground to jump
  return o
 end,
 can_jump=function(self)
  if self.is.jumping
   and self.btn1:valid() then
   printh("can jump: jumping") -- ###########################
   return true
  end
  if self.is.grounded
   and self.btn1.tick<self.max.prejump then
   printh("can jump: grounded: tick:"..(self.btn1.tick)) -- ###########################
   self.btn1.tick=self.btn1.min
   return true
  end
  if self.is.grounded
   and self.cayote:valid() then
   printh("can jump: cayote") -- ###########################
   return true
  end
  local face=self.anim.current.face
  if self.is.sliding
   and self.slide:valid()
   and face~=self.slide.dir then
   printh("can jump: sliding") -- ###########################
   return true
  end
  return false
 end,
 reset=function(self)
  self.complete=false
  self.score=0
  self.health=500
  self.x=self.sx
  self.y=self.sy
 end,
 destroy=function(self)
 end,
 hit=function(self)
 end,
 update=function(self)
  if self.complete then return end
  animatable.update(self)
  local face=self.anim.current.face
  local stage=self.anim.current.stage
  local move

  -- checks for direction change
  local check=function(self,stage,face)
   if face~=self.anim.current.face then
    if stage=="still" then stage="walk" end
    if stage=="jump_fall" then stage="fall" end
    if not self.anim.current.transitioning then
     self.anim.current:set(stage.."_turn")
     self.anim.current.transitioning=true
    end
   end
  end

  -- horizontal
  if btn(pad.left) then
   self.anim.current.face=dir.left
   check(self,stage,face)
   self.dx=self.dx-self.ax
  elseif btn(pad.right) then
   self.anim.current.face=dir.right
   check(self,stage,face)
   self.dx=self.dx+self.ax
  else
   if self.is.jumping or self.is.falling then
    self.dx=self.dx*drag.air
   else
    self.dx=self.dx*drag.ground
   end
  end
  self.dx=mid(-self.max.dx,self.dx,self.max.dx)

  move=self:can_move_x()

  -- can move horizontally
  if move.ok then
   self.x=self.x+round(self.dx)

  -- cannot move horizontally
  else
   self.x=move.tx+(self.dx>0 and -8 or 8)
   if move.flag==1 then
    if not self.is.grounded then
     printh("hit a slide wall") -- #################################
     local face=self.dx<0 and 1 or 2
     if not self.is.sliding then
      self.preslide:reset(self.preslide.min)
      self.slide:reset(self.slide.min)
      self.slide.dir=face
     end
     self.anim.current.face=face
     self.anim.current:set("wall")
     self:set_state("sliding")
    end
   end
  end

  -- jump
  if self.btn1:pressed() and self:can_jump() then
   self.dy=self.dy+self.ay
  else
   if self.is.jumping then
    self.btn1.disabled=true
   else
    self.btn1.disabled=false
   end
  end
  self.dy=self.dy+(self.is.sliding and drag.wall or drag.gravity)
  self.dy=mid(-self.max.dy,self.dy,self.max.dy)

  move=self:can_move_y()

  -- can move vertically
  if move.ok then

   -- moving down the screen
   if self.dy>0 then
    if self.is.grounded then
     self.cayote:increment()
     if self.cayote:valid() then
      self.dy=0
     else
      self.anim.current:set("fall")
      self:set_state("falling")
     end
    elseif self.is.sliding then
     if self.preslide:valid() then
       self.dy=0
       self.preslide:increment()
     else
      if self.slide:valid() then
       self.slide:increment()
      end
     end
    else
     if not self.anim.current.transitioning then
      self.anim.current:set(self.is.jumping and "jump_fall" or "fall")
     end
     self:set_state("falling")
    end

   -- moving up the screen
   else
    if not self.is.jumping then
     self.anim.current:set("jump")
    end
    self:set_state("jumping")
   end
   self.y=self.y+round(self.dy)

  -- cannot move vertically
  else
   self.y=move.ty+(self.dy>0 and -8 or 8)
   if self.dy>0 then
    if not self.anim.current.transitioning then
     self.anim.current:set(round(self.dx)==0 and "still" or "walk")
     --self.anim.current:set(abs(self.dx)<self.min.dx and "still" or "walk")
    end
    self:set_state("grounded")
    self.cayote:reset()
    self.preslide:reset()
    self.slide:reset()
   else -- self.dy<0
    self.btn1:reset()
    self.dy=0
    self.anim.current:set("jump_fall")
    self:set_state("falling")
   end
  end

  -- btn 2
  if self.btn2:pressed() then

  else

  end

 end,
 draw=function(self)
  if self.complete then return end
  animatable.draw(self)
 end
} setmetatable(player,{__index=animatable})

function _init()
 p=player:create(120,232)

 printh("p.anim.current.frame:"..p.anim.current.frame)
 local x local y
 for x=0,63 do for y=0,31 do
  local s=mget(x,y)
  if s==p.anim.current.frame then
   mset(x,y,0)
   p.x=x*8
   p.y=y*8
  end
 end end

end

function _update60()
 p:update()
 p.camera:update()
end

function _draw()
 cls()
 p.camera:map()
 p:draw()
 -- draw hud
 camera(0,0)
 print(p.x..","..p.y)
end

function round(x) return flr(x+0.5) end

__gfx__
0000000022288e8822288e8822288e8800000000000000000000000022288e8822288e8822288e8800000000000000000000000022288e880000000000000000
0000000033bb8e8833bb8e8833bb8e8822288e8800000000000000002288babb2288babb2288babb22288e88000000000000000033bb8e880000000000000000
0000000022888e8822888e8822888e8833bb8e8822288e8822288e8822888e8822888e8822888e882288babb22288e8822288e8822888e880000000000000000
0000000022288e8822288e8822288e8822888e8833bb8e8833bb8e8822288e8822288e8822288e8822888e882288babb2288babb22288e880000000000000000
0000000002222220022222200222222022288e8822888e8822888e8802222220022222200222222022288e8822888e8822888e88022222200000000000000000
000000000000288000288000000000000222222022288e8822288e880288000000028800000000000222222022288e8822288e88002880000000000000000000
00000000000000000000000002882880002880000222222002222220000000000000000002882880000288000222222002222220000000000000000000000000
00000000000002880000028800000000288000000228800000288280288000002880000000000000000002880002288002828800288000000000000000000000
0000000022288e8822288f880000000022288e880000000022288e8822288f8822288e8822288e8822288e8822288e8822288e88000000000000000000000000
0000000033bbb98833b9777922288e8822bb979b22288e8833bbb98833b9777922bb979b22bb979b33b9777933bbb9882288babb000000000000000000000000
0000000022888e8822888f8822bb979b22888e8833bbbe8822888e8822888f8822888e8822888e8822888e8822888e8822888e88000000000000000000000000
0000000022288e8822288e8822888e8822288e8822888e8822288e8822288e8822288e8822288e8822288e8822288e8822288e88000000000000000000000000
00000000022222200222222022288e880222222022288e8802222220022222200222222002222220022222200222222002222220000000000000000000000000
00000000028800000028280002222220000028800222222000002880000028000028800002880000002800000002880000028800000000000000000000000000
00000000000000000000000000288000000000000002880000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000288000000000000002880002880000288000000288000002800000288000000028800000028000000288000000288000000000000000000000000
22288e8822288e880000000000000000000000000000000000000000000000000000000000000000000000000000000011001100070007000000000000000000
33bb8e882288babb00000000000000000000000000000000000000000000000000000000000000000000000000000000c700c700011001100000000000000000
22888e8822888e8800000000000000000000000000000000000000000000000000000000000000000000000000000000cccccccc0cc00cc000000000c00c7007
22288e8822288e8800000000000000000000000000000000000000000000000000000000000000000000000000000000cccccccccccccccc00cc00cccccccccc
02222220022222200000000000000000000000000000000000000000000000000000000000000000000000000000000011cc11ccccccccccc7ccc7cccccccccc
00288000000288000000000000000000000000000000000000000000000000000000000000000000000000000000000011111111c11cc11ccccccccc1cc11cc1
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005151515111111111cc11cc1111111111
28800000000002880000000000000000000000000000000000000000000000000000000000000000000000000000000015151515515151511111111151515151
b3bb3bbb00000003b00000003333333300000000000000000000004a44444444000ddd00000000000000000000000000d100001d0000000000010000228e8000
bbbbbbbb0000003bbb0000000303b3b000000000000020000000049a44444444055dd6d00000000000000000000000001000000100000000001c100028bab000
3b3bb3b30000003bb0000000000300b00000000000088800000049aa4444444455dddd60000000000000000000000000000000000000000001c6c100228e8000
4b53b5350000003b0000000000000000003030000028a82009999a00444444445ddddddd00000000000000000000000000000000000000001ccc6c1002220000
4354354500000003b00000000000000003383330000888004909a000444444445ddddddd000000000005d6001010101000000000011cc7c001ccc10000000000
4454454400000000000000000000000008333383000023b04000a00044444444555ddddd5d6000000055ddd07070707000000000011cc7c0001c100000000000
444444440000000300000000000000003333833300033b0044099000444444445555555055dd05000d055dd0606060601000000101111c100001000000000000
444444440000000000000000000000000333333000003b000444000044444444055555000550055055d055006d6d6d6dd100001d22888e880000000000000000
0000000000011000000cc000000770000000000000000000000aa000ccc667660000000000000000000000000000000000000000000000000000000000000000
44499a9944499a9944499a9944499a99000000000008800044499a9900111d110000000000000000000000000000000000000000000000000000000000000000
44999a9944999a9944999a9944999a990002200044499a9944999a99cc6667660000000000000000000000000000000000000000000000000000000000000000
44499a9944499a9944499a9944499a9944499a9944999a9944499a99ccc667660000000000000000000000000000000000000000000000000000000000000000
28e028e0028e08e02028e08e28028e0e44999a9944499a9928028e0e0cccccc00000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000044499a992028e08e00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003000000000300000000000028e08e00300300000300000000000000000000000000000000000000000000000000000000000000000000000000000
0300030030300030003030030030030033333333333033033030030300c6c6000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000003010000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
3700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3700000000000000000000000000003900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
37000000003a0000010000000031303030303030320000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3700003130303032000000000000003333003300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3700000033000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3739000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3730303030303030303030303030303030303030303030303030303030303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
