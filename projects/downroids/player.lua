player={
 create=function(self)
  local o=entity.create(self,flr(screen.width/2),flr(screen.height/2),0,0.02,0.0125)
  --[[
  o=extend(
   o,
   {
    shoot=0,
    shield={on=false,health=10,size=11,colour=15,max=10},
    weapon=weapon_types[1],
    health=10,
    max=10,
    score=0
   }
  )
  ]]
  --o.btn1=button:create(pad.btn1)
  o:reset()
  return o
 end,
 update=function(self)

  if self.complete then
   self.df=0
   self.force=self.force*0.98
   entity.update(self)
   if self.force==0 and btnp(pad.btn1) then
    self:reset()
   end
   return
  end

  -- rotation
  if btn(pad.left) then
   self.angle=self.angle-self.da
  elseif btn(pad.right) then
   self.angle=self.angle+self.da
  end
  self.angle=self.angle%1

  -- shield
  self.shield.on=btn(pad.btn2) and self.shield.health>0

  -- fire
  if not self.shield.on and btn(pad.btn1) then
   self.df=self.df+0.1
   if self.shoot==0 then
    bullets:add(bullet:create(self.x,self.y,(self.angle+0.5)%1,self.weapon.bullet_type))
    smoke:create(self.x-cos(self.angle)*10,self.y+sin(self.angle)*10,10,{size={5,10},col=2})
    smoke:create(self.x-cos(self.angle)*10,self.y+sin(self.angle)*10,5,{size={2,5},col=4})
    self.shoot=self.weapon.rate
   end
  else
   self.df=0
   self.force=self.force*0.95
  end
  if self.shoot>0 then self.shoot-=1 end

  entity.update(self)

  local size=self.shield.on and 11 or 5
  for _,e in pairs(enemies.items) do
   local d=self:distance(e)
   if d<size+e.size then
    if self.shield.on then
     self.shield.health=self.shield.health-1
     self.score=self.score+e.score
    else
     self:damage(1)
    end
    e:destroy()
   end
  end

  for _,k in pairs(pickups.items) do
   local d=self:distance(k)
   if d<size+k.size then
    if not self.shield.on then
     self.score=self.score+k.score
     if k.type==1 then
      self.health=min(self.health+k.health,self.max)
     elseif k.type==2 then
      self.shield.health=min(self.shield.health+k.health,self.shield.max)
     else

     end
    end
    k:destroy()
   end
  end


 end,
 draw=function(self)
  if self.complete then
   if self.force==0 then
    dprint("press \142 to restart",28,61,8,2)
    if btnp(pad.btn1) then
     self:reset()
    end
   end
   return
  end
  --if self.complete then return end
  local x1=self.x+cos(self.angle-0.4)*7
  local x2=self.x+cos(self.angle-0.25)*6
  local y1=self.y-sin(self.angle-0.4)*7
  local y2=self.y-sin(self.angle-0.25)*6
  line(x1,y1,x2,y2,5)
  circ(x1,y1,1,7)
  x1=self.x+cos(self.angle+0.4)*7
  x2=self.x+cos(self.angle+0.25)*6
  y1=self.y-sin(self.angle+0.4)*7
  y2=self.y-sin(self.angle+0.25)*6
  line(x1,y1,x2,y2,5)
  circ(x1,y1,1,7)
  circ(self.x+flr(cos(self.angle)*1.2),self.y-flr(sin(self.angle)*1.2),2,6)
  circ(self.x,self.y,4,11)
  if self.shield.on then
   if t%4==0 then
    self.shield.size=self.shield.size==12 and 11 or 12
    self.shield.colour=self.shield.colour==15 and 14 or 15
   end
   circ(self.x,self.y,self.shield.size,self.shield.colour)
  end
 end,
 destroy=function(self)
  entity.destroy(self)
  smoke:create(self.x,self.y,20,{size={20,30},col=11})
  smoke:create(self.x+flr(cos(self.angle)*1.2),self.y-flr(sin(self.angle)*1.2),10,{size={10,20},col=6})
  local x1=self.x+cos(self.angle-0.4)*7
  local x2=self.x+cos(self.angle-0.25)*6
  local y1=self.y-sin(self.angle-0.4)*7
  local y2=self.y-sin(self.angle-0.25)*6
  smoke:create(x1,y1,10,{size={5,10},col=5})
  smoke:create(x2,y2,10,{size={5,10},col=5})
  smoke:create(x1,y1,10,{size={10,20},col=7})
  x1=self.x+cos(self.angle+0.4)*7
  x2=self.x+cos(self.angle+0.25)*6
  y1=self.y-sin(self.angle+0.4)*7
  y2=self.y-sin(self.angle+0.25)*6
  smoke:create(x1,y1,10,{size={5,10},col=5})
  smoke:create(x2,y2,10,{size={5,10},col=5})
  smoke:create(x1,y1,10,{size={10,20},col=7})
 end,
 reset=function(self)
  self=extend(
   self,
   {
    shoot=0,
    shield={on=false,health=10,size=11,colour=15,max=10},
    weapon=weapon_types[1],
    health=10,
    max=10,
    score=0,
    complete=false
   }
  )
 end
} setmetatable(player,{__index=entity})
