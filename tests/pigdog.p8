pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- pigdog
-- by neil popham

screen={width=128,height=128}
pad={left=0,right=1,up=2,down=3,btn1=4,btn2=5}
dir={left=1,right=2,neutral=3}
drag=0.75
stage=nil
high_scores={7000,6500,6000,5500,5000,4500,4000,3500,3000,2500}
colours={1,2,5,4,8,3,13,14,12,9,6,11,15,7,10}
cartdata_version=1

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

sprite={
 create=function(self,params)
  local o=particle.create(self,params)
  return o
 end,
 draw=function(self)
  if self.life==0 then return true end
  spr(self.sprite,self.x,self.y)
  self.life=self.life-1
  return self.life==0
 end
} setmetatable(sprite,{__index=particle})

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
  --o.update=function(self,ps)
   -- do nothing
  --end
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
  return o
 end,
 init_particle=function(self,ps,p)
  emmiter.init_particle(self,ps,p)
  p.x=self.target.x+self.dx+p.dx
  p.y=self.target.y+self.dy+p.dy
 end
} setmetatable(follower,{__index=emmiter})

-- [[ affectors ]]

affector={
 create=function(self,params)
  local o=params or {}
  setmetatable(o,self)
  self.__index=self
  return o
 end,
 update=function(self,ps)
  -- do nothing
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
  o.action={
   function(self,i,p) if i % 3==0 then p.col=10 else p.col=7 end end,
   function(self,i,p) p.col=p.ocol end,
   function(self,i,p) p.col=self.col[1][p.ocol+1] end,
   function(self,i,p) p.col=self.col[2][p.ocol+1] end,
   function(self,i,p) p.col=1 end
  }
  o.update=function(self,ps)
   for i,p in pairs(ps.particles) do
    if p.ocol==nil then p.ocol=p.col end
    local life=p.life/p.ttl
    local c=1
    while life<self.cycle[c] do c=c-1 end
    local action=self.action[c]
    action(i,p)
    --[[
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
    ]]
   end
  end
  return o
 end
} setmetatable(heat,{__index=affector})

-- [[ particle system ]]

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
  --for _,e in pairs(self.emitters) do e:update(self) end -- #######################
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

bullet_smoke={
 create=function(self,x,y,cols,count)
  cols=cols or {6,13,5} -- {14,8,2} -- {10,9,8} -- {11,3,1}
  count=count or 10
  local ps=particle_system.create(self)
  add(ps.emitters,stationary:create({force={0.2,0.5},angle={1,360}}))
  add(ps.affectors,gravity:create({force=0.1}))
  add(ps.affectors,size:create({shrink=0.9,cycle={4,2,0},col=cols}))
  ps.add_particle=function(self)
   particle_system.add_particle(
    self,
    circle:create({x=x,y=y,dx={-4,4},dy={-4,4},size={2,4},col={6},life={30,60}})
   )
  end
  for i=1,count do
   ps:add_particle()
  end
  return ps
 end
} setmetatable(bullet_smoke,{__index=particle_system})

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

bullet_col={
 create=function(self)
  local o=collection.create(self)
  return o
 end
} setmetatable(bullet_col,{__index=collection})

enemy_col={
 create=function(self)
  local o=collection.create(self)
  o.reset(self)
  return o
 end,
 reset=function(self)
  collection.reset(self)
  self.wave=0
  self.delay={0,240,310}
  self:clear()
 end,
 clear=function(self)
  if self.wave>0 then self.delay[1]=120 end
  self.t=0
  self.wty=-6
 end,
 update=function(self)
  if self.count==0 then
   if p.complete then return end
   self.t=self.t+1
   if self.t>self.delay[3] then
    self:clear()
    -- start new wave
    self.wave=self.wave+1
    for i=0,120,16 do
     self:add(alien:create(i,20,mrnd({1,3})))
    end
   elseif self.t>self.delay[2] then
    self.wty=self.wty+1
   elseif self.t>self.delay[1] then
    if self.wty<61 then
     self.wty=self.wty+1
    end
   end
  end
  collection.update(self)
 end,
 draw=function(self)
  collection.draw(self)
  if self.t>self.delay[1] and self.t<self.delay[3] then
   printh("t:"..self.t.." wty:"..self.wty) -- ############################### when wty==128 we can stop t there
   dprint("wave "..lpad(self.wave+1),50,self.wty)
  end
 end
} setmetatable(enemy_col,{__index=collection})

