stage_over={
 t=0,
 init=function(self)
  self.t=0
 end,

 reset=function()
  enemies:reset()
  bullets:reset()
  destructables:reset()
  pickups:reset()
  particles:reset()
  p:reset(true)
 end,

 update=function(self)
  stage_main.update(self)
  if self.t>120 then
   if btn(pad.btn1) then
    self:reset()
    stage=stage_main
    stage:init()
   elseif btn(pad.btn2) or self.t>1800 then
    self:reset()
    stage=stage_intro
    stage:init()
   end
  end
  self.t+=1
 end,

 draw=function(self)
  stage_main.draw(self)
  if self.t>120 then
   oprint("game over",46,61,8)
   oprint("press \142 to restart",28,90,6)
   oprint("or \151 to return to the menu",12,100,6)
  end
 end
}
