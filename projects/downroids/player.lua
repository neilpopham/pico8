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
   if self.force==0 then
    stages:update(stage_over)
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
  self.periphery={(self.angle-0.625)%1,(self.angle+0.625)%1}

  -- shield
  self.shield.on=btn(pad.btn2) and self.shield.health>0
  local shielding,size=self.shield.on,5
  if shielding then
   size=11
   sfx(3)
  --else
  end

  -- fire
  if not shielding and btn(pad.btn1) then
   self.df=self.df+0.1
   if self.shoot==0 then
    bullets:add(bullet:create(self.x,self.y,(self.angle+0.5)%1,self.weapon.bullet_type))
    smoke:create(self.x-cos(self.angle)*10,self.y+sin(self.angle)*10,10,{size={5,10},col=2})
    smoke:create(self.x-cos(self.angle)*10,self.y+sin(self.angle)*10,5,{size={2,5},col=4})
    self.shoot=self.weapon.rate
    sfx(self.weapon.sfx)
   end
  else
   self.df=0
   self.force=self.force*0.95
  end
  if self.shoot>0 then self.shoot-=1 end

  entity.update(self)

  for _,e in pairs(enemies.items) do
   e.visible=self:sees(e)
   local d=self:distance(e)
   if d<size+e.size then
    if shielding then
     self.shield.health=self.shield.health-1
     self.score=self.score+e.score
    else
     self:damage(1)
    end
    e:destroy()
   end
  end

  for _,k in pairs(pickups.items) do
   k.visible=self:sees(k)
   local d=self:distance(k)
   if d<size+k.size then
    if not shielding then
     self.score=self.score+k.score
     sfx(2)
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
  if self.complete then return end
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
  --circ(self.x+flr(cos(self.angle)*1.2),self.y-flr(sin(self.angle)*1.2),2,6)
  circ(self.x,self.y,4,11)
  if self.shield.on then
   if stages.t%4==0 then
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
  shells:create(self.x,self.y,20,{col=11,force={2,6}})
  local x1=self.x+cos(self.angle-0.4)*7
  local x2=self.x+cos(self.angle-0.25)*6
  local y1=self.y-sin(self.angle-0.4)*7
  local y2=self.y-sin(self.angle-0.25)*6
  smoke:create(x1,y1,10,{size={5,10},col=5})
  smoke:create(x2,y2,10,{size={5,10},col=5})
  smoke:create(x1,y1,10,{size={10,20},col=7})
  shells:create(x1,y1,10,{col=5,force={2,6}})
  x1=self.x+cos(self.angle+0.4)*7
  x2=self.x+cos(self.angle+0.25)*6
  y1=self.y-sin(self.angle+0.4)*7
  y2=self.y-sin(self.angle+0.25)*6
  smoke:create(x1,y1,10,{size={5,10},col=5})
  smoke:create(x2,y2,10,{size={5,10},col=5})
  smoke:create(x1,y1,10,{size={10,20},col=7})
  shells:create(x1,y1,10,{col=5,force={2,6}})
 end,
 reset=function(self)
  self=extend(
   self,
   {
    shoot=10,
    shield={on=false,health=10,size=11,colour=15,max=10},
    weapon=weapon_types[1],
    health=10,
    max=10,
    score=0,
    complete=false
   }
  )
 end,
 sees=function(self,o)
  local a,a1,a2,v=atan2(o.x-self.y,self.y-o.y),(self.angle-0.625)%1,(self.angle+0.625)%1,false
  if a1>a2 then
   if a>=a1 or a<=a2 then v=true end
  else
    if a>=a1 and a<=a2 then v=true end
  end
  if a>=a1 and a<=a2 then v=true end
  return v
 end
} setmetatable(player,{__index=entity})
