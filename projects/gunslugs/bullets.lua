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

bullet_update_linear=function(self,face)
 self.x=self.x+(face==dir.left and -self.ax or self.ax)
 local cx,cy=p.camera:position()
 if self.x<(cx-self.type.w) or self.x>(cx+screen.width) then
   printh("bullet complete:"..self.x)
   self.complete=true
 end
end

bullet_types={
 {sprite=32,ax=3,ay=3,w=2,h=2,player=true,health=200,update=bullet_update_linear}
}

bullet={
 create=function(self,x,y,dir,type)
  printh("bullet:"..x) -- ############################################################
  local btype=bullet_types[type]
  local o=movable.create(self,x,y,btype.ax,btype.ay)
  o.type=btype
  o.dir=dir
  o:add_hitbox(btype.w,btype.h)
  --if o.type.player then
   --o.x=o.x-o.hitbox.x+4-flr(o.type.w/2)
  --end
  o.t=0
  o.phase=0
  return o
 end,
 destroy=function(self)
  self.complete=true
  local x=self.x+(self.type.w/2)
  local y=self.y+(self.type.h/2)
  --explosions:add(pixels:create(x,y,{7,8,9,10},10))
  --explosions:add(small_smoke:create(x,y,{6,5,1},8+self.type.w))
 end,
 update=function(self)
  self.type.update(self,self.dir)
  self.t=self.t+1
  if not self.complete then
   if self.type.player then
    if enemies.count>0 then
     for _,e in pairs(enemies.items) do
      if self:collide_object(e) then
       self:destroy()
       e:damage(self.type.health)
       break
      end
     end
    end
   else
    if self:collide_object(p) then
     self:destroy()
     p:damage(self.type.health)
    end
   end
  end
 end,
 draw=function(self)
  if self.complete then return true end
  spr(self.type.sprite,self.x,self.y)
  return false
 end
} setmetatable(bullet,{__index=movable})