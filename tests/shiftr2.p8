pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- splitter
-- by neil popham

local pad={left=0,right=1,up=2,down=3,btn1=4,btn2=5}
local dir={left=1,right=2}
local drag={air=1,ground=0.25,gravity=0.75,wall=0.1}

local mapdata={
 data={},
 decompress=function(self)
  local total,level=0,{}
  for y=0,31 do
   for x=0,127 do
    local raw=mget(x,y)
    local sprite=raw%16
    local count=(raw-sprite)/16
    if count==0 then count=16 end
    add(level,{count,sprite})
    total+=count
    if total==256 then
     add(self.data,level)
     total,level=0,{}
    end
   end
  end
 end,
 load=function(self,level)
  local t=0
  for _,block in pairs(self.data[level]) do
   for i=1,block[1] do
    mset(t%16,flr(t/16),block[2])
    t+=1
   end
  end
 end
}

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

local pane={
 create=function(self,tx,ty,mx,my,sx,sy)
 local o={x=sx,y=sy,map={x=mx,y=my},tile={x=tx,y=ty},new={x=sx,y=sy},d=0.5}
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
  self.dir=dir or self.dir
  self.index=index or self.index
  self.queued=true
  printh("===")
  printh("split "..self.dir.." "..self.index.." "..p.x..","..p.y)
  for _,entity in pairs(entities) do
    printh(entity.paused and "paused" or "not paused")
    if not entity.paused then return end
  end
  printh("start slide")
  self.queued=false
  self.sliding=true
  for _,pane in pairs(self.panes) do
   if self.dir==pad.left or self.dir==pad.right then
    if pane.tile.y==self.index then
     pane.sliding=true
     pane.dir=self.dir
     pane.new.x=self.dir==pad.left and pane.x-64 or pane.x+64
    end
   else
    if pane.tile.x==self.index then
     pane.sliding=true
     pane.dir=self.dir
     pane.new.y=self.dir==pad.up and pane.y-64 or pane.y+64
    end
   end
  end
  for _,entity in pairs(entities) do
    entity:split(self.dir,self.index)
  end
 end,
 disabled=function(self)
  return self.sliding or not self.active -- or self.queued or not self.active
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
  if self.queued then self:split() end
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
      --entity.paused=false
    end
  end
 end,
 draw=function(self)
  for _,pane in pairs(self.panes) do
   pane:draw()
  end
 end
}

local object={
 create=function(self,x,y)
  local o={x=x,y=y}
  setmetatable(o,self)
  self.__index=self
  return o
 end
}

