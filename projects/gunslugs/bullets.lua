bullet_collection={
 create=function(self)
  local o=collection.create(self)
  o.reset(self)
  return o
 end,
 add=function(self,object)
  if object.type.player then
   self.player=self.player+1
  else
   self.enemy=self.enemy+1
  end
  collection.add(self,object)
 end,
 del=function(self,object)
  if object.type.player then
   self.player=self.player-1
  else
   self.enemy=self.enemy-1
  end
  collection.del(self,object)
 end,
 reset=function(self)
  collection.reset(self)
  self.player=0
  self.enemy=0
 end
} setmetatable(bullet_collection,{__index=collection})

-- basic bullet update function to move bullet only horizontally
bullet_update_linear=function(self,face)
 self.x=self.x+(face==dir.left and -self.ax or self.ax)
 local cx=p.camera:position()
 if self.x<(cx-self.type.w-8) or self.x>(cx+screen.width+8) then
   self.complete=true
 end
end

bullet_update_arc=function(self,face)
 if self.t==0 then
  self.angle=face==dir.left and 0.7 or 0.8
  self.angle+=round(p.dx)*0.05
  self.force=6
  self.g=0.5--drag.gravity
  self.b=0.7
 end
 local md=6
 affector.gravity(self)
 --local dx=self.dx
 --local dy=self.dy
 self.dx=mid(-md,self.dx,md)
 self.dy=mid(-md,self.dy,md)
 affector.bounce(self)
 self.x+=self.dx
 local cx=p.camera:position()
 if self.x<(cx-self.type.w-8) or self.x>(cx+screen.width+8) then
   self.complete=true
 end
 self.y+=self.dy
 if self.t>60 then
  self:destroy()
  doublesmoke(
   self.x,
   self.y,
   {20,10,10},
   {
    {col=8,size={8,12}},
    {col=7,size={8,12}},
    {col=8,life={20,40}}
   }
  )
 end
end

-- types of bullet
bullet_types={
 {
  sprite=32,
  ax=3,
  w=2,
  h=2,
  player=true,
  health=200,
  update=bullet_update_linear
 },
 {
  sprite=33,
  ax=3,
  w=2,
  h=2,
  player=false,
  health=200,
  update=bullet_update_linear
 },
 {
  sprite=34,
  ax=3,
  w=4,
  h=4,
  player=true,
  health=200,
  update=bullet_update_linear,
  range=20,
  shake=3
 },
 {
  sprite=35,
  w=4,
  h=5,
  player=true,
  health=200,
  update=bullet_update_arc,
  range=20,
  shake=3
 }
}

bullet={
 create=function(self,x,y,face,type)
  local ttype=bullet_types[type]
  local o=movable.create(
   self,
   x-(face==dir.left and ttype.w or 0),
   flr(y-ttype.h/2),
   ttype.ax,
   ttype.ay,
   ttype.dx,
   ttype.dy
  )
  o.type=ttype
  o.dir=face
  o.t=0
  o:add_hitbox(ttype.w,ttype.h)
  bullets:add(o)
 end,
 destroy=function(self)
  self.complete=true
  -- draw some smoke exploding from the thing we just hit
  local angle=self.dir==dir.left and {0.75,1.25} or {0.25,0.75}
  smoke:create(
   self.x+self.type.w/2,
   self.y+self.type.h/2,
   5,
   {col=12,angle=angle,force={2,3},size={1,3}}
  )
  -- if we are explosive then cause some collateral damage
  if self.type.range then
   p.camera:shake(self.type.shake)
   self:collateral(self.type.range,self.type.health)
  end
 end,
 update=function(self)
  -- if we're not alive then stop now
  if self.complete then return end
  -- use bullet type function to update position
  self.type.update(self,self.dir)
  -- if we're still alive
  if not self.complete then
   -- if we are a player bullet
   if self.type.player then
    -- have we hit an an enemy?
    for _,e in pairs(enemies.items) do
     if e.visible and self:collide_object(e) then
      self:destroy()
      e:damage(self.type.health)
      break
     end
    end
   -- if we're not a player bullet have we hit the player?
   elseif self:collide_object(p) then
    self:destroy()
    p:damage(self.type.health)
   end
   -- if we hit something then end now
   if self.complete then return end
   --have we hit a visible destructabe?
   local move=self:collide_destructable()
   if not move.ok then
    self:destroy()
    move.d:damage(self.type.health)
   end
   --[[
   for _,d in pairs(destructables.items) do
    if self:collide_object(d) then
     self:destroy()
     d:damage(self.type.health)
    end
   end
   ]]
  end
  self.t+=1
 end,
 draw=function(self)
  spr(self.type.sprite,self.x,self.y)
 end
} setmetatable(bullet,{__index=movable})
