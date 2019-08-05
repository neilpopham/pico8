stage_over={
 t=0,
 init=function(self)
  self.t=0
 end,
 update=function(self)
  stage_main.update(self)
  if self.t>120 then
   if btn(pad.btn1) then
    stage=stage_main
    stage:init()
   elseif btn(pad.btn2) or self.t>1800 then
    enemies:reset()
    bullets:reset()
    destructables:reset()
    pickups:reset()
    particles:reset()
    p:reset(true)
    stage=stage_intro
    stage:init()
   end
  end
  self.t+=1
 end,
 draw=function(self)
  if self.t>120 then
   print("game over",46,48,9)
   print("press \142 to restart",28,60,13)
   print("or \151 to return to the menu",12,68,13)
  else
   stage_main:draw()
   if self.t>80 then
    local t=self.t-80
    for y=8,127,8 do
     rectfill(-1,y,t*4,y+3,0)
    end
    for y=12,127,8 do
     rectfill(127-t*4,y,128,y+3,0)
    end
   end
  end
 end
}
