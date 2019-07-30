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
  p:reset()
 end,

 update=function(self)
  stage_main.update(self)
  if btn(pad.btn1) and self.t>120 then
   self:reset()
   stage=stage_main
   stage:init()
  elseif btn(pad.btn2) or self.t>1800 then
   self:reset()
   stage=stage_intro
   stage:init()
  end
  self.t=self.t+1
 end,

 draw=function(self)
  stage_main.draw(self)
  print("press \142 or \151 to start",18,110,7)
 end
}
