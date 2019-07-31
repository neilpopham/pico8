destructable_types={
 nil,
 {sprite=2,health=50,col=9,size={6,12}},
 {sprite=3,health=50,col=8,size={10,16},range=15,shake=2},
 {sprite=4,health=50,col=11,size={16,24},range=20,shake=3}
}

destructable={
 create=function(self,x,y,type)
  local ttype=destructable_types[type]
  local o=movable.create(self,x,y,0,0,0,4)
  o.type=ttype
  o.health=ttype.health
  return o
 end,
 destroy=function(self,health)
  self.complete=true
  self.visible=false
  printh("destructable destroy at "..self.x..","..self.y.." with "..health)
  local size={self.type.size[1]*(health/200),self.type.size[2]*(health/200)}
  printh("size1:"..size[1].." size2:"..size[2]) -- ########################
  doublesmoke(
   (flr(self.x/8)*8)+4,
   (flr(self.y/8)*8)+4,
   {10,5,5},
   {
    {col=self.type.col,size=size},
    {col=7,size=size},
    {col=self.type.col,life={20,30}}
   }
  )
  -- if we are explosive then cause some collateral damage
  if self.type.range then
   p.camera:shake(self.type.shake)
   self:collateral(self.type.range,abs(self.health))
  end
 end,
 --[[
 foobar=function(self,strength,health,dir)
  self:damage(health)
 end,
 ]]
 update=function(self)
  if not self.visible then return end
  self.dy=self.dy+0.25
  self.dy=mid(-self.max.dy,self.dy,self.max.dy)
  move=self:can_move_y()
  if move.ok then
   for _,d in pairs(destructables.items) do
    if d.visible and self~=d then
     if self:collide_object(d) then
      move.ok=false
      move.ty=d.y
      break
     end
    end
   end
  end
  if move.ok then
   self.y=self.y+round(self.dy)
  else
   --self.y=move.ty-8
   if self.dy>1 then
    particles:add(
     smoke:create(self.x+4,self.y+7,10,{size={4,8}})
    )
    sfx(2)
   end
   self.dy=0
  end
 end,
 draw=function(self)
  if not self.visible then return end
  spr(self.type.sprite,self.x,self.y)
 end
} setmetatable(destructable,{__index=movable})
