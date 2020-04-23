stage_main_ui={
 x=0,
 y=0,
 init=function(self)
  p.gun=guns[1]
 end,
 update=function(self)
  self:_update()
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
  -- draw ui panel
  self.panel()
  -- draw gun options
  for _,g in pairs(guns) do
   rectfill(4+g.x*spc,110+g.y*10,8+g.x*spc,114+g.y*10,g.col)
   print(lpad(g.credits,2), 12+g.x*spc,110+g.y*10,g.credits>p.credits and 0 or 12)
  end
  -- current gun attributes
  spr(16,60,109)
  spr(17,60,115)
  spr(18,60,121)
  self.drawbars(p.gun.range,110,2)
  self.drawbars(p.gun.power,116,3)
  self.drawbars(p.gun.speed,122,6)
  print(p.gun.name,126-(#p.gun.name*4),110,6)
  -- player selector
  rect(3+self.x*spc,109+self.y*10,9+self.x*spc,115+self.y*10,7)
 end,
 _update=function(self)
  -- close ui
  if btnp(pad.btn2) then
   stage:set_state(stage_main_viewing)
   return
  end
 end,
 panel=function()
  -- draw ui panel
  rectfill(1,107,127,127,1)
  rect(1,107,127,127,7)
  line(2,106,126,106,0)
 end,
 drawbars=function(v,y)
  for i=1,5 do
   line(65+2*i,y,65+2*i,y+2,i>v and 0 or 12)
  end
 end
}


stage_main_info={
 x=0,
 y=0,
 init=function(self)
  dumptable(p.gun)
 end,
 update=function(self)
  stage_main_ui._update(self)
  if btnp(pad.left) and self.x>0 then self.x-=1 end
  if btnp(pad.right) and self.x<2 then self.x+=1 end
 end,
 draw=function(self)
  local spc=24
  -- draw ui panel
  stage_main_ui.panel()

  u={
   {s=16,a="range"},
   {s=17,a="power"},
   {s=18,a="speed"},
  }
  for k,v in pairs(u) do
   local o=(k-1)*spc+4
   spr(v.s,o,109)
   self.drawbars(p.gun[v.a],o+5)
   rectfill(o,116,o+4,120,3)
   print("+",o+1,116,7)
   print("10",o+9,116,12)
  end

  rectfill(3*spc+4,116,3*spc+8,120,3)

  print("sell",85,116,12)

 --[[
  spr(16,4,109)
  spr(17,45,109)
  spr(18,86,109)
  self.drawbars(p.gun.range,9)
  self.drawbars(p.gun.power,50)
  self.drawbars(p.gun.speed,91)

  print("+",5,116,12)
  print("+",46,116,12)
  print("+",87,116,12)

  print("10",13,116,12)
  print("15",54,116,12)
  print("20",95,116,12)
  ]]

  -- player selector
  rect(3+self.x*spc,115+self.y*10,9+self.x*spc,121+self.y*10,7)
 end,
 drawbars=function(v,x)
  for i=1,5 do
   line(x+2*i,110,x+2*i,112,i>v and 0 or 12)
   --rectfill(4+6*i,y,7+6*i,y+3,i>v and 0 or 12)
  end
 end
}
