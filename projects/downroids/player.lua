player={
 create=function(self)
  local o=entity.create(self,flr(screen.width/2),flr(screen.height/2),0.02,0.0125)
  o=extend(
   o,
   {
    shoot=0,
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

  -- fire
  if btn(pad.btn1) then
   self.df=self.df+4
   if self.shoot==0 then
    bullets:add(bullet:create(self.x,self.y,(self.angle+0.5)%1,self.weapon.bullet_type))
    smoke:create(self.x-cos(self.angle)*10,self.y+sin(self.angle)*10,10,{size={5,10},col=2})
    smoke:create(self.x-cos(self.angle)*10,self.y+sin(self.angle)*10,5,{size={2,5},col=4})

    --[[
    doublesmoke(
     self.x-cos(self.angle)*10,
     self.y+sin(self.angle)*10,
     {10,5},
     {{size={5,10},col=2},{size={2,5},col=4}}
    )
    ]]


    self.shoot=self.weapon.rate
   end
  else
   self.df=0
   self.force=self.force*0.95
  end
  if self.shoot>0 then self.shoot-=1 end

  if btn(pad.btn2) then
   self.angle=0
  end

  entity.update(self)

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
  circ(self.x-flr(cos(self.angle)*1.2),self.y+flr(sin(self.angle)*1.2),2,6)
  circ(self.x,self.y,4,11)
 end
}
