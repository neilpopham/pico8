destructable_types={
 nil,
 {sprite=2,health=50,col=9,range=1,size={6,12}},
 {sprite=3,health=50,col=8,range=15,size={8,16}}
}

destructable={
 create=function(self,x,y,type)
  local ttype=destructable_types[type]
  local o=movable.create(self,x,y,0,0,0,4)
  o.type=ttype
  o.health=ttype.health
  return o
 end,
 hit=function(self,health)
  --smoke:create((flr(self.x/8)*8)+4,(flr(self.y/8)*8)+4,5,{col=self.type.col,size={6,12}})
 end,
 destroy=function(self,health)
  self.complete=true
  self.visible=false
  printh("destructable destroy at "..self.x..","..self.y.." with "..health)
  local size1=self.type.size[1]*(health/200)
  local size2=self.type.size[2]*(health/200)
  local size={size1,size2}
  printh("size1:"..size[1].." size2:"..size[2])
  smoke:create((flr(self.x/8)*8)+4,(flr(self.y/8)*8)+4,10,{col=self.type.col,size=size})
  smoke:create((flr(self.x/8)*8)+4,(flr(self.y/8)*8)+4,10,{col=7,size=size})
  for _,d in pairs(destructables.items) do
   if d.visible and self~=d then
    local distance=self:distance(d)
    if distance<self.type.range then
     --local strength=distance/self.type.range
     --printh("collateral:"..strength.." "..(self.type.health*strength))
     --d:damage(self.type.health*strength)
     d:damage(abs(self.health))
    end
   end
  end
 end,
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
      break
     end
    end
   end
  else
   self.y=move.ty-8
  end
  if move.ok then
   self.y=self.y+round(self.dy)
  else
   if self.dy>1 then
    particles:add(
     smoke:create(self.x+4,self.y+7,10,{size={4,8}})
    )
   end
   self.dy=0
  end
 end,
 draw=function(self)
  if not self.visible then return false end
  if self.complete then return true end
  spr(self.type.sprite,self.x,self.y)
  return false
 end
} setmetatable(destructable,{__index=movable})