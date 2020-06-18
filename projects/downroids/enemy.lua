enemy={
 create=function(self)
  local angle=rnd()
  local x=p.x+cos(angle)*screen.width/2
  local y=p.y-sin(angle)*screen.height/2
  angle=(angle+0.5+rnd()/10)%1
  local o=entity.create(self,x,y,angle,0.02,0.0125)
  o=extend(
   o,
   {
    force=1,
    ttl=100,
    shoot=0,
    size=4,
    weapon=weapon_types[1],
    health=100,
    score=10,
    sfx=1
   }
  )
  return o
 end,
 update=function(self)
  if self.complete then return end
  entity.update(self,true)
  if (abs(p.x-self.x)>screen.width*2) or (abs(p.y-self.y)>screen.height*2) then
   self.complete=true
  end
  for _,b in pairs(bullets.items) do
   local d=self:distance(b)
   if d<4+b.type.size then
    self:destroy()
    b.complete=true
    p.score=p.score+self.score
   end
  end
 end,
 draw=function(self)
  --circ(self.x,self.y,4,6)
  if self.visible then circ(self.x,self.y,4,6) else circ(self.x,self.y,4,2) end
 end,
 destroy=function(self)
  self.complete=true
  smoke:create(self.x,self.y,7,{size={10,20},col=6})
  smoke:create(self.x,self.y,4,{size={5,10},col=7})
  smoke:create(self.x,self.y,3,{size={2,5},col=8})

  shells:create(self.x,self.y,10,{col=3,force={1,3}})
  shells:create(self.x,self.y,10,{col=2,force={2,6}})

  sfx(self.sfx)
 end
} setmetatable(enemy,{__index=entity})
