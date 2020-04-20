player={
 create=function(self)
  local o=entity.create(self,64,64,0,0,0)
  o:reset()
  return o
 end,
 update=function(self)

  -- rotation
  if btn(pad.left) then
   self.da=self.da-0.001
  elseif btn(pad.right) then
   self.da=self.da+0.001
  else
   self.da=self.da*0.92
  end
  if abs(self.da)<0.001 then self.da=0 end

  self.da=mid(-0.025,self.da,0.025)
  self.angle=self.angle+self.da
  self.angle=self.angle%1
  self.x=64+cos(self.angle)*21
  self.y=64-sin(self.angle)*21
  self.langle=(self.angle-0.125)%1
  self.rangle=(self.angle+0.125)%1

  if btn(pad.btn1) and self.shoot==0 then
   bullets:add(bullet:create(self.x,self.y,self.angle,self.weapon.bullet_type))
   self.shoot=self.weapon.rate
  end
  if self.shoot>0 then self.shoot-=1 end

 end,
 draw=function(self)
  for i=0,0.99,0.05 do

   pset(64+cos(i)*21,64-sin(i)*21,1)
  end
  circ(self.x,self.y,2,2)
  circ(64,64,12,9)
 end,
 destroy=function(self)
  entity.destroy(self)
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
