pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- run.jump.die
-- by neil popham

pad={left=0,right=1,up=2,down=3,btn1=4,btn2=5}
screen={width=128,height=128,x2=127,y2=127}
dir={left=1,right=2}
drag={air=0.95,ground=0.65,gravity=0.7}

function mrnd(x,f)
 if f==nil then f=true end
 local v=(rnd()*(x[2]-x[1]+(f and 1 or 0.0001)))+x[1]
 return f and flr(v) or flr(v*1000)/1000
end

function round(x)
 return flr(x+0.5)
end

function extend(...)
 local arg={...}
 local o=del(arg,arg[1])
 for a in all(arg) do
  for k,v in pairs(a) do
   o[k]=v
  end
 end
 return o
end

function clone(o)
 local c={}
 for k,v in pairs(o) do
  c[k]=v
 end
 return c
end

function set_visible(collection)
 local cx=p.camera:position()
 local cx2=cx+screen.width
 for _,o in pairs(collection.items) do
  o.visible=(o.complete==false and o.x>=cx-32 and o.x<=cx2+32)
 end
end

function zget(tx,ty)
 local tile=mget(tx,ty)
 if fget(tx,ty,0) then return true end
 for _,d in pairs(destructables.items) do
  if d.visible then
   local dx,dy=flr(d.x/8),flr(d.y/8)
   if dx==tx and dy==ty then return true end
  end
 end
 return false
end

function oprint(text,x,y,col)
 for dx=-1,1 do
  for dy=-1,1 do
   print(text,x+dx,y+dy,0)
  end
 end
 print(text,x,y,col)
end

function lpad(x,n)
 n=n or 2
 return sub("0000000"..x,-n)
end

particle={
 create=function(self,params)
  params=params or {}
  params.life=params.life or {60,120}
  params.angle=mrnd(params.angle,false)
  params.force=mrnd(params.force,false)
  local o=params
  o=extend(o,{x=params.x,y=params.y,life=mrnd(params.life),complete=false})
  setmetatable(o,self)
  self.__index=self
  return o
 end,
 draw=function(self,fn)
  self:_draw()
  self.life-=1
  if self.life==0 then self.complete=true end
 end
}

spark={
 _draw=function(self)
  pset(self.x,round(self.y),self.col)
 end
} setmetatable(spark,{__index=particle})

circle={
 _draw=function(self)
  circfill(self.x,self.y,self.size,self.col)
 end
} setmetatable(circle,{__index=particle})

affector={

 gravity=function(self)
  local dx=cos(self.angle)*self.force
  local dy=-sin(self.angle)*self.force
  dy+=self.g
  self.angle=atan2(dx,-dy)
  self.force=sqrt(dx^2+dy^2)
  self.dx=cos(self.angle)*self.force
  self.dy=-sin(self.angle)*self.force
 end,

 bounce=function(self)
  local x,y=self.x+self.dx,self.y
  local tile=mget(flr(x/8),flr(y/8))
  if fget(tile,0) then
   self.force=self.force*self.b
   self.angle=(0.5-self.angle)%1
  end
  x,y=self.x,self.y+self.dy
  tile=mget(flr(x/8),flr(y/8))
  if fget(tile,0) then
   self.force=self.force*self.b
   self.angle=(1-self.angle)%1
  end
  self.dx=cos(self.angle)*self.force
  self.dy=-sin(self.angle)*self.force
 end,

 size=function(self)
  self.size=self.size*self.shrink
  if self.size<0.5 then self.complete=true end
 end,

 shells=function(self)
  affector.gravity(self)
  affector.bounce(self)
  affector.update(self)
 end,

 smoke=function(self)
  self.dx=cos(self.angle)*self.force
  self.dy=-sin(self.angle)*self.force
  affector.size(self)
  affector.update(self)
 end,

 update=function(self)
  self.x+=self.dx
  self.y+=self.dy
 end
}

shells={
 create=function(self,x,y,count,params)
  for i=1,count do
   local s=spark:create(
    extend(
     {
      x=x,
      y=y,
      life={30,60},
      force={1,2},
      g=0.2,
      b=0.7,
      angle={0.6,0.9}
     },
     params
    )
   )
   s.update=affector.shells
   particles:add(s)
  end
 end
}

smoke={
 create=function(self,x,y,count,params)
  for i=1,count do
   local s=circle:create(
    extend(
     {
      x=x,
      y=y,
      delay=0,
      col=7,
      life={10,20},
      force={0.2,1},
      angle={0,1},
      size={4,6},
      shrink=0.8
     },
     params
    )
   )
   if params.size then s.size=mrnd(params.size) end
   s.update=affector.smoke
   particles:add(s)
  end
 end
}

function doublesmoke(x,y,count,params)
 smoke:create(x,y,count[1],params[1])
 smoke:create(x+1,y-1,count[2],params[2])
 shells:create(x,y,count[3],params[3])
end

cam={
 create=function(self,item,width,height)
  local o={
   target=item,
   x=item.x,
   y=item.y,
   buffer=12,
   min=40,
   force=0,
   sx=0,
   sy=0
  }
  o.max=width-88
  setmetatable(o,self)
  self.__index=self
  return o
 end,
 update=function(self)
  local min_x = self.x-self.buffer
  local max_x = self.x+self.buffer
  if min_x>self.target.x then
   self.x+=min(self.target.x-min_x,2)
  end
  if max_x<self.target.x then
   self.x+=min(self.target.x-max_x,2)
  end
  if self.x<self.min then
   self.x=self.min
  elseif self.x>self.max then
   self.x=self.max
  end
  if self.force>0 then
   self.sx=1-rnd(2)
   self.sy=1-rnd(2)
   self.sx*=self.force
   self.sy*=self.force
   self.force*=0.9
   if self.force<0.1 then
    self.force,self.sx,self.sy=0,0,0
   end
  end
 end,
 position=function(self)
  return self.x-self.min
 end,
 map=function(self)
  camera(self:position()+self.sx,self.sy)
  map(0,0)
 end,
 shake=function(self,force)
  self.force=min(self.force+force,9)
 end,
}

counter={
 create=function(self,min,max)
  local o={tick=0,min=min,max=max}
  setmetatable(o,self)
  self.__index=self
  return o
 end,
 increment=function(self)
  self.tick+=1
  if self.tick>self.max then
   self:reset()
   if type(self.on_max)=="function" then
    self:on_max()
   end
  end
 end,
 reset=function(self,value)
  value=value or 0
  self.tick=value
 end,
 valid=function(self)
  return self.tick>=self.min and self.tick<=self.max
 end
}

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
   if i.complete then self:del(i) end
  end
 end,
 draw=function(self)
  if self.count==0 then return end
  for _,i in pairs(self.items) do
   i:draw()
  end
 end,
 add=function(self,object)
  add(self.items,object)
  self.count+=1
 end,
 del=function(self,object)
  del(self.items,object)
  self.count-=1
 end,
 reset=function(self)
  self.items={}
  self.count=0
 end
}

