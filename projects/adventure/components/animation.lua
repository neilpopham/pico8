animation=component:create(
 function(self,stages,stage,dir)
  self.stages=stages
  self.current={tick=0,frame=1,sprite=0,loop=true,transitioning=false,stage=stage,dir=dir}
  for sn,s in pairs(self.stages) do
   for d=1,#s.dir do
    s.dir[d].fcount=#s.dir[d].frames
   end
  end
 end
)

animation.update=function(self,entity)
 local c=self.current
 local s=self.stages[c.stage]
 local d=s.dir[c.dir]
 if c.loop then
  c.tick=c.tick+1
  if c.tick==s.ticks then
   c.tick=0
   c.frame=c.frame+1
   if c.frame>d.fcount then
    if s.next then
     self.set(self,s.next)
     d=self.stages[c.stage].dir[c.dir]
    elseif s.loop then
     c.frame=1
    else
     c.frame=d.fcount
     c.loop=false
    end
   end
  end
 end
 self.current.sprite=d.frames[c.frame]
end

animation.reset=function(self)
 local c=self.current
 c.frame=1
 c.tick=0
 c.loop=true
 c.transitioning=false
end

animation.set=function(self,stage,dir)
 local c=self.current
 if c.stage==stage then return end
 self.reset(self)
 c.stage=stage
 c.dir=dir or c.dir
end

animation.draw=function(self,entity)
 local position=entity:get(position)
 printh(self.current.sprite..","..position.x..","..position.y)
 spr(self.current.sprite,position.x,position.y)
end