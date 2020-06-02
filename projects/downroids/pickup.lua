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
  if self.complete then return end
  entity.update(self,true)
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
  smoke:create(self.x,self.y,10,{size={10,20},col=self.colour})
  smoke:create(self.x,self.y,5,{size={5,10},col=self.colour-2})
  --shells:create(self.x,self.y,30,{col=self.colour,force={2,6}})
 end
} setmetatable(pickup,{__index=entity})
