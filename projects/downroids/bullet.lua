weapon_types={
 {
  bullet_type=1,
  rate=10,
  sfx=0
 }
}

bullet_types={
 {
  force=3,
  size=2,
  draw=function(self)
   circ(self.x,self.y,2,8)
  end
 }
}


bullet={
 create=function(self,x,y,angle,type)
  local ttype=bullet_types[type]
  local o=entity.create(self,x,y,angle,0.02,0.0125)
  o=extend(
   o,
   {
    type=ttype,
    ttl=40
   }
  )
  return o
 end,
 update=function(self)
  if self.complete then return end
  self.dx=cos(self.angle)*self.type.force
  self.dy=-sin(self.angle)*self.type.force
  self.dx=self.dx-p.dx
  self.dy=self.dy-p.dy
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