local movable={
 create=function(self,x,y,ax,ay,dx,dy)
  local o=object.create(self,x,y)
  o=extend(
   o,
   {
    ax=ax,
    ay=ay,
    dx=0,dy=0,
    ox=0,sx=x,
    sy=y,
    min={dx=0.05,dy=0.05},
    max={dx=dx,dy=dy},
    complete=false,
    sliding=false,
    paused=false,
    tick=0,
    type=0,
    health=0
   }
  )
  return o
 end,
 distance=function(self,target)
  local dx=self.target.x/1000-self.x/1000
  local dy=self.target.y/1000-self.y/1000
  return sqrt(dx^2+dy^2)*1000
 end,
 collision=function(self,x1,y1,x2,y2)
  return x1<x2+8 and x2<x1+8 and y1<y2+8 and y2<y1+8
 end,
 collide_object=function(self,object)
  if self.complete or object.complete then return false end
  --if self==object then return false end
  local x=(self.x+round(self.dx))%128
  local y=self.y
  local collided=self:collision(x,y,object.x,object.y)
  if x>120 then
   collided=collided or self:collision(x-128,y,object.x,object.y)
   printh("x>120 "..x.." dx:"..self.dx)
   printh((x-128)..","..y..","..object.x..","..object.y)
   printh(collided and "collided" or "didnt collide")
  elseif x<0 then
   collided=collided or self:collision(x+128,y,object.x,object.y)
   printh("x<0 "..x)
   printh((x+128)..","..y..","..object.x..","..object.y)
   printh(collided and "collided" or "didnt collide")
  elseif object.x>120 then
   collided=collided or self:collision(x,y,object.x-128,object.y)
   printh("x2>120 "..object.x)
   printh(x..","..y..","..(object.x-128)..","..object.y)
   printh(collided and "collided" or "didnt collide")
  elseif object.x<0 then
   collided=collided or self:collision(x,y,object.x+128,object.y)
   printh("x2<0 "..object.x)
   printh(x..","..y..","..(object.x+128)..","..object.y)
   printh(collided and "collided" or "didnt collide")
  end
  return collided
 end,
 can_move=function(self,points,flag)
  for _,p in pairs(points) do
   local tx=flr(p[1]/8)
   local ty=flr(p[2]/8)
   local tile=self:mapget(tx,ty)
   if flag and fget(tile,flag) then
    return {ok=false,flag=flag,tile=tile,tx=tx*8,ty=ty*8}
   elseif fget(tile,0) then
    return {ok=false,flag=0,tile=tile,tx=tx*8,ty=ty*8}
   end
  end
  return {ok=true}
 end,
 can_move_x=function(self)
  local x=(self.x+round(self.dx)+(self.dx>0 and 7 or 0))%128
  return self:can_move({{x,self.y},{x,self.y+7}},1)
 end,
 can_move_y=function(self)
  local y=(self.y+round(self.dy)+(self.dy>0 and 7 or 0))%128
  return self:can_move({{self.x,y},{self.x+7,y}})
 end,
 wont_fall=function(self)
  local y=(self.y+8)%128
  local x=(self.x+round(self.dx)+(self.dx>0 and 7 or 0))%128
  local move=self:can_move({{x,y}})
  return {ok=not move.ok,tx=x-x%8,ty=y-y%8}
 end,
 ismovable=function(self)
  local move=self:can_move_x()
  if move.ok then
   move=self:wont_fall()
  end
  return move
 end,
 fits_cell=function(self)
  return self.x%8==0 and self.y%8==0
 end,
 finished_moving=function(self)
  return self:fits_cell() and self.x~=self.ox
 end,
 is=function(self,types)
  for _,t in pairs(types) do
   if self.type==t then return true end
  end
  return false
 end,
 isnt=function(self,types)
  for _,t in pairs(types) do
   if self.type==t then return false end
  end
  return true
 end,
 damage=function(self,health)
  self.health=self.health-health
  if self.health>0 then
   self:hit()
  else
   self:destroy()
  end
 end,
 get_pane=function(self,x,y)
  x=x or self.x
  y=y or self.y
  local tile_x=x<64 and 1 or 2
  local tile_y=y<64 and 1 or 2
  for i,pane in pairs(tile.panes) do
   if pane.tile.x==tile_x and pane.tile.y==tile_y then
    return pane
   end
  end
 end,
 mapget=function(self,tx,ty)
  self.pane=self:get_pane(tx*8,ty*8)
  tx=tx-self.pane.x/8
  ty=ty-self.pane.y/8
  return mget(self.pane.map.x+tx,self.pane.map.y+ty)
 end,
 split=function(self,dir,index)
  self.pane=self:get_pane()
  self.sliding=self.pane.sliding
  self.px=self.x-self.pane.x
  self.py=self.y-self.pane.y
  return self.sliding
 end,
 checkbounds=function(self)
  self.x=self.x%128
  self.y=self.y%128
 end,
 setstill=function(self,x)
  self.x=x
  self.dx=0
  self.still=true
  self.ox=x
  printh("resetting to "..self.x)
  --if (self.anim) self.anim.current:set("still")
 end,
 hit=function(self)
  -- do nothing
 end,
 destroy=function(self)
  -- do nothing
 end,
 update=function(self)
  if tile.queued and self:fits_cell() then
   self.paused=true
   self.dx=0
  elseif self.sliding then
   self.x=self.pane.x+self.px
   self.y=self.pane.y+self.py
  elseif self.paused then
    self.paused=false
  end
  self:checkbounds()
 end,
 draw=function(self,sprite)
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
} setmetatable(movable,{__index=object})

local animatable={
 create=function(self,x,y,ax,ay,dx,dy)
  local o=movable.create(self,x,y,ax,ay,dx,dy)
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
  return o
 end,
 animate=function(self)
  local current=self.anim.current
  local stage=self.anim.stage[current.stage]
  local face=stage.face[current.face]
  if not self.sliding and not self.paused then
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
 draw=function(self)
  local sprite=self.animate(self)
  movable.draw(self,sprite)
 end
} setmetatable(animatable,{__index=movable})

