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
  o.cols={11,7,3,11}
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
  if not animatable.update(self) then return end
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
    ----printh(self.x.." "..self.ox.." "..self.dx.." (done)")
    ----printh("moved from "..self.ox.." to "..self.x.." dx:"..self.dx.." (done) b.x:"..b.x)
    self.still=true
    self.anim.current:set("still")
    --self.dx=0
   elseif not self.anim.current.transitioning then
    self.dx=self.dx*1.25
    --self.dx=self.dx+self.ax
    self.dx=mid(-self.max.dx,self.dx,self.max.dx)

    local move={ok=true}

    if self:collide_object(b) then
     ----printh("player collided with block")
     ----printh("p.x:"..self.x.." p.dx:"..self.dx.." b.x"..b.x)
     b.dx=self.dx
     move=b:ismovable()
     if not move.ok then
      self:setstill(self.x-self.x%8)
      self.anim.current:set("still")
      --printh("block not movable")
     end
    end

    if move.ok then

     move=self:ismovable()
     if move.ok then
      ----printh("player can move")
      self.x=self.x+round(self.dx)
      self:checkbounds()
      if not self.anim.current.transitioning then
       self.anim.current:set(self.dx==0 and "still" or "walk")
      end
     end

     if not move.ok then
      self:setstill(move.tx+(self.dx>0 and -8 or 8))
      self.anim.current:set("still")
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
    --printh("moving left")
    flagmoving()

   -- right button pressed
   elseif btn(pad.right) then
    self.anim.current.face=dir.right
    check(self,stage,face)
    if round(self.dx)==0 then self.dx=self.ax end
    --printh("moving right")
    flagmoving()

   -- still and no button pressed
   else
    self.dx=self.dx*drag.ground
    if abs(self.dx)<self.min.dx then self.dx=0 end
   end

  end
 end
} setmetatable(player,{__index=animatable})

local enemy={
 create=function(self,x,y)
  local o=animatable.create(self,x,y,0.06,0,1,0)
  o.anim:add_stage("walk",5,true,{26,27,28,27},{23,24,25,24})
  o.anim:add_stage("walk_turn",5,false,{29,30,31},{31,30,29},"walk")
  o.anim:init("walk",dir.right)
  --o:reset()
  --o.max.health=o.health
  o.type=2
  o.cols={2,7,8,8}
  return o
 end,
 --[[
 reset=function(self)
  self.complete=false
  self.health=1500
  self.x=self.sx
  self.y=self.sy
  self.tick=0
 end,
 hit=function(self)
 end,
 ]]
 destroy=function(self)
  self.complete=true
 end,
 update=function(self)
  if not animatable.update(self) then return end
  if tile.sliding then return end
  local current=self.anim.current
  if current.transitioning then return end -- don't move while turning
  local face=current.face
  local stage=current.stage
  if face==dir.left then
   self.dx=self.dx-self.ax
  else
   self.dx=self.dx+self.ax
  end
  self.dx=mid(-self.max.dx,self.dx,self.max.dx)
  local move={ok=true} -- ,tx=flr(self.x/8)*8}
  if self:collide_object(b) then
   ----printh("enemy collided with block")
   ----printh("e.tx:"..move.tx.." e.x:"..self.x.." e.dx:"..self.dx.." b.x:"..b.x)
   b.dx=self.dx
   move=b:ismovable()
   if not move.ok then
    ----printh("block not movable "..self.x.." vs "..(self.x%8))
    self:setstill(self.x-self.x%8)
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
   current.face=face==dir.left and dir.right or dir.left
   self.dx=0
   --self.x=move.tx+(self.dx>0 and -8 or 8)
   --if not self.anim.current.transitioning then
   current:set(stage.."_turn")
   current.transitioning=true
   --end
  end
  if self:collide_object(p) then
   --printh("collided with player")
   p:destroy()
  end
 end
} setmetatable(enemy,{__index=animatable})

