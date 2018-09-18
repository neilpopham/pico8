pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--
-- by neil popham

-- [[ particles ]]

function prand(value,floor)
 if floor==nil then floor=true end
 local v=(rnd()*(value[2]-value[1]))+value[1]
 return floor and flr(v) or v
end

particle={
 create=function(self,params)
  params=params or {}
  params.dx=params.dx or {6,12}
  params.dy=params.dy or params.dx
  params.life=params.life or {10,30}
  params.col=params.col or {1,15}
  local o=params
  o.x=o.x+prand(params.dx)
  o.y=o.y+prand(params.dy)
  o.life=prand(params.life)
  o.ttl=o.life
  if type(params.col)=="number" then
   o.col=params.col
  else
   o.col=prand(params.col)
  end
  setmetatable(o,self)
  self.__index=self
  return o
 end
}

spark={
 create=function(self,params)
  local o=particle.create(self,params)
  o.draw=function(self)
   if self.life==0 then return true end
   pset(self.x,self.y,self.col)
   self.life=self.life-1
   return self.life==0
  end
  return o
 end
} setmetatable(spark,{__index=particle})

circle={
 create=function(self,params)
  local o=particle.create(self,params)
  params.size=params.size or {8,16}
  o.size=prand(params.size)
  o.draw=function(self)
   if self.life==0 then return true end
   circfill(self.x,self.y,o.size,self.col)
   self.life=self.life-1
   return self.life==0
  end
  return o
 end
} setmetatable(circle,{__index=particle})

-- [[ emmiters ]]

emmiter={
 create=function(self,params)
  local o=params or {}
  o.angle=o.angle or {1,360}
  o.force=o.force or {1,3}
  o.update=function(self,ps)
   -- do nothing
  end
  setmetatable(o,self)
  self.__index=self
  return o
 end,
 init_particle=function(self,ps,p)
  p.angle=prand(self.angle)/360
  p.force=prand(self.force,false)
 end
}

stationary={
 create=function(self,params)
  local o=emmiter.create(self,params)
  return o
 end
} setmetatable(stationary,{__index=emmiter})

follower={
 create=function(self,params)
  local o=emmiter.create(self,params)
  o.dx=o.dx or {0,0}
  o.dy=o.dy or o.dx
  o.update=function(self,ps)
   for _,p in pairs(ps.particles) do
    self:update_particle(ps,p)
   end
  end
  o.update_particle=function(self,ps,p)
   p.x=self.target.x+self.dx+p.dx
   p.y=self.target.y+self.dy+p.dy
  end
  o.init_particle=function(self,ps,p)
   emitter.init_particle(self,ps,p)
   self:update_particle(ps,p)
  end
  return o
 end
} setmetatable(follower,{__index=emmiter})

-- [[ affectors ]]

affector={
 create=function(self,params)
  local o=params or {}
  o.update=function(self,ps)
   -- do nothing
  end
  setmetatable(o,self)
  self.__index=self
  return o
 end
}

force={
 create=function(self,params)
  local o=affector.create(self,params)
  o.update=function(self,ps)
   for _,p in pairs(ps.particles) do
    if self.force then
     p.force=prand(self.force,false)
    elseif self.dforce then
     p.force=p.force+prand(self.dforce,false)
    end
   end
  end
  return o
 end
} setmetatable(force,{__index=affector})

randomise={
 create=function(self,params)
  local o=affector.create(self,params)
  o.angle=o.angle or {1,360}
  o.update=function(self,ps)
   for _,p in pairs(ps.particles) do
    p.angle=(p.angle+(prand(self.angle)/360)) % 1
   end
  end
  return o
 end
} setmetatable(randomise,{__index=affector})

