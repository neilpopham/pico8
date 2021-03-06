pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- pigdog
-- by neil popham

screen={width=128,height=128,x2=127,y2=127}
pad={left=0,right=1,up=2,down=3,btn1=4,btn2=5}
dir={left=1,right=2,neutral=3}
drag=0.75
stage=nil
high_scores={7000,6500,6000,5500,5000,4500,4000,3500,3000,2500}
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
    if p.x<0 or p.x>screen.x2
     or p.y<0 or p.y>screen.y2 then
     p.life=0
    end
   end
  end
  return o
 end
} setmetatable(bounds,{__index=affector})

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
  o.shrink=o.shrink or 0.9
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
    p.force=sqrt(dx^2+dy^2)
   end
  end
  return o
 end
} setmetatable(gravity,{__index=affector})

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

simple={
 create=function(self,fn,tick)
  local o={complete=false,tick=tick,fn=fn}
  setmetatable(o,self)
  self.__index=self
  return o
 end,
 update=function(self)
  self.tick=self.tick-1
 end,
 draw=function(self)
  self.fn(tick)
  self.complete=self.tick<1
  return self.complete
 end
}

-- [[ particle instances ]]

stars={
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
} setmetatable(stars,{__index=particle_system})

pixels={
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
} setmetatable(pixels,{__index=particle_system})

big_smoke={
 create=function(self,x,y,cols,count)
  cols=cols or {10,9,8} -- {14,8,2} {10,9,8} {11,3,1}
  count=count or 20
  local ps=particle_system.create(self)
  add(ps.emitters,stationary:create({force={0.2,0.5},angle={1,360}}))
  add(ps.affectors,gravity:create({force=0.1}))
  add(ps.affectors,size:create({col=cols}))
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
} setmetatable(big_smoke,{__index=particle_system})

small_smoke={
 create=function(self,x,y,cols,count)
  cols=cols or {6,13,5} -- {14,8,2} {10,9,8} {11,3,1}
  count=count or 10
  local ps=particle_system.create(self)
  add(ps.emitters,stationary:create({force={0.2,0.5},angle={1,360}}))
  add(ps.affectors,gravity:create({force=0.1}))
  add(ps.affectors,size:create({cycle={4,2,0},col=cols}))
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
} setmetatable(small_smoke,{__index=particle_system})

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

enemy_collection={
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
    local num=mrnd({6,min(12,5+(enemies.wave/5))})
    local t={}
    if enemies.wave>5 then
     for i=1,enemies.wave/5,1 do add(t,4) end
    end
    if enemies.wave>2 then
     for i=1,enemies.wave/2,1 do add(t,3) end
    end
    while #t<num do
     add(t,mrnd({1,2}))
    end
    for i=1,num do
     self:add(alien:create(-16,-16,i,t[i]))
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
   dprint("wave "..lpad(self.wave+1),50,self.wty)
  end
 end
} setmetatable(enemy_collection,{__index=collection})