local player={
 create=function(self,x,y)
  local o=animatable.create(self,x,y,0.25,0,1,0)
  local animation=o.anim
  animation:add_stage("still",1,false,{20},{17})
  animation:add_stage("walk",5,true,{20,21,22,21},{17,18,19,18})
  animation:add_stage("walk_turn",3,false,{32,33,34},{34,33,32},"still")
  animation:init("still",dir.right)
  o:reset()
  o.max.health=o.health
  o.type=1
  o.cols={7,3,11,11}
  return o
 end,
 reset=function(self)
  self.complete=false
  self.still=true
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
  if tile.sliding then return end

  local face=self.anim.current.face
  local stage=self.anim.current.stage

  -- checks for direction change
  local check=function(self,stage,face)
   if face~=self.anim.current.face then
    if stage=="still" then stage="walk" end
    if not self.anim.current.transitioning then
     self.anim.current:set(stage.."_turn")
     self.anim.current.transitioning=true
    end
   end
  end

  if not self.still then

   if self:finished_moving() then
    --printh(self.x.." "..self.ox.." "..self.dx.." (done)")
    printh("moved from "..self.ox.." to "..self.x.." dx:"..self.dx.." (done) b.x:"..b.x)
    self.still=true
    self.anim.current:set("still")
    --self.dx=0
   elseif not self.anim.current.transitioning then
    self.dx=self.dx*1.25
    --self.dx=self.dx+self.ax
    self.dx=mid(-self.max.dx,self.dx,self.max.dx)

    local move={ok=true}

    if self:collide_object(b) then
     printh("player collided with block")
     printh("p.x:"..self.x.." p.dx:"..self.dx.." b.x"..b.x)
     b.dx=self.dx
     move=b:ismovable()
     if not move.ok then
      self:setstill(self.x-self.x%8)
      printh("block not movable")
     end
    end

    if move.ok then

     move=self:ismovable()
     if move.ok then
      self.x=self.x+round(self.dx)
      self:checkbounds()
      if not self.anim.current.transitioning then
       self.anim.current:set(self.dx==0 and "still" or "walk")
      end
     end

     if not move.ok then
      self:setstill(move.tx+(self.dx>0 and -8 or 8))
     end

    end
   end
  end

  -- if we are currently still
  if self.still then

   local flagmoving=function()
    if stage=="still" then self.anim.current:set("walk") end
    self.still=false
    self.ox=self.x
   end

   -- shifting
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
   end

   -- left button pressed
   if btn(pad.left) then
    self.anim.current.face=dir.left
    check(self,stage,face)
    if round(self.dx)==0 then self.dx=-self.ax end
    printh("moving left")
    flagmoving()

   -- right button pressed
   elseif btn(pad.right) then
    self.anim.current.face=dir.right
    check(self,stage,face)
    if round(self.dx)==0 then self.dx=self.ax end
    printh("moving right")
    flagmoving()

   -- still and no button pressed
   else
    self.dx=self.dx*drag.ground
    if abs(self.dx)==0.01 then self.dx=0 end
   end

  end
 end,
 draw=function(self)
  if self.complete then return end
  animatable.draw(self)
 end
} setmetatable(player,{__index=animatable})

