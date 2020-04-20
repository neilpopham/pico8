stages={
 new=nil,
 update=function(self,new)
  self.new=new
 end,
 draw=function(self)
  if self.new then
   stage=self.new
   self.new=nil
   stage:init()
  end
 end
}

stage_intro={
 init=function(self)
 end,
 update=function(self)
  if btnp(4) then
   stages:update(stage_main)
  end
 end,
 draw=function(self)
  print("press \142 to start",30,61,7)
  print("\142",54,61,9)
 end
}

stage_main={
 init=function(self)
  particles=collection:create()
  enemies=collection:create()
  pickups=collection:create()
  bullets=collection:create()
  p=player:create()
 end,
 update=function(self)
  particles:update()
  p:update()
  if enemies.count<3 and rnd()<0.05 then
   enemies:add(enemy:create())
  end
  if pickups.count<3 and rnd()<0.05 then
   pickups:add(pickup:create())
  end
  enemies:update()
  pickups:update()
  bullets:update()
 end,
 draw=function(self)
  particles:draw()
  p:draw()
  enemies:draw()
  pickups:draw()
  bullets:draw()
 end
}

stage_outro={
 init=function(self)
 end,
 update=function(self)
  if btnp(4) then
   stages:update(stage_intro)
  end
 end,
 draw=function(self)
  print("outro",0,0,7)
 end
}