bullet_collection={
 create=function(self)
  local o=collection.create(self)
  o.reset(self)
  return o
 end,
 add=function(self,object)
  if object.type.player then
   self.player=self.player+1
  else
   self.alien=self.alien+1
  end
  collection.add(self,object)
 end,
 del=function(self,object)
  if object.type.player then
   self.player=self.player-1
  else
   self.alien=self.alien-1
  end
  collection.del(self,object)
 end,
 reset=function(self)
  collection.reset(self)
  self.player=0
  self.alien=0
 end
} setmetatable(bullet_collection,{__index=collection})

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
  o.health=0
  return o
 end,
 distance=function(self,target)
  local dx=self.x-target.x
  local dy=self.y-target.y
  local d=sqrt(dx^2+dy^2)
  return d>0 and d or 32727
 end,
 collide_object=function(self,object)
  if self.complete or object.complete then return false end
  local x=self.x
  local y=self.y
  local hitbox=self.hitbox
  return (x+hitbox.x<=object.x+object.hitbox.x2) and
   (object.x+object.hitbox.x<x+hitbox.w) and
   (y+hitbox.y<=object.y+object.hitbox.y2) and
   (object.y+object.hitbox.y<y+hitbox.h)
 end,
 damage=function(self,health)
  self.health=self.health-health
  if self.health>0 then
   self:hit()
  else
   self:destroy()
  end
 end,
 hit=function(self)
  -- do nothing
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
  o.anim:add_stage("core",4,true,{16,35},{17,36},{18,37})
  o.anim:init("core",dir.neutral)
  o.sx=x
  o.sy=y
  o:reset()
  o.max.health=o.health
  o.max.bombs=5
  return o
 end,
 reset=function(self)
  self.complete=false
  self.score=0
  self.health=500
  self.bullet=1
  self.bombs=3
  self.x=self.sx
  self.y=self.sy
  self.b=8
  self.trail=player_trail:create(self)
  self.drone=drone:create(self)
  self.drone.complete=true
 end,
 destroy=function(self)
  sfx(3)
  sfx(2)
  explosions:add(pixels:create(self.x+4,self.y+4,{2,3,11},20))
  explosions:add(big_smoke:create(self.x+4,self.y+4,{11,3,1},30))
  cam:shake(5,0.9)
  self.complete=true
  save_score(self.score)
  stage=game_over
  game_over:init()
 end,
 hit=function(self)
  sfx(4)
  explosions:add(pixels:create(self.x+4,self.y+4,{2,3,11},10))
  explosions:add(big_smoke:create(self.x+4,self.y+4,{11,3,1},5))
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
   if self.x>screen.width-self.hitbox.w then
    self.x=screen.width-self.hitbox.w
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
   if self.y>screen.height-self.hitbox.h then
    self.y=screen.height-self.hitbox.h
    self.dy=0
   end
  end
  -- fire
  if self.b>0 then
   self.b=self.b-1
  elseif btn(pad.btn1) then
   sfx(0)
   bullets:add(bullet:create(self.x,self.y,self.bullet))
   self.b=6
  else
   self.b=0
  end
  -- smart bomb
  if btnp(pad.btn2) then
   if self.bombs>0 then
    self.bombs=self.bombs-1
    particles:add(smart_bomb:create(self.x+4,self.y+4))
    cam:shake(5,0.93)
    if enemies.count>0 then
     for _,e in pairs(enemies.items) do
      local d=self:distance(e)
      if d<40 then
       local health=(40-d)*50
       e:damage(health)
      end
     end
    end
    if bullets.count>0 then
     for _,b in pairs(bullets.items) do
      if not b.type.player then
       local d=self:distance(b)
       if d<40 then
        local health=(40-d)*50
        b:damage(health)
       end
      end
     end
    end
   end
  end
  self.trail:update()
  self.drone:update()
 end,
 draw=function(self)
  if self.complete then return end
  animatable.draw(self)
  self.trail:draw()
  self.drone:draw()
 end
} setmetatable(player,{__index=animatable})

-- [[ bullets ]]

bullet_update_linear=function(self)
 self.y=self.y+self.ay
 if self.y<-self.type.h or self.y>screen.y2 then
   self.complete=true
 end
end

bullet_update_angled=function(self)
 if self.phase==0 then
  self.max={dx=1,dy=1}
  local dx=p.x+p.hitbox.w/2-self.x+self.hitbox.w/2
  local dy=p.y+p.hitbox.h/2-self.y+self.hitbox.h/2
  self.angle=atan2(dx,-dy)
  self.dx=self.dx+cos(self.angle)
  self.dx=mid(-self.max.dx,self.dx,self.max.dx)
  self.dy=self.dy-sin(self.angle)
  self.dy=mid(-self.max.dy,self.dy,self.max.dy)
  self.phase=1
 end
 self.x=self.x+round(self.dx)
 self.y=self.y+round(self.dy)
 if self.x<-self.type.w or self.x>screen.x2
  or self.y<-self.type.h or self.y>screen.y2 then
  self.complete=true
 end
end

bullet_update_homing=function(self)
 if self.phase==0 then
  self.max={dx=1,dy=1}
  self.phase=1
 end
 if p.complete or self.t>180 then
  self:destroy()
 else
  local dx=p.x+p.hitbox.w/2-self.x+self.hitbox.w/2
  local dy=p.y+p.hitbox.h/2-self.y+self.hitbox.h/2
  self.angle=atan2(dx,-dy)
  self.dx=self.dx+cos(self.angle)*self.ax
  self.dx=mid(-self.max.dx,self.dx,self.max.dx)
  self.x=self.x+round(self.dx)
  self.dy=self.dy-sin(self.angle)*self.ay
  self.dy=mid(-self.max.dy,self.dy,self.max.dy)
  self.y=self.y+round(self.dy)
 end