local enemy={
 create=function(self,x,y)
  local o=animatable.create(self,x,y,0.1,0,1,0)
  --o.anim:add_stage("still",1,false,{26},{23})
  o.anim:add_stage("walk",5,true,{26,27,28,27},{23,24,25,24})
  o.anim:add_stage("walk_turn",5,false,{29,30,31},{31,30,29},"walk")
  o.anim:init("walk",dir.right)
  o:reset()
  o.max.health=o.health
  o.type=2
  o.cols={2,7,8,8}
  return o
 end,
 reset=function(self)
  self.complete=false
  self.health=1500
  self.x=self.sx
  self.y=self.sy
  self.tick=0
 end,
 destroy=function(self)
 end,
 hit=function(self)
 end,
 update=function(self)
  if self.complete then return end

  local current=self.anim.current

  animatable.update(self)

  if tile.sliding then return end
  if current.transitioning then return end -- don't move while turning

  local face=current.face
  local stage=current.stage

  if face==dir.left then
   self.dx=self.dx-self.ax
  else
   self.dx=self.dx+self.ax
  end

  self.dx=mid(-self.max.dx,self.dx,self.max.dx)
  --printh("enemy dx:"..self.dx)

  local move={ok=true,tx=flr(self.x/8)*8}

  if self:collide_object(b) then
   printh("enemy collided with block")
   printh("e.tx:"..move.tx.." e.x:"..self.x.." e.dx:"..self.dx.." b.x:"..b.x)
   b.dx=self.dx
   move=b:ismovable()
   if not move.ok then
    printh("block not movable "..self.x.." vs "..(self.x%8))
    self:setstill(self.x-self.x%8)
    printh(b.x)
    printh(move.tx)
   end
  end

  if move.ok then
   move=self:ismovable()
   if move.ok then
    self.x=self.x+round(self.dx)
    self:checkbounds()
   end
  end

  if not move.ok then
   self.anim.current.face=face==dir.left and dir.right or dir.left
   self.dx=0
   --self.x=move.tx+(self.dx>0 and -8 or 8)
   --if not self.anim.current.transitioning then
   self.anim.current:set(stage.."_turn")
   self.anim.current.transitioning=true
   --end
  end

  if self:collide_object(p) then
   printh("collided with player")
   p:destroy()
  end

 end,
 draw=function(self)
  if self.complete then return end
  animatable.draw(self)
 end
} setmetatable(enemy,{__index=animatable})

local block={
 create=function(self,x,y)
  local o=movable.create(self,x,y,1,1,1,1)
  o:reset()
  o.max.health=o.health
  o.type=3
  o.cols={4,4,8,9}
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
  movable.update(self)
  if tile.sliding then return end

  if not self.still then
   if self:finished_moving() then
    self.still=true
   else
    self.dx=mid(-self.max.dx,self.dx*1.25,self.max.dx)
   end
  end

  for i,entity in pairs(entities) do
   if entity:is({1,2}) and self:collide_object(entity) then
    printh("block collided with type "..entity.type)
    self.dx=entity.dx
    local move=self:ismovable()
    if move.ok then
     self.still=false
     self.dx=entity.dx
     self.ox=self.x
    else
     self:setstill(move.tx+(self.dx>0 and -8 or 8))
    end
   end
  end

  if self.still then
   --self:controller() -- make movement
   --check movement possible
  else
   self.x+=round(self.dx)
   self:checkbounds()
  end



 --[[
  self.dx=0
  if self:collide_object(p) then
   printh("block collided with player")
   printh("block x:"..b.x.." player x:"..p.x)
   self.dx=p.dx
   local move=self:ismovable()
   if move.ok then
    self.still=false
    --self.x=p.x+(p.dx>0 and 8 or -8)
    self.x+=round(p.dx)
    self:checkbounds()
   else
    self:setstill(move.tx+(self.dx>0 and -8 or 8))
    --p:setstill(move.tx+(p.dx>0 and -16 or 16))
   end
  end
  ]]

 end,
 draw=function(self)
  if self.complete then return end
  movable.draw(self,4)
 end
} setmetatable(block,{__index=movable})

local door={
 create=function(self,x,y)
  local o=movable.create(self,x,y,1,1,1,1)
  o.t=0
  o:reset()
  o.max.health=o.health
  o.type=4
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
  movable.update(self)
  if tile.sliding then return end
  self.t=(self.t+1)%16
 end,
 draw=function(self)
  if self.complete then return end
  movable.draw(self,5)
  local x,y,x2,y2,t=self.x,self.y,self.x+7,self.y+7,flr(self.t/2)
  pset(x+t,y,7)
  pset(x2,y+t,7)
  pset(x2-t,y2,7)
  pset(x,y2-t,7)
  --for i=1,10 do pset(x+rnd(8),y+rnd(8),6) end
 end
} setmetatable(door,{__index=movable})

