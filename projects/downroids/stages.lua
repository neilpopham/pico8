stages={
 init=function(self)
  self.new,self.t=nil,0
 end,
 update=function(self,new)
  self.new=new
 end,
 draw=function(self)
  if self.new then
   stage=self.new
   self:init()
   stage:init()
  end
  self.t+=1
  if self.t>32766 then self.t=0 end
 end
}
stages:init()

stage_intro={
 init=function(self)

 end,
 update=function(self)
  if btnp(pad.btn1) then
   stages:update(stage_main)
  end
 end,
 draw=function(self)
  dprint("press \142 to start",32,61,8,2)
  dprint("\142",56,61,11,9)
  dprint("written by neil popham",21,116,14,12)
 end
}

stage_main={
 init=function(self)

 end,
 update=function(self)
  p:update()
  bullets:update()
  particles:update()
 end,
 draw=function(self)
  bullets:draw()
  p:draw()
  particles:draw()
 end
}

stage_over={
 init=function(self)

 end,
 update=function(self)
  bullets:update()
  particles:update()
 end,
 draw=function(self)
  bullets:draw()
  particles:draw()
  if stages.t>60 then
   dprint("press \142 to restart",28,61,8,2)
   if btnp(pad.btn1) or stages.t>600 then
    p:reset()
    stages:update(stages.t>600 and stage_intro or stage_main)
   end
  end
 end
}