explosion_col={
 create=function(self)
  local o=collection.create(self)
  return o
 end
} setmetatable(explosion_col,{__index=collection})

particle_col={
 create=function(self)
  local o=collection.create(self)
  return o
 end
} setmetatable(particle_col,{__index=collection})

drop_col={
 create=function(self)
  local o=collection.create(self)
  return o
 end
} setmetatable(drop_col,{__index=collection})

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
  if self.complete then return false end
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

player={
 create=function(self,x,y)
  local o=animatable.create(self,x,y,0.2,0.2)
  o.anim:add_stage("core",1,false,{16},{17},{18})
  o.anim:init("core",dir.neutral)
  o.sx=x
  o.sy=y
  o.reset(self)
  return o
 end,
 reset=function(self)
  self.complete=false
  self.score=0
  self.bullet=1
  self.damage=500
  self.bombs=3
  self.x=self.sx
  self.y=self.sy
  self.trail=player_trail:create(self)
 end,
 destroy=function(self)
  sfx(3)
  explosions:add(ship_particles:create(self.x+4,self.y+4,{2,3,11},20))
  explosions:add(ship_smoke:create(self.x+4,self.y+4,{11,3,1},30))
  cam:shake(5,0.9)
  self.complete=true
  save_score(self.score)
  stage=game_over
  game_over:init()
 end,
 hit=function(self)
  sfx(3)
  explosions:add(ship_particles:create(self.x+4,self.y+4,{2,3,11},10))
  explosions:add(ship_smoke:create(self.x+4,self.y+4,{11,3,1},5))
  cam:shake(2,0.8)
 end,
 update=function(self)
  if self.complete then return end
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
   self.dx=self.dx*drag
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
   self.dy=self.dy*drag
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
  -- button 1
  if btnp(pad.btn1) then
   sfx(0)
   bullets:add(bullet:create(self.x,self.y,self.bullet))
  end
  -- button 2
  if btnp(pad.btn2) then
   if self.bombs>0 then
    self.bombs=self.bombs-1
    particles:add(smart_bomb:create(self.x+4,self.y+4))
    cam:shake(5,0.93)
    if enemies.count>0 then
     for _,enemy in pairs(enemies.items) do
      local dx=abs(self.x-enemy.x)
      local dy=abs(self.y-enemy.y)
      local distance=sqrt(dx^2+dy^2)
      if distance<40 then
       printh("smart bomb:hit enemy")
       enemy.damage=enemy.damage-1000
       if enemy.damage<1 then
        enemy:destroy()
       else
        enemy:hit()
       end
      end
     end
    end
   end
  end
  -- trail
  self.trail:update()
 end,
 draw=function(self)
  if self.complete then return end
  animatable.draw(self)
  self.trail:draw()
 end
} setmetatable(player,{__index=animatable})

drop={
 sprites={38,39,40},
 cols={9,11,8,12},
 create=function(self,x,y,type)
  local o=movable.create(self,x,y,0,0.2)
  o.type=type
  o.sprite=self.sprites[type]
  return o
 end,
 destroy=function(self)
  self.complete=true
  sfx(5)
  cam:shake(1,0.8)
  local col=self.cols[self.type]
  --explosions:add(ship_particles:create(self.x+4,self.y+4,{7,col,col},10))
  explosions:add(ship_smoke:create(self.x+4,self.y+4,{7,col,col},10))
 end,
 update=function(self)
  --movable.update(self)
  self.y=self.y+1
  if self.y>127 then
   self.complete=true
  else
   if self:collide_object(p) then
    self:destroy()
    printh("drop hit player!") -- ##################################
    printh("type:"..self.type) -- ##################################
    if self.type==1 then
     p.bombs=p.bombs+1
    elseif self.type==2 then
     p.bullet=2
    elseif self.type==3 then
     p.bullet=3
    end
   end
  end
 end,
 draw=function(self)
  --movable.draw(self)
  if self.complete then return true end
  spr(self.sprite,self.x,self.y)
  return false
 end
} setmetatable(drop,{__index=movable})

