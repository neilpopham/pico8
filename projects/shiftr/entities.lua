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
   --printh("enemy collided with block")
   --printh("e.tx:"..move.tx.." e.x:"..self.x.." e.dx:"..self.dx.." b.x:"..b.x)
   b.dx=self.dx
   move=b:ismovable()
   if not move.ok then
    --printh("block not movable "..self.x.." vs "..(self.x%8))
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
   printh("collided with player")
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
  self.tick=(self.tick+1)%16
  if self:collide_object(b) and b:fits_cell() then
   printh("BLOCK HIT DOOR!!!!!")
  end
 end,
 draw=function(self)
  if self.complete then return end
  if not movable.draw(self,5) then return end
  local x,y,x2,y2,t=self.x,self.y,self.x+7,self.y+7,flr(self.tick/2)
  pset(x+t,y,7)
  pset(x2,y+t,7)
  pset(x2-t,y2,7)
  pset(x,y2-t,7)
 end
} setmetatable(door,{__index=movable})

local portal={
 create=function(self,x,y)
  local o=movable.create(self,x,y)
  o.odx={}
  --o:reset()
  --o.max.health=o.health
  o.type=5
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

  for i,entity in pairs(entities) do
   if entity:isnt({self.type}) and self:collide_object(entity) and entity:fits_cell() then
    if self.odx[i]==nil then
     printh("transporting type "..entity.type.." with dx "..entity.dx) -- ##############################
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
     printh("receiving type "..entity.type.." with dx "..self.odx[i]) -- ##############################
     entity.dx=self.odx[i]
     entity.still=false
     beam:create(self.x,self.y,entity.cols,20)
    end
   else
    self.odx[i]=nil
   end
  end
 end,
 draw=function(self)
  if self.complete then return end
  if not movable.draw(self,7) then return end
  movable.draw(self,7)
  pset(self.x+1+rnd(6),self.y+6,11)
  pset(self.x+1+rnd(6),self.y+6,11)
  pset(self.x+1+rnd(6),self.y+5,11)
 end
} setmetatable(portal,{__index=movable})