end

bullet_types={
 {sprite=1,ax=0,ay=-4,w=2,h=6,player=true,health=200,update=bullet_update_linear},
 {sprite=2,ax=0,ay=-5,w=6,h=6,player=true,health=400,update=bullet_update_linear},
 {sprite=3,ax=0,ay=-6,w=8,h=6,player=true,health=600,update=bullet_update_linear},
 {sprite=4,ax=0,ay=1,w=2,h=6,player=false,health=50,update=bullet_update_linear},
 {sprite=5,ax=1,ay=1,w=4,h=4,player=false,health=75,update=bullet_update_angled},
 {sprite=6,ax=1,ay=1,w=5,h=5,player=false,health=100,update=bullet_update_homing},
 {sprite=7,ax=0.1,ay=0.1,w=3,h=3,player=false,health=50,update=bullet_update_angled},
}

bullet={
 create=function(self,x,y,type)
  local otype=bullet_types[type]
  local o=movable.create(self,x,y,otype.ax,otype.ay)
  o.type=otype
  o:add_hitbox(otype.w,otype.h)
  if o.type.player then
   o.x=o.x-o.hitbox.x+4-flr(o.type.w/2)
  end
  o.t=0
  o.phase=0
  return o
 end,
 destroy=function(self)
  self.complete=true
  local x=self.x+(self.type.w/2)
  local y=self.y+(self.type.h/2)
  explosions:add(pixels:create(x,y,{7,8,9,10},10))
  explosions:add(small_smoke:create(x,y,{6,5,1},8+self.type.w))
 end,
 update=function(self)
  movable.update(self)
  self.type.update(self)
  self.t=self.t+1
  if not self.complete then
   if self.type.player then
    if enemies.count>0 then
     for _,e in pairs(enemies.items) do
      if self:collide_object(e) then
       self:destroy()
       e:damage(self.type.health)
       break
      end
     end
    end
   else
    if self:collide_object(p) then
     self:destroy()
     p:damage(self.type.health)
    end
   end
  end
 end,
 draw=function(self)
  if self.complete then return true end
  spr(self.type.sprite,self.x,self.y)
  return false
 end
} setmetatable(bullet,{__index=movable})

-- [[ aliens ]]

alien_update_looper_core=function(self,a,da,x,y)
 if self.phase==0 then
  self.max={dx=3,dy=3}
  self.ax=0.2
  self.ay=0.2
  self.x=mrnd(x)
  self.y=y
  self.angle=a
  self.loop=1
  self.phase=1
 elseif self.phase==1 then
  if self.t>(self.index-1)*8 then
   self.phase=2
  end
 elseif self.phase==2 then
  self.angle=(self.angle+da)%1
  --if self.angle<0.01 then
  -- self.loop=self.loop+1
  --end
  self.dx=self.dx+(cos(self.angle)*self.ax)
  self.dx=mid(-self.max.dx,self.dx,self.max.dx)
  self.x=self.x+round(self.dx)
  self.dy=self.dy-(sin(self.angle)*self.ay)
  self.dy=mid(-self.max.dy,self.dy,self.max.dy)
  self.y=self.y+round(self.dy)
  if self.t>180 and rnd()<0.001 then
   --self.phase=3
  end
 elseif self.phase==3 then
  local dx=p.x+p.hitbox.w/2-self.x+self.hitbox.w/2
  local dy=p.y+p.hitbox.h/2-self.y+self.hitbox.h/2
  self.angle=atan2(dx,-dy)
  self.dx=self.dx+cos(self.angle)*self.ax
  self.dx=mid(-self.max.dx,self.dx,self.max.dx)
  self.x=self.x+round(self.dx)
  self.dy=self.dy-sin(self.angle)*self.ay
  self.dy=mid(-self.max.dy,self.dy,self.max.dy)
  self.y=self.y+round(self.dy)
 end
end

alien_update_looper=function(self)
 alien_update_looper_core(self,0,0.01,{16,24},-32)
end

