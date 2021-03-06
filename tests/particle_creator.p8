pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--
-- by neil popham

--[[ standard ]]

local screen={width=128,height=128}

function round(x) return flr(x+0.5) end

--[[ local ]]

-- gets a colour fade array from the sprite sheet
-- using the fade from dank tomb by jakub wasilewski
function get_colour_fade(s1,s2)
 s1=s1 or 111
 s2=s2 or 127
 c1=get_sprite_cols(s1)
 c2=get_sprite_cols(s2)
 for x=1,8 do
  for y=1,8 do
   c1[x][y+8]=c2[x][y]
   printh(c2[x][y])
  end
 end
 return c1
end

function get_sprite_origin(s)
 local x=(s*8) % 128
 local y=flr(s/16)*8
 return {x,y}
end

function get_sprite_cols(s)
 local pos=get_sprite_origin(s)
 local cols={}
 for dx=0,7 do
   cols[dx+1]={}
  for dy=0,7 do
   cols[dx+1][dy+1]=sget(pos[1]+dx,pos[2]+dy)
  end
 end
 return cols
end

function get_sprite_col_spread(s,ignore)
 ignore=ignore or 16
 local data=get_sprite_cols(s)
 local cols={}
 local total=0
 for dx=1,8 do
  for dy=1,8 do
   col=data[dx][dy]
   if col~=ignore then
    col=col+1
    if cols[col]==nil then cols[col]={count=0,percent=0} end
    cols[col].count=cols[col].count+1
    total=total+1
   end
  end
 end
 for i,_ in pairs(cols) do
  cols[i].percent=cols[i].count/total
 end
 return cols
end

function get_colour_array(s,count)
 local cols=get_sprite_col_spread(s)
 local array={}
 for i,col in pairs(cols) do
  local p=count*col.percent
  for c=1,p do
   add(array,i-1)
  end
 end
 return array
end

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
 if type(params.col)=="number" then
  t.col=params.col
 else
  t.col=t.rand(params.col.min,params.col.max)
 end

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
 params.size=params.size or {min=3,max=12}
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
 params.size=params.size or {min=3,max=12}
 t.size=t.rand(params.size.min,params.size.max)
 t.draw=function(self)
  if self.lifespan==0 then return true end
  line(self.x,self.y,self.x+(cos(self.angle)*self.size),self.y-(sin(self.angle)*self.size),self.col)
  self.lifespan=self.lifespan-1
  return (self.lifespan==0)
 end
 return t
end

particle_types.circle=function(self,params)
 params=params or {}
 local t=particle_types:core(params)
 params.size=params.size or {min=8,max=14}
 t.size=t.rand(params.size.min,params.size.max)
 t.draw=function(self)
  if self.lifespan==0 then return true end
  circfill(self.x,self.y,self.size,self.col)
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
  end
 end
 e.update=function(self,ps)
  -- do nothing
 end
 return e
end

-- affectors
particle_affectors={}
particle_affectors.colour_fade=get_colour_fade() -- store for future reuse
particle_affectors.decay=function(self,params)
 local a=params or {}
 a.decay=a.decay or 0.6
 a.update=function(self,ps)
  for _,p in pairs(ps.particles) do
   local dx=cos(p.angle)*p.force
   local dy=-sin(p.angle)*p.force
   if round(dx)==0 and round(dy)==0 then
    p.lifespan=flr(p.lifespan*self.decay)
   end
  end
 end
 return a
end

particle_affectors.force=function(self,params)
 local a=params or {}
 a.update=function(self,ps)
  for _,p in pairs(ps.particles) do
   if self.force then
    p.force=p.rand(self.force.min,self.force.max,false)
   elseif self.dforce then
    p.force=p.force+p.rand(self.dforce.min,self.dforce.max,false)
   end
  end
 end
 return a
end

particle_affectors.randomise=function(self,params)
 local a=params or {}
 a.angle=a.angle or {min=1,max=360}
 a.update=function(self,ps)
  for _,p in pairs(ps.particles) do
   p.angle=(p.angle+(p.rand(self.angle.min,self.angle.max)/360)) % 1
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
 a.force=a.force or 0.25
 a.update=function(self,ps)
  for _,p in pairs(ps.particles) do
   local dx=cos(p.angle)*p.force
   local dy=-sin(p.angle)*p.force
   dy=dy+self.force
   p.angle=atan2(dx,-dy)
   --p.force=sqrt((dx*dx)+(dy*dy))
   p.force=sqrt((dx^2)+(dy^2))
  end
 end
 return a
