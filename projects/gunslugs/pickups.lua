pickup={
 destroy=function(self)
  self.visible=false
  self.complete=true
 end,
 update=function(self)
  if not self.visible then return end
 end,
 draw=function(self)
  if not self.visible then return end
  animatable.draw(self)
 end
} setmetatable(pickup,{__index=animatable})

medikit={
 create=function(self,x,y)
  local o=animatable.create(self,x,y,0,0,0,0)
  o.anim:add_stage("still",4,true,{40,41,42,43,44,45},{})
  o.anim:init("still",dir.left)
  return o
 end,
 update=function(self)
  if not self.visible then return end
 	if self:collide_object(p) then
   sfx(5)
   p.health=min(p.health+200,p.max.health)
   smoke:create(self.x+4,self.y+4,10,{col=8,size={8,16}})
   self:destroy()
  end
 end
} setmetatable(medikit,{__index=pickup})