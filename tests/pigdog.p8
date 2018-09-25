pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- pigdog
-- by neil popham

screen={width=128,height=128}
pad={left=0,right=1,up=2,down=3,btn1=4,btn2=5}

dir={left=1,right=2,neutral=3}
drag={air=0.75}
score=0
level=0

-- [[ particles ]]

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
    p.angle=mrnd(self.angle)/360
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
    if p.x<0 or p.x>127
     or p.y<0 or p.y>127 then
     p.life=0
    end
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

gravity={
 create=function(self,params)
  local o=affector.create(self,params)
  o.force=o.force or 0.25
  o.update=function(self,ps)
   for _,p in pairs(ps.particles) do
    local dx=cos(p.angle)*p.force
    local dy=-sin(p.angle)*p.force
    dy=dy+self.force
    p.angle=atan2(dx,-dy)
    p.force=sqrt((dx^2)+(dy^2))
   end
  end
  return o
 end
} setmetatable(gravity,{__index=affector})

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
 create=function(self)
  local s={
   particles={},
   emitters={},
   affectors={},
   complete=false,
   count=0,
   tick=0
  }
  setmetatable(s,self)
  self.__index=self
  return s
 end,
 update=function(self)
  if self.complete then return end
  for _,e in pairs(self.emitters) do e:update(self) end
  for _,a in pairs(self.affectors) do a:update(self) end
  self.tick=self.tick+1
 end,
 draw=function(self)
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
 end,
 add_particle=function(self,p)
  add(self.particles,p)
  for _,e in pairs(self.emitters) do e:init_particle(self,p) end
  self.count=self.count+1
  self.complete=false
 end,
 reset=function(self)
  self.complete=false
  self.particles={}
  self.count=0
 end
}

-- [[ particle instances ]]

star_particles={
 create=function(self)
  local ps=particle_system.create(self)
  add(ps.emitters,stationary:create({force={0.5,3},angle={90,90}}))
  add(ps.affectors,bounds:create())
  ps.add_particle=function(self)
   particle_system.add_particle(
    self,
    spark:create({x=mrnd({1,126}),y=0,col={1,5,6},life={255,255}})
   )
  end
  ps:add_particle()
  ps.update=function(self)
   if self.tick%4==0 then self:add_particle() end
   particle_system.update(self)
  end
  return ps
 end
} setmetatable(star_particles,{__index=particle_system})

ship_particles={
 create=function(self,x,y,cols)
  cols=cols or {7,8,9,10}
  local ps=particle_system.create(self)
  add(ps.emitters,stationary:create({force={2,4},angle={1,360}}))
  add(ps.affectors,gravity:create({force=0.2}))
  ps.add_particle=function(self)
   particle_system.add_particle(
    self,
    spark:create({x=x,y=y,col=cols,life={30,80}})
   )
  end
  for i=1,10 do
   ps:add_particle()
  end
  return ps
 end
} setmetatable(ship_particles,{__index=particle_system})

ship_smoke={
 create=function(self,x,y,cols)
  cols=cols or {10,9,8} -- {14,8,2} -- {10,9,8} -- {11,3,1}
  local ps=particle_system.create(self)
  add(ps.emitters,stationary:create({force={0.2,0.5},angle={1,360}}))
  add(ps.affectors,gravity:create({force=0.1}))
  add(ps.affectors,size:create({shrink=0.9,col=cols}))
  ps.add_particle=function(self)
   particle_system.add_particle(
    self,
    circle:create({x=x,y=y,dx={-10,10},dy={-10,10},size={6,16},col={7},life={30,80}})
   )
  end
  for i=1,20 do
   ps:add_particle()
  end
  return ps
 end
} setmetatable(ship_smoke,{__index=particle_system})

player_trail={
 create=function(self,target)
  local ps=particle_system.create(self)
  ps.target=target
  add(ps.emitters,follower:create({force={0.2,1},target=target,angle={60,120}}))
  add(ps.affectors,size:create({cycle={3,2,1},col={6,13,2},shrink=0.95}))
  ps.add_particle=function(self)
   particle_system.add_particle(
    self,
    circle:create({x=self.target.x,y=self.target.y,life={10,30},col={7},size={2,4},dx={2,6},dy={10,12}})
   )
  end
  ps.update=function(self)
   if self.tick%2==0 then self:add_particle() end
   particle_system.update(self)
  end
  return ps
 end
} setmetatable(player_trail,{__index=particle_system})