end

particle_affectors.heat=function(self,params)
 local a=params or {}
 a.cycle=a.cycle or {0.9,0.6,0.4,0.25}
 a.particles={}
 a.col={
  {0,0,1,1,2,1,5,6,2,4,9,3,13,5,4,9},
  {0,0,0,0,1,1,1,1,5,13,1,2,4,1,5,1,2,2}
 }
 a.update=function(self,ps)
  for i,p in pairs(ps.particles) do
   if self.particles[i]==nil then
    self.particles[i]={col=p.col,lifespan=p.lifespan}
   end
   local life=p.lifespan/self.particles[i].lifespan
   if life>self.cycle[1] then
    if i % 3==0 then p.col=10 else p.col=7 end
   elseif life>self.cycle[2] then
    p.col=self.particles[i].col
   elseif life>self.cycle[3] then
    p.col=self.col[1][self.particles[i].col+1]
   elseif life>self.cycle[4] then
    p.col=self.col[2][self.particles[i].col+1]
   else
    p.col=1
   end
  end
 end
 return a
end

particle_affectors.heat2=function(self,params)
 local a=params or {}
 a.cycle=a.cycle or {0.1,0.3,0.5}
 a.white=a.white or 0.96
 a.particles={}
 a.col=particle_affectors.colour_fade
 a.update=function(self,ps)
  for i,p in pairs(ps.particles) do
   if self.particles[i]==nil then
    self.particles[i]={col=p.col,lifespan=p.lifespan}
   end
   local life=p.lifespan/self.particles[i].lifespan
   local c=min(#self.cycle,7)
   if self.white and life>self.white then
    if i % 3==0 then p.col=10 else p.col=7 end
   else
    while c>0 and life>self.cycle[c] do c=c-1 end
    p.col=self.col[c+1][self.particles[i].col+1]
   end
  end
 end
 return a
end

particle_affectors.gravity_old=function(self,params)
 local a=params or {}
 a.force=a.force or 0.015
 a.update=function(self,ps)
  for _,p in pairs(ps.particles) do
   if p.angle>0.75 then
    p.angle=(p.angle+a.force) % 1
   elseif p.angle>0.25 then
    p.angle=p.angle-a.force
   elseif p.angle<0.25 then
    p.angle=p.angle+a.force
   end
  end
 end
 return a
end

particle_affectors.circle=function(self,params)
 local a=params or {}
 a.shrink=a.shrink or 0.96
 a.cycle=a.cycle or {9,5,2}
 a.col=a.col or {6,5,1}
 a.update=function(self,ps)
  local m=min(#a.cycle,#a.col)
  for _,p in pairs(ps.particles) do
   p.size=p.size*self.shrink
   for i=1,m do
    if p.size<a.cycle[i] then p.col=a.col[i] end
   end
  end
 end
 return a
end

function create_particle_system(params)
 local s={
  particles={},
  emitters={},
  affectors={},
  complete=false
 }
 s.params=params or {}
 s.reset=function(self)
  self.complete=false
  self.particles={}
  self.params.count=0
 end
 s.add_particle=function(self,p)
  add(self.particles,p)
  self.params.count=self.params.count+1
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
  --for i=1,self.params.count do
   --local p=self.particles[i]
   p.dx=cos(p.angle)*p.force
   p.dy=-sin(p.angle)*p.force
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
 s.affectors[1]=particle_affectors:randomise({angle={min=-5,max=5}})
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
 s.affectors[1]=particle_affectors:randomise({angle={min=2,max=10}})
 s.affectors[2]=particle_affectors:force({force={min=1,max=3}})
 for i=1,count do
  s.particles[i]=particle_types:rect({x=x,y=y,lifespan={min=2,max=20}})
 end
 s:emit()
 return s
end

function create_spark(x,y,count)
 local s=create_particle_system({x=x,y=y,count=count})
 add(s.emitters,particle_emitters:stationary({x=x,y=y,force={min=2,max=6},angle={min=200,max=340}}))
 add(s.affectors,particle_affectors:gravity_old({force=0.02}))
 add(s.affectors,particle_affectors:bounce({force=0.6}))
 for i=1,count do
  s:add_particle(particle_types:spark({x=x,y=y,col={min=1,max=15},lifespan={min=100,max=240}}))
 end
 s:emit()
 return s
end

function create_spark_2(x,y,count)
 local s=create_particle_system({x=x,y=y,count=count})
 add(s.emitters,particle_emitters:stationary({x=x,y=y,force={min=4,max=10},angle={min=240,max=300}}))
 add(s.affectors,particle_affectors:gravity({force=0.2}))
 add(s.affectors,particle_affectors:bounce({force=0.3}))
 add(s.affectors,particle_affectors:heat())
 add(s.affectors,particle_affectors:decay())

 for i=1,count do
  s:add_particle(particle_types:spark({x=x,y=y,col={min=1,max=15},lifespan={min=160,max=480}}))
 end
 s:emit()
 return s
end

function create_line(x,y,count)
 local s=create_particle_system({x=x,y=y,count=count})
 add(s.emitters,particle_emitters:stationary({x=x,y=y,force={min=2,max=3},angle={min=1,max=360}}))
 --add(s.affectors,particle_affectors:bounce({force=0.9}))
	add(s.affectors,particle_affectors:drag({force=0.97}))
 for i=1,count do
  s:add_particle(particle_types:line({x=x,y=y,col={min=1,max=15},lifespan={min=20,max=100}}))
 end
 s:emit()
 return s
end

function create_sprite_exploder(sprite,x,y,count)
 local s=create_particle_system({x=x,y=y,count=count,sprite=sprite})
 add(s.emitters,particle_emitters:stationary({x=x,y=y,force={min=2,max=6},angle={min=240,max=300}}))
 add(s.affectors,particle_affectors:gravity({force=0.3}))
 add(s.affectors,particle_affectors:bounce({force=0.6}))
 add(s.affectors,particle_affectors:heat2())
 add(s.affectors,particle_affectors:decay())
 local cols=get_colour_array(sprite,count)
 for i=1,count do
  s:add_particle(particle_types:spark({x=x,y=y,col=cols[i],lifespan={min=160,max=480}}))
 end
 s:emit()
 return s
end


function create_circle(x,y,count)
 local s=create_particle_system({x=x,y=y,count=count})
 add(s.emitters,particle_emitters:stationary({x=x,y=y,force={min=0.5,max=2},angle={min=1,max=360}}))
 add(s.affectors,particle_affectors:circle())
 add(s.affectors,particle_affectors:randomise({angle={min=1,max=3}}))
 for i=1,count do
  s:add_particle(particle_types:circle({x=x,y=y,col=7,lifespan={min=20,max=60},size={min=5,max=15}}))
 end
 s:emit()
 return s
end

function _init()
 p=create_spark_2(40+rnd(48),40+rnd(48),flr(rnd(20)+20))
end

function _update60()
 if btnp(4) then
  p=create_smoke(40+rnd(48),40+rnd(48),flr(rnd(20)+10))
  p=create_circle(40+rnd(48),40+rnd(48),flr(rnd(20)+10))
 end
 if btnp(5) then
  p=create_rect(40+rnd(48),40+rnd(48),flr(rnd(200)+200))
 end
 if btnp(0) then
  p=create_sprite_exploder(1,40+rnd(48),40+rnd(48),flr(rnd(150)+150))
 end
 if btnp(1) then
  p=create_line(40+rnd(48),40+rnd(48),flr(rnd(50)+50))
 end
 if btnp(2) then
  p=create_spark_2(40+rnd(48),40+rnd(48),flr(rnd(150)+150))
 end
 if btnp(3) then
  p=create_sprite_exploder(2,40+rnd(48),40+rnd(48),flr(rnd(150)+150))
 end
 p:update()
end

function _draw()
 cls()
 map(0,0)
 p:draw()
end
__gfx__
00000000888888887777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000008bbbbbb879997ee700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000008bbbbbb879997ee700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000008888888879997ee700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000008777777879997ee700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000008aaaaaa879997ee700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000008aaaaaa879997ee700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000888888887777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011100000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000022110000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033311000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042211000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000055111000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066d51000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000776d1000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088221000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000094221000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a9421000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bb331000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccd51000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d5511000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ee821000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d4221000
