pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- pigdog
-- by neil popham

screen={width=128,height=128}
pad={left=0,right=1,up=2,down=3,btn1=4,btn2=5}

dir={left=1,right=2,neutral=3}
drag={air=0.75}
stage=nil
high_score=32000

-->8
--particles

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

linear={
 create=function(self,params)
  local o=particle.create(self,params)
  o.size=params.size or 3
  return o
 end,
 draw=function(self)
  if self.life==0 then return true end
  line(self.x,self.y,self.x+(cos(self.angle)*self.size),self.y-(sin(self.angle)*self.size),self.col)
  self.life=self.life-1
  return self.life==0
 end
} setmetatable(linear,{__index=particle})


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

delay={
 create=function(self,params)
  local o=affector.create(self,params)
  o.update=function(self,ps)
   for _,p in pairs(ps.particles) do
    if ps.tick<=p.delay then
     if p.oforce==nil then p.oforce=p.force end
     p.force=0
    elseif ps.tick>p.delay and p.oforce>0 then
     p.force=p.oforce
     p.oforce=0
    end
   end
  end
  return o
 end
} setmetatable(delay,{__index=affector})

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
 create=function(self,x,y,cols,count)
  cols=cols or {7,8,9,10}
  count=count or 10
  local ps=particle_system.create(self)
  add(ps.emitters,stationary:create({force={2,4},angle={1,360}}))
  add(ps.affectors,gravity:create({force=0.2}))
  ps.add_particle=function(self)
   particle_system.add_particle(
    self,
    spark:create({x=x,y=y,col=cols,life={30,80}})
   )
  end
  for i=1,count do
   ps:add_particle()
  end
  return ps
 end
} setmetatable(ship_particles,{__index=particle_system})

