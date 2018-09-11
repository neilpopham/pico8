pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--
-- by neil popham

local screen={width=128,height=128}

function round(x) return flr(x+0.5) end

particle_types={}
particle_types.core=function(self,params)
 local t=params
 t.rand=function(min,max,floor)
  if floor==nil then floor=true end
  local v=(rnd()*(max-min))+min
  return floor and flr(v) or v
 end
 params.dx=params.dx or {min=6,max=12}
 params.dy=params.dy or t.dx
 t.x=t.x+t.rand(params.dx.min,params.dx.max)
 t.y=t.y+t.rand(params.dy.min,params.dy.max)
 t.dx=0
 t.dy=0
 params.lifespan=params.lifespan or {min=10,max=30}
 t.lifespan=t.rand(params.lifespan.min,params.lifespan.max)
 params.col=params.col or {min=1,max=15}
 t.col=t.rand(params.col.min,params.col.max)
 --params.angle=params.angle or {min=1,max=360}
 --t.angle=t.rand(params.angle.min,params.angle.max)/360
 return t
end
particle_types.smoke=function(self,params)
 params=params or {}
 local t=particle_types:core(params)
 params.max=params.max or {min=6,max=16}
 t.max=t.rand(params.max.min,params.max.max)
 params.min=params.min or {min=2,max=5}
 t.size=t.rand(params.min.min,params.min.max)
 t.step=(t.max-t.size)/t.lifespan
 t.draw=function(self)
  if self.lifespan==0 then return true end
  circfill(self.x,self.y,self.size,1)
  if self.size>1 then
   circfill(self.x,self.y,self.size-1,5)
   if self.size>2 then
    circfill(self.x,self.y,self.size-2,6)
    if self.size>3 then
     --circfill(self.x,self.y,self.size-3,7)
     --circfill(self.x,self.y,max(ceil(rnd(self.size-3)),self.size-(self.size/2)),7)
     --circfill(self.x+(self.size/6),self.y-(self.size/6),self.size/2,7)
     circfill(self.x+(self.size/12),self.y-(self.size/12),self.size/1.6,7)
    end
   end
  end
  self.size=self.size+self.step
  self.lifespan=self.lifespan-1
  return (self.lifespan==0)
 end
 return t
end
particle_types.spark=function(self,params)
 params=params or {}
 local t=particle_types:core(params)
 t.draw=function(self)
  if self.lifespan==0 then return true end
  pset(self.x,self.y,self.col)
  self.lifespan=self.lifespan-1
  return (self.lifespan==0)
 end
 return t
end

particle_types.rect=function(self,params)
 params=params or {}
 local t=particle_types:core(params)
 params.size = params.size or {min=3,max=12}
 t.size=t.rand(params.size.min,params.size.max)
 t.draw=function(self)
  if self.lifespan==0 then return true end
  rectfill(self.x,self.y,self.x+self.size,self.y+self.size,self.col)
  self.lifespan=self.lifespan-1
  return (self.lifespan==0)
 end
 return t
end

particle_types.line=function(self,params)
 params=params or {}
 local t=particle_types:core(params)
 params.size = params.size or {min=3,max=12}
 t.size=t.rand(params.size.min,params.size.max)
 t.draw=function(self)
  if self.lifespan==0 then return true end
  line(self.x,self.y,self.x+(cos(self.angle)*self.size),self.y-(sin(self.angle)*self.size),self.col)
  self.lifespan=self.lifespan-1
  return (self.lifespan==0)
 end
 return t
end

--emitters
particle_emitters={}
particle_emitters.stationary=function(self,params)
 local e=params or {}
 e.angle=e.angle or {min=1,max=360}
 e.force=e.force or {min=1,max=3}
 e.emit=function(self,ps)
  for _,p in pairs(ps.particles) do
   p.angle=p.rand(self.angle.min,self.angle.max)/360
   p.force=p.rand(self.force.min,self.force.max,false)
   p.dx=cos(p.angle)*p.force
   p.dy=-sin(p.angle)*p.force
  end
 end
 e.update=function(self,ps)
  -- do nothing
 end
 return e
