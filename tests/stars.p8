pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- starfield
-- by neil popham

local screen={width=128,height=128}
local pad={left=0,right=1,up=2,down=3,btn1=4,btn2=5}

particle={
 create=function(self,params)
  params=params or {}
  params.dx=params.dx or {0,0}
  params.dy=params.dy or params.dx
  params.life=params.life or {10,30}
  params.col=params.col or {1,15}
  local o=params
  o.dx=mrnd(params.dx)
  o.dy=mrnd(params.dy)
  o.x=params.x+o.dx
  o.y=params.y+o.dy
  o.life=mrnd(params.life)
  o.ttl=o.life
  --o.enabled=true
  if #params.col==2 then
   o.col=mrnd(params.col)
  else
  	o.col=params.col[mrnd({1,#params.col})]
  end
  setmetatable(o,self)
  self.__index=self
  return o
 end
}

spark={
 create=function(self,params)
  local o=particle.create(self,params)
  return o
 end,
 draw=function(self)
  if self.life==0 then return true end
  pset(self.x,self.y,self.col)
  self.life=self.life-1
  return self.life==0
 end 
} setmetatable(spark,{__index=particle})

circle={
 create=function(self,params)
  local o=particle.create(self,params)
  params.size=params.size or {8,16}
  o.size=mrnd(params.size)
  o.draw=function(self)
   if self.life==0 then return true end
   --if not self.enabled then return false end
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
 	if type(self.angle)=="number" then
 	 p.angle=self.angle/360
 	else
   p.angle=mrnd(self.angle)/360
  end
  p.force=mrnd(self.force,false)
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
  params.dx=params.dx or {0,0}
  params.dy=params.dy or params.dx
  o.dx=mrnd(params.dx)
  o.dy=mrnd(params.dy)
  o.init_particle=function(self,ps,p)
   emmiter.init_particle(self,ps,p)
   p.x=self.target.x+self.dx+p.dx
   p.y=self.target.y+self.dy+p.dy
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

bounds={
 create=function(self,params)
  local o=affector.create(self,params)
  o.update=function(self,ps)
   for _,p in pairs(ps.particles) do
    if p.y>127 then p.life=0 end
   end
  end
  return o
 end
} setmetatable(bounds,{__index=affector})

force={
 create=function(self,params)
  local o=affector.create(self,params)
  o.update=function(self,ps)
   for _,p in pairs(ps.particles) do
    if self.force then
     p.force=mrnd(self.force,false)
    elseif self.dforce then
     p.force=p.force+mrnd(self.dforce,false)
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
    p.angle=(p.angle+(mrnd(self.angle)/360)) % 1
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
    --if not p.enabled then return end
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
  o.col={
   {0,0,1,1,2,1,5,6,2,4,9,3,13,5,4,9},
   {0,0,0,0,1,1,1,1,5,13,1,2,4,1,5,1,2,2}
  }
  o.update=function(self,ps)
   for i,p in pairs(ps.particles) do
    if p.ocol==nil then p.ocol=p.col end
    local life=p.life/p.ttl
    if life>self.cycle[1] then
     if i % 3==0 then p.col=10 else p.col=7 end
    elseif life>self.cycle[2] then
     p.col=p.ocol
    elseif life>self.cycle[3] then
     p.col=self.col[1][p.ocol+1]
    elseif life>self.cycle[4] then
     p.col=self.col[2][p.ocol+1]
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
   count=0,
   tick=0
  }
  s.params=params or {}
  s.update=function(self)
   if self.complete then return end
   for _,e in pairs(self.emitters) do e:update(self) end
   for _,a in pairs(self.affectors) do a:update(self) end
   self.tick=self.tick+1
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
    if dead then
     del(self.particles,p)
     self.count=self.count-1
    end
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

star_particle={
 create=function(self,params)
  local ps=particle_system.create(self,params)
  add(ps.emitters,stationary:create({force={0.5,3},angle=90}))
  add(ps.affectors,bounds:create())
  ps.add_particle=function(self)
  	local s=spark:create({x=mrnd({1,126}),y=0,col={1,5,6},life={256,256}})
   particle_system.add_particle(self,s)
  end
  ps:add_particle()
  return ps
 end
} setmetatable(star_particle,{__index=particle_system})


function _init()
 stars=star_particle:create()
end

function _update60()
 if rnd(2)>1 then stars:add_particle() end
 stars:update() 
end

function _draw()
 cls()
 stars:draw()
 print(stars.count,0,0,10)
end

function mrnd(x,f)
 if f==nil then f=true end
 local v=(rnd()*(x[2]-x[1]+(f and 1 or 0.0001)))+x[1]
 return f and flr(v) or flr(v*1000)/1000
end