-- [[ collections ]]

collection={
 create=function(self)
  local o={
   items={},
   count=0,
  }
  setmetatable(o,self)
  self.__index=self
  return o
 end,
 update=function(self)
  if self.count==0 then return end
  for _,i in pairs(self.items) do
   i:update()
  end
 end,
 draw=function(self)
  if self.count==0 then return end
  for _,i in pairs(self.items) do
   i:draw()
   if i.complete then self:del(i) end
  end
 end,
 add=function(self,object)
  add(self.items,object)
  self.count=self.count+1
 end,
 del=function(self,object)
  del(self.items,object)
  self.count=self.count-1
 end
}

bullets={
 create=function(self)
  local o=collection.create(self)
  return o
 end
} setmetatable(bullets,{__index=collection})

enemies={
 create=function(self)
  local o=collection.create(self)
  return o
 end
} setmetatable(enemies,{__index=collection})

explosions={
 create=function(self)
  local o=collection.create(self)
  return o
 end
} setmetatable(explosions,{__index=collection})

particles={
 create=function(self)
  local o=collection.create(self)
  return o
 end
} setmetatable(particles,{__index=collection})

-- [[ objects ]]

object={
 create=function(self,x,y)
  local o={x=x,y=y,hitbox={x=0,y=0,w=8,h=8,x2=7,y2=7}}
  setmetatable(o,self)
  self.__index=self
  return o
 end,
 add_hitbox=function(self,w,h,x,y)
  x=x or 0
  y=y or 0
  self.hitbox={x=x,y=y,w=w,h=h,x2=x+w-1,y2=y+h-1}
 end
}

movable={
 create=function(self,x,y,ax,ay)
  local o=object.create(self,x,y)
  o.ax=ax
  o.ay=ay
  o.dx=0
  o.dy=0
  o.min={dx=0.05,dy=0.05}
  o.max={dx=2,dy=2}
  o.complete=false
  return o
 end,
 collide_object=function(self,object)
  local x=self.x+self.dx
  local y=self.y+self.dy
  local hitbox=self.hitbox
  return (x+hitbox.x<object.x+object.hitbox.x2) and
   (object.x+object.hitbox.x<x+hitbox.w) and
   (y+hitbox.y<object.y+object.hitbox.y2) and
   (object.y+object.hitbox.y<y+hitbox.h)
 end,
 destroy=function(self)
  -- do nothing
 end,
 update=function(self)
  -- do nothing
 end,
 draw=function(self)
  -- do nothing
 end
} setmetatable(movable,{__index=object})

animatable={
 create=function(self,x,y,ax,ay)
  local o=movable.create(self,x,y,ax,ay)
  return o
 end,
 anim={
  init=function(self,stage,dir)
   -- record frame count for each stage dir
   for s in pairs(self.stage) do
    for d=1,3 do
     self.stage[s].dir[d].fcount=#self.stage[s].dir[d].frames
    end
   end
   -- init current values
   self.current:set(stage,dir)
  end,
  stage={},
  current={
   reset=function(self)
    self.frame=1
    self.tick=0
    self.loop=true
    self.transitioning=false
   end,
   set=function(self,stage,dir)
    if self.stage==stage then return end
    self.reset(self)
    self.stage=stage
    self.dir=dir or self.dir
   end
  },
  add_stage=function(self,name,ticks,loop,neutral,left,right,next)
   self.stage[name]={
    ticks=ticks,
    loop=loop,
    dir={{frames=left},{frames=right},{frames=neutral}},
    next=next
   }
  end
 },
 animate=function(self)
  local c=self.anim.current
  local s=self.anim.stage[c.stage]
  local d=s.dir[c.dir]
  if c.loop then
   c.tick=c.tick+1
   if c.tick==s.ticks then
    c.tick=0
    c.frame=c.frame+1
    if c.frame>d.fcount then
     if s.next then
      c:set(s.next)
      d=self.anim.stage[c.stage].dir[c.dir]
     elseif s.loop then
      c.frame=1
     else
      c.frame=d.fcount
      c.loop=false
     end
    end
   end
  end
  return s.dir[c.dir].frames[c.frame]
 end,
 update=function(self)
  -- do nothing
 end,
 draw=function(self)
  local sprite=self.animate(self)
  spr(sprite,self.x,self.y)
 end
} setmetatable(animatable,{__index=movable})

