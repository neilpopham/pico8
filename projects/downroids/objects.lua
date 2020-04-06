weapon_types={
 {
  bullet_type=1,
  rate=10,
  sfx=4,
  sprite=61
 }
}

bullet_types={
 {
  force=3,
  draw=function(self)
   circ(self.x,self.y,2,8)
  end
 }
}


bullet={
 create=function(self,x,y,angle,type)
  local ttype=bullet_types[type]
  local o={
   x=x,
   y=y,
   angle=angle,
   force=ttype.force,
   dx=0,
   dy=0,
   complete=false
  }
  o.type=ttype
  setmetatable(o,self)
  self.__index=self
  return o
 end,
 update=function(self)
  if self.complete then return end
  self.dx=cos(self.angle)*self.force
  self.dy=-sin(self.angle)*self.force
  self.x=self.x+self.dx
  self.y=self.y+self.dy
  self:check_visibility()
 end,
 draw=function(self)
  self.type.draw(self)
 end,
 check_visibility=function(self)
  if self.x<8 or self.x>screen.width+8 or self.y<8 or self.y>screen.width+8 then
    self.complete=true
    printh("complete")
  end
 end
}