local block={
 create=function(self,x,y)
  local o=movable.create(self,x,y,1,1,1,1)
  o:reset()
  o.max.health=o.health
  o.type=3
  o.cols={4,4,8,9}
  o.moving=false
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
  if not movable.update(self) then return end
  if tile.sliding then return end

  if not self.still then
   if self:finished_moving() then
    self:setstill(self.x)
  -- else
    --self.dx=mid(-self.max.dx,self.dx*1.25,self.max.dx) -- rely on move contact until dx==1?
   end
  end

  local matches=self:colliding_with({1,2})
  for _,entity in pairs(matches) do
   --printh("block colliding with  type:"..entity.type)
  end
  if #matches>0 then
   local dx=self.dx
   for _,entity in pairs(matches) do
    if entity.type==1 then
     dx=entity.dx
     break
    elseif dx==0 and self.dx~=0 and sgn(entity.dx)==sgn(self.dx) then
     dx=entity.dx
     break
    elseif dx==0 then
     dx=entity.dx
    end
   end
   --printh("dx:"..dx)
   local move=self:ismovable()
   if move.ok then
    self.still=false
    self.dx=dx
    self.ox=self.x
   else
    self:setstill(move.tx+(self.dx>0 and -8 or 8))
   end
  end

--[[
  for i,entity in pairs(entities) do
   if entity:is({1,2}) and self:collide_object(entity) then
    --printh("block collided with type "..entity.type)
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
]]

  if not self.still then
   self.x+=round(self.dx)
   self:checkbounds()
  end

 end,
 draw=function(self)
  movable.draw(self,4)
 end
} setmetatable(block,{__index=movable})

local door={
 create=function(self,x,y)
  local o=movable.create(self,x,y,1,1,1,1)
  --o:reset()
  o.max.health=o.health
  o.type=4
  return o
 end,
 --[[
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
 ]]
 update=function(self)
  if not movable.update(self) then return end
  if tile.sliding then return end
  --self.tick=(self.tick+1)%16
  if self:collide_object(b) and b:fits_cell() then
   --printh("BLOCK HIT DOOR!!!!!")
  end
  self.tick+=1&7
 end,
 draw=function(self)
  if self.complete then return end
  if not movable.draw(self,5) then return end

  --[[
  local x,y,x2,y2,t=self.x,self.y,self.x+7,self.y+7,flr(self.tick/2)
  pset(x+t,y,7)
  pset(x2,y+t,7)
  pset(x2-t,y2,7)
  pset(x,y2-t,7)
  ]]

  --[[
  for i=1,2 do
   pset(self.x-1,self.y+rnd(7),12)
   pset(self.x+8,self.y+rnd(7),12)
   pset(self.x+rnd(7),self.y-1,12)
  end
  ]]

  --[[
  for i=1,12 do
   local a=(self.tick-i*6)/64
   --pset(self.x+4+cos(a)*7,self.y+4-sin(a)*7,12)
   line(self.x+4,self.y+4,self.x+4+cos(a)*6,self.y+4-sin(a)*6,12)
  end
  ]]

  --[[
  for y=0,15 do
   for x=0,15 do
    local s=mget(x,y)
    if s>0 then pset(self.x+x\2,self.y+y\2,7) end
   end
  end
  for k,e in pairs(entities) do
   pset(self.x+e.x\16,self.y+e.y\16,e.cols and e.cols[1] or 8)
  end
  ]]

  --[[
  for i=1,self.tick do
   pset(self.x+1+rnd(6),self.y+1+rnd(6),7)
   --pset(self.x+rnd(8),self.y+rnd(8),7)
  end
  ]]

  --[[
  local y=self.y+self.tick\4
  line(self.x,y,self.x+7,y,7)
  for i=1,3 do
   pset(self.x+rnd(8),y+1,7)
   if y>self.y then pset(self.x+rnd(8),y-1,7) end
  end
  ]]

 end
} setmetatable(door,{__index=movable})