alien_update_looper_anti=function(self)
 alien_update_looper_core(self,0.5,-0.01,{106,114},-32)
end

alien_update_looper_reverse=function(self)
 alien_update_looper_core(self,1,-0.01,{16,24},168)
end

alien_update_looper_high=function(self)
 alien_update_looper_core(self,0,0.01,{16,24},-96)
end

alien_update_linear=function(self)
 if self.phase==0 then
  self.max.dy=1
  self.x=self.index*16-8
  self.y=-8
  self.phase=1
 end
 if self.phase==1 then
  if self.t>(self.index-1)*8 then
   self.phase=2
  end
 elseif self.phase==2 then
  self.dy=self.dy+self.ax
  self.dy=mid(-self.max.dy,self.dy,self.max.dy)
  if self.t%self.type.rate==0 then self.y=self.y+round(self.dy) end
 end
end

alien_type={
 create=function(self,params)
  local o=params or {}
  o.ax=o.ax or 0.2
  o.ay=o.ay or 0.2
  o.sfx=o.sfx or {hit=4,destroy=3}
  o.neutral=o.neutral or {20}
  o.left=o.left or o.neutral
  o.right=o.right or o.neutral
  o.score=o.score or 50
  o.health=o.health or 100
  o.pixels=o.pixels or {7,8,9,10}
  o.smoke=o.smoke or {10,9,8}
  o.update=o.update or alien_update_looper
  o.fire_rate=o.fire_rate or 0.0005
  o.bullet=o.bullet or 5
  o.rate=2
  setmetatable(o,self)
  self.__index=self
  return o
 end
}

alien_types={
 alien_type:create({neutral={19},score=50,health=100,fire_rate=0,bullet=6,pixels={9,10,12},smoke={12,9,4}}),
 alien_type:create({neutral={20},score=100,health=200,bullet=7,pixels={1,2,8,12},smoke={14,8,2}}),
 alien_type:create({neutral={21},score=150,health=400,bullete=5,pixels={8,9,11},smoke={11,9,3}}),
 alien_type:create({neutral={22},score=300,health=1000,bullet=6,pixels={1,4,9,10,13},smoke={6,13,1}}),
}

alien={
 create=function(self,x,y,index,type)
  local otype=alien_types[type]
  local o=animatable.create(self,x,y,otype.ax,otype.ay)
  o.anim:add_stage("core",1,false,otype.neutral,otype.left,otype.right)
  o.anim:init("core",dir.neutral)
  o.max={dx=2,dy=2}
  o.type=otype
  o.health=otype.health
  o.t=0
  o.index=index
  o.phase=0
  return o
 end,
 destroy=function(self)
  sfx(self.type.sfx.destroy)
  explosions:add(pixels:create(self.x+4,self.y+4,self.type.pixels))
  explosions:add(big_smoke:create(self.x+4,self.y+4,self.type.smoke))
  cam:shake(1,0.9)
  self.complete=true
  p.score=p.score+self.type.score
  local r=rnd()
  if r<min(20,enemies.wave)*(0.01/(drops.count+1)) then
   local type=0
   local t={}
   if p.health<p.max.health then
    for i=1,3 do add(t,4) end
   end
   if p.bombs<p.max.bombs then
    for i=1,3 do add(t,1) end
   end
   if p.bullet<3 then
    local b=p.bullet==1 and 2 or 3
    for i=1,2 do add(t,b) end
   end
   if r<0.33 then add(t,5) end
   if r<0.25 and p.drone.complete then
    add(t,6)
   end
   if #t>0 then type=t[mrnd({1,#t})] end
   if type>0 then
    drops:add(drop:create(self.x,self.y,type))
   end
  end
 end,
 hit=function(self)
  sfx(self.type.sfx.hit)
  explosions:add(pixels:create(self.x+4,self.y+4,self.type.pixels,10))
  explosions:add(small_smoke:create(self.x+4,self.y+4,self.type.smoke,5))
  cam:shake(1,0.7)
 end,
 fire=function(self)
  local r=rnd()
  if r<min(20,enemies.wave)*self.type.fire_rate
   and bullets.alien<3 then
   bullets:add(bullet:create(self.x+self.hitbox.w/2,self.y+self.hitbox.h/2,self.type.bullet))
  end
 end,
 update=function(self)
  self.type.update(self)
  self:fire()
  self.t=self.t+1
  if self.y>screen.y2 then
   --self.complete=true
  else
   if self:collide_object(p) then
    self:destroy()
    p:damage(self.health)
   end
  end
 end,
 draw=function(self)
  if self.complete then return true end
  animatable.draw(self)
  return false
 end
} setmetatable(alien,{__index=animatable})