bullet_update_linear=function(self)
 self.y=self.y+self.ay
end

bullet_types={
 {sprite=1,ax=0,ay=-4,w=2,h=6,player=true,damage=200,update=bullet_update_linear},
 {sprite=2,ax=0,ay=-6,w=6,h=6,player=true,damage=400,update=bullet_update_linear},
 {sprite=3,ax=0,ay=-6,w=8,h=6,player=true,damage=600,update=bullet_update_linear}
}

bullet={
 create=function(self,x,y,type)
  local otype=bullet_types[type]
  local o=movable.create(self,x,y,otype.ax,otype.ay)
  o.type=otype
  o.add_hitbox(self,otype.w,otype.h)
  return o
 end,
 destroy=function(self)
  self.complete=true
  explosions:add(ship_particles:create(self.x+(self.type.w/2),self.y+(self.type.h/2),{7,8,9,10},10))
  explosions:add(bullet_smoke:create(self.x+(self.type.w/2),self.y+(self.type.h/2),{6,5,1},8+self.type.w))
 end,
 update=function(self)
  movable.update(self)
  self.type.update(self)
  if self.x<0 or self.x>127
   or self.y<0 or self.y>127 then
   self.complete=true
  else
   if self.type.player then
    if enemies.count>0 then
     for i,enemy in pairs(enemies.items) do
      if self:collide_object(enemy) then
       printh("bullet:collided with enemy") -- ######################
       self:destroy()
       enemy.damage=enemy.damage-self.type.damage
       if enemy.damage<1 then
        enemy:destroy()
       else
        enemy:hit()
       end
       break
      end
     end
    end
   else
    if self:collide_object(p) then
     printh("bullet:collided with player") -- ######################
     self:destroy()
     p.damage=p.damage-self.type.damage
     if p.damage<1 then
      p:destroy()
     else
      p:hit()
     end
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
  --self.dx=self.dx+self.ax
  --self.dx=mid(-self.max.dx,self.dx,self.max.dx)
  --self.dy=self.dy+self.ay
  --self.dy=mid(-self.max.dy,self.dy,self.max.dy)
 end

alien_types={
 {
  ax=0.05,ay=0.5,
  neutral={20},left={20},right={20},
  sfx=3,
  score=50,
  damage=100,
  pixels={7,8,9,10},
  smoke={10,9,8},
  update=alien_update_linear
 },
 {
  ax=0.05,ay=0.5,
  neutral={21},left={21},right={21},
  sfx=3,
  score=100,
  damage=150,
  pixels={7,8,9,10},
  smoke={14,8,2},
  update=alien_update_linear
 },
 {
  ax=0.05,ay=0.5,
  neutral={22},left={22},right={22},
  sfx=3,
  score=200,
  damage=500,
  pixels={7,8,9,10},
  smoke={11,3,1},
  update=alien_update_linear
 }
}

alien={
 create=function(self,x,y,type)
  local otype=alien_types[type]
  local o=animatable.create(self,x,y,otype.ax,otype.ay)
  o.max={dx=1,dy=1}
  o.anim:add_stage("core",1,false,otype.neutral,otype.left,otype.right)
  o.anim:init("core",dir.neutral)
  o.type=otype
  o.damage=otype.damage
  return o
 end,
 destroy=function(self)
  sfx(self.type.sfx)
  explosions:add(ship_particles:create(self.x+4,self.y+4,self.type.pixels))
  explosions:add(ship_smoke:create(self.x+4,self.y+4,self.type.smoke))
  self.complete=true
  p.score=p.score+self.type.score
  cam:shake(1,0.9)
  if p.bombs<5 or p.bullet<3 then
   local type=1
   if true then--if rnd()>1 then -- should be based on self.score and maybe wave
    if p.bullet<3 and (p.bombs==5 or rnd()>0.33) then
     type=p.bullet==1 and 2 or 3
    end
    drops:add(drop:create(self.x,self.y,type))
   end
  end
 end,
 hit=function(self)
  sfx(self.type.sfx)
  explosions:add(ship_particles:create(self.x+4,self.y+4,self.type.pixels,10))
  explosions:add(bullet_smoke:create(self.x+4,self.y+4,self.type.smoke,5))
  cam:shake(1,0.7)
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
    self:destroy()
    p.damage=p.damage-self.damage
    if p.damage<1 then
     p:destroy()
    else
     p:hit()
    end
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
 init=function(self)
   self.blank=true
   self.t=0
   self.c=1
   for i=1,15 do pal(i,0) end
 end,
 update=function(self)
  cam:update()
  particles:update() -- update particles
  if self.blank and time()>1 then
   if self.t%2==0 then
    pal(colours[self.c],colours[self.c])
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
  particles:draw()
  dprint("press \142 or \151 to start",18,110)
  for i=1,10 do
   dprint(lpad(i).."                 "..lpad(high_scores[i],5),16,16+i*8,10,4)
  end
 end
}

game={
 init=function(self)
  enemies:reset()
  p:reset()
 end,
 update=function(self)
  cam:update()
  p:update()
  bullets:update()
  enemies:update()
  explosions:update()
  particles:update()
  drops:update()
 end,
 draw=function(self)
  cls(0)
  camera(cam:position())
  particles:draw()
  drops:draw()
  bullets:draw()
  enemies:draw()
  explosions:draw()
  p:draw()
  draw_hud()
  --[[
  print(stat(1),0,40,1) --############################
  print(#e.items,0,47,1) --############################
  print(#x.items,0,54,1) --############################
  print(#b.items,0,61,1) --############################
  print(#s.items,0,68,1) --############################
  --]]
 end
}

game_over={
 t=0,
 init=function(self)
  self.blank=false
  self.t=0
  self.c=15
 end,
 update=function(self)
  cam:update()
  bullets:update()
  enemies:update()
  explosions:update()
  particles:update()
  drops:update()
  if self.t>3600 then
   self.blank=true
  elseif self.t>60 then
   if btn(pad.btn1) then
    stage=game
    stage:init()
   elseif btn(pad.btn2) then
    self.blank=true
   end
  end
  if self.blank then
   if self.t%2 then
    pal(colours[self.c],0)
    self.c=self.c-1
    if self.c==0 then
     stage=intro
     stage:init()
    end
   end
  end
  self.t=self.t+1
 end,
 draw=function(self)
  cls(0)
  camera(cam:position())
  particles:draw()
  drops:draw()
  bullets:draw()
  enemies:draw()
  explosions:draw()
  if self.t>60 then
   dprint("game over",46,61,9,8)
   dprint("press \142 to restart",28,90)
   dprint("or \151 to return to the menu",12,100)
  end
  draw_hud()
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

function load_scores()
 for i=1,10 do
  local s=dget(i)
  printh("dget("..i..")="..s)
  if s>0 then
   high_scores[i]=s
  end
  high_score=high_scores[1]
 end
end

function save_score(s)
 if s>high_scores[10] then
  for i=1,10 do
   if s>high_scores[i] then
    for j=10,i+1,-1 do
     high_scores[j]=high_scores[j-1]
    end
    high_scores[i]=s
    for i=1,10 do dset(i,high_scores[i]) end
    break
   end
  end
 end
end

function draw_hud()
 -- scores
  dprint(lpad(p.score,5),108,2,7,5)
  dprint(lpad(high_scores[1],5),54,2,9,4)
  -- life
  for i=1,5 do
   spr(p.damage>=i*100 and 35 or 36,7*(i-1),3)
  end
  -- bombs
  if p.bombs>0 then
   for i=1,p.bombs do
    spr(37,124-6*(i-1),124)
   end
  end
end

function _init()
 -- cartdata
 cartdata("pops_pigdog_"..cartdata_version)
 load_scores()
 -- create player
 p=player:create(60,96)
 -- create collections
 bullets=bullet_col:create()
 enemies=enemy_col:create()
 explosions=explosion_col:create()
 particles=particle_col:create()
 drops=drop_col:create()
 -- populate collections
 particles:add(star_particles:create())
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
-- f|boolean|whether to return the floor of the value. default is true
function mrnd(x,f)
 if f==nil then f=true end
 local v=(rnd()*(x[2]-x[1]+(f and 1 or 0.0001)))+x[1]
 return f and flr(v) or flr(v*1000)/1000
end

-- e.g.> x=round(1.23) -- rounds 1.23 to the nearest integer
-- x|float|the number to round
function round(x) return flr(x+0.5) end

-- e.g.> dprint("text",0,0,7,2) -- prints "text" at 0,0 in white with a purple shadow
-- s|text|the text to print
-- x|integer|x co-ordinate
-- y|integer|y co-ordinate
-- c1|integer|the main text colour. default is white
-- c2|integer|the shadow colour. default is purple
function dprint(s,x,y,c1,c2)
 c1=c1 or 7
 c2=c2 or 2
 print(s,x,y+1,c2)
 print(s,x,y,c1)
end

-- e.g.> lpad(123,5) -- returns 00123
-- x|integer|the number to pad
-- n|integer|the number of characters to return. default is 2
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
000000000000000008888880080800000d0d00000d80000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000088889888888e8000ddd6d0005ddd0000099999900bbbbbb0088888800cccccc0000000000000000000000000000000000000000000000000
000000000000000088119a8888888000ddddd00055dd0000499689993bb777bb28777888dcc8c8cc000000000000000000000000000000000000000000000000
000000000000000088119998088800000ddd000005500000496666993bbbb7bb28887888dc88888c000000000000000000000000000000000000000000000000
0000000000000000881111880080000000d0000000000000416666193b7777bb28877788dc88888c000000000000000000000000000000000000000000000000
000000000000000088111188000000000000000000000000411661193b77bbbb28887788dcc888cc000000000000000000000000000000000000000000000000
00000000000000008888888800000000000000000000000044111194337777b322777782ddcc8ccd000000000000000000000000000000000000000000000000
0000000000000000088888800000000000000000000000000444444003333330022222200dddddd0000000000000000000000000000000000000000000000000
__label__
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888ffffff882222228888888888888888888888888888888888888888888888888888888888888888228228888ff88ff888222822888888822888888228888
88888f8888f882888828888888888888888888888888888888888888888888888888888888888888882288822888ffffff888222822888882282888888222888
88888ffffff882888828888888888888888888888888888888888888888888888888888888888888882288822888f8ff8f888222888888228882888888288888
88888888888882888828888888888888888888888888888888888888888888888888888888888888882288822888ffffff888888222888228882888822288888
88888f8f8f88828888288888888888888888888888888888888888888888888888888888888888888822888228888ffff8888228222888882282888222288888
888888f8f8f8822222288888888888888888888888888888888888888888888888888888888888888882282288888f88f8888228222888888822888222888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555550000000000000000000000000000000000000000000000000000000000000000005555550000000000000000000000000000000000000000005555555
55555550000000000000000000000000000000000000000000000000000000000000000005555550000000000011111111112222222222333333333305555555
55555550000000000000000000000000000000000000000000000000000000000000000005555550000000000011111111112222222222333333333305555555
55555550000000000000000000000000000000000000000000000000000000000000000005555550000000000011111111112222222222333333333305555555
55555550000000000000000000000000000000000000000000000000000000000000000005555550000000000011111111112222222222333333333305555555
55555550000000000000000000000000000000000000000000000000000000000000000005555550000000000011111111112222222222333333333305555555
55555550000000000000000000000000000000000000000000000000000000000000000005555550000000000011111111112222222222333333333305555555
55555550000000000000000000000000000000000000000000000000000000000000000005555550000000000011111111112222222222333333333305555555
55555550000000000000000000000000000000000000000000000000000000000000000005555550000000000011111111112222222222333333333305555555
5555555000000000cccccccccccccccccccccccccccccccccccccccccccccccc0000000005555550000000000011111111112222222222333333333305555555
5555555000000000cccccccccccccccccccccccccccccccccccccccccccccccc0000000005555550444444444455555555556666666666777777777705555555
5555555000000000cccccccccccccccccccccccccccccccccccccccccccccccc0000000005555550444444444455555555556666666666777777777705555555
5555555000000000cccccccccccccccccccccccccccccccccccccccccccccccc0000000005555550444444444455555555556666666666777777777705555555
5555555000000000cccccccccccccccccccccccccccccccccccccccccccccccc0000000005555550444444444455555555556666666666777777777705555555
5555555000000000cccccccccccccccccccccccccccccccccccccccccccccccc0000000005555550444444444455555555556666666666777777777705555555
5555555000000000cccccccccccccccccccccccccccccccccccccccccccccccc0000000005555550444444444455555555556666666666777777777705555555
5555555000000000cccccccccccccccccccccccccccccccccccccccccccccccc0000000005555550444444444455555555556666666666777777777705555555
55555550ddddddddcccccccccccccccc88888888cccccccc88888888cccccccccccccccc05555550444444444455555555556666666666777777777705555555
55555550ddddddddcccccccccccccccc88888888cccccccc88888888cccccccccccccccc05555550444444444455555555556666666666777777777705555555
55555550ddddddddcccccccccccccccc88888888cccccccc88888888cccccccccccccccc0555555088888888889999999999aaaaaaaaaabbbbbbbbbb05555555
55555550ddddddddcccccccccccccccc88888888cccccccc88888888cccccccccccccccc0555555088888888889999999999aaaaaaaaaabbbbbbbbbb05555555
55555550ddddddddcccccccccccccccc88888888cccccccc88888888cccccccccccccccc0555555088888888889999999999aaaaaaaaaabbbbbbbbbb05555555
55555550ddddddddcccccccccccccccc88888888cccccccc88888888cccccccccccccccc0555555088888888889999999999aaaaaaaaaabbbbbbbbbb05555555
55555550ddddddddcccccccccccccccc88888888cccccccc88888888cccccccccccccccc0555555088888888889999999999aaaaaaaaaabbbbbbbbbb05555555
55555550ddddddddcccccccccccccccc88888888cccccccc88888888cccccccccccccccc0555555088888888889999999999aaaaaaaaaabbbbbbbbbb05555555
55555550ddddddddcccccccc8888888888888888888888888888888888888888cccccccc0555555088888888889999999999aaaaaaaaaabbbbbbbbbb05555555
55555550ddddddddcccccccc8888888888888888888888888888888888888888cccccccc0555555088888888889999999999aaaaaaaaaabbbbbbbbbb05555555
55555550ddddddddcccccccc8888888888888888888888888888888888888888cccccccc05555550888888888777777777777aaaaaaaaabbbbbbbbbb05555555
55555550ddddddddcccccccc8888888888888888888888888888888888888888cccccccc05555550ccccccccc700000000007eeeeeeeeeffffffffff05555555
55555550ddddddddcccccccc8888888888888888888888888888888888888888cccccccc05555550ccccccccc70dddddddd07eeeeeeeeeffffffffff05555555
55555550ddddddddcccccccc8888888888888888888888888888888888888888cccccccc05555550ccccccccc70dddddddd07eeeeeeeeeffffffffff05555555
55555550ddddddddcccccccc8888888888888888888888888888888888888888cccccccc05555550ccccccccc70dddddddd07eeeeeeeeeffffffffff05555555
55555550ddddddddcccccccc8888888888888888888888888888888888888888cccccccc05555550ccccccccc70dddddddd07eeeeeeeeeffffffffff05555555
55555550ddddddddcccccccc8888888888888888888888888888888888888888cccccccc05555550ccccccccc70dddddddd07eeeeeeeeeffffffffff05555555
55555550ddddddddcccccccc8888888888888888888888888888888888888888cccccccc05555550ccccccccc70dddddddd07eeeeeeeeeffffffffff05555555
55555550ddddddddcccccccc8888888888888888888888888888888888888888cccccccc05555550ccccccccc70dddddddd07eeeeeeeeeffffffffff05555555
55555550ddddddddcccccccc8888888888888888888888888888888888888888cccccccc05555550ccccccccc700000000007eeeeeeeeeffffffffff05555555
55555550ddddddddcccccccc8888888888888888888888888888888888888888cccccccc05555550000000000777777777777000000000000000000005555555
55555550ddddddddcccccccc8888888888888888888888888888888888888888cccccccc05555555555555555555555555555555555555555555555555555555
55555550ddddddddcccccccc8888888888888888888888888888888888888888cccccccc05555555555555555555555555555555555555555555555555555555
55555550ddddddddcccccccc8888888888888888888888888888888888888888cccccccc05555555555555555555555555555555555555555555555555555555
55555550ddddddddcccccccccccccccc888888888888888888888888cccccccccccccccc05555550000000555556667655555555555555555555555555555555
55555550ddddddddcccccccccccccccc888888888888888888888888cccccccccccccccc05555550000000555555666555555555555555555555555555555555
55555550ddddddddcccccccccccccccc888888888888888888888888cccccccccccccccc0555555000000055555556dddddddddddddddddddddddd5555555555
55555550ddddddddcccccccccccccccc888888888888888888888888cccccccccccccccc0555555000d0005555555655555555555555555555555d5555555555
55555550ddddddddcccccccccccccccc888888888888888888888888cccccccccccccccc05555550000000555555576666666d6666666d666666655555555555
55555550ddddddddcccccccccccccccc888888888888888888888888cccccccccccccccc05555550000000555555555555555555555555555555555555555555
55555550ddddddddcccccccccccccccc888888888888888888888888cccccccccccccccc05555550000000555555555555555555555555555555555555555555
55555550ddddddddcccccccccccccccc888888888888888888888888cccccccccccccccc05555555555555555555555555555555555555555555555555555555
55555550ddddddddddddddddcccccccccccccccc88888888ccccccccccccccccdddddddd05555555555555555555555555555555555555555555555555555555
55555550ddddddddddddddddcccccccccccccccc88888888ccccccccccccccccdddddddd05555556665666555556667655555555555555555555555555555555
55555550ddddddddddddddddcccccccccccccccc88888888ccccccccccccccccdddddddd05555556555556555555666555555555555555555555555555555555
55555550ddddddddddddddddcccccccccccccccc88888888ccccccccccccccccdddddddd0555555555555555555556dddddddddddddddddddddddd5555555555
55555550ddddddddddddddddcccccccccccccccc88888888ccccccccccccccccdddddddd055555565555565555555655555555555555555555555d5555555555
55555550ddddddddddddddddcccccccccccccccc88888888ccccccccccccccccdddddddd05555556665666555555576666666d6666666d666666655555555555
55555550ddddddddddddddddcccccccccccccccc88888888ccccccccccccccccdddddddd05555555555555555555555555555555555555555555555555555555
55555550ddddddddddddddddcccccccccccccccc88888888ccccccccccccccccdddddddd05555555555555555555555555555555555555555555555555555555
5555555000000000dddddddddddddddddddddddddddddddddddddddddddddddd0000000005555555555555555555555555555555555555555555555555555555
5555555000000000dddddddddddddddddddddddddddddddddddddddddddddddd0000000005555555555555555555555555555555555555555555555555555555
5555555000000000dddddddddddddddddddddddddddddddddddddddddddddddd0000000005555550005550005550005550005550005550005550005550005555
5555555000000000dddddddddddddddddddddddddddddddddddddddddddddddd00000000055555011d05011d05011d05011d05011d05011d05011d05011d0555
5555555000000000dddddddddddddddddddddddddddddddddddddddddddddddd0000000005555501110501110501110501110501110501110501110501110555
5555555000000000dddddddddddddddddddddddddddddddddddddddddddddddd0000000005555501110501110501110501110501110501110501110501110555
5555555000000000dddddddddddddddddddddddddddddddddddddddddddddddd0000000005555550005550005550005550005550005550005550005550005555
5555555000000000dddddddddddddddddddddddddddddddddddddddddddddddd0000000005555555555555555555555555555555555555555555555555555555
55555550000000000000000000000000000000000000000000000000000000000000000005555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555550000000055555555555555555555555555555555555555555555555555
5555555555555555555555555d555555ddd5555d5d5d5d5555d5d555555557555555550cccccc056666666666666555557777755555555555555555555555555
555555555555555555555555ddd55555ddd555555555555555d5d5d555555575555555dcc8c8cc56ddd6d6d6dd66555577ddd775566666555666665556666655
55555555555555555555555ddddd5555ddd5555d55555d5555d5d5d555555557555555dc88888c56d6d6d6d66d66555577d7d77566dd666566ddd66566ddd665
5555555555555555555555ddddd55555ddd555555555555555ddddd555777777755555dc88888c56d6d6ddd66d66555577d7d775666d66656666d665666dd665
555555555555555555555d5ddd5555ddddddd55d55555d55d5ddddd557577777555555dcc888cc56d6d666d66d66555577ddd775666d666566d666656666d665
555555555555555555555d55d55555d55555d555555555555dddddd557557775555555ddcc8ccd56ddd666d6ddd655557777777566ddd66566ddd66566ddd665
555555555555555555555ddd555555ddddddd55d5d5d5d55555ddd55575557555555550dddddd056666666666666555577777775666666656666666566666665
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555566666665ddddddd5ddddddd5ddddddd5
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
5080080d05028dd0055820d0000000000002200001dddd1000444400500000060000000777777777700000000000000000000000000000000000000000000000
000000000000000008888880080800000d0d00000d80000000000000000000000000000700000000700000000000000000000000000000000000000000000000
000000000000000088889888888e8000ddd6d0005ddd0000099999900bbbbbb0088888070cccccc0700000000000000000000000000000000000000000000000
000000000000000088119a8888888000ddddd00055dd0000499689993bb777bb28777807dcc8c8cc700000000000000000000000000000000000000000000000
000000000000000088119998088800000ddd000005500000496666993bbbb7bb28887807dc88888c700000000000000000000000000000000000000000000000
0000000000000000881111880080000000d0000000000000416666193b7777bb28877707dc88888c700000000000000000000000000000000000000000000000
000000000000000088111188000000000000000000000000411661193b77bbbb28887707dcc888cc700000000000000000000000000000000000000000000000
00000000000000008888888800000000000000000000000044111194337777b322777707ddcc8ccd700000000000000000000000000000000000000000000000
0000000000000000088888800000000000000000000000000444444003333330022222070dddddd0700000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000777777777700000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888

__sfx__
00010000300502e0502c0502a0502905028050260402504025040240402404024040230402104020070200401f0401e0401d0401c0401b0401b0401a04019040140001000013000110000e0000b0000900007000
000200003265031660306602f6702e6702d6702c6702a670276702567023660216601f6501d6501a65019640176301663012630106300f6200c6200a6200762003610016100f6000d6000b600096000760003600
00150000086400a650086500865008650076500565005650066500565005640056400563004630036200362003610016100660005600046000460003600036000360003600026000430003300033000330003300
00070000366502d660246601b65017650146500e640086300662004610016100161001600016001d6001c6001b6001a6001a60019600186001760017600000000000000000000000000000000000000000000000
0006000038660246601d65015640116300e6200861003610036000360002600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00060000205502355028550235501d550304003040030400304000b50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
