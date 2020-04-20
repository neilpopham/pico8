
-- Particles
-- by Neil Popham
-- 2020-04-15 Trying to streamline an extensible particle system
-- I suppose it depends:
--  * What can be shared in particle.create
--  * Whether there will be multiple particles using pixel or circle
--     * If not then pixel/bullet and circle/smoke could be merged
--  * Whether affectors will be shared between particles (very likely)
--  * Whether remove_offscreen affector could (depending on requirements) move
--    into particle.update
--  * Whether is_offscreen could be a particle object function, or even a core function or
--    a function for a base object that particle extends


particle={
 create=function(self,params)
  params=params or {}
  params.life=mrnd(params.life or {60,120})
  params.angle=mrnd(params.angle or {0,1},false)
  params.force=mrnd(params.force,false)
  local o=setmetatable(
   extend(
    params,
    {complete=false,dx=0,dy=0}
   ),
   self
  )
  self.__index=self
  return o
 end,
 offscreen=function(self)
  return (self.x<0 or self.x>127 or self.y<0 or self.y>127)
 end,
 update=function(self)
  self.x+=self.dx
  self.y+=self.dy
  if self:offscreen() then self.complete=true end
  self.life=self.life-1
  if self.life==0 then self.complete=true end
 end,
 draw=function(self)
  -- shared drawing
 end
}

pixel={
 draw=function(self)
  pset(self.x,self.y,self.col)
  particle.draw(self)
 end
} setmetatable(pixel,{__index=particle})

circle={
 draw=function(self)
  circfill(self.x,self.y,self.size,self.col)
  particle.draw(self)
 end
} setmetatable(circle,{__index=particle})

function move_right(self)
 self.dx+=0.1
end

function move_down(self)
 self.dy+=0.1
end

-- if affectors tend to use angle and force this could be a shared core affector
-- applied near the end, or *possibly* part of particle.update
function set_diffs(self)
 self.dx=cos(self.angle)*self.force
 self.dy=-sin(self.angle)*self.force
end

function shrink_size(self)
 self.size=self.size*.9
 if self.size<1 then self.complete=true end
end

-- could be a particle object function, or even a core function or
-- a function for a base object that particle extends
function is_offscreen(self)
 if self.x<0 or self.x>127 or self.y<0 or self.y>127 then return true end
 return false
end

-- could (depending on requirements) move into particle.update
-- or also be part of a base object
function remove_offscreen(self)
 if is_offscreen(self) then self.complete=true end
end

--[[
object={
 create=function(self,x,y)
  local o=setmetatable({x=x,y=y},self)
  self.__index=self
  return o
 end,
 offscreen=function(self)
  if self.x<0 or self.x>127 or self.y<0 or self.y>127 then
   return true
  end
  return false
 end,
 clear=function(self)
  if self:offscreen() then self.complete=true end
 end
}
]]

bullet={
 update=function(self)
  move_right(self)
  move_down(self)
  particle.update(self)
  --remove_offscreen(self)
 end
} setmetatable(bullet,{__index=pixel})

smoke={
 update=function(self)
  shrink_size(self)
  move_down(self)
  particle.update(self)
  --remove_offscreen(self)
 end
} setmetatable(smoke,{__index=circle})


function do_bullet()
 particles:add(
  bullet:create({
   x=mrnd({0,127}),
   y=mrnd({0,127}),
   force={2,2},
   col=mrnd({1,15})
  })
 )
end

function do_smoke()
 particles:add(
  smoke:create({
   x=mrnd({0,127}),
   y=mrnd({0,127}),
   force={2,2},
   col=mrnd({1,15}),
   size=mrnd({10,20})
  })
 )
end
