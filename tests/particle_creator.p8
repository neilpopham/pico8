pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--
-- by neil popham

particle_types={}
particle_types.core=function(self,x,y,ax,ay)
 local t={x=x,y=y,ax=ax,ay=ay}
 return t
end
particle_types.smoke=function(self,x,y,ax,ay)
 local t=particle_types:core(x,y,ax,ay)
 t.x=t.x+flr(rnd(12))-6
 t.y=t.y+flr(rnd(12))-6
 t.max=flr(rnd(10))+6
 t.lifespan=flr(rnd(20))+5
 t.size=flr(rnd(3))+2
 t.step=(t.max-t.size)/t.lifespan
 t.angle=360/(flr(rnd(359))+1)
 t.draw=function(self)
  if self.lifespan==0 then return end
  circfill(self.x,self.y,self.size,1)
  if self.size>1 then
   circfill(self.x,self.y,self.size-1,5)
  end
  if self.size>2 then
   circfill(self.x,self.y,self.size-2,6)
  end
  if self.size>3 then
   circfill(self.x,self.y,self.size-3,7)
  end
  if self.size<self.max then
   self.size=self.size+self.step
  end
  self.lifespan=self.lifespan-1
 end
 return t
end
particle_types.spark=function(self,x,y,ax,ay)
 local t=particle_types:core(x,y,ax,ay)
 t.x=t.x+flr(rnd(12))-6
 t.y=t.y+flr(rnd(12))-6
 t.lifespan=flr(rnd(20))+5
 t.angle=360/(flr(rnd(359))+1)
 t.col=rnd(14)+1
 t.draw=function(self)
  if self.lifespan==0 then return end
   pset(self.x,self.y,self.col)
   self.lifespan=self.lifespan-1
 end
 return t
end

particle_types.rect=function(self,x,y,ax,ay)
 local t=particle_types:core(x,y,ax,ay)
 t.x=t.x+flr(rnd(12))-6
 t.y=t.y+flr(rnd(12))-6
 t.lifespan=flr(rnd(20))+5
 t.angle=360/(flr(rnd(359))+1)
 t.col=rnd(14)+1
 t.size=rnd(9)+3
 t.draw=function(self)
  if self.lifespan==0 then return end
   rectfill(self.x,self.y,self.x+self.size,self.y+self.size,self.col)
   self.lifespan=self.lifespan-1
 end
 return t
end

particle_emitters={}
particle_emitters.explode=function(self,params)
 local e=params
 e.update=function(self,ps)
  -- some emitters may change the position
 end
 return e
end

particle_affectors={}
particle_affectors.force=function(self,params)
 local a=params
 a.update=function(self,ps)
  for _,p in pairs(ps.particles) do
   p.x=p.x+sin(p.angle)*a.force
   p.y=p.y+cos(p.angle)*a.force
  end
 end
 return a
end
particle_affectors.randomise=function(self,params)
 local a=params
 a.update=function(self,ps)
  for _,p in pairs(ps.particles) do
   p.angle=360/(flr(rnd(359))+1)
  end
 end
 return a
end

function create_particle_system()
 local s={
  particles={},
  emitters={},
  affectors={}
 }
 s.update=function(self)
  for _,e in pairs(self.emitters) do
   e:update(self)
  end
  for _,a in pairs(self.affectors) do
   a:update(self)
  end
 end
 s.draw=function(self)
  for _,p in pairs(self.particles) do
   p:draw()
  end
 end
 return s
end

function create_smoke(x,y,count)
 local s=create_particle_system()
 s.params={x=x,y=y,count=count}
 s.emitters[1]=particle_emitters:explode({})
 s.affectors[1]=particle_affectors:randomise({})
 s.affectors[2]=particle_affectors:force({force=4.75})
 for i=1,count do
  s.particles[i]=particle_types:smoke(x,y,0,0)
  --s.particles[i]=particle_types:spark(x,y,1,1)
  --s.particles[i]=particle_types:rect(x,y,1,1)
 end
 return s
end

--[[
function particle_creator(emitter,index)
 local x={
  emitter=emitter,
  index=index,
  x=x,
  y=y
 }
 x.onend=function(self)

 end
end

function particle_emitter(total)
 local x={
  particles={},
  count=0,
  total=total
 }
 x.onend=function(self,index)
  local p = self.particles[self.count]
  self.particles[self.count]=self.particles[index]
  self.particles[index]=p
  self.count=self.count-1
 end
 for i=1,self.total do
  self.particles[i]=particle_creator()
 end
 return x
end

]]




function _init()
 p=create_smoke(64,64,20)
end

function _update()
 if btnp(4) or btnp(5) then
  p=create_smoke(40+rnd(48),40+rnd(48),rnd(300))
 end
 p:update()
end

function _draw()
 cls()
 p:draw()
end