drop={
 cols={11,9,9,8,7,12},
 sprites={
  {48,49,50,51},
  {52,53,54,55},
  {56,57,58,59},
  {60,61,62,63},
  {40,41,42,43},
  {44,45,46,47},
 },
 create=function(self,x,y,type)
  local o=animatable.create(self,x,y,0,0.2)
  local sprites=self.sprites[type]
  o.anim:add_stage("core",8,true,sprites,sprites,sprites)
  o.anim:init("core",dir.neutral)
  o.max={dx=1,dy=1}
  o.type=type
  return o
 end,
 destroy=function(self)
  sfx(5)
  local col=self.cols[self.type]
  explosions:add(big_smoke:create(self.x+4,self.y+4,{7,col,col},10))
  cam:shake(1,0.8)
  self.complete=true
 end,
 update=function(self)
  animatable.update(self)
  local d=16
  if not p.complete then
   local d=self:distance(p)
  end
  if d<16 then
   if p.x>self.x then
    self.x=self.x+1
   elseif p.x<self.x then
    self.x=self.x-1
   end
   if p.y>self.y then
    self.y=self.y+1
   elseif p.y<self.y then
    self.y=self.y-1
   end
  elseif self.anim.current.tick%2==0 then
    self.y=self.y+1
  end
  if self.y>screen.y2 then
   self.complete=true
  else
   if self:collide_object(p) then
    self:destroy()
    if self.type==1 then
     p.bombs=p.bombs+1
    elseif self.type==2 then
     p.bullet=2
    elseif self.type==3 then
     p.bullet=3
    elseif self.type==4 then
     p.health=min(p.max.health,p.health+200)
    elseif self.type==5 then
     cam:shake(5,0.95)
     for _,e in pairs(enemies.items) do e:destroy() end
     for _,b in pairs(bullets.items) do b:destroy() end
     for _,d in pairs(drops.items) do d:destroy() end
     explosions:add(simple:create(function() rectfill(0,0,screen.x2,screen.y2,7) end,5))
    elseif self.type==6 then
     p.drone:reset()
    end
    for _,d in pairs(drops.items) do
     if d.type==self.type then
      if (self.type==1 and p.bombs==p.max.bombs)
       or self.type==2
       or self.type==3
       or (self.type==4 and p.health==p.max.health)
       or self.type==6 then
       d:destroy()
      end
     end
    end
   end
  end
 end,
 draw=function(self)
  if self.complete then return true end
  animatable.draw(self)
  return false
 end
} setmetatable(drop,{__index=animatable})

drone={
 create=function(self,target)
  local o=animatable.create(self,target.x+target.hitbox.w/2,target.y+target.hitbox.h/2,0.25,0.25)
  o.anim:add_stage("core",4,true,{12,13,14,15},{12},{12})
  o.anim:init("core",dir.neutral)
  o:add_hitbox(5,5)
  o.max={dx=3,dy=3}
  o.strength=100
  o:reset()
  return o
 end,
 reset=function(self)
  self.health=2000
  self.complete=false
 end,
 destroy=function(self)
  sfx(3)
  explosions:add(pixels:create(self.x+2,self.y+2,{7,6,5}))
  explosions:add(big_smoke:create(self.x+2,self.y+2,{7,6,5}))
  cam:shake(1,0.9)
  self.complete=true
 end,
 hit=function(self)
  sfx(3)
  explosions:add(pixels:create(self.x+2,self.y+2,{7,6,5},10))
  explosions:add(small_smoke:create(self.x+2,self.y+2,{7,6,5},5))
  cam:shake(1,0.7)
 end,
 update=function(self)
  if self.complete then return end
  if p.x>self.x then
   self.dx=self.dx+self.ax
  else
   self.dx=self.dx-self.ax
  end
  self.dx=mid(-self.max.dx,self.dx,self.max.dx)
  self.x=self.x+round(self.dx)
  if p.y>self.y then
   self.dy=self.dy+self.ay
  else
   self.dy=self.dy-self.ay
  end
  self.dy=mid(-self.max.dy,self.dy,self.max.dy)
  self.y=self.y+round(self.dy)
  local x=false
  for _,e in pairs(enemies.items) do
   local d=self:distance(e)
   if d<10 then
    x=true
    e:damage(self.strength)
    self:damage(20)
    local angle=atan2(e.dx,-e.dy)
    self.dx=cos(angle)*self.max.dx
    self.dy=-sin(angle)*self.max.dy
   end
  end
  for _,b in pairs(bullets.items) do
   if not b.type.player then
    local d=self:distance(b)
    if d<10 then
     x=true
     b:damage(self.strength)
     self:damage(10)
    end
   end
  end
  if x then
   local aura=function()
    local x=self.x+self.hitbox.w/2
    local y=self.y+self.hitbox.h/2
    circfill(x,y,8,11)
    circfill(x,y,7,12)
   end
   explosions:add(simple:create(aura,5))
  end
 end,
 draw=function(self)
  if self.complete then return true end
  animatable.draw(self)
  return false
 end
} setmetatable(drone,{__index=animatable})

