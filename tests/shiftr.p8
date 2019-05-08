pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- splitter
-- by neil popham

local pad={left=0,right=1,up=2,down=3,btn1=4,btn2=5}
local screen={width=128,height=128}

local dir={left=1,right=2}
local drag={air=1,ground=0.25,gravity=0.75,wall=0.1}

local pane={
 create=function(self,tx,ty,mx,my,sx,sy)
 local o={x=sx,y=sy,map={x=mx,y=my},tile={x=tx,y=ty},new={x=sx,y=sy},d=0.5,dx=0,dy=0}
  setmetatable(o,self)
  self.__index=self
  return o
 end,
 reset=function(self)
  self.d=0.5
  self.sliding=false
  self.tile.y=self.y==0 and 1 or 2
  self.tile.x=self.x==0 and 1 or 2
 end,
 update=function(self)
  if self.sliding==false then return false end
  local x=self.x
  local y=self.y
  --local x,y=self.x,self.y
  self.d=self.d*1.25
  if self.dir==pad.up then
   self.y=self.y-self.d
   if self.y<=self.new.y then
    self.y=self.new.y<0 and 64 or 0
    self:reset()
   end
  elseif self.dir==pad.down then
   self.y=self.y+self.d
   if self.y>=self.new.y then
    self.y=self.new.y>64 and 0 or 64
    self:reset()
   end
  elseif self.dir==pad.left then
   self.x=self.x-self.d
   if self.x<=self.new.x then
    self.x=self.new.x<0 and 64 or 0
    self:reset()
   end
  elseif self.dir==pad.right then
   self.x=self.x+self.d
   if self.x>=self.new.x then
    self.x=self.new.x>64 and 0 or 64
    self:reset()
   end
  end
  return true
 end,
 draw=function(self)
  map(self.map.x,self.map.y,self.x,self.y,8,8)
  if self.y<0 then
   map(self.map.x,self.map.y,self.x,self.y+128,8,8)
  elseif self.y>64 then
   map(self.map.x,self.map.y,self.x,self.y-128,8,8)
  elseif self.x<0 then
   map(self.map.x,self.map.y,self.x+128,self.y,8,8)
  elseif self.x>64 then
   map(self.map.x,self.map.y,self.x-128,self.y,8,8)
  end
 end
}

local tile={
 panes={},
 sliding=false,
 active=true,
 dir=0,
 x=0,
 y=0,
 split=function(self,dir,index)
  if self:disabled() then return end
  self.sliding=true
  self.dir=dir
  self.index=index
  for _,pane in pairs(self.panes) do
   if dir==pad.left or dir==pad.right then
    if pane.tile.y==index then
     pane.sliding=true
     pane.dir=dir
     pane.new.x=dir==pad.left and pane.x-64 or pane.x+64
    end
   else
    if pane.tile.x==index then
     pane.sliding=true
     pane.dir=dir
     pane.new.y=dir==pad.up and pane.y-64 or pane.y+64
    end
   end
  end
  for _,entity in pairs(entities) do
    entity:split(dir,index)
  end
 end,
 disabled=function(self)
  return self.sliding or not self.active
 end,
 init=function(self)
  for y=0,1 do
   for x=0,1 do
    local pane=pane:create(x+1,y+1,x*8,y*8,x*64,y*64)
    add(self.panes,pane)
   end
  end
 end,
 update=function(self)
  if not self.sliding then return end
  local sliding=false
  for _,pane in pairs(self.panes) do
   if pane.sliding then
    sliding=pane:update() or sliding
   end
  end
  if not sliding then
    self.sliding=false
    for _,entity in pairs(entities) do
      entity.sliding=false
    end
  end
 end,
 draw=function(self)
  for _,pane in pairs(self.panes) do
   pane:draw()
  end
 end
}