object={
 create=function(self,x,y)
  local o=setmetatable(
   {
    x=x,
    y=y,
    hitbox={x=0,y=0,w=8,h=8,x2=7,y2=7},
    complete=false,
    health=0
   },
   self
  )
  self.__index=self
  return o
 end,
 add_hitbox=function(self,w,h,x,y)
  x=x or 0
  y=y or 0
  self.hitbox={x=x,y=y,w=w,h=h,x2=x+w-1,y2=y+h-1}
 end,
 distance=function(self,target)
  local dx=(target.x+4)/1000-(self.x+4)/1000
  local dy=(target.y+4)/1000-(self.y+4)/1000
  return sqrt(dx^2+dy^2)*1000
 end,
 collide_object=function(self,object,x,y)
  if self.complete or object.complete then return false end
  local x=x or self.x
  local y=y or self.y
  local hitbox=self.hitbox
  return (x+hitbox.x<=object.x+object.hitbox.x2) and
   (object.x+object.hitbox.x<x+hitbox.w) and
   (y+hitbox.y<=object.y+object.hitbox.y2) and
   (object.y+object.hitbox.y<y+hitbox.h)
 end,
 damage=function(self,health)
  self.health-=health
  if self.health>0 then
   self:hit(health)
  else
   self:destroy(health)
  end
 end,
 hit=function(self,health)
 end,
 destroy=function(self,health)
  self.complete=true
 end,
 collateral=function(self,range,health)
  if range==0 then return end
  local foo={}
  for _,d in pairs(destructables.items) do
   if d.visible and d~=self then
    add(foo,d)
   end
  end
  for _,e in pairs(enemies.items) do
   if e.visible and e~=self then
    add(foo,e)
   end
  end
  add(foo,p)
  for _,o in pairs(foo) do
   distance=self:distance(o)
   if distance<range then
    o:foobar(range/distance,health,o.x<self.x and -1 or 1)
   end
  end
 end,
 foobar=function(self,strength,health,dir)
  self:damage(health)
  if not self.complete then
   local dx=6*strength
   self.dx+=dx*dir
   self.dy=-dx
   self.max.dy=6
  end
 end,
 draw=function(self,sprite)
  if not self.complete then
   spr(sprite,self.x,self.y)
  end
 end
}

movable={
 create=function(self,x,y,ax,ay,dx,dy)
  local o=object.create(self,x,y)
  o=extend(
   o,
   {
    ax=ax,
    ay=ay,
    dx=0,
    dy=0,
    ox=0,
    sx=x,
    sy=y,
    min={dx=0.05,dy=0.05},
    max={dx=dx,dy=dy}
   }
  )
  return o
 end,
 can_move=function(self,points,flag)
  for _,p in pairs(points) do
   local tx,ty=flr(p[1]/8),flr(p[2]/8)
   local tile=mget(tx,ty)
   if flag and fget(tile,flag) then
    return {ok=false,flag=flag,tile=tile,tx=tx*8,ty=ty*8}
   elseif fget(tile,0) then
    return {ok=false,flag=0,tile=tile,tx=tx*8,ty=ty*8}
   end
  end
  return {ok=true}
 end,
 can_move_x=function(self)
  local x=self.x+round(self.dx)
  if self.dx>0 then x+=self.hitbox.x2 end
  return self:can_move({{x,self.y},{x,self.y+self.hitbox.y2}},1)
 end,
 can_move_y=function(self,flag)
  local y=self.y+round(self.dy)
  if self.dy>0 then y+=self.hitbox.y2 end
  return self:can_move({{self.x,y},{self.x+self.hitbox.x2,y}},flag)
 end,
 collide_destructable=function(self,x,y)
  for _,d in pairs(destructables.items) do
   if d.visible and self~=d and self:collide_object(d,x,y) then
    return {ok=false,ty=d.y,tx=d.x,d=d}
   end
  end
  return {ok=true}
 end
} setmetatable(movable,{__index=object})