-->8
--stages

intro={
 init=function(self)
   self.blank=true
   self.t=0
   self.screen=1
   self.sprite=1
   for i=1,15 do pal(i,0) end
 end,
 update=function(self)
  cam:update()
  particles:update()
  if self.blank and time()>1 then
   pal()
  end
  if btnp(pad.btn1) or btnp(pad.btn2) then
   if self.blank then pal() end
   stage=game
   game:init()
  end
  self.t=self.t+1
  if btnp(pad.left) then
   self.screen=self.screen-1
   self.t=0
  end
  if btnp(pad.right) or self.t>480 then
   self.screen=self.screen+1
   self.t=0
  end
  if self.screen==0 then self.screen=3 end
  if self.screen==4 then self.screen=1 end
 end,
 draw=function(self)
  cls(0)
  particles:draw()
  dprint("press \142 or \151 to start",18,110,12,1)
  if self.screen==1 then
   sspr(0,32,84,8,22,48,84,8)
  elseif self.screen==2 then
   for i=1,10 do
    dprint("hall of fame",40,8,9,8)
    dprint(lpad(i).."                 "..lpad(high_scores[i],5),16,12+i*8,10,4)
   end
  else
   spr(drop.sprites[1][self.sprite],16,16)
   dprint("extra smart bomb",48,18)
   spr(drop.sprites[2][self.sprite],16,26)
   dprint("increase fire power",36,28)
   spr(drop.sprites[4][self.sprite],16,36)
   dprint("restore ship health",36,38)
   spr(drop.sprites[5][self.sprite],16,46)
   dprint("mega bomb",76,48)
   spr(drop.sprites[6][self.sprite],16,56)
   dprint("drone",92,58)
   dprint("\139\145\148\131",16,72,6,13)
   dprint("move ship",76,72)
   dprint("\142",16,80,6,13)
   dprint("fire",96,80)
   dprint("\151",16,88,6,13)
   dprint("smart bomb",72,88)
   if self.t%8==0 then
    self.sprite=self.sprite+1
    if self.sprite==5 then self.sprite=1 end
   end
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
 end
}

