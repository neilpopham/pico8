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
 if self.x<(cx-self.type.w) or self.x>(cx+screen.width) then
   self.complete=true
 end
end

-- types of bullet
bullet_types={
 {sprite=32,ax=3,ay=3,w=2,h=2,player=true,health=200,update=bullet_update_linear},
 {sprite=33,ax=3,ay=3,w=2,h=2,player=false,health=200,update=bullet_update_linear}
}

bullet={
 create=function(self,x,y,dir,type)
  local ttype=bullet_types[type]
  local o=movable.create(self,x,y,ttype.ax,ttype.ay)
  o.type=ttype
  o.dir=dir
  o:add_hitbox(ttype.w,ttype.h)
  return o
 end,
 destroy=function(self)
  self.complete=true
  -- draw some smoke exploding from the thing we just hit
  local x=self.x+(self.type.w/2)
  local y=self.y+(self.type.h/2)
  local angle=self.dir==dir.left and {0.75,1.25} or {0.25,0.75}
  smoke:create(x,y,5,{col=12,angle=angle,force=mrnd({2,3},false),size={1,3}})
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
    -- have we hit an anemeny?
    for _,e in pairs(enemies.items) do
     if self:collide_object(e) then
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
   --have we hit avisible  destructabe?
   for _,d in pairs(destructables.items) do
    if self:collide_object(d) then
     self:destroy()
     d:damage(self.type.health)
    end
   end
  end
 end,
 draw=function(self)
  spr(self.type.sprite,self.x,self.y)
 end
} setmetatable(bullet,{__index=movable})