animatable={
 create=function(self,...)
  local o=movable.create(self,...)
  o.anim={
   init=function(self,stage,dir)
    for s in pairs(self.stage) do
     for d=1,#self.stage[s].dir do
      self.stage[s].dir[d].fcount=#self.stage[s].dir[d].frames
     end
    end
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
   add_stage=function(self,name,ticks,loop,left,right,next)
    self.stage[name]={
     ticks=ticks,
     loop=loop,
     dir={{frames=left},{frames=right}},
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
   c.tick+=1
   if c.tick==s.ticks then
    c.tick=0
    c.frame+=1
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
 draw=function(self)
  object.draw(self,self.animate(self))
 end
} setmetatable(animatable,{__index=movable})

button={
 create=function(self,index)
  local o=counter.create(self,1,12)
  o.index=index
  o.released=true
  o.disabled=false
  return o
 end,
 check=function(self)
  if btn(self.index) then
   if self.disabled then return end
   if self.tick==0 and not self.released then return end
   self:increment()
   self.released=false
  else
   if not self.released then
    local tick=self.tick==0 and self.max or self.tick
    if type(self.on_release)=="function" then
     self:on_release(tick)
    end
    if tick>12 then
     if type(self.on_long)=="function" then
      self:on_long(tick)
     end
    else
     if type(self.on_short)=="function" then
      self:on_short(self.tick)
     end
    end
   end
   self:reset()
   self.released=true
  end
 end,
 pressed=function(self)
  self:check()
  return self:valid()
 end
} setmetatable(button,{__index=counter})

destructable_types={
 nil,
 {sprite=2,health=10,col=9,size={6,12}},
 {sprite=3,health=10,col=8,size={10,16},range=15,shake=2},
 {sprite=4,health=10,col=11,size={16,24},range=20,shake=3}
}

destructable={
 create=function(self,x,y,type)
  local ttype=destructable_types[type]
  local o=movable.create(self,x,y,0,0,0,3)
  o.type=ttype
  o.health=ttype.health
  o.t=0
  return o
 end,
 destroy=function(self,health)
  self.complete=true
  self.visible=false
  local size={self.type.size[1]*(health/200),self.type.size[2]*(health/200)}
  doublesmoke(
   (flr(self.x/8)*8)+4,
   (flr(self.y/8)*8)+4,
   {10,5,5},
   {
    {col=self.type.col,size=size},
    {col=7,size=size},
    {col=self.type.col,life={20,30}}
   }
  )
  if self.type.range then
   p.camera:shake(self.type.shake)
   self:collateral(self.type.range,abs(self.health))
   sfx(4)
  else
   sfx(2)
  end
 end,
 foobar=function(self,strength,health,dir)
  self.fb={strength,health,dir}
  local t=round(20/strength)
  if self.t>0 then
   self.t=min(self.t,t)
  else
   self.t=t
  end
 end,
 update=function(self)
  if not self.visible then return end
  if self.t>0 then
   self.t-=1
   if self.t==0 then
    object.foobar(self,self.fb[1],self.fb[2],self.fb[3])
   end
  end
  self.dy+=0.25
  self.dy=mid(-self.max.dy,self.dy,self.max.dy)
  move=self:can_move_y()
  if move.ok then
   move=self:collide_destructable()
  end
  if move.ok then
   self.y+=round(self.dy)
  else
   if self.dy>1 then
    particles:add(
     smoke:create(self.x+4,self.y+7,10,{size={4,8}})
    )
    sfx(2)
   end
   self.dy=0
  end
 end,
 draw=function(self)
  if not self.visible then return end
  spr(self.type.sprite,self.x,self.y)
 end
} setmetatable(destructable,{__index=movable})

weapon_types={
 -- pistol
 {
  bullet_type=1,
  rate=20,
  sfx=4,
  sprite=61
 },
 -- semi-auto
 {
  bullet_type=1,
  rate=10,
  sfx=4,
  sprite=61
 },
 --rocket launcher
 {
  bullet_type=3,
  rate=40,
  sfx=4,
  sprite=61
 }
}

enemy_shoot_dumb=function(self)
 local face=self.anim.current.dir
 bullet:create(
  self.x+(face==dir.left and 0 or 8),self.y+5,face,self.type.bullet_type
 )
 shells:create(self.x+(face==dir.left and 2 or 4),self.y+3,1,{col=3})
 sfx(4)
end

enemy_has_shot_dumb=function(self,target)
 return true
end

enemy_has_shot_cautious=function(self,target)
 if p.complete then return false end
 if target.y~=self.y then return false end
 local tx,ty=flr(self.x/8),flr(self.y/8)
 local px=flr(target.x/8)
 local step=target.x>self.x and 1 or -1
 for x=tx,px,step do
  if zget(x,ty) then return false end
 end
 return true
end

enemy_add_stages=function(o,stage,count,loop,left,right,next)
 o.anim:add_stage(stage,count,loop,left,right,next)
end

enemy_stages_goon=function(o)
 enemy_add_stages(o,"still",1,false,{48},{51})
 enemy_add_stages(o,"run",5,true,{48,49,48,50},{51,52,51,53})
 enemy_add_stages(o,"jump",1,false,{50},{53})
 enemy_add_stages(o,"fall",1,false,{49},{52})
 enemy_add_stages(o,"run_turn",3,false,{54},{54},"still")
 enemy_add_stages(o,"jump_turn",3,false,{54},{54},"jump")
 enemy_add_stages(o,"fall_turn",3,false,{54},{54},"fall")
 enemy_add_stages(o,"jump_fall",3,false,{54},{54},"fall")
end

enemy_stages_spider=function(o)
 enemy_add_stages(o,"still",1,false,{55},{56})
 enemy_add_stages(o,"run",5,true,{55,57},{56,58})
end

local goons={
 {itchy=0.5,b=60,dx=1},
 {itchy=0.5,b=60,dx=1,has_shot=enemy_has_shot_cautious},
 {itchy=0.5,b=60,dx=1,jumps=true},
 {itchy=0.5,b=60,dx=1,jumps=true,has_shot=enemy_has_shot_cautious},
 {itchy=0.5,b=60,dx=1,col=9,has_shot=enemy_has_shot_cautious,bullet_type=3},
 {itchy=0.7,b=60,dx=1,col=9,jumps=true,has_shot=enemy_has_shot_cautious,bullet_type=3},
 {itchy=0.5,b=60,dx=2,jumps=true,has_shot=enemy_has_shot_cautious,bullet_type=2},
}

enemy_types={
 {
  health=100,
  col=6,
  size={8,12},
  b=60,
  itchy=0.3,
  bullet_type=2,
  dx=1,
  jumps=false,
  has_shot=enemy_has_shot_dumb,
  shoot=enemy_shoot_dumb,
  add_stages=enemy_stages_goon
 }
}

for _,e in pairs(goons) do
  local o=extend(clone(enemy_types[1]),e)
  add(enemy_types,o)
end

add(
 enemy_types, -- spider
 {
  health=50,
  col=1,
  size={8,12},
  b=60,
  itchy=0,
  dx=2,
  jumps=true,
  add_stages=enemy_stages_spider
 }
)


enemy={
 create=function(self,x,y,type)
  local ttype=enemy_types[type]
  local o=animatable.create(self,x,y,0.15,-2,ttype.dx,3)
  ttype.add_stages(o)
  o.anim:init("run",dir.left)
  o.type=ttype
  o.health=ttype.health
  o.b=0
  o.p=0
  o.button=counter:create(1,13)
  return o
 end,
 hit=function(self)
  smoke:create(self.x+4,self.y+4,10,{col=7,size=self.type.size})
  shells:create(self.x+4,self.y+4,5,{col=8,life={20,40}})
 end,
 destroy=function(self)
  self.complete=true
  self.visible=false
  doublesmoke(
   (flr(self.x/8)*8)+4,
   (flr(self.y/8)*8)+4,
   {20,10,10},
   {
    {col=self.type.col,size=self.type.size},
    {col=7,size=self.type.size},
    {col=8,life={20,40}}
   }
  )
 end,
 update=function(self)
  if not self.visible then return end
  if not p.complete then
   if p.x<self.x then
     self.anim.current.dir=dir.left
     self.dx=self.dx-self.ax
   else
     self.anim.current.dir=dir.right
     self.dx=self.dx+self.ax
   end
  end
  self.dx=mid(-self.max.dx,self.dx,self.max.dx)
  move=self:can_move_x()
  if move.ok then
   move=self:collide_destructable(self.x+round(self.dx),self.y)
  end
  if move.ok then
   self.x+=round(self.dx)
  else
   if self.type.jumps then
    if self.dy==0 then self.button:increment() end
    if self.button:valid() then
     self.dy=self.dy+self.ay
     self.max.dy=3
     self.button:increment()
    end
   else
    self.dx=0
   end
  end
  self.dy=self.dy+drag.gravity
  move=self:can_move_y()
  if move.ok then
   --if self.dy>0 then self.max.dy=3 end
   move=self:collide_destructable(self.x,self.y+round(self.dy))
  end
  self.dy=mid(-self.max.dy,self.dy,self.max.dy)
  if move.ok then
   self.y+=round(self.dy)
  else
   self.y=move.ty+(self.dy>0 and -8 or 8)
   self.dy=0
   self.button:reset()
  end
  self.anim.current:set(round(self.dx)==0 and "still" or "run")
  if self.p>0 then
   self.p=max(0,self.p-1)
  elseif self:collide_object(p) then
   p:foobar(1,20,sgn(self.dx))
   sfx(2)
   self.p=30
  end
  if self.b>0 then
   self.b-=1
  else
   local r=rnd()
   if r<self.type.itchy and self.type.has_shot(self,p) then
    self.type.shoot(self)
   end
   self.b=self.type.b
  end
 end,
 draw=function(self)
  if not self.visible then return end
  pal(15,self.type.col)
  animatable.draw(self)
 end
} setmetatable(enemy,{__index=animatable})

p=animatable:create(8,112,0.15,-2,2,3)
local add_stage=function(...) p.anim:add_stage(...) end
add_stage("still",1,false,{16},{19})
add_stage("run",5,true,{16,17,16,18},{19,20,19,21})
add_stage("jump",1,false,{18},{21})
add_stage("fall",1,false,{17},{20})
add_stage("run_turn",3,false,{22},{22},"still")
add_stage("jump_turn",3,false,{22},{22},"jump")
add_stage("fall_turn",3,false,{22},{22},"fall")
add_stage("jump_fall",3,false,{22},{22},"fall")
p.anim:init("still",dir.right)
p.reset=function(self,full)
 self.anim.current.dir=dir.right
 self.max.prejump=8
 self.max.health=500
 self.is={
  grounded=false,
  jumping=false,
  falling=false
 }
 self.complete=false
 self.visible=true
 self.f=0
 self.x=8
 self.y=112
 self.dx=0
 self.dy=0
 self.camera=cam:create(p,1024,128)
 if full then
  self.weapon=weapon_types[1]
  self.health=self.max.health
 end
 self.shoot=30
 self.grenade=30
 p.btn1.released=false
end
p.btn1=button:create(pad.btn1)
p:reset(true)
p.cayote=counter:create(1,3)
p.add_health=function(self,health)
 self.health=min(self.health+health,self.max.health)
end
p.set_state=function(self,state)
 for s in pairs(self.is) do
  self.is[s]=false
 end
 self.is[state]=true
end
p.can_jump=function(self)
 if self.is.jumping
  and self.btn1:valid() then
  return true
 end
 if self.is.grounded
  and self.btn1.tick<self.max.prejump then
  self.btn1.tick=self.btn1.min
  return true
 end
 if self.is.grounded
  and self.cayote:valid() then
  return true
 end
 return false
end
p.can_move_x=function(self)
 local x=self.x+round(self.dx)
 if x<0 then return {ok=false,tx=-8} end
 return movable.can_move_x(self)
end
p.hit=function(self,health)
 p.camera:shake(2)
 smoke:create(self.x+4,self.y+4,20,{col=12,size={12,20}})
 shells:create(self.x+4,self.y+4,5,{col=8,life={20,30}})
end
p.destroy=function(self,health)
 self.complete=true
 p.camera:shake(3)
 doublesmoke(
  self.x+4,
  self.y+4,
  {20,10,10},
  {{col=12,size={12,30}},{col=7,size={12,30}},{col=8,life={40,80}}}
 )
 stage=stage_over
 stage:init()
end
p.update=function(self)
  if self.complete then return end
  local face=self.anim.current.dir
  local stage=self.anim.current.stage
  local move
  local check=function(self,stage,face)
   if face~=self.anim.current.dir then
    if stage=="still" then stage="run" end
    if stage=="jump_fall" then stage="fall" end
    if not self.anim.current.transitioning then
     self.anim.current:set(stage.."_turn")
     self.anim.current.transitioning=true
    end
   end
  end
  -- horizontal
  if btn(pad.left) then
   self.anim.current.dir=dir.left
   check(self,stage,face)
   self.dx-=self.ax
  elseif btn(pad.right) then
   self.anim.current.dir=dir.right
   check(self,stage,face)
   self.dx+=self.ax
  else
   if self.is.jumping or self.is.falling then
    self.dx*=drag.air
   else
    self.dx*=drag.ground
   end
  end
  self.dx=mid(-self.max.dx,self.dx,self.max.dx)
  move=self:can_move_x()
  if move.ok then
   move=self:collide_destructable(self.x+round(self.dx),self.y)
  end

  -- can move horizontally
  if move.ok then
   self.x+=round(self.dx)
   local adx=abs(self.dx)
   if adx<0.05 then self.dx=0 end
   if adx>0.5 and self.is.grounded then
    smoke:create(self.x+(face==dir.left and 3 or 4),self.y+7,1,{size={1,3}})
   end
   if self.x>1023 and self.visible then
    self:add_health(250)
    --sfx(5)
    stage_main:complete()
    self.visible=false
   end

  -- cannot move horizontally
  else
   self.x=move.tx+(self.dx>0 and -8 or 8)
   self.dx=0
  end

  -- jump
  if self.btn1:pressed() and self:can_jump() then
   self.dy+=self.ay
   self.max.dy=3
  else
   if self.is.jumping then
    self.btn1.disabled=true
   else
    self.btn1.disabled=false
   end
  end
  self.dy+=drag.gravity
  self.dy=mid(-self.max.dy,self.dy,self.max.dy)
  move=self:can_move_y()
  if move.ok then
   move=self:collide_destructable(self.x,self.y+round(self.dy))
  end

  -- can move vertically
  if move.ok then
   -- moving down the screen
   if self.dy>0 then
    if self.is.grounded then
     self.cayote:increment()
     if self.cayote:valid() then
      self.dy=0
     else
      self.anim.current:set("fall")
      self:set_state("falling")
     end
    else
     if not self.anim.current.transitioning then
      self.anim.current:set(self.is.jumping and "jump_fall" or "fall")
     end
     self:set_state("falling")
    end
    self.f+=1
   -- moving up the screen
   else
    if not self.is.jumping then
     self.anim.current:set("jump")
     smoke:create(self.x+(face==dir.left and 3 or 4),self.y+7,20,{col=7,size={4,8}})
    end
    self:set_state("jumping")
   end
   self.y+=round(self.dy)

  -- cannot move vertically
  else
   self.y=move.ty+(self.dy>0 and -8 or 8)
   if self.dy>0 then
    if not self.anim.current.transitioning then
     self.anim.current:set(round(self.dx)==0 and "still" or "run")
    end
    -- falling
    if self.is.falling then
     smoke:create(
      self.x+(face==dir.left and 3 or 4),
      self.y+7,
      2*self.f,
      {col=self.f>10 and 10 or 7,size={self.f/3,self.f}}
     )
     if self.f>10 then
      p.camera:shake(self.f/16)
      self.dy=min(-3,-(round(self.f/6)))
      self.max.dy=6
      sfx(2)
     end
    end
    self:set_state("grounded")
    self.cayote:reset()
   -- hit a roof
   else
    self.btn1:reset()
    self.dy=0
    self.anim.current:set("jump_fall")
    self:set_state("falling")
   end
   self.f=0
  end

  -- fire
  if btn(pad.btn2) and self.shoot==0 then
   bullet:create(
    self.x+(face==dir.left and 0 or 8),
    self.y+5,
    face,
    self.weapon.bullet_type
   )
   shells:create(
    self.x+(face==dir.left and 2 or 4),
    self.y+4,
    1,
    {col=9}
   )
   self.shoot=self.weapon.rate
   sfx(self.weapon.sfx)
  end
  if self.shoot>0 then self.shoot-=1 end

  -- grenade
  if btn(pad.down) and self.grenade==0 then
   bullet:create(
    self.x+(face==dir.left and 0 or 8),
    self.y+8,
    face,
    4
   )
   self.grenade=60
  end
  if self.grenade>0 then self.grenade-=1 end

end

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
   self.enemy=self.enemy+1
  end
  collection.add(self,object)
 end,
 del=function(self,object)
  if object.type.player then
   self.player=self.player-1
  else
   self.enemy=self.enemy-1
  end
  collection.del(self,object)
 end,
 reset=function(self)
  collection.reset(self)
  self.player=0
  self.enemy=0
 end
} setmetatable(bullet_collection,{__index=collection})


bullet_update_linear=function(self,face)
 self.x=self.x+(face==dir.left and -self.ax or self.ax)
 self:check_visibility()
end

bullet_update_arc=function(self,face)
 if self.t==0 then
  self.x+=(face==dir.left and 4 or -4)
  self.y-=self.type.h/2
  self.angle=face==dir.left and 0.7 or 0.8
  self.angle+=flr(p.dx)*0.05
  self.force=6
  self.g=0.5
  self.b=0.7
 end
 local md=6
 affector.gravity(self)
 local move=self:can_move_x()
 if not move.ok then
  self.force=self.force*self.b
  self.angle=(0.5-self.angle)%1
 end
 move=self:can_move_y()
 if not move.ok then
  self.force=self.force*self.b
  self.angle=(1-self.angle)%1
 end
 self.dx=cos(self.angle)*self.force
 self.dy=-sin(self.angle)*self.force
 self.dx=mid(-md,self.dx,md)
 self.dy=mid(-md,self.dy,md)
 self.x+=self.dx
 self.y+=self.dy
 if self.t>60 then
  self:destroy()
 end
 self:check_visibility()
end

bullet_types={
 {
  sprite=32,
  ax=3,
  w=2,
  h=2,
  player=true,
  health=100,
  update=bullet_update_linear
 },
 {
  sprite=33,
  ax=3,
  w=2,
  h=2,
  player=false,
  health=100,
  update=bullet_update_linear
 },
 {
  sprite=34,
  ax=3,
  w=4,
  h=4,
  player=false,
  health=200,
  update=bullet_update_linear,
  range=15,
  shake=3
 },
 {
  sprite=35,
  w=5,
  h=5,
  player=true,
  health=200,
  update=bullet_update_arc,
  range=20,
  shake=3
 }
}

bullet={
 create=function(self,x,y,face,type)
  local ttype=bullet_types[type]
  local o=movable.create(
   self,
   x-(face==dir.left and ttype.w or 0),
   flr(y-ttype.h/2),
   ttype.ax,
   ttype.ay,
   ttype.dx,
   ttype.dy
  )
  o.type=ttype
  o.dir=face
  o.t=0
  o:add_hitbox(ttype.w,ttype.h)
  bullets:add(o)
 end,
 check_visibility=function(self)
  local cx=p.camera:position()
  if self.x<(cx-self.type.w-8) or self.x>(cx+screen.width+8) then
    self.complete=true
  end
 end,
 destroy=function(self)
  self.complete=true
  local angle=self.dir==dir.left and {0.75,1.25} or {0.25,0.75}
  smoke:create(
   self.x+self.type.w/2,
   self.y+self.type.h/2,
   5,
   {col=12,angle=angle,force={2,3},size={1,3}}
  )
  if self.type.range then
   doublesmoke(
    self.x,
    self.y,
    {20,10,10},
    {
     {col=8,size={8,12}},
     {col=7,size={8,12}},
     {col=8,life={20,40}}
    }
   )
   sfx(3) 
   p.camera:shake(self.type.shake)
   self:collateral(self.type.range,self.type.health)
  end
 end,
 update=function(self)
  if self.complete then return end
  self.type.update(self,self.dir)
  if not self.complete then
   if self.type.player then
    for _,e in pairs(enemies.items) do
     if e.visible and self:collide_object(e) then
      self:destroy()
      e:damage(self.type.health)
      break
     end
    end
   elseif self:collide_object(p) then
    self:destroy()
    p:damage(self.type.health)
   end
   if self.complete then return end
   local move=self:collide_destructable()
   if not move.ok then
    self:destroy()
    move.d:damage(self.type.health)
   end
  end
  self.t+=1
 end,
 draw=function(self)
  spr(self.type.sprite,self.x,self.y)
 end
} setmetatable(bullet,{__index=movable})

pickup={
 destroy=function(self)
  self.visible=false
  self.complete=true
  sfx(5)
 end,
 update=function(self)
  if not self.visible then return end
 end,
 draw=function(self)
  if not self.visible then return end
  animatable.draw(self)
 end
} setmetatable(pickup,{__index=animatable})

medikit={
 create=function(self,x,y)
  local o=animatable.create(self,x,y,0,0,0,0)
  o.anim:add_stage("still",4,true,{26,27,28,29,30,31},{})
  o.anim:init("still",dir.left)
  return o
 end,
 update=function(self)
  if not self.visible then return end
 	if self:collide_object(p) then
   p:add_health(250)
   smoke:create(self.x+4,self.y+4,10,{col=8,size={8,16}})
   self:destroy()
  end
 end
} setmetatable(medikit,{__index=pickup})

function fillmap(level)
 local data,levels,floors,pool,m,f={},{15,11,7},120
 -- init
 for x=0,127 do
  data[x]={}
  data[x][15]=1
 end
 -- init
 -- place floors
 for x=0,127 do
  if x>7 and x<120 then
   if x%4==0 then
    if rnd()<0.5 then
     for i=x,x+3 do
      if not data[i] then data[i]={} end
      data[i][levels[2]]=1
     end
     floors+=4
    end
    if data[x-3][levels[2]]==1 then
     if rnd()<0.5 then
      for i=x,x+3 do
       if not data[i] then data[i]={} end
       data[i][levels[3]]=1
      end
      floors+=4
     end
    end
   end
  end
 end
 -- place loors
 -- create destructables pool
 pool={}
 f=floors
 local green_barrels=4+2*level
 for i=1,green_barrels do
  add(pool,4)
 end
 local red_barrels=12+2*level
 for i=1,red_barrels do
  add(pool,3)
 end
 local count=#pool+1
 local total=70+level*2
 if count<total then
  for i=count,total do
   add(pool,2)
  end
 end
 -- create destructables pool
 -- place destructables
 for x=7,124 do
  local pcount=#pool
  local l1=2/3*pcount/f
  local l2=1/3*pcount/f
  for i,l in pairs(levels) do
   if data[x][l]==1 then
    local m=l1
    if data[x-1][l-1] then m*=1.5 end
    if rnd()<m and #pool>0 then
     local d=del(pool,pool[mrnd{1,#pool}])
     data[x][l-1]=d
     if rnd()<l2 and #pool>0 then
      d=del(pool,pool[mrnd{1,#pool}])
      data[x][l-2]=d
     end
    end
    f-=1
   end
  end
 end
 -- place destructables
 -- create enemies pool
 pool={}
 f=floors
 local total=6+level
 local best=min(level+1,8)
 local lower=flr((level+3)/4)
 for i=1,total do
   add(pool,mrnd({lower,best}))
 end
 for i=1,lower do
   if rnd()<0.5 then add(pool,9) end
 end
 local ecount=#pool
 -- create enemies pool
 -- place enemies
 local r=0
 repeat
  for x=124,32,-8 do
   for i,l in pairs(levels) do
    if ecount>0 and data[x] and data[x][l]==1 then
     local m=(ecount/(f/6))+r
     if rnd()<m then
      local p=l
      repeat p-=1 until data[x][p]==nil
      data[x][p]=48
      ecount-=1
      f-=4
     end
    end
   end
  end
  r+=0.3
 until ecount==0
 -- place enemies
 -- place medikits
 for x=120,32,-16 do
  for i,l in pairs(levels) do
   if data[x] and data[x][l]==1 then
    if rnd()<0.2 then
     data[x][l-3]=40
     break
    end
   end
  end
 end
 -- place medikits
 -- place bricks
 for x=0,127 do
  if x>0 then
   for y=2,9 do
    if not data[x][y] or (data[x][y]>=9 and data[x][y]<=13) then
     r=rnd()
     m=0.5/y
     if data[x][y-1] and data[x][y-1]>=9 and data[x][y-1]<=14 then m=0.8/y end
     if data[x-1][y] and data[x-1][y]>=9 and data[x-1][y]<=13 then m=1.4/y end
     if r<m then
      data[x][y]=13
      r=rnd()
      if r<0.2 then data[x][y]=mrnd({9,13}) end
      if not data[x-1][y] then data[x-1][y]=9 end
      if x<127 and not data[x+1] then
       data[x+1]={}
       if not data[x+1][y] then data[x+1][y]=10 end
      end
      if not data[x][y-1] then data[x][y-1]=11 end
      if not data[x][y+1] then data[x][y+1]=12 end
     end
    end
   end
  end
 end
 -- place bricks
 -- create map from data
 for x=0,127 do
  for y=0,15 do
   if not data[x][y] then data[x][y]=0 end
   if data[x][y]>=2 and data[x][y]<=4 then
    destructables:add(destructable:create(x*8,y*8,data[x][y]))
   elseif data[x][y]==48 then
    local type=del(pool,pool[mrnd{1,#pool}])
    enemies:add(enemy:create(x*8,y*8,type))
   elseif data[x][y]==40 then
    pickups:add(medikit:create(x*8,y*8))
   else
    mset(x,y,data[x][y])
   end
  end
 end
 -- create map from data
end

stage_intro={
 init=function(self)
 end,
 update=function(self)
  if btnp(pad.btn1) or btnp(pad.btn2) then
   stage=stage_main
   stage:init()
  end
 end,
 draw=function(self)
  oprint("press \142 or \151 to start",18,60,6)
 end
}

stage_main={
 t=0,
 init=function(self)
  level=0
  self:next(true)
  self.draw=self.draw_intro
  self.t=0
 end,
 next=function(self,full)
  level+=1
  enemies:reset()
  bullets:reset()
  destructables:reset()
  pickups:reset()
  particles:reset()
  p:reset(full)
  fillmap(level)
 end,
 complete=function(self)
  --self:next()
  self.draw=self.draw_outro
 end,
 update=function(self)
  p:update()
  p.camera:update()
  bullets:update()
  set_visible(destructables)
  set_visible(enemies)
  set_visible(pickups)
  enemies:update()
  destructables:update()
  pickups:update()
  particles:update()
 end,
 draw_intro=function(self)
  self:draw_core()
  local f=flr(self.t/2)
  if f<6 then
   for y=8,127,8 do
    for x=0,127,8 do
     circfill(x+3,y+3,6-f,0)
    end
   end
   self:draw_hud()
   self.t+=1
  else
   self.t=0
   self.draw=self.draw_core
  end
 end,
 draw_outro=function(self)
  local f=flr(self.t/2)
  if f<6 then
   self:draw_core()
   for y=8,127,8 do
    for x=0,127,8 do
     circfill(x+3,y+3,f,0)
    end
   end
   self:draw_hud()
   self.t+=1
  elseif f>10 then
   self.t=0
   self.draw=self.draw_intro
   self:next()
  else
   self.t+=1
  end
 end,
 draw_core=function(self)
  p.camera:map()
  enemies:draw()
  pal()
  bullets:draw()
  destructables:draw()
  pickups:draw()
  particles:draw()
  p:draw()
  self:draw_hud()
 end,
 draw_hud=function(self)
  camera(0,0)
  print("level",1,1,6)
  print(lpad(level),24,1,9)
  --spr(62,48,1)
  --spr(63,56,1)
  spr(p.weapon.sprite,60,1)
  -- health
  for i=1,p.max.health/100 do
   spr(p.health>=i*100 and 47 or 46,87+(8*(i-1)),0)
  end
 end
}

stage_over={
 t=0,
 init=function(self)
  self.t=0
 end,
 update=function(self)
  stage_main.update(self)
  if self.t>120 then
   if btn(pad.btn1) then
    stage=stage_main
    stage:init()
   elseif btn(pad.btn2) or self.t>1800 then
    enemies:reset()
    bullets:reset()
    destructables:reset()
    pickups:reset()
    particles:reset()
    p:reset(true)
    stage=stage_intro
    stage:init()
   end
  end
  self.t+=1
 end,
 draw=function(self)
  if self.t<100 then
   stage_main:draw()
  else
   local f=flr((self.t-100)/2)
   if f<6 then
    stage_main:draw()
    for y=8,127,8 do
     for x=0,127,8 do
      circfill(x+3,y+3,f,0)
     end
    end
   else
    stage_main:draw_hud()
    print("game over",46,48,9)
    print("press \142 to restart",28,60,13)
    print("or \151 to return to the menu",12,68,13)
    if f<12 then
     for y=8,127,8 do
      for x=0,127,8 do
       circfill(x+3,y+3,12-f,0)
      end
     end
    end
   end
  end
 end
}


function _init()
 enemies=collection:create()
 particles=collection:create()
 bullets=bullet_collection:create()
 destructables=collection:create()
 pickups=collection:create()
 stage=stage_intro
 draw_stage=stage
 stage:init()
end

function _update60()
 stage:update()
end

function _draw()
 cls()
 draw_stage:draw()
 draw_stage=stage
end

__gfx__
0000000077777776aaaaaaa98e6e8822b6a6bb330000000000000000000000000000000000001111111000000000000011101111111011110000000000000000
000000007666666da999999428e822223b6b3333000000001d6d11111d6d11111d6d111100001111111000000000000011101111111011110000000000000000
000000007666666d944444448e6e8822b6a6bb33000000001d6d11111d6d11111d6d111100001111111000000000000011101111111011110000000000000000
000000007666666da999999482228822b333bb33000000001d6d11111d6d11111d6d111100000000000000000000000000000000000000000000000000000000
000000007666666da99999942e2e28223a3a3b330000000001d1111001d1111001d1111000000000111111101111111000000000111111100000000000000000
000000007666666daaaaaaa482228822b333bb330000000008800000000880000000088000000000111111101111111000000000111111100000000000000000
000000007666666da99999948e6e8822b6a6bb330000000000000000000000000000000000000000111111101111111000000000111111100000000000000000
000000006ddddddd9444444428e822223b6b33330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111000000000000000011111111000000000000000011111111000000000000000000000000000000000000000000000000000000000000000000000000
04444411111111111111111111444440111111111111111114444441000000000000000000000000667777660667777000d67700000dd00000776d0007777660
0141441104444411044444111144141011444440114444401414414100000000000000000000000067788776067788e000d6e800000dd000008e6d000e887760
04444411014144110141441111444440114414101144141014444441000000000000000000000000778888770678888000d68800000dd00000886d0008888760
04124410044444110444441101442140114444401144444014211241000000000000000000000000778888770678888000d68800000dd00000886d0008888760
6333333064124410641244100333366601442146014421466333333000000000000000000000000067788776067788e000d6e800000dd000008e6d000e887760
03344330044333300333442003311330033113300222133013333330000000000000000000000000667777660667777000d67700000dd00000776d0007777660
02202220000022200220000002220220022200000000022002200220000000000000000000000000000000000000000000000000000000000000000000000000
a7000000ba0000000990000002220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aa000000bb00000099a90000228e2000000000000000000000000000000000000888888000288800000280000002200000082000008882000550550002202200
00000000000000009999000028882000000000000000000000000000000000008887788802887880002288000002200000882200088788205ddddd5028888820
00000000000000000990000022822000000000000000000000000000000000008877778802877780002878000002200000878200087778205ddd6d502888e820
00000000000000000000000002220000000000000000000000000000000000008877778802877780002878000002200000878200087778205ddddd5028888820
000000000000000000000000000000000000000000000000000000000000000088877888028878800022880000022000008822000887882005ddd50002888200
0000000000000000000000000000000000000000000000000000000000000000088888800028880000028000000220000008200000888200005d500000282000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005000000020000
0f7fffff0000000000000000f7fffff00000000000000000ff7fffff0000000000000000000000000000000000000000000000000d0000000000d00000000000
0f7fffff0f7fffff0f7ffffff7fffff0f7fffff0f7fffff0ff7fffff000131100113100000013110011310000000000000000000666666660002666666666666
0171ffff0f7fffff0f7ffffff7ff1f10f7fffff0f7fffff0f1dff11f001112111121110000111211112111000000000000000000dddddddd4444dddddddddddd
0f7fffff0171ffff0171fffff7fffff0f7ff1f10f7ff1f10ff7fffff071121233212117007112123321211700000000000000000111600004444206044444000
0f7fffff0f7fffff0f7ffffff7fffff0f7fffff0f7fffff0ff7fffff0c111211112111c00c111211112111c00000000000000000555000004440060000000000
6dddddd06f7fffff6f7fffff0dddd666f7fffff6f7fffff665ddddd0333111311311133333311131131113330000000000000000555000000000000000000000
0dd11dd0011dddd00ddd11500dd11dd00dd11dd005551dd0d5ddddd0633111300311133663131113311131360000000000000000000000000000000000000000
05505550000055500550000005550550055500000000055005500550303030300303030303030303303030300000000000000000000000000000000000000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0600066606060666060000009990990000000000000000000000000000000d000000000000000000000000002202200022022000220220002202200022022000
06000600060606000600000090900900000000000000000000000000000066666666000000000000000000028888820288888202888882028888820288888200
060006600606066006000000909009000000000000000000000000000000dddddddd00000000000000000002888e8202888e8202888e8202888e8202888e8200
06000600066606000600000090900900000000000000000000000000000011160000000000000000000000028888820288888202888882028888820288888200
06660666006006660666000099909990000000000000000000000000000055500000000000000000000000002888200028882000288820002888200028882000
00000000000000000000000000000000000000000000000000000000000055500000000000000000000000000282000002820000028200000282000002820000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020000000200000002000000020000000200000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00111111101111111011111110111111101111111000000000000000000000000011111110111111101111111011111110111111101111111000000000000000
00111111101111111011111110111111101111111000000000000000000000000011111110111111101111111011111110111111101111111000000000000000
00111111101111111011111110111111101111111000000000000000000000000011111110111111101111111011111110111111101111111000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111000001110111111101111111011111110111100000000000000000000111111101111111011111110111111101111111011111110111100000000000000
11111000001110111111101111111011111110111100000000000000000000111111101111111011111110111111101111111011111110111100000000000000
11111000001110111111101111111011111110111100000000000000000000111111101111111011111110111111101111111011111110111100000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00111111101111111011111110111111101111111000000000000000000000000011111110111111101111111000000000111111101111111011111110000000
00111111101111111011111110111111101111111000000000000000000000000011111110111111101111111000000000111111101111111011111110000000
00111111101111111011111110111111101111111000000000000000000000000011111110111111101111111000000000111111101111111011111110000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00111011111110111111101111111011111110111100000000000000000000000011101111111011111110111111101111111011111110111100001111000000
00111011111110111111101111111011111110111100000000000000000000000011101111111011111110111111101111111011111110111100001111000000
00111011111110111111101111111011111110111100000000000000000000000011101111111011111110111111101111111011111110111100001111000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10111111101111111000000000000000001111111000000000000000000000000000000000000000001111111000000000000000000000000000000000111111
10111111101111111000000000000000001111111000000000000000000000000000000000000000001111111000000000000000000000000000000000111111
10111111101111111000000000000000001111111000000000000000000000000000000000000000001111111000000000000000000000000000000000111111
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111011111110111100000000000000001110111100000000000000000000000000000000000011111110111111101111111011111110111111101111111011
11111011111110111100000000000000001110111100000000000000000000000000000000000011111110111111101111111011111110111111101111111011
11111011111110111100000000000000001110111100000000000000000000000000000000000011111110111111101111111011111110111111101111111011
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10000000000000000000000000111111101111111000000000000000000000000000000000000000001111111000000000111111101111111011111110000000
10000000000000000000000000111111101111111000000000000000000000000000000000000000001111111000000000111111101111111011111110000000
10000000000000000000000000111111101111111000000000000000000000000000000000000000001111111000000000111111101111111011111110000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11000011110000111100001111111011111110111100000000000000000000000000000000000000001110111100000000111011111110111111101111111011
11000011110000111100001111111011111110111100000000000000000000000000000000000000001110111100000000111011111110111111101111111011
11000011110000111100001111111011111110111100000000000000000000000000000000000000001110111100000000111011111110111111101111111011
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000111111
00000000000000000000000000111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000111111
00000000000000000000000000111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000111111
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000001110111100000000111011110000000000000000000000008e6e88220000000000000000aaaaaaa900000000000000000000111100000000111011
000000000011101111000000001110111100000000000000000000000028e822220000000000000000a999999400000000000000000000111100000000111011
00000000001110111100000000111011110000000000000000000000008e6e882200000000000000009444444400000000000000000000111100000000111011
0000000000000000000000000000000000000000000000000000000000822288220000000000000000a999999400000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000002e2e28220000000000000000a999999400000000000000000000000011111110000000
0000000000000000000000000000000000000000000000000000000000822288220000000000000000aaaaaaa400000000000000000000000011111110000000
00000000000000000000000000000000000000000000000000000000008e6e88220000000000000000a999999400000000000000000000000011111110000000
000000000000000000000000000000000000000000000000000000000028e8222200000000000000009444444400000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000007777777677777776777777767777777600000000000000000000000011101111000000
00000000000000000000000000000000000000000000000000000000007666666d7666666d7666666d7666666d00000000000000000000000011101111000000
00000000000000000000000000000000000000000000000000000000007666666d7666666d7666666d7666666d00000000000000000000000011101111000000
00000000000000000000000000000000000000000000000000000000007666666d7666666d7666666d7666666d00000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000007666666d7666666d7666666d7666666d00000000000000001111111000000000000000
00000000000000000000000000000000000000000000000000000000007666666d7666666d7666666d7666666d00000000000000001111111000000000000000
00000000000000000000000000000000000000000000000000000000007666666d7666666d7666666d7666666d00000000000000001111111000000000000000
00000000000000000000000000000000000000000000000000000000006ddddddd6ddddddd6ddddddd6ddddddd00000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011111110000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011111110000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011111110000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000111111100000000000000000000000001111111011111110000000
00000000000000000000000000000000000000000000000000000000000000000000000000111111100000000000000000000000001111111011111110000000
00000000000000000000000000000000000000000000000000000000000000000000000000111111100000000000000000000000001111111011111110000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000011111111000000000000000000000000001111111011110000000000000000000000001110111111101111000000
00000000000000000000000000000000000011444440000000000000000000000000001111111011110000000000000000000000001110111111101111000000
00000000000000000000000000000000000011441410000000000000000000000000001111111011110000000000000000000000001110111111101111000000
00000000000000000000000000000000000011444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000001442140000000000000000000000000000000111111100000000000000000000000000000000011111110000000
00000000000000000000000000000000000003333666000000000000000000000000000000111111100000000000000000000000000000000011111110000000
00000000000000000000000000000000000003311330000000000000000000000000000000111111100000000000000000000000000000000011111110000000
00000000000000000000000000000000000002220220000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000aaaaaaa9aaaaaaa9aaaaaaa900000000000000000000000011101111000000000000000000000000aaaaaaa911101111000000
00000000000000000000000000a9999994a9999994a999999400000000000000000000000011101111000000000000000000000000a999999411101111000000
00000000000000000000000000944444449444444494444444000000000000000000000000111011110000000000000000000000009444444411101111000000
00000000000000000000000000a9999994a9999994a999999400000000000000000000000000000000000000000000000000000000a999999400000000000f00
0000000000000000000000f000a9999994a9999994a999999400000000000000000000000000000000000000000000000000000000a999999400000000000000
0f000000000000000000000000aaaaaaa4aaaaaaa4aaaaaaa400000000000000000000000000000000000000000000000000000000aaaaaaa400000000000000
00000000000000000000000000a9999994a9999994a9999994000000000000000000000000000000000000000000000f0000000000a999999400000000000000
0000000f00000000000000000094444444944444449444444400000000000000f000000000000000000000000000000000000000009444444400000000000000
00000000000000000000000000777777767777777677777776777777760000000000000000000000000000000077777776777777767777777677777776777777
00000000000000f000000000007666666d7666666d7666666d7666666d000000000000000000000000000000007666666d7666666d7666666d7666666d766666
000000000000000000000000007666666d7666666d7666666d7666666d000000000000000000000000000000007666666d7666666d7666666d7666666d766666
00000000f000000000000000007666666d7666666d7666666d7666666d000000000000000000000000000000007666666d7666666d7666666d7666666d766666
000000000000000000000000007666666d7666666d7666666d7666666d000000000000000000000000000000007666666d7666666d7666666d7666666d766666
000000000000000000000000f07666666d7666666d7666666d7666666d00000000000000000f000000000000007666666d7666666d7666666d7666666d766666
00000000000000000f000000007666666d7666666d7666666d7666666d000000000000000000000000000000007666666d7666666d7666666d7666666d766666
00000f000000000000000000006ddddddd6ddddddd6ddddddd6ddddddd000000000000000000000000000000006ddddddd6ddddddd6ddddddd6ddddddd6ddddd
f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000f0000000000000000000000000000000000000f00000000000000000000000000000000000f00000000f00f000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f00000000
00000000000000000000000000000000000000000f0000000000000000000000000000000000000000000000f000000000000000000000000000000000000000
00f0000000000000000000000000000000000000000000000000000000000000000000000000000f0000000000f0000000000000000f00000000000000000000
000000000000000000000000000000000000000000000000000000000000f000000000000000f000000000000000000000000000000000000000000000000000
00000000000000000000000f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000f000000000000000000000000000000000000000000000000000000000000000f00000f00000000000000000000000000000000
000f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f00f000000000000f0000f00000000000
0f000000000000000000000000000000000000000000000000000000000000f0000000000000000000f000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000f000000000000000000f000000f00000f000f00000000f00000000000000000000000f0000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f0000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000f0000000000f00000000000000f00000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000b6a6bb3300000000000000000000000000000000000000000000000000000000aaaaaaa9aaaaaaa900000000aaaaaa
00000000000000000000000000000000003b6b333300000f00000000000000000000000000000000000000000000000000a9999994a999999400000000a99999
0000000000000000000000000000000000b6a6bb33000000000f0f0000000000000000000000000000000000000000000f944444449444444400000f00944444
0000000000000000f0f000000000000000b333bb33000000000000000000000000000000f0000000000000000000000000a9999994a999999400000f0fa99999
00000000000000000000000000000000003a3a3b330000000000000000000000000000f000000000000000000000000000a9999994a999999400000000a99999
0000000000000000000000000000000000b333bb3300000000000000000000000000000000000000000000000000000000aaaaaaa4aaaaaaa400000000aaaaaa
0000000000000000000000000000000000b6a6bb330000000000000000000000000f000000000000000000000000000000a9999994a999999400000000a99999
00000000000000000000000000000000003b6b33330000000000000000000000000000000000000000000000f00000000094444444944444440f000000944444
76777777767777777677777776777777767777777677777776777777767777777677777776777777767777777677777776777777767777777677777776777777
6d7666666d7666666d7666666d7666666d7666666d7666666d7666666d7666666d7666666d7666666d7666666d7666666d7666666d7666666d7666666d766666
6d7666666d7666666d7666666d7666666d7666666d7666666d7666666d7666666d7666666d7666666d7666666d7666666d7666666d7666666d7666666d766666
6d7666666d7666666d7666666d7666666d7666666d7666666d7666666d7666666d7666666d7666666d7666666d7666666d7666666d7666666d7666666d766666
6d7666666d7666666d7666666d7666666d7666666d7666666d7666666d7666666d7666666d7666666d7666666d7666666d7666666d7666666d7666666d766666
6d7666666d7666666d7666666d7666666d7666666d7666666d7666666d7666666d7666666d7666666d7666666d7666666d7666666d7666666d7666666d766666
6d7666666d7666666d7666666d7666666d7666666d7666666d7666666d7666666d7666666d7666666d7666666d7666666d7666666d7666666d7666666d766666
dd6ddddddd6ddddddd6ddddddd6ddddddd6ddddddd6ddddddd6ddddddd6ddddddd6ddddddd6ddddddd6ddddddd6ddddddd6ddddddd6ddddddd6ddddddd6ddddd

__gff__
0003010101000000000000000000000000000000000000000000000000000000000000000000000001010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00010000300502e0502c0502a0502905028050260402504025040240402404024040230402104020070200401f0401e0401d0401c0401b0401b0401a04019040140001000013000110000e0000b0000900007000
0001000038770367703477032770307702e7702d7702b7702977028770277702577024770237702277021770207701f7701e7701e7701d7701b7701a750187501674013740117300e7300c720097200771006710
0001000027640206401b6401464008640076300563005630066300562005620056200561004600036000360003600016000660005600046000460003600036000360003600026000430003300033000330003300
00040000366502d660246601b65017650146500e640086300662004610016100161001600016001d6001c6001b6001a6001a60019600186001760017600000000000000000000000000000000000000000000000
0004000038640246401d63015630116200e6200861003610036000360002600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00060000205502355028550235501d550304003040030400304000b50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
