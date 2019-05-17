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
  return self.sliding or not self.active-- or self.queued or not self.active
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
  o.ox=0
  o.min={dx=0.05,dy=0.05}
  o.max={dx=dx,dy=dy}
  o.complete=false
  o.health=0
  o.sliding=false
  o.paused=false
  o.tick=0
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
  local x=self.x+round(self.dx)
  if self.dx>0 then x=x+7 end
  x=x%128
  return self:can_move({{x,self.y},{x,self.y+7}},1)
 end,
 --[[
 can_move_y=function(self)
  local y=self.y+round(self.dy)
  if self.dy>0 then y=y+7 end
  y=y%128
  return self:can_move({{self.x,y},{self.x+7,y}})
 end,
 ]]
 can_move_y=function(self)
  local y=(self.y+8)%128
  local x=(self.x+round(self.dx)+(self.dx>0 and 7 or 0))%128
  --local x=self.x+round(self.dx)
  --if self.dx>0 then x+=7 end
  --x=x%128
  local move=self:can_move({{x,y}})
  return {ok=not move.ok,tx=x-x%8,ty=y-y%8}
  --move.tx=x-x%8
  --move.ty=y-y%8
  --move.ok=not move.ok
  --return move
 end,
 fits_cell=function(self)
  return self.x%8==0 and self.y%8==0
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
  --if self.x>=57 and self.x<=64 then self.x=round(self.x/8)*8 end
  --if self.y>=57 and self.y<=64 then self.y=round(self.y/8)*8 end
  self.pane=self:get_pane()
  self.sliding=self.pane.sliding
  self.px=self.x-self.pane.x
  self.py=self.y-self.pane.y
  return self.sliding
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
   return true
  end
  if self.sliding then
   self.x=self.pane.x+self.px
   self.y=self.pane.y+self.py
  else
   if self.paused then
    if self.tick==2 then
     self.paused=false
     self.tick=0
    end
    self.tick+=1
   end
  end
  if self.x<=-8 then self.x+=128 end
  if self.x>=128 then self.x-=128 end
  if self.y<=-8 then self.y+=128 end
  if self.y>=128 then self.y-=128 end
  return self.sliding
 end,
 draw=function(self)
  -- do nothing
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
 --update=function(self)
  --movable.update(self)
 --end,
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
  local o=animatable.create(self,x,y,0.25,0,1,0)
  o.anim:add_stage("still",1,false,{20},{17})
  o.anim:add_stage("walk",5,true,{20,21,22,21},{17,18,19,18})
  o.anim:add_stage("walk_turn",3,false,{32,33,34},{34,33,32},"still")
  o.anim:init("still",dir.right)
  o.sx=x
  o.sy=y
  o:reset()
  o.max.health=o.health
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

   local face=self.anim.current.face
   local stage=self.anim.current.stage
   local move

   -- checks for direction change
   local check=function(self,stage,face)
    if face~=self.anim.current.face then
     printh("changing dir")
     if stage=="still" then stage="walk" end
     if not self.anim.current.transitioning then
      self.anim.current:set(stage.."_turn")
      self.anim.current.transitioning=true
     end
    end
   end

   if not self.still then
    if self:fits_cell() and self.x~=self.ox then
     printh(self.x.." "..self.ox.." "..self.dx.." (done)")
     self.still=true
     self.anim.current:set("still")
    elseif not self.anim.current.transitioning then
     self.dx=self.dx*1.25
     self.dx=mid(-self.max.dx,self.dx,self.max.dx)

     move=self:can_move_x()
     if move.ok then
      move=self:can_move_y()
      if move.ok then
       self.x=self.x+round(self.dx)
       printh(self.x.." "..self.ox.." "..self.dx)
       if not self.anim.current.transitioning then
        self.anim.current:set(self.dx==0 and "still" or "walk")
       end
      else
       printh("will fall "..move.tx..","..move.ty)
      end
     end

     if not move.ok then
      self.x=move.tx+(self.dx>0 and -8 or 8)
      self.dx=0
      self.still=true
      printh("resetting to "..self.x)
      self.anim.current:set("still")
     end

    end
   end

   if self.still then

    -- left button pressed
    if btn(pad.left) then
     self.anim.current.face=dir.left
     check(self,stage,face)
     if stage=="still" then self.anim.current:set("walk") end
     printh(self.dx)
     if round(self.dx)==0 then self.dx=-self.ax end
     self.still=false
     self.ox=self.x
     printh("moving left ")
    -- right button pressed
    elseif btn(pad.right) then
     self.anim.current.face=dir.right
     check(self,stage,face)
     if stage=="still" then self.anim.current:set("walk") end
     printh(self.dx)
     if round(self.dx)==0 then self.dx=self.ax end
     self.still=false
     self.ox=self.x
     printh("moving right")
    -- still and no button pressed
    else
     self.dx=self.dx*drag.ground
     if abs(self.dx)==0.01 then self.dx=0 end
    end
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
  self.tick=0
 end,
 destroy=function(self)
 end,
 hit=function(self)
 end,
 update=function(self)
  if self.complete then return end

  local current=self.anim.current
  local face=current.face
  local stage=current.stage
  local move

  animatable.update(self)
  if tile.sliding then return end

  if face==dir.left then
   self.dx=self.dx-self.ax
  else
   self.dx=self.dx+self.ax
  end
  self.dx=mid(-self.max.dx,self.dx,self.max.dx)

  move=self:can_move_x()
  if move.ok then
   move=self:can_move_y()
    if move.ok then
     self.x=self.x+round(self.dx)
    end
  end
  if not move.ok then
   self.x=move.tx+(self.dx>0 and -8 or 8)
   self.anim.current.face=face==dir.left and dir.right or dir.left
   self.dx=0
   if not self.anim.current.transitioning then
    self.anim.current:set(stage.."_turn")
    self.anim.current.transitioning=true
   end
  end

  if self:collide_object(p) then
   printh("collided with player")
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
  o.anim:add_stage("still",1,false,{16},{16})
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
  if tile.sliding then return end

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