controllable={
 create=function(self,x,y,ax,ay)
  local o=animatable.create(self,x,y,ax,ay)
  return o
 end,
 update=function(self)
  animatable.update(self)
  -- horizontal movement
  if btn(pad.left) then
   self.anim.current.dir=dir.left
   self.dx=self.dx-self.ax
  elseif btn(pad.right) then
   self.anim.current.dir=dir.right
   self.dx=self.dx+self.ax
  else
   self.anim.current.dir=dir.neutral
   self.dx=self.dx*drag.air
  end
  self.dx=mid(-self.max.dx,self.dx,self.max.dx)
  if abs(self.dx)<self.min.dx then self.dx=0 end
  if self.dx~=0 then
   self.x=self.x+round(self.dx)
   if self.x<0 then
    self.x=0
    self.dx=0
   end
   if self.x>120 then
    self.x=120
    self.dx=0
   end
  end
  -- vertical movement
  if btn(pad.up) then
   self.dy=self.dy-self.ay
  elseif btn(pad.down) then
   self.dy=self.dy+self.ay
  else
   self.dy=self.dy*drag.air
  end
  self.dy=mid(-self.max.dy,self.dy,self.max.dy)
  if abs(self.dy)<self.min.dy then self.dy=0 end
  if self.dy~=0 then
   self.y=self.y+round(self.dy)
   if self.y<0 then
    self.y=0
    self.dy=0
   end
   if self.y>120 then
    self.y=120
    self.dy=0
   end
  end
  -- buttons
  if btnp(pad.btn1) then
   b:add(bullet:create(p.x,p.y,self.bullet))
  end
 end,
 draw=function(self)
  animatable.draw(self)
 end
} setmetatable(controllable,{__index=animatable})

player={
 create=function(self,x,y)
  local p=controllable.create(self,x,y,0.2,0.2)
  p.anim:add_stage("core",1,false,{16},{17},{18})
  p.anim:init("core",dir.neutral)
  p.bullet=1
  p.trail=player_trail:create(p)
  return p
 end,
 destroy=function(self)
  x:add(ship_particles:create(self.x+4,self.y+4,{11,6,8}))
  x:add(ship_smoke:create(self.x+4,self.y+4,{15,14,8}))
  cam:shake(2,0.9)
  self.complete=true
 end,
 update=function(self)
  if self.complete then return end
  controllable.update(self)
  self.trail:update()
 end,
 draw=function(self)
  if self.complete then return end
  controllable.draw(self)
  self.trail:draw()
 end
} setmetatable(player,{__index=controllable})

bullet_types={
 {sprite=1,ax=0,ay=-4,w=2,h=6,player=true},
 {sprite=2,ax=0,ay=-6,w=6,h=6,player=true}
}

bullet={
 create=function(self,x,y,type)
  local otype=bullet_types[type]
  local o=movable.create(self,x,y,otype.ax,otype.ay)
  o.type=otype
  o.add_hitbox(self,otype.w,otype.h)
  return o
 end,
 update=function(self)
  movable.update(self)
  self.y=self.y+self.ay
  if self.x<0 or self.x>127
   or self.y<0 or self.y>127 then
   self.complete=true
  else
   if self.type.player then
    if e.count>0 then
     for i,enemy in pairs(e.items) do
      if self:collide_object(enemy) then
       printh("bullet:collided with enemy") -- ######################
       enemy:destroy()
      end
     end
    end
   else
    if self:collide_object(p) then
     printh("bullet:collided with player") -- ######################
     p:destroy()
    end
   end
  end
 end,
 draw=function(self)
  --movable.draw(self)
  if self.complete then return true end
  spr(self.type.sprite,self.x-self.hitbox.x+4-flr(self.type.w/2),self.y)
  return false
 end
} setmetatable(bullet,{__index=movable})

alien_types={
 {ax=0.01,ay=0.01,neutral={19},left={19},right={19},score=100}
}

