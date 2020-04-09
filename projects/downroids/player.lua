player={
 create=function(self)
  local o=entity.create(self,flr(screen.width/2),flr(screen.height/2),0,0.02,0.0125)
  o=extend(
   o,
   {
    shoot=0,
    shield={on=false,health=10,size=11,colour=15},
    weapon=weapon_types[1],
    health=100
   }
  )
  --o.btn1=button:create(pad.btn1)
  return o
 end,
 update=function(self)

  -- rotation
  if btn(pad.left) then
   self.angle=self.angle-self.da
  elseif btn(pad.right) then
   self.angle=self.angle+self.da
  end
  self.angle=self.angle%1

  -- shield
  self.shield.on=btn(pad.btn2)

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
     if k.type==1 then
      self.health=self.health+k.health
     elseif k.type==2 then
      self.shield.health=self.shield.health+k.health
     else

     end
    end
    k:destroy()
   end
  end

 end,
 draw=function(self)
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
 end
} setmetatable(player,{__index=entity})