local portal={
 create=function(self,x,y,i)
  local o=movable.create(self,x,y)
  o.index=i
  o.odx={}
  o.type=5
  return o
 end,
 update=function(self)
  if not movable.update(self) then return end
  if tile.sliding then return end
  for i,entity in pairs(entities) do
   if entity:isnt({self.type}) and self:collide_object(entity) and entity:fits_cell() then
    if self.odx[i]==nil then
     --printh("transporting type "..entity.type.." with dx "..entity.dx) -- ##############################
     for _,portal in pairs(portals.items) do
      if portal.index==self.index and portal~=self then
       portal.odx[i]=entity.dx
       entity.y=portal.y
       entity:setstill(portal.x)
       beam:create(self.x,self.y,entity.cols,20)
       break
      end
     end
    else
     --printh("receiving type "..entity.type.." with dx "..self.odx[i]) -- ##############################
     entity.dx=self.odx[i]
     if entity.dx==0 then
      entity.dx=entity.max.dx
      entity.anim:init("walk",dir.right)
     end
     local move=entity:ismovable()
     if not move.ok then entity:flip() end
     entity.still=false
     beam:create(self.x,self.y,entity.cols,20)
     self.odx[i]=nil
    end
   end
  end
 end,
 draw=function(self)
  if self.complete then return end
  if not movable.draw(self,7) then return end
  movable.draw(self,7)
  for i=1,3 do
   pset(self.x+1+rnd(6),self.y+6-i\3,11)
  end
 end
} setmetatable(portal,{__index=movable})

local lift={
 create=function(self,x,y)
  local o=movable.create(self,x,y,0,1,0,1)
  o.type=6
  o.dy=-1
  o.tick=60
  return o
 end,
 update=function(self)
  if not movable.update(self) then return end
  if tile.sliding then return end
  local tx,ty=self:gettile()
  --printh(self.t)
  for i,entity in pairs(entities) do
   if entity.y==self.y-8 and entity.x>self.x-8 and entity.x<self.x+8 and entity:isnt({4,5}) then
    mset(tx,ty,8)
    self.t=max(self.tick,1)
    return
   end
  end
  --printh(self.t)
  if self.tick>0 then
   self.tick-=1
   if self.tick==0 then
    mset(tx,ty,0)
   end
   return
  end
  self.y+=self.dy
  local tx,ty=self:gettile()
  if self:fits_cell() then
   for _,o in pairs({-1,1}) do
    local s=self:mapget(self.x\8+o,self.y\8)
    if fget(s,0) then
     --if self.dy<0 then smoke:create(self.x,self.y+6,{5,6,7},4) end
     self.dy=self.dy*-1
     mset(tx,ty,8)
     self.tick=60
     break
    end
   end
  end
 end,
 draw=function(self)
  if self.complete then return end
  movable.draw(self,8)
  if self.tick==0 and self.dy<0 then
   if self.y%8==0 then smoke:create(self.x,self.y+6,{13},2) end
   for i=1,3 do
    --pset(self.x+2+i\3+rnd(4-i\2),self.y+6+i\2,9+i\3)
    pset(self.x+2+rnd(4),self.y+5+i,9+i\3)
   end
  end
 end
} setmetatable(lift,{__index=movable})

local fryer={
 create=function(self,x,y,i)
  local o=movable.create(self,x,y)
  o.type=7
  return o
 end,
 update=function(self)
  if not movable.update(self) then return end
  if tile.sliding then return end
  for i,entity in pairs(entities) do
   if entity.y==self.y-8 and entity.x==self.x and entity:is({1,2}) then
    printh("FRY THEM!!!!")
    entity.complete=true
    beam:create(self.x,self.y,{12,7},20)
   end
  end
 end,
 draw=function(self)
  if self.complete then return end
  movable.draw(self,9)
  for i=1,3 do
   pset(self.x+1+rnd(6),self.y-1-i\3,rnd({7,12}))
  end
 end
} setmetatable(fryer,{__index=movable})
