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
    dx=0,
    dy=0,
    ox=0,
    sx=x,
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
 colliding_with=function(self,types)
  local matches={}
  for i,entity in pairs(entities) do
   if entity:is(types) and self:collide_object(entity) then
    add(matches,entity)
   end
  end
  return matches
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
  if self.complete then return false end
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
  return true
 end,
 draw=function(self,sprite)
  if self.complete then return false end
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
  return true
 end
} setmetatable(movable,{__index=object})

local animatable={
 create=function(self,...)
  local o=movable.create(self,...)
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