end

-- affectors
particle_affectors={}

particle_affectors.force=function(self,params)
 local a=params or {}
 a.update=function(self,ps)
  for _,p in pairs(ps.particles) do
   p.dx=cos(p.angle)*p.force
   p.dy=-sin(p.angle)*p.force
  end
 end
 return a
end

particle_affectors.randomise=function(self,params)
 local a=params or {}
 a.angle=a.angle or {min=1,max=360}
 a.update=function(self,ps)
  for _,p in pairs(ps.particles) do
   p.angle=(p.angle+(p.rand(a.angle.min,a.angle.max)/360)) % 1
  end
 end
 return a
end

particle_affectors.bounce=function(self,params)
 local a=params or {}
 a.force=a.force or 0.8
 a.update=function(self,ps)
  for _,p in pairs(ps.particles) do
   local h=false
   local x=p.x+p.dx y=p.y
   if x<0 or x>screen.width then
    h=true
   else
    tile=mget(flr(x/8),flr(y/8))
    if fget(tile,0) then h=true end
   end 
   if h then
    p.force=p.force*self.force
    p.angle=(0.5-p.angle) % 1
   end
   local v=false
   local x=p.x y=p.y+p.dy
   if y<0 or y>screen.height then
    v=true
   else
    tile=mget(flr(x/8),flr(y/8))
    if fget(tile,0) then v=true end
   end
   if v then
    p.force=p.force*self.force
    p.angle=(1-p.angle) % 1
   end
   p.dx=cos(p.angle)*p.force
   p.dy=-sin(p.angle)*p.force
   if round(p.dx)==0 and round(p.dy)==0 then
    p.lifespan=0
   end
  end
 end
 return a
end

particle_affectors.drag=function(self,params)
 local a=params or {}
 a.force=a.force or 0.98
 a.update=function(self,ps)
  for _,p in pairs(ps.particles) do
   p.force=p.force*a.force
  end
 end
 return a
end

particle_affectors.gravity=function(self,params)
 local a=params or {}
 a.force=a.force or 0.015
 a.update=function(self,ps)
  for _,p in pairs(ps.particles) do
  --[[
   local ang=(p.angle+0.75) % 1
   if ang>0 and ang<0.5 then
    p.angle=p.angle-(a.force*(ang))
   elseif ang>0.5 or ang<1 then
    p.angle=(p.angle+(a.force*ang)) % 1
   end
   --]]
   ---[[
   if p.angle>0.75 then
    p.angle=(p.angle+a.force) % 1
   elseif p.angle>0.25 then
    p.angle=p.angle-a.force
   elseif p.angle<0.25 then
    p.angle=p.angle+a.force
   end
   --]]
  end
 end
 return a
end

function create_particle_system()
 local s={
  particles={},
  emitters={},
  affectors={},
  complete=false
 }
 s.reset=function(self)
  self.complete=false
  self.particles={}
  self.params.count=0
 end
 s.emit=function(self)
  for _,e in pairs(self.emitters) do
   e:emit(self)
  end
 end
 s.update=function(self)
  if self.complete then return end
  for _,e in pairs(self.emitters) do
   e:update(self)
  end
  for _,a in pairs(self.affectors) do
   a:update(self)
  end
 end
 s.draw=function(self)
  if self.complete then return end
  local done=true
  for i,p in pairs(self.particles) do
   --p.x=p.x+round(p.dx)
   --p.y=p.y+round(p.dy)
   p.x=p.x+p.dx
   p.y=p.y+p.dy
   local dead=self.particles[i]:draw()
   done=done and dead
  end
  --[[
  for i=1,self.params.count do
   local dead=self.particles[i]:draw()
   if dead then
    ----local oldp=self.particles[i]
    --self.particles[i]=self.particles[self.params.count]
    ----self.particles[self.params.count]=oldp
    --self.params.count=self.params.count-1
   end
   done=done and dead
  end
  ]]
  if done then self.complete=true end
 end
 return s
end

