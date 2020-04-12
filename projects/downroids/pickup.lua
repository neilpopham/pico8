pickup={
 create=function(self)
  local angle=rnd()
  local x=p.x+cos(angle)*screen.width/2
  local y=p.y-sin(angle)*screen.height/2
  angle=(angle+0.5+rnd()/7)%1
  local type=mrnd({1,2})
  local o=entity.create(self,x,y,angle,0.02,0.0125)
  o=extend(
   o,
   {
    force=1,
    ttl=1000,
    size=4,
    health=2,
    score=100,
    type=type,
    colour=type==1 and 11 or 15
   }
  )
  return o
 end,
 update=function(self)
  --entity.update(self)
  if self.complete then return end
  self.dx=cos(self.angle)*self.force
  self.dy=-sin(self.angle)*self.force
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
  circ(self.x,self.y,4,self.colour)
  circ(self.x,self.y,2,self.colour-2)
 end,
 destroy=function(self)
  self.complete=true
  smoke:create(self.x,self.y,10,{size={5,10},col=5})
  smoke:create(self.x,self.y,5,{size={2,5},col=8})
 end
} setmetatable(enemy,{__index=entity})
