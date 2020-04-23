stage_main_ui={
 x=0,
 y=0,
 init=function(self)

 end,
 update=function(self)
  if btnp(pad.btn2) then
   stage:set_state(stage_main_viewing)
   return
  end
  if btnp(pad.left) and self.x==1 then self.x-=1 end
  if btnp(pad.right) and self.x==0 then self.x+=1 end
  if btnp(pad.up) and self.y==1 then self.y-=1 end
  if btnp(pad.down) and self.y==0 then self.y+=1 end
  for i,g in pairs(guns) do
   g.selected=(g.x==self.x and g.y==self.y)
   if g.selected then p.gun=g end
  end
  if btnp(pad.btn1) and p.gun.credits<=p.credits then
   p.credits-=p.gun.credits
   stage:set_state(stage_main_placing)
  end
 end,
 draw=function(self)
  local spc=28
  function draw_bars(v,y,c)
   c=12
   for i=1,5 do
    line(65+2*i,y,65+2*i,y+2,i>v and 0 or c)
   end
  end
  -- draw ui panel
  rectfill(1,107,127,127,1)
  rect(1,107,127,127,7)
  line(2,106,126,106,0)
  -- draw gun options
  for _,g in pairs(guns) do
   rectfill(4+g.x*spc,110+g.y*10,8+g.x*spc,114+g.y*10,g.col)
   print(lpad(g.credits,2), 12+g.x*spc,110+g.y*10,g.credits>p.credits and 0 or 12)
  end
  -- current gun attributes
  spr(16,60,109)
  spr(17,60,115)
  spr(18,60,121)
  draw_bars(p.gun.range,110,2)
  draw_bars(p.gun.power,116,3)
  draw_bars(p.gun.speed,122,6)
  print(p.gun.name,126-(#p.gun.name*4),110,6)
  -- player selector
  rect(3+self.x*spc,109+self.y*10,9+self.x*spc,115+self.y*10,7)
 end
}
