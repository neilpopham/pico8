enemy={
 create=function(self,x,y,angle,size)
  if x==nil then
   angle=rnd()
   x=64+cos(angle)*92
   y=64-sin(angle)*92
   angle=(angle+0.5+rnd()/10)%1
  end
  size=size or 12
  local o=entity.create(self,x,y,angle,0.02,0.0125)
  o=extend(
   o,
   {
    force=1,
    shoot=0,
    size=size,
    weapon=weapon_types[1],
    health=100,
    score=10,
    ghosts={},
    tta=20,
    active=false
   }
  )
  return o
 end,
 update=function(self)
  if self.complete then return end
  self.dx=cos(self.angle)*self.force
  self.dy=-sin(self.angle)*self.force
  self.x=self.x+self.dx
  self.y=self.y+self.dy
  print(self.x..","..self.y,0,0,7)
  self.ghosts={}
  if self.active then
   if self.x<self.size then
    add(self.ghosts,entity:create(128+self.x,self.y))
    if self.x<0 then
     self.x=127+self.x
    end
   end
   if self.x>128-self.size then
    add(self.ghosts,entity:create(self.x-128,self.y))
    if self.x>127 then
     self.x=self.x-127
    end
   end
   if self.y<self.size then
    add(self.ghosts,entity:create(self.x,128+self.y))
    if self.y<0 then
     self.y=127+self.y
    end
   end
   if self.y>128-self.size then
    add(self.ghosts,entity:create(self.x,self.y-128))
    if self.y>127 then
     self.y=self.y-127
    end
   end
  elseif self.tta==0 and self.x>=self.size and self.x<=127-self.size and self.y>=self.size and self.y<=127-self.size then
   self.active=true
  else
   if self.tta>0 then self.tta=self.tta-1 end
  end
  if self.tta==0 then
   for _,b in pairs(bullets.items) do
    if self:distance(b)<self.size+b.type.size then
     if self.size>3 then

      local edx=cos(self.angle)*self.size/2
      local edy=-sin(self.angle)*self.size/2

      local a1=b.angle+0.25%1
      local a2=b.angle+0.75%1
      local dx1=cos(a1)*3
      local dy1=-sin(a1)*3
      local dx2=cos(a2)*3
      local dy2=-sin(a2)*3

      local dx=edx+dx1
      local dy=edy+dy1
      printh("===")
      printh(edx..","..edy.." and "..dx..","..dy)
      local angle=atan2(dx,-dy)
      enemies:add(enemy:create(self.x,self.y,angle,self.size/2))
      dx=edx+dx2
      dy=edy+dy2
      printh(edx..","..edy.." and "..dx..","..dy)
      angle=atan2(dx,-dy)
      enemies:add(enemy:create(self.x,self.y,angle,self.size/2))


      --enemies:add(enemy:create(self.x,self.y,a1,self.size/2))
      --enemies:add(enemy:create(self.x,self.y,a2,self.size/2))
     end
     self:destroy()
     return
    end
   end
  end
 end,
 draw=function(self)
  --if self.complete then return end
  --printh(self.x..","..self.y)
  circ(self.x,self.y,self.size,self:visible() and 8 or 6)
  for _,g in pairs(self.ghosts) do
   circ(g.x,g.y,self.size,g:visible() and 8 or 5)
  end
 end,
 destroy=function(self)
  entity.destroy(self)
 end
} setmetatable(enemy,{__index=entity})