local portal={
 create=function(self,x,y)
  local o=movable.create(self,x,y,1,1,1,1)
  o.t=0
  o.odx={}
  o:reset()
  o.max.health=o.health
  o.type=5
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
  movable.update(self)
  if tile.sliding then return end
  self.t=(self.t+1)%8

  for i,entity in pairs(entities) do
   --if entity~=self and self:collide_object(entity) then
   --if entity.type~=5 and self:collide_object(entity) then
   if entity:isnt({self.type}) and self:collide_object(entity) and entity:fits_cell() then
    if self.odx[i]==nil then
     printh("transporting type "..entity.type.." with dx "..entity.dx)
     for _,portal in pairs(portals.items) do
      if portal.x~=self.x or portal.y~=self.y then
       portal.odx[i]=entity.dx
       entity.y=portal.y
       entity:setstill(portal.x)
       beam:create(self.x,self.y,entity.cols,20)
       break
      end
     end
    else
     printh("receiving type "..entity.type.." with dx "..self.odx[i])
     entity.dx=self.odx[i]
     entity.still=false
     beam:create(self.x,self.y,entity.cols,20)
    end
   else
    self.odx[i]=nil
   end
  end

--[[
  if self:collide_object(b) then
   printh("colliding with block "..self.x..","..self.y.." "..b.x..","..b.y)
   if self.odx.b~=0 then
    printh("destination b "..self.dx)
    b.dx=self.odx.b
    b.still=false
    b.x=b.x+round(self.odx.b)
    if b.y<self.y then b.y+=1 end
    if b.x%8==0 then
     self.odx.b=0
     b.dx=0
     b.still=true
    end
    printh("portal.update: b.x:"..b.x)
   elseif b.x==self.x and b.y==self.y then
    printh("transporting b "..b.dx)
    for _,portal in pairs(portals.items) do
     if portal.x~=self.x or portal.y~=self.y then
      b.x=portal.x
      b.y=portal.y-4
      --b.y=portal.y
      portal.odx.b=b.dx
     end
    end
   end
  end
]]

--[[
  if self:collide_object(p) then
   printh("colliding with player "..self.x..","..self.y.." "..p.x..","..p.y)
   if self.odx.p~=0 then
    printh("destination p "..self.odx.p)
    p.dx=self.odx.p
    p.still=false
    printh("portal.update: p.x:"..p.x)
   elseif p.x==self.x and p.y==self.y then
    printh("transporting b "..p.dx)
    for _,portal in pairs(portals.items) do
     if portal.x~=self.x or portal.y~=self.y then
      p.x=portal.x
      p.y=portal.y
      p.ox=p.x
      portal.odx.p=p.dx
      p:setstill(p.x)
     end
    end
   end
  else
   self.odx.p=0
  end
]]

 end,
 draw=function(self)
  if self.complete then return end
  movable.draw(self,7)
  local c=t()%2==0 and 3 or 11
  pset(self.x+1+rnd(6),self.y+6,c)
  pset(self.x+1+rnd(6),self.y+6,c)
  pset(self.x+1+rnd(6),self.y+5,c)

  if self.odx[i]~=nil then
   for i=1,20 do
    pset(mrnd({self.x,self.x+7}),mrnd({self.y,self.y+7}),15)
   end
   printh("transporting")
  end

 end
} setmetatable(portal,{__index=movable})

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

-- globals
--portals,enemies,entities,p,b,particles=collection:create(),collection:create(),{},collection:create()
portals=collection:create()
enemies=collection:create()
particles=collection:create()
entities={}

-- turn placeholders into objects
function placeholders()
 local s
 for ty=0,15 do
  for tx=0,15 do
   s,x,y=mget(tx,ty),tx*8,ty*8
   if s==2 then
    p=player:create(x,y)
    add(entities,p)
    mset(tx,ty,0)
   elseif s==3 then
    local e=enemy:create(x,y)
    enemies:add(e)
    add(entities,e)
    mset(tx,ty,0)
   elseif s==4 then
    b=block:create(x,y)
    add(entities,b)
    mset(tx,ty,0)
   elseif s==5 then
    d=door:create(x,y)
    add(entities,d)
    mset(tx,ty,0)
   elseif s==7 then
    local r=portal:create(x,y)
    portals:add(r)
    add(entities,r)
    mset(tx,ty,0)
    mset(tx,ty+1,6)
   end
  end
 end
end

