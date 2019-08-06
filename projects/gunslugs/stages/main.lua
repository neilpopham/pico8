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
  local f=flr(self.t/2)
  if f<6 then
   for y=8,127,8 do
    for x=0,127,8 do
     circfill(x+3,y+3,6-f,0)
    end
   end
   self:draw_hud()
   self.t+=1
  else
   self.t=0
   self.draw=self.draw_core
  end
 end,
 draw_outro=function(self)
  local f=flr(self.t/2)
  if f<6 then
   self:draw_core()
   for y=8,127,8 do
    for x=0,127,8 do
     circfill(x+3,y+3,f,0)
    end
   end
   self:draw_hud()
   self.t+=1
  elseif f>10 then
   self.t=0
   self.draw=self.draw_intro
   self:next()
  else
   self.t+=1
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
  self:draw_hud()
 end,
 draw_hud=function(self)
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