function create_smoke(x,y,count)
 local s=create_particle_system()
 s.params={x=x,y=y,count=count}
 s.emitters[1]=particle_emitters:stationary({x=x,y=y,force={min=0.2,max=0.6}})
 --s.affectors[1]=particle_affectors:randomise({angle={min=1,max=10}})
 --s.affectors[2]=particle_affectors:force({force=0.5})
 for i=1,count do
  s.particles[i]=particle_types:smoke({x=x,y=y,lifespan={min=10,max=50},dx={min=-16,max=16},dy={min=-16,max=16}})
  --s.particles[i]=particle_types:spark({x=x,y=y,lifespan={min=10,max=30},col={min=10,max=14}})
  --s.particles[i]=particle_types:rect({x=x,y=y,lifespan={min=10,max=30}})
 end
 s:emit()
 return s
end

function create_rect(x,y,count)
 local s=create_particle_system()
 s.params={x=x,y=y,count=count}
 s.emitters[1]=particle_emitters:stationary({x=x,y=y})
 s.affectors[1]=particle_affectors:randomise({})
 s.affectors[2]=particle_affectors:force({force=3})
 for i=1,count do
  s.particles[i]=particle_types:rect({x=x,y=y,lifespan={min=2,max=20}})
 end
 s:emit()
 return s
end

function create_spark(x,y,count)
 local s=create_particle_system()
 s.params={x=x,y=y,count=count}

 add(s.emitters,particle_emitters:stationary({x=x,y=y,force={min=2,max=6},angle={min=200,max=340}}))
 --add(s.affectors,particle_affectors:randomise())
 add(s.affectors,particle_affectors:gravity({force=0.02}))

 --add(s.affectors,particle_affectors:force({force=1}))
 add(s.affectors,particle_affectors:bounce({force=0.6}))
 
 --add(s.affectors,particle_affectors:randomise())
 --add(s.affectors,particle_affectors:drag({force=0.99}))

 --s.emitters[1]=particle_emitters:stationary({x=x,y=y,force={min=1,max=2},angle={min=180,max=360}})
 --s.affectors[1]=particle_affectors:randomise({angle={min=-5,max=5}})
 --s.affectors[2]=particle_affectors:force({force=1})
 --s.affectors[3]=particle_affectors:bounce({force=0.8})
 --s.affectors[3]=particle_affectors:gravity()
 --s.affectors[3]=particle_affectors:drag()
 for i=1,count do
  s.particles[i]=particle_types:spark(
   {
    x=x,
    y=y,
    col={min=1,max=15},
    lifespan={min=100,max=240}
   }
  )
 end
 s:emit()
 return s
end

function create_line(x,y,count)
 local s=create_particle_system()
 s.params={x=x,y=y,count=count}
 add(s.emitters,particle_emitters:stationary({x=x,y=y,force={min=2,max=3},angle={min=1,max=360}}))
 --add(s.affectors,particle_affectors:gravity())
 --add(s.affectors,particle_affectors:force({force=1}))
 add(s.affectors,particle_affectors:bounce({force=0.9}))
 for i=1,count do
  s.particles[i]=particle_types:line(
   {
    x=x,
    y=y,
    col={min=1,max=15},
    lifespan={min=20,max=100}
   }
  )
 end
 s:emit()
 return s
end

function _init()
 p=create_spark(40+rnd(48),40+rnd(48),flr(rnd(20)+20))
end

function _update60()
 if btnp(4) then
  p=create_smoke(40+rnd(48),40+rnd(48),flr(rnd(20)+10))
 end
 if btnp(5) then
  p=create_rect(40+rnd(48),40+rnd(48),flr(rnd(200)+200))
 end
 if btnp(0) then
  p=create_spark(40+rnd(48),40+rnd(48),flr(rnd(50)+50))
 end
 if btnp(1) then
  p=create_line(40+rnd(48),40+rnd(48),flr(rnd(50)+50))
 end
 p:update()
end

function _draw()
 cls()
 map(0,0)
 p:draw()
end
__gfx__
00000000888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000