function _init()
 printh("####")
 printh("init")
 printh("####")
 --mapdata:decompress()
 --mapdata:load(1)
 tile:init()
 placeholders()
end

function _update60()
 tile:update()
 portals:update()
 p:update()
 enemies:update()
 b:update()
 d:update()
 particles:update()
end

function _draw()
 cls()
 rectfill(0,0,63,63,1)
 rectfill(64,64,127,127,1)
 tile:draw()
 d:draw()
 b:draw()
 portals:draw()
 enemies:draw()
 p:draw()
 particles:draw()

 --[[
 for pane in all(tile.panes) do
  print(pane.x..","..pane.y.." ("..pane.map.x..","..pane.map.y..")",pane.tile.x*64-64,pane.tile.y*64-64,3)
 end
 ]]

end

-- shared functions

function mrnd(x,f)
 if f==nil then f=true end
 local v=(rnd()*(x[2]-x[1]+(f and 1 or 0.0001)))+x[1]
 return f and flr(v) or flr(v*1000)/1000
end

function round(x)
 return flr(x+0.5)
end

function extend(t1,t2)
 for k,v in pairs(t2) do t1[k]=v end
 return t1
end

__gfx__
0000000077777776000000000000000099999999ccccccccaaaaaaa9000000001000000100000000000000001cc77cc1cccccccc00000000aaaaaaa900000000
000000007666666d0bbbb3300000007c94644642cccccccca9999994000000000000000000000000000000001cc77cc1cccccccc00000000a999999400000000
000000007666666dbbbb777c0000087142222222cccccccc94444444000000000000000000000000000000001cc77cc1cccccccc00000000a999999400000000
000000007666666dbbbb71718288287194444442cccccccc6ddddddd000000000001100000000000000000001cc77cc1cccccccc00000000a999999400000b30
000000007666666dbbbb777c8288287c94444442cccccccc7666666d000000000001100000000000000000001cc77cc1cccccccc00000000a99999940000bbb3
000000007666666dbbbbbb338288288299999999cccccccc7666666d000000000000000000000000aaaaaaa91cc77cc1cccccccc00000000a999999400003b33
000000007666666d3bbbb3338288288294644642cccccccc7666666d000000000000000000000000a99999941cc77cc1cccccccc00000000a99999940006d330
000000006ddddddd333333332222222242222222cccccccc6ddddddd3bb77bb31000000100000000944444441cc77cc1cccccccc00000000944444440006d000
99999999000000000bbbb33000000000000000000bbbb33000000000000000000000007c0000027c000000007c0000007c80000000000000777c777c00000000
946446420bbbb330bbbb777c000000000bbbb330777cbb33000000000000007c00000871000282717c0000001c2000001c8280000007777c711c711c7c77c000
42222222bbbb777cbbbb71710bbbb330777cbb33171cbb330bbbb3300000087100282871008282711c2000001c2828001c82820002871111711c711c1111c280
94444442bbbb7171bbbb777cbbbb777c171cbb33777cbb33777cbb33828828710828287c0082827c1c2882827c2828207c8282008287111177cc77cc1111c282
94444442bbbb777cbbbbbb33bbbb7171777cbb33bbbbbb33171cbb338288287c08282882008282827c288282882828208282820082877ccc888888827c77c282
99999999bbbbbb33bbbbbb33bbbb777cbbbbbb33bbbbbb33777cbb33828828820828288200828282882882828828282082828200828282228822228222828282
946446423bbbb3333bbbb3333bbbb3333bbbb3333bbbb3333bbbb333828828820828288200828282882882828828282082828200828288828888888288828282
42222222333333333333333333333333333333333333333333333333222222220222222200222222222222222222222022222200222222222222222222222222
000000000bbbb3300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0bbbb330777c777c0bbbb33000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bb777c7c711c711c77c77c3300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bb711c1c777c777c71c11c3300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bb777c7cbbbbbb3377c77c3300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbb33bbbbbb33bbbbbb3300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3bbbb3333bbbb3333bbbb33300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333333333333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000940000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08200000009994000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88820000009944000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
28220000000440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
022dd000000dd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0006d0000006d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0001000000000100010000010000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000700000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010100000000010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000010300000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000050003000007000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000001010101000001010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000010000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