ship_smoke={
 create=function(self,x,y,cols,count)
  cols=cols or {10,9,8} -- {14,8,2} -- {10,9,8} -- {11,3,1}
  count=count or 20
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
  for i=1,count do
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

smart_bomb={
 create=function(self,x,y)
  local ps=particle_system.create(self)
  ps.x=x
  ps.y=y
  add(ps.emitters,stationary:create({force={4,4},angle={1,360}}))
  add(ps.affectors,randomise:create({angle={2,2}}))
  ps.add_particle=function(self)
   particle_system.add_particle(
    self,
    spark:create({x=x,y=y,life={16,40},col={1,3,5}})
    --linear:create({x=x,y=y,size=2,life={16,40},col={1,3,5}})
   )
  end
  for i=1,40 do
   ps:add_particle()
  end
  return ps
 end,
 draw=function(self)
  particle_system.draw(self)
  if self.tick<5 then
   circfill(self.x,self.y,32,11)
   circfill(self.x,self.y,30,12)
  end
 end
} setmetatable(smart_bomb,{__index=particle_system})

-- [[ screen memory ]]

--[[
function get_address(x,y)
 return 0x6000+flr(x/2)+(y*64)
end

function get_colour_pair(a)
 local b=peek(a)
 local l=b%16
 local r=(b-l)/16
 return {l,r}
end

function convert_to_particles(x,y,w,h)
 w=w or 128
 h=h or 128
 local ax={x,x+w-1}
 local ay={y,y+h-1}
 local a2=get_address(ax[2],ay[2])
 local ps=particle_system:create()
 add(ps.emitters,stationary:create({force={6,16},angle={-10,10}}))
 add(ps.affectors,delay:create())
 repeat
  local a1=get_address(x,y)
  local p=get_colour_pair(a1)
  for i=1,2 do
   if p[i]>0 then
    local z=(x+i-1-ax[1])+((y-ay[1])*(rnd()+1))
    ps:add_particle(spark:create({x=x+i-1,y=y,col={p[i]},life={20,80},delay=z}))
   end
  end
  x=x+2
  if x>ax[2] then
   x=ax[1]
   y=y+1
  end
 until a1==a2
 return ps
end
--]]

-->8
--collections

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
 end,
 reset=function(self)
  self.items={}
  self.count=0
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
  o.reset(self)
  return o
 end,
 reset=function(self)
  collection.reset(self)
  self.t=0
  self.wave=0
  self.delay={0,240,360}
  self.wty=-8
 end,
 update=function(self)
  if self.count==0 then
   printh("no enemies")
   if p.complete then return end
   self.t=self.t+1
   if self.t>self.delay[3] then
    self.t=0
    self.wty=-8
    self.wave=self.wave+1
    self.delay={120,240,360}
    for i=0,120,16 do
     self:add(alien:create(i,20,1))
    end
   elseif self.t>self.delay[2] then
    self.wty=self.wty+1
   elseif self.t>self.delay[1] then
    if self.wty<61 then self.wty=self.wty+1 end
    --s:add(self.ps)
   --elseif self.t==self.delay[1]+5 then
    --self.ps=convert_to_particles(50,61,29,7)
   end
  end
  collection.update(self)
 end,
 draw=function(self)
  collection.draw(self)
  if self.t>self.delay[1] and self.t<self.delay[3] then
   dprint("wave "..lpad(self.wave+1),50,self.wty)
  end
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

-->8
--objects

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
  o.anim={
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
  }
  return o
 end,
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
   sfx(0)
   b:add(bullet:create(p.x,p.y,self.bullet))
  end

  if btnp(pad.btn2) then
   s:add(smart_bomb:create(self.x+4,self.y+4))
   cam:shake(5,0.93)
   if e.count>0 then
    for _,enemy in pairs(e.items) do
     local dx=abs(self.x-enemy.x)
     local dy=abs(self.y-enemy.y)
     local distance=sqrt(dx^2+dy^2)
     if distance<40 then
      enemy:destroy()
     end
    end
   end
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
  p.trail=player_trail:create(p)
  p.reset(self)
  return p
 end,
 reset=function(self)
  self.complete=false
  self.score=0
  self.bullet=1
  self.x=60
  self.y=100
 end,
 destroy=function(self)
  sfx(3)
  x:add(ship_particles:create(self.x+4,self.y+4,{2,3,11},20))
  x:add(ship_smoke:create(self.x+4,self.y+4,{11,3,1},30))
  cam:shake(5,0.9)
  self.complete=true
  stage=game_over
  game_over:init()
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

bullet_update_linear=function(self)
 self.y=self.y+self.ay
end
bullet_types={
 {sprite=1,ax=0,ay=-4,w=2,h=6,player=true,update=bullet_update_linear},
 {sprite=2,ax=0,ay=-6,w=6,h=6,player=true,update=bullet_update_linear},
 {sprite=3,ax=0,ay=-6,w=8,h=6,player=true,update=bullet_update_linear}
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
  self.type.update(self)
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

alien_update_linear=function(self)
  self.dx=self.dx+self.ax
  self.dx=mid(-self.max.dx,self.dx,self.max.dx)
  self.dy=self.dy+self.ay
  self.dy=mid(-self.max.dy,self.dy,self.max.dy)
 end

alien_types={
 {
  ax=0.05,ay=0.5,
  neutral={20},left={20},right={20},
  sfx=3,
  score=100,
  update=alien_update_linear
 },
 {
  ax=0.05,ay=0.5,
  neutral={21},left={21},right={21},
  sfx=3,
  score=150,
  update=alien_update_linear
 }
}

alien={
 create=function(self,x,y,type)
  local otype=alien_types[type]
  local o=animatable.create(self,x,y,otype.ax,otype.ay)
  o.max.dy=1
  o.anim:add_stage("core",1,false,otype.neutral,otype.left,otype.right)
  o.anim:init("core",dir.neutral)
  o.type=otype
  return o
 end,
 destroy=function(self)
  sfx(self.type.sfx)
  x:add(ship_particles:create(self.x+4,self.y+4))
  x:add(ship_smoke:create(self.x+4,self.y+4))
  self.complete=true
  p.score=p.score+self.type.score
  cam:shake(1,0.9)
 end,
 update=function(self)

  self.type.update(self)

  self.x=self.x+round(self.dx)
  if self.x<-8 then self.x=120 end
  if self.x>127 then self.x=0 end

  self.y=self.y+round(self.dy)
  if self.y<-8 then self.y=120 end
  if self.y>127 then self.y=0 end

  if self.y<0 or self.y>127 then
   self.complete=true
  else
   if self:collide_object(p) then
    printh("alien:collided with player") -- ######################
    p:destroy()
    self:destroy()
    self.complete=true
   end
  end
 end,
 draw=function(self)
  if self.complete then return true end
  animatable.draw(self)
  return false
 end
} setmetatable(alien,{__index=animatable})

-->8
--stages

intro={
 blank=false,
 t=0,
 c=1,
 cols={1,2,5,4,8,3,13,14,12,9,6,11,15,7,10},
 init=function(self)
  -- set all colours to black so we can fade in
   for i=1,15 do pal(i,0) end
   self.blank=true
 end,
 update=function(self)
  cam:update()
  s:update() -- update particles
  -- is it time to fade in?
  if self.blank and time()>2 then
   if self.t%5==0 then
    pal(self.cols[self.c],self.cols[self.c])
    self.c=self.c+1
    if self.c==16 then self.blank=false end
   end
   self.t=self.t+1
  end
  if btnp(pad.btn1) or btnp(pad.btn2) then
   cam:shake(2,0.7)
   if self.blank then pal() end
   stage=game
   game:init()
  end
 end,
 draw=function(self)
  cls(0)
  camera(cam:position())
  s:draw() -- draw particles
  dprint("press \142 or \151 to start",18,100)
  print(stat(1),100,0,3)
 end
}

game={
 init=function(self)
  e:reset()
  p:reset()
 end,
 update=function(self)
  cam:update()
  p:update() -- update player
  b:update() -- update bullets
  e:update() -- update enemies
  x:update() -- update explosions
  s:update() -- update particles
 end,
 draw=function(self)
  cls(0)
  camera(cam:position())
  s:draw() -- draw particles
  b:draw() -- draw bullets
  e:draw() -- draw enemies
  x:draw() -- draw explosions
  p:draw() -- draw player

  print(stat(1),0,10,3)
  print(lpad(p.score,5),108,2,7)
  print(lpad(high_score,5),54,2,9)
  print(#e.items,0,0,2)
  print(#x.items,10,0,2)
  print(#b.items,20,0,2)
  print(#s.items,30,0,2)
 end
}

game_over={
 t=0,
 init=function(self)
  self.t=0
 end,
 update=function(self)
  cam:update()
  b:update() -- update bullets
  e:update() -- update enemies
  x:update() -- update explosions
  s:update() -- update particles
  if self.t>60 then
   if btn(pad.btn1) then
    stage=game
    game:init()
   end
  end
  self.t=self.t+1
 end,
 draw=function(self)
  cls(0)
  camera(cam:position())
  s:draw() -- draw particles
  b:draw() -- draw bullets
  e:draw() -- draw enemies
  x:draw() -- draw explosions
  if self.t>60 then
   dprint("game over",46,61,10,8)
   dprint("press \142 to restart",28,90)
   dprint("or \151 to return to the menu",12,100)
  end
  print(lpad(p.score,5),108,2,7)
  print(lpad(high_score,5),54,2,9)
 end
}

-->8
--core

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
   self.x=0
   self.y=0
  end
 end,
 position=function(self)
  return self.x,self.y
 end
}

function _init()
 -- create player
 p=player:create(60,96)
 -- create collections
 b=bullets:create()
 e=enemies:create()
 x=explosions:create()
 s=particles:create()
 -- populate collections
 s:add(star_particles:create())
 -- set the stage
 stage=intro
 stage:init()
end

function _update60()
 stage:update()
end

function _draw()
 stage:draw()
end

-- shared functions

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

function dprint(s,x,y,c1,c2)
 c1=c1 or 7
 c2=c2 or 2
 print(s,x,y+1,c2)
 print(s,x,y,c1)
end

function lpad(x,n)
 n=n or 2
 return sub("0000000"..x,-n)
end

__gfx__
00000000770000007700770077066077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000aa000000aa00aa00aa0990aa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000990000009900990099044099000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000980000009800890098044089000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000880000008800880088022088000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000080000008000080080000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000560000005600000056000b000b0000000000000d00700008008003000000b0000000000000000000000000000000000000000000000000000000000000000
005dd600005dd66005ddd6003d67b00002200ef00dd11c7004999aa00d0000600000000000000000000000000000000000000000000000000000000000000000
505ddd06005ddd00005ddd00dd667000222eeeffdd1cc1c7499999aa55dd66660000000000000000000000000000000000000000000000000000000000000000
005bbd00053bd66005ddbbd05dd6600022dcc6ef01c8ec104998899a528d68860000000000000000000000000000000000000000000000000000000000000000
5053bd06003bdd6005ddbb0005dd000022ddccef0dc8ec7044288899522d62860000000000000000000000000000000000000000000000000000000000000000
55533ddd0533dd6005dd3bd000000000022eeee00dc88c704428889905dd66600000000000000000000000000000000000000000000000000000000000000000
5055550d05555d6005d555d0000000000322eeb00ddccc7004422990055ddd600000000000000000000000000000000000000000000000000000000000000000
5080080d05028dd0055820d0000000000002200001dddd1000444400500000060000000000000000000000000000000000000000000000000000000000000000
00000000000000000888888008080000018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000088889888888e800011110000000000000cccccc0033333300888888000000000000000000000000000000000000000000000000000000000
000000000000000088119a88888880001111000000000000ccc18ccc333777338877788800000000000000000000000000000000000000000000000000000000
000000000000000088119998088800000110000000000000cc1111cc333337338888788800000000000000000000000000000000000000000000000000000000
000000000000000088111188008000000000000000000000cd1111dc337777338887778800000000000000000000000000000000000000000000000000000000
000000000000000088111188000000000000000000000000cdd11ddc337733338888778800000000000000000000000000000000000000000000000000000000
000000000000000088888888000000000000000000000000ccddddcc337777338877778800000000000000000000000000000000000000000000000000000000
0000000000000000088888800000000000000000000000000cccccc0033333300888888000000000000000000000000000000000000000000000000000000000
__sfx__
00010000300502e0502c0502a0502905028050260402504025040240402404024040230402104020040200401f0401e0401d0401c0401b0401b0401a04019040140001000013000110000e0000b0000900007000
000200003265031660306602f6702e6702d6702c6702a670276702567023660216601f6501d6501a65019640176301663012630106300f6200c6200a6200762003610016100f6000d6000b600096000760003600
00150000086400a650086500865008650076500565005650066500565005640056400563004630036200362003610016100660005600046000460003600036000360003600026000430003300033000330003300
00070000366502d660246601b65017650146500e640086300662004610016100161001600016001d6001c6001b6001a6001a60019600186001760017600000000000000000000000000000000000000000000000
0006000038660246601d65015640116300e6200861003610036000360002600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