local counter={
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

local button={
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

local object={
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

local movable={
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
  o.sliding=false
  o.tile={}
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
   local tile=mget(tx,ty)
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
 split=function(self,dir,index)
  self.tile.x=self.x<64 and 1 or 2
  self.tile.y=self.y<64 and 1 or 2
  for i,pane in pairs(tile.panes) do
   if pane.tile.x==self.tile.x and pane.tile.y==self.tile.y then
    self.sliding=pane.sliding
    self.pane=pane
    self.dx=self.x-pane.x
    self.dy=self.y-pane.y
    return self.sliding
   end
  end
 end,
 hit=function(self)
  -- do nothing
 end,
 destroy=function(self)
  -- do nothing
 end,
 update=function(self)
  if self.sliding then
   self.x=self.pane.x+self.dx
   self.y=self.pane.y+self.dy
   if self.x<=-8 then self.x+=128 end
   if self.x>=128 then self.x-=128 end
   if self.y<=-8 then self.y+=128 end
   if self.y>=128 then self.y-=128 end
   return true
  else
   return false
  end
 end,
 draw=function(self)
  -- do nothing
 end
} setmetatable(movable,{__index=object})


local animatable={
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
  if not self.sliding then
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
  end
  return face.frames[current.frame]
 end,
 update=function(self)
  movable.update(self)
 end,
 draw=function(self)
  local sprite=self.animate(self)
  spr(sprite,self.x,self.y)
  if self.x<0 then
   spr(sprite,self.x+128,self.y)
  elseif self.x>120 then
   spr(sprite,self.x-128,self.y)
  end
  if self.y<0 then
   spr(sprite,self.x,self.y+128)
  elseif self.y>120 then
   spr(sprite,self.x,self.y-128)
  end
 end
} setmetatable(animatable,{__index=movable})

local player={
 create=function(self,x,y)
  local o=animatable.create(self,x,y,0.25,-3,2,4)
  o.anim:add_stage("still",1,false,{2},{2})
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
  if self.sliding then return end

  --self.btn2:pressed()
  if btn(pad.btn2) and not tile:disabled() then
   if btn(pad.up) then
    tile:split(pad.up,self.x<64 and 1 or 2)
   elseif btn(pad.down) then
    tile:split(pad.down,self.x<64 and 1 or 2)
   elseif btn(pad.left) then
    tile:split(pad.left,self.y<64 and 1 or 2)
   elseif btn(pad.right) then
    tile:split(pad.right,self.y<64 and 1 or 2)
   end
  else
   if btnp(pad.up) then self.y=self.y-64 end
   if btnp(pad.down) then self.y=self.y+64 end
   if btnp(pad.left) then self.x=self.x-64 end
   if btnp(pad.right) then self.x=self.x+64 end
  end

  if btnp(pad.btn1) then
   printh("p: "..p.x..","..p.y)
   printh("b: "..b.x..","..b.y)
  end

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



  if self.btn2:pressed() then

  else

  end


--[[
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
 ]]
 end,
 draw=function(self)
  if self.complete then return end
  animatable.draw(self)
 end
} setmetatable(player,{__index=animatable})

local enemy={
 create=function(self,x,y)
  local o=animatable.create(self,x,y,0.25,-0.25,1,1)
  o.anim:add_stage("still",1,false,{3},{3})
  o.anim:add_stage("walk",5,true,{1,2,3,4,5,6},{7,8,9,10,11,12})
  o.anim:add_stage("walk_turn",5,false,{20,18,21,6},{17,18,19,12},"still")
  o.anim:init("still",dir.right)
  o.sx=x
  o.sy=y
  o:reset()
  o.max.health=o.health
  return o
 end,
 reset=function(self)
  self.complete=false
  self.health=1500
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
  if self.sliding then return end

  local face=self.anim.current.face
  local stage=self.anim.current.stage
  local move

  if self.anim.current.face==dir.left then
   self.dx=self.dx-self.ax
  else
   self.dx=self.dx+self.ax
  end

  self.dx=mid(-self.max.dx,self.dx,self.max.dx)

  move=self:can_move_x()

  -- can move horizontally
  if move.ok then
   self.x=self.x+round(self.dx)
  else
   self.x=move.tx+(self.dx>0 and -8 or 8)
   self.anim.current.face=self.anim.current.face==dir.left and dir.right or dir.left
   self.dx=0
  end
 end,
 draw=function(self)
  if self.complete then return end
  animatable.draw(self)
 end
} setmetatable(enemy,{__index=animatable})

local block={
 create=function(self,x,y)
  local o=animatable.create(self,x,y,0.25,-3,2,4)
  o.anim:add_stage("still",1,false,{4},{4})
  o.anim:init("still",dir.right)
  o.sx=x
  o.sy=y
  o:reset()
  o.max.health=o.health
  return o
 end,
 reset=function(self)
  self.complete=false
  self.health=2500
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
 end,
 draw=function(self)
  if self.complete then return end
  animatable.draw(self)
 end
} setmetatable(block,{__index=animatable})

collection={
 create=function(self)
  local o={
   items={},
   count=0,
  }
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

enemy_collection={
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
 end,
 update=function(self)
  collection.update(self)
 end,
 draw=function(self)
  collection.draw(self)
 end
} setmetatable(enemy_collection,{__index=collection})


function _init()
 tile:init()
 p=player:create(0,0)
 b=block:create(0,0)
 enemies=enemy_collection:create()
 enemies:add(enemy:create(0,0))
 enemies:add(enemy:create(0,0))

 -- create collection of all objects
 entities={}
 add(entities,p)
 add(entities,b)
 for _,enemy in pairs(enemies.items) do
  add(entities,enemy)
 end
 printh("entities:"..#entities)

 -- turn placeholders into objects
 local cell={}
 for y=0,15 do
  cell[y]={}
  for x=0,15 do
   cell[y][x]=mget(x,y)
  end
 end
 for _,entity in pairs(entities) do
  local current=entity.anim.current
  local stage=entity.anim.stage[current.stage]
  local face=stage.face[current.face]
  local frame=face.frames[current.frame]
  local found=false
  for y=0,15 do for x=0,15 do
   if not found then
    if cell[y][x]==frame then
     mset(x,y,0)
     cell[y][x]=0
     entity.x=x*8
     entity.y=y*8
     found=true
    end
   end
  end end
 end
 printh("done")

end

function _update60()
 tile:update()
 enemies:update()
 p:update()
 b:update()
end

function _draw()
 cls()
 tile:draw()
 enemies:draw()
 p:draw()
 b:draw()
end

function round(x) return flr(x+0.5) end

__gfx__
000000001111111122222222333333334444444488888888cccccccc777777760000000000000000000000000000000000000000000000000000000000000000
000000001111111122222222333333334444444488888888cccccccc7666666d0000000000000000000000000000000000000000000000000000000000000000
000000001111111122222222333333334444444488888888cccccccc7666666d0000000000000000000000000000000000000000000000000000000000000000
000000001111111122222222333333334444444488888888cccccccc7666666d0000000000000000000000000000000000000000000000000000000000000000
000000001111111122222222333333334444444488888888cccccccc7666666d0000000000000000000000000000000000000000000000000000000000000000
000000001111111122222222333333334444444488888888cccccccc7666666d0000000000000000000000000000000000000000000000000000000000000000
000000001111111122222222333333334444444488888888cccccccc7666666d0000000000000000000000000000000000000000000000000000000000000000
000000001111111122222222333333334444444488888888cccccccc6ddddddd0000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0701010101010101000000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010107000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010107000300070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010107070707070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201010100010107070000000000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0707070707070707070101010707070700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000010101010101010700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000010101010101010700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000070000010103070101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000101000070707070707070101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0707070700000000010101010101010700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000