enemies,entities,p,b=enemy_collection:create(),{}

-- turn placeholders into objects
function placeholders()
 local s
 for y=0,15 do
  for x=0,15 do
   s=mget(x,y)
   if s==17 then
    p=player:create(x*8,y*8)
    add(entities,p)
    mset(x,y,0)
   elseif s==16 then
    b=block:create(x*8,y*8)
    add(entities,b)
    mset(x,y,0)
   elseif s==23 then
    local e=enemy:create(x*8,y*8)
    enemies:add(e)
    add(entities,e)
    mset(x,y,0)
   end
  end
 end
end

function _init()
 printh("####")
 printh("init")
 printh("####")
 tile:init()
 placeholders()

 -- turn placeholders into objects
 --[[
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
]]
end

function _update60()
 tile:update()
 enemies:update()
 p:update()
 b:update()
end

function _draw()
 cls()
 rectfill(0,0,63,63,1)
 rectfill(64,64,127,127,1)
 tile:draw()
 enemies:draw()
 p:draw()
 b:draw()

 -- draw beam flickr!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 --local y=8+rnd(24)
 --line(32,y,39,y,1)

end

function round(x) return flr(x+0.5) end

__gfx__
00000000777777760000000000000000aaaaaaa97777777607c77c701cc77cc10000000000000000000000000000000000000000000000000000000000000000
000000007666666d0000000000000000a99999947666666d7cccccc71cc77cc10000000000000000000000000000000000000000000000000000000000000000
000000007666666d0000000000000000a99999947666666dcccccccc1cc77cc10000000000000000000000000000000000000000000000000000000000000000
000000007666666d00000b3000000000a99999947666666d7cccccc71cc77cc10000000000000000000000000000000000000000000000000000000000000000
000000007666666d0000bbb300000000a99999947666666d7cccccc71cc77cc10000000000000000000000000000000000000000000000000000000000000000
000000007666666d00003b3300000000a99999947666666dcccccccc1cc77cc10000000000000000000000000000000000000000000000000000000000000000
000000007666666d0006d33000000000a99999947666666d7cccccc71cc77cc10000000000000000000000000000000000000000000000000000000000000000
000000006ddddddd0006d00000000000944444446ddddddd07c77c701cc77cc10000000000000000000000000000000000000000000000000000000000000000
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
0001000001010001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0100000001010101010101010000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0003000007000001001700000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010001010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1000000003000001010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010000000101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000110000010002000017010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010100000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