alien={
 create=function(self,x,y,type)
  local otype=alien_types[type]
  local o=animatable.create(self,x,y,otype.ax,otype.ay)
  o.anim:add_stage("core",1,false,otype.neutral,otype.left,otype.right)
  o.anim:init("core",dir.neutral)
  o.type=otype
  return o
 end,
 destroy=function(self)
  x:add(ship_particles:create(self.x+4,self.y+4))
  x:add(ship_smoke:create(self.x+4,self.y+4))
  self.complete=true
  score=score+self.type.score
  cam:shake(1,0.9)
 end,
 update=function(self)
  --movable.update(self)

  self.dx=self.dx+self.ax
  self.dx=mid(-self.max.dx,self.dx,self.max.dx)
  self.x=self.x+round(self.dx)
  if self.x<-8 then self.x=120 end
  if self.x>127 then self.x=0 end

  self.dy=self.dy+self.ay
  self.dy=mid(-self.max.dy,self.dy,self.max.dy)
  self.y=self.y+round(self.dy)

  if self.y<0 or self.y>127 then
   self.complete=true
  else
   if self:collide_object(p) then
    printh("alien:collided with player") -- ######################
    p:destroy()
    self:destroy()
   end
  end
 end,
 draw=function(self)
  if self.complete then return true end
  animatable.draw(self)
  return false
 end
} setmetatable(alien,{__index=animatable})

-- [[ camera ]]

cam={
 x=0,y=0,force=0,decay=0,max=5,
 shake=function(self,force,decay)
  self.force=min(self.force+force,self.max)
  self.decay=max(self.decay,decay)
 end,
 update=function(self)
  if self.force==0 then return end
  self.angle=rnd()
  self.x=cos(self.angle)*self.force
  self.y=sin(self.angle)*self.force
  self.force=self.force*self.decay
  if self.force<0.1 then
   self.force=0
   self.decay=0
  end
 end,
 position=function(self)
  return self.x,self.y
 end
}

-- [[ core routines ]]

function _init()
 -- create player
 p=player:create(64,96)
 -- create collections
 b=bullets:create()
 e=enemies:create()
 x=explosions:create()
 s=particles:create()
 -- populate collections
 s:add(star_particles:create())

 --[[

use proc gen
the earlier the level the less likely a difficult alien is likely to be picked
pick most diff firs then fill with easiest

almost want affectors to apply an affector to an enemies path

]]
 for i=0,120,8 do
  e:add(alien:create(i,20,1))
 end

end

function _update60()
 cam:update()
 p:update() -- update player
 b:update() -- update bullets
 e:update() -- update enemies
 x:update() -- update explosions
 s:update() -- update particles
 --if rnd(20)>19.8 then cam:shake(rnd(5)+3,0.9) end
end

function _draw()
 cls(0)
 camera(cam:position())
 s:draw() -- draw particles
 b:draw() -- draw bullets
 e:draw() -- draw enemies
 x:draw() -- draw explosions
 p:draw() -- draw player

 print(stat(1),100,0,3)
 print(score,0,10,6)
 print(#e.items,0,0,2)
 print(#x.items,20,0,2)
 print(#b.items,40,0,2)
 print(#s.items,60,0,2)
end

-- [[ shared functions ]]

-- e.g.> x=mrnd({5,10}) -- returns an integer between 5 and 10 inclusive
-- x|table|the minimum and maximum values
-- f|boolean|whether to return the floor of the value. default is true.
function mrnd(x,f)
 if f==nil then f=true end
 local v=(rnd()*(x[2]-x[1]+(f and 1 or 0.0001)))+x[1]
 return f and flr(v) or flr(v*1000)/1000
end

-- e.g.> x=round(1.23) -- rounds 1.23 to the nearest integer
-- x|float|the number to round
function round(x) return flr(x+0.5) end

__gfx__
00000000770000008800880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000aa0000003b003b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000990000003b003b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000980000003b003b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000880000003b003b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000080000003300330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00056000000560000005600000a77a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
005dd600005dd66005ddd60009a77a90000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
505ddd06005ddd00005ddd00009a7a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
005bbd00053bd66005ddbbd00099a900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5053bd06003bdd6005ddbb0000099000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55533ddd0533dd6005dd3bd000090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5055550d05555d6005d555d000009000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5080080d05028dd0055820d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
