weapon_types={
 {
  bullet_type=1,
  rate=5,
  sfx=4
 }
}

bullet_types={
 {
  force=3,
  size=2,
  draw=function(self)
   --circ(self.x,self.y,2,11)
   pset(self.x,self.y,11)
  end
 }
}

bullet={
 create=function(self,x,y,angle,type)
  local bullet_type=bullet_types[type]
  local o=entity.create(self,x,y,angle,0.02,0.0125)
  o=extend(
   o,
   {
    type=bullet_type,
    ttl=40
   }
  )
  return o
 end,
 update=function(self)
  if self.complete then return end
  self.dx=cos(self.angle)*self.type.force
  self.dy=-sin(self.angle)*self.type.force
  self.x=self.x+self.dx
  self.y=self.y+self.dy
  if self.ttl==0 then
   self.complete=true
  else
   self.ttl=self.ttl-1
  end
 end,
 draw=function(self)
  self.type.draw(self)
 end
} setmetatable(bullet,{__index=entity})
