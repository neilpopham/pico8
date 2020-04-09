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
    score=10
   }
  )
  return o
 end,
 update=function(self)
  if self.complete then return end
  self.dx=cos(self.angle)*self.force
  self.dy=-sin(self.angle)*self.force
  self.dx=self.dx-p.dx
  self.dy=self.dy-p.dy
  self.x=self.x+self.dx
  self.y=self.y+self.dy

  --[[
  if self.x<0 then
   self.x=screen.x2+self.x
  end
  if self.x>screen.x2 then
   self.x=self.x-screen.x2
  end
  if self.y<0 then
   self.y=screen.y2+self.y
  end
  if self.y>screen.y2 then
   self.y=self.y-screen.y2
  end
  ]]

  if (abs(p.x-self.x)>screen.width*2) or (abs(p.y-self.y)>screen.height*2) then
   self.complete=true
  end

  for _,b in pairs(bullets.items) do
   local d=self:distance(b)
   if d<4+b.type.size then
    self.complete=true
    b.complete=true
    smoke:create(self.x-cos(self.angle),self.y+sin(self.angle),10,{size={5,10},col=5})
    smoke:create(self.x-cos(self.angle),self.y+sin(self.angle),5,{size={2,5},col=7})
    p.score=p.score+self.score
   end
  end

  --[[
  if self.ttl==0 then
   --self:check_visibility()
  else
   self.ttl=self.ttl-1
  end

  ]]

 end,
 draw=function(self)
  circ(self.x,self.y,4,6)
 end,
 destroy=function(self)
  self.complete=true
  smoke:create(self.x,self.y,10,{size={5,10},col=9})
  smoke:create(self.x,self.y,5,{size={2,5},col=11})
 end
} setmetatable(enemy,{__index=entity})
