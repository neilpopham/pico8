stage_main={
 t=0,
 init=function(self)
  level=0
  self:next(true)
  self.draw=self.draw_intro
  self.t=0
 end,
 next=function(self,full)
  level+=1
  enemies:reset()
  bullets:reset()
  destructables:reset()
  pickups:reset()
  particles:reset()
  p:reset(full)
  fillmap(level)
 end,
 complete=function(self)
  --self:next()
  self.draw=self.draw_outro
 end,
 update=function(self)
  p:update()
  p.camera:update()
  bullets:update()
  set_visible(destructables)
  set_visible(enemies)
  set_visible(pickups)
  enemies:update()
  destructables:update()
  pickups:update()
  particles:update()
 end,
 draw_intro=function(self)
  self:draw_core()
  self.t+=1
  for y=8,127,8 do
   rectfill(self.t*4,y,128,y+3,0)
  end
  for y=12,127,8 do
   rectfill(-1,y,127-self.t*4,y+3,0)
  end
  if self.t>32 then
   self.t=0
   self.draw=self.draw_core
  end
 end,
 draw_outro=function(self)
  self:draw_core()
  self.t+=1
  for y=8,127,8 do
   rectfill(-1,y,self.t*4,y+3,0)
  end
  for y=12,127,8 do
   rectfill(127-self.t*4,y,128,y+3,0)
  end
  if self.t>32 then
   self.t=0
   self.draw=self.draw_intro
   self:next()
  end
 end,
 draw_core=function(self)
  p.camera:map()
  enemies:draw()
  pal()
  bullets:draw()
  destructables:draw()
  pickups:draw()
  particles:draw()
  p:draw()
  -- draw hud
  camera(0,0)
  print("level",1,1,6)
  print(lpad(level),24,1,9)
  --spr(62,48,1)
  --spr(63,56,1)
  spr(p.weapon.sprite,60,1)
  -- health
  for i=1,p.max.health/100 do
   spr(p.health>=i*100 and 47 or 46,87+(8*(i-1)),0)
  end
 end
}
