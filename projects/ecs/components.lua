position=component:create(
 function(self,x,y)
  self.x=x
  self.y=y
 end
)

movement=component:create(
 function(self,dx,dy,ax,ay)
  self.mdx=dx
  self.mdy=dy
  self.ax=ax
  self.ay=ay
  self.dx=0
  self.dy=0
 end
)

automove=component:create()

automove.update=function(self,entity)
 local position,movement=entity:get(position),entity:get(movement)
 movement.dx=movement.dx+movement.ax
 movement.dx=mid(-movement.mdx,movement.dx,movement.mdx)
 position.x=position.x+movement.dx
end

controlled=component:create()

controlled.update=function(self,entity)
 local position,movement=entity:get(position),entity:get(movement)
 if btn(0) then
  movement.dx=movement.dx-movement.ax
 elseif btn(1) then
  movement.dx=movement.dx+movement.ax
 else
  movement.dx=movement.dx*drag.ground
  if abs(movement.dx)<movement.ax then movement.dx=0 end
 end
 movement.dx=mid(-movement.mdx,movement.dx,movement.mdx)
 position.x=position.x+movement.dx
 if btn(2) then
  movement.dy=movement.dy-movement.ay
 elseif btn(3) then
  movement.dy=movement.dy+movement.ay
 else
  movement.dy=movement.dy*drag.ground
  if abs(movement.dy)<movement.ay then movement.dy=0 end
 end
 movement.dy=mid(-movement.mdy,movement.dy,movement.mdy)
 position.y=position.y+movement.dy
end

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

sprite=component:create(
 function(self,sprite)
  self.sprite=sprite
 end
)

sprite.draw=function(self,entity)
 local position=entity:get(position)
 spr(self.sprite,position.x,position.y)
end