size={
 create=function(self,params)
  local o=affector.create(self,params)
  o.shrink=o.shrink or 0.96
  o.cycle=o.cycle or {9,5,2}
  o.col=o.col or {6,5,1}
  o.update=function(self,ps)
   local m=min(#self.cycle,#self.col)
   for _,p in pairs(ps.particles) do
    p.size=p.size*self.shrink
    for i=1,m do
     if p.size<self.cycle[i] then p.col=self.col[i] end
    end
    if p.size<0.5 then p.life=0 end
   end
  end
  return o
 end
} setmetatable(size,{__index=affector})

heat={
 create=function(self,params)
  local o=affector.create(self,params)
  o.cycle=o.cycle or {0.9,0.6,0.4,0.25}
  o.particles={}
  o.col={
   {0,0,1,1,2,1,5,6,2,4,9,3,13,5,4,9},
   {0,0,0,0,1,1,1,1,5,13,1,2,4,1,5,1,2,2}
  }
  o.update=function(self,ps)
   for i,p in pairs(ps.particles) do
    if self.particles[i]==nil then
     self.particles[i]=p.col
    end
    local life=p.life/p.ttl
    if life>self.cycle[1] then
     if i % 3==0 then p.col=10 else p.col=7 end
    elseif life>self.cycle[2] then
     p.col=self.particles[i]
    elseif life>self.cycle[3] then
     p.col=self.col[1][self.particles[i]+1]
    elseif life>self.cycle[4] then
     p.col=self.col[2][self.particles[i]+1]
    else
     p.col=1
    end
   end
  end
  return o
 end
} setmetatable(heat,{__index=affector})

-- [[ system ]]

particle_system={
 create=function(self,params)
  local s={
   particles={},
   emitters={},
   affectors={},
   complete=false,
   count=0
  }
  s.params=params or {}
  s.update=function(self)
   if self.complete then return end
   for _,e in pairs(self.emitters) do e:update(self) end
   for _,a in pairs(self.affectors) do a:update(self) end
  end
  s.draw=function(self)
   if self.complete then return end
   local done=true
   for i,p in pairs(self.particles) do
    p.dx=cos(p.angle)*p.force
    p.dy=-sin(p.angle)*p.force
    p.x=p.x+p.dx
    p.y=p.y+p.dy
    local dead=p:draw()
    done=done and dead
    if dead then del(self.particles,p) end
   end
   if done then self.complete=true end
  end
  setmetatable(s,self)
  self.__index=self
  return s
 end,
 add_particle=function(self,p)
  add(self.particles,p)
  for _,e in pairs(self.emitters) do e:init_particle(self,p) end
  self.count=self.count+1
 end,
 reset=function(self)
  self.complete=false
  self.particles={}
  self.count=0
 end
}

--[[
particle_type={
 create=function(self,params)
  local o=params or {}
  o.system=particle_system:create(params)
  add(o.system.emitters,stationary:create())
  add(o.system.affectors,randomise:create({angle={4,16}}))
  add(o.system.affectors,force:create({dforce={-0.2,0.2}}))
  o.init=function(self)
   for i=1,self.count do
    o.system:add_particle(spark:create({x=x,y=y,life={30,120}}))
   end
  end
  setmetatable(o,self)
  self.__index=self
  return o
 end
}

spark_particle={
 create=function(self,params)
  o=particle_type.create(self,params)
  o.angle=o.angle or {1,360}
  o.update=function(self,ps)
   for _,p in pairs(ps.particles) do
    p.angle=(p.angle+(prand(self.angle)/360)) % 1
   end
  end
  return o
 end
} setmetatable(spark_particle,{__index=particle_type})
]]

spark_particle={
 create=function(self,params)
  local ps=particle_system.create(self,params)
  add(ps.emitters,stationary:create())
  add(ps.affectors,randomise:create({angle={4,16}}))
  add(ps.affectors,force:create({dforce={-0.2,0.2}}))
  add(ps.affectors,heat:create())
  ps.add_particle=function(self)
   particle_system.add_particle(
    self,
    spark:create({x=self.params.x,y=self.params.y,life={30,120}})
   )
  end
  ps.reset=function(self)
   particle_system.reset(self)
   for i=1,self.params.count do
    self:add_particle()
   end
  end
  ps:reset()
  return ps
 end
} setmetatable(spark_particle,{__index=particle_system})

circle_particle={
 create=function(self,params)
  local ps=particle_system.create(self,params)
  add(ps.emitters,stationary:create({force={0.4,1.2}}))
  --add(ps.affectors,randomise:create({angle={4,16}}))
  --add(ps.affectors,force:create({dforce={-0.2,0.2}}))
  add(ps.affectors,size:create({cycle={0},shrink=0.96}))
  ps.add_particle=function(self)
   particle_system.add_particle(
    self,
    circle:create({x=self.params.x,y=self.params.y,life={30,120},col=7,size={8,16}})
   )
  end
  ps.reset=function(self)
   particle_system.reset(self)
   for i=1,self.params.count do
    self:add_particle()
   end
  end
  ps:reset()
  return ps
 end
} setmetatable(circle_particle,{__index=particle_system})


--[[
function do_sparks(x,y,count)
 ps=particle_system:create({x=x,y=y,count=count})
 add(ps.emitters,stationary:create())
 add(ps.affectors,randomise:create({angle={4,16}}))
 add(ps.affectors,force:create({dforce={-0.2,0.2}}))
 for i=1,count do
  ps:add_particle(spark:create({x=x,y=y,life={30,120}}))
 end
 --ps:init()
 return ps
end
]]

function _init()
 -- do_sparks(64,64,100)
 --s=spark_particle:create({x=64,y=64,count=100})
 s=circle_particle:create({x=64,y=64,count=100})
end

function _update60()

 if not s.complete then
  s:add_particle()
  s:update()
 end

 if btnp(0) or btnp(1) or btnp(2) or btnp(3) then s:reset() end
 if btnp(4) then s=circle_particle:create({x=64,y=64,count=100}) end
 if btnp(5) then s=spark_particle:create({x=64,y=64,count=100}) end

end

function _draw()
 cls()
 if not s.complete then s:draw() end
end