game_over={
 t=0,
 init=function(self)
  self.t=0
 end,
 reset=function()
  enemies:reset()
  drops:reset()
  bullets:reset()
  explosions:reset()
  end,
 update=function(self)
  cam:update()
  bullets:update()
  enemies:update()
  explosions:update()
  particles:update()
  drops:update()
  if btn(pad.btn1) and self.t>120 then
   self:reset()
   stage=game
   stage:init()
  elseif btn(pad.btn2) or self.t>1800 then
   self:reset()
   stage=intro
   stage:init()
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
  if self.t>120 then
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
  for i=1,p.max.health/100 do
   spr(p.health>=i*100 and 32 or 33,7*(i-1),3)
  end
  -- bombs
  if p.bombs>0 then
   for i=1,p.bombs do
    spr(34,124-6*(i-1),122)
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
 bullets=bullet_collection:create()
 explosions=collection:create()
 particles=collection:create()
 drops=collection:create()
 enemies=enemy_collection:create()
 -- populate collections
 particles:add(stars:create())
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
000000007700000077007700770000778000000008800000009000000b000000000000000000000000000000000000000d6700000cac00000d6700000d670000
00000000aa000000aa00aa00aa0660aa8800000088e8000009a90000b3b0000000000000000000000000000000000000cd677000ddc77000dd67c000dd677000
0000000099000000990099009909909999000000888800009a7a90000b00000000000000000000000000000000000000acd660005dd660005ddca0005dd66000
00000000980000009800890098094089770000000880000009a900000000000000000000000000000000000000000000c5ddd00055ddd00055ddc00055cdd000
00000000880000008800880088044088cc00000000000000009000000000000000000000000000000000000000000000055d0000055d0000055d00000cac0000
00000000080000008000080080042008cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000560000005600000056000c90009c022010220890b0980001dd10011111110000000000000000000000000000000000000000000d007000080080002200ef0
005dd600005dd66005ddd6009accca90282c28209abbba900dd44dd01bbbbb1000000000000000000000000000000000000000000dd11c7004999aa0222eeeff
505ddd06005ddd00005ddd000cc9cc0002e2e2000b888b001d4994d11b3b3b100000000000000000000000000000000000000000dd1cc1c7499999aa22dcc6ef
005bbd00053bd66005ddbbd00c999c001c2f2c10bb888bb0d49aa94d1bb3bb10000000000000000000000000000000000000000001c8ec104998899a22ddccef
5053bd06003bdd6005ddbb000cc9cc0002e2e2000b888b00d49aa94d1b3b3b1000000000000000000000000000000000000000000dc8ec7044288899022eeee0
55533ddd0533dd6005dd3bd09accca90282c28209abbba901d4994d11bbbbb1000000000000000000000000000000000000000000dc88c70442888990322eeb0
5055550d05555d6005d555d0c90009c022010220890b09800dd44dd01111111000000000000000000000000000000000000000000ddccc700442299000022000
5080080d05028dd0055820d0000000000000000000000000001dd10000000000000000000000000000000000000000000000000001dddd100044440000000000
080800000d0d00000d80000000056000000560000005600000000000000000000000000000000000000000000000000000000000000000000000000000000000
888e8000ddd6d0005ddd0000005dd600005dd66005ddd60000000000000000000666660000dd600000ddd000006dd0000ccccc0000ddc00000ddd00000cdd000
88888000ddddd00055dd0000505ddd06005ddd00005ddd000000000000000000666666600dd6660000ddd0000666dd00ccccccc00ddccc0000ddd0000cccdd00
088800000ddd000005500000005bbd00053bd66005ddbbd00000000000000000668886600dd6880000ddd0000226dd00cc777cc00ddc670000ddd000066cdd00
0080000000d00000000000005053bd06003bdd6005ddbb000000000000000000668886600dd6880000ddd0000226dd00c70707c00ddc650000ddd000056cdd00
000000000000000000000000555bbddd053bdd6005ddbbd00000000000000000668886600dd6880000ddd0000226dd00cc777cc00ddc670000ddd000066cdd00
00000000000000000000000050d55d0d055ddd6005ddd5d00000000000000000666666600dd6660000ddd0000666dd00ccccccc00ddccc0000ddd0000cccdd00
0000000000000000000000005090090d0509add0055a90d000000000000000000666660000dd600000ddd000006dd0000ccccc0000ddc00000ddd00000cdd000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0bbbbb000033b0000033300000b33000099999000044900000444000009440000999990000449000004440000094400008888800002280000022200000822000
bbbbbbb0033bbb00003330000bbb3300999999900449990000444000099944009999999004499900004440000999440088888880022888000022200008882200
bb777bb0033b670000333000066b33009979799004497600004440000d6944009797979004496700004440000d69440088878880022886000022200006882200
bb777bb0033b670000333000066b33009979799004497600004440000d6944009797979004496700004440000d69440088777880022867000022200006682200
bb777bb0033b670000333000066b33009979799004497600004440000d6944009797979004496700004440000d69440088878880022886000022200006882200
bbbbbbb0033bbb00003330000bbb3300999999900449990000444000099944009999999004499900004440000999440088888880022888000022200008882200
0bbbbb000033b0000033300000b33000099999000044900000444000009440000999990000449000004440000094400008888800002280000022200000822000
67777777777777709aa7007770777777777006777777777777700077777777707770007770777777777000000000000000000000000000000000000000000000
d6670000000d667044490d6670000000dd700d6670000000d6670d6670000000d6670d6670000000667000000000000000000000000000000000000000000000
d6670000000d667000000d667000000000000d6670000000d6670d6670000000d6670d6670000000000000000000000000000000000000000000000000000000
d6670000000d667067770d667000000000000d6670000000d6670d667009aa00d6670d6670000000000000000000000000000000000000000000000000000000
d6660dddddd66600d6670d667000070777770d6670000000d6670d6670044900d6670d6670000707777700000000000000000000000000000000000000000000
d667000000000000d6670d6670000000d6670d6670000000d6670d6670000000d6670d6670000000d66700000000000000000000000000000000000000000000
d667000000000000d6670d6670000000d6670d6670000000d6670d6670000000d6670d6670000000d66700000000000000000000000000000000000000000000
ddd6000000000000ddd600ddddddddddddd60dddd0ddddddddd000ddddddddddddd000dddddddddddddd00000000000000000000000000000000000000000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050000000000000000000000600000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000005067777777777777709aa700777077777777700677777777777770007777777770777000777077777777700000000000000000000000
0000000000000000000000d6670000000d667044490d6670000000dd700d6670000000d6670d6670000000d6670d667000000066700000000000000000000000
0000000000000000000000d6670000000d667000000d667000000000000d6670000000d6670d6670000000d6670d667000000000000060000000000000000000
0000000000000000000000d6670000000d667067770d667000000000000d6670000000d6670d667009aa00d6670d667000000000000000000000000000000000
0000000000000000000000d6660dddddd66600d6670d667000070777770d6670000000d6670d6670044900d6670d667000070777770000000000000000000000
0000000000000000000000d667000000000000d6670d6670000000d6670d6670000000d6670d6670000000d6670d6670000000d6670000000000000000000000
0000000000000000000000d667000000000000d6670d6670000000d6670d6670000000d6670d6670000000d6670d6670000000d6670000000000000000000000
0000000000000000000000ddd6000000000000ddd600ddddddddddddd60dddd0ddddddddd000ddddddddddddd000dddddddddddddd0000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000050000000000000000000000000000000000000000000000000000000000000000000000060
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000500000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000ccc0ccc0ccc00cc00cc000000ccccc0000000cc0ccc000001ccccc000000ccc00cc000000cc0ccc0ccc0ccc0ccc0000000000000000000
000000000000000000c1c0c1c0c110c110c1100000cc111cc00000c1c0c1c00000cc1c1cc000001c10c1c00000c1101c10c1c0c1c01c10000000000000000000
000000000000000000ccc0cc10cc00ccc0ccc00000cc5c0cc60000c0c0cc100000ccc1ccc000000c00c0c00000ccc00c00ccc0cc100c00000000000000000000
000000000000000000c110c1c0c10011c011c00000cc010cc00000c0c0c1c00000cc1c1cc000000c00c0c0000011c00c00c1c0c1c00c00000000000000000000
000000000000000000c000c0c0ccc0cc10cc1000001ccccc100000cc10c0c000001ccccc1000000c00cc100000cc100c00c0c0c0c00c00000000000000000000
00000000000000000010001010111011001100000001111100000011001010000001111100000001001100000011000100101010100100000000000000000000
00000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000
00000000000000000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__sfx__
00010000300502e0502c0502a0502905028050260402504025040240402404024040230402104020070200401f0401e0401d0401c0401b0401b0401a04019040140001000013000110000e0000b0000900007000
0001000038770367703477032770307702e7702d7702b7702977028770277702577024770237702277021770207701f7701e7701e7701d7701b7701a750187501674013740117300e7300c720097200771006710
0009000027640206501b6501465008650076500565005650066500565005640056400563004630036200362003610016100660005600046000460003600036000360003600026000430003300033000330003300
00070000366502d660246601b65017650146500e640086300662004610016100161001600016001d6001c6001b6001a6001a60019600186001760017600000000000000000000000000000000000000000000000
0004000038640246401d63015630116200e6200861003610036000360002600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00060000205502355028550235501d550304003040030400304000b50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
