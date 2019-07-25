particle={
 create=function(self,params)
  params=params or {}
  params.life=params.life or {60,120}
  local o=params
  o=extend(o,{x=params.x,y=params.y,life=mrnd(params.life),complete=false})
  setmetatable(o,self)
  self.__index=self
  return o
 end,
 draw=function(self,fn)
  if self.life==0 then return true end
  self:_draw()
  self.life=self.life-1
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
  dy=dy+self.g
  self.angle=atan2(dx,-dy)
  self.force=sqrt(dx^2+dy^2)
  self.dx=cos(self.angle)*self.force
  self.dy=-sin(self.angle)*self.force
 end,

 bounce=function(self)
  local h,tile=false
  local x,y=self.x+self.dx,self.y
  local cx,cy=p.camera:position()
  if x<cx or x>(cx+screen.width) then
   h=true
  else
   tile=mget(flr(x/8),flr(y/8))
   if fget(tile,0) then h=true end
  end
  if h then
   self.force=self.force*self.b
   self.angle=(0.5-self.angle) % 1
  end
  local v=false
  local x,y=self.x,self.y+self.dy
  if y<0 or y>screen.height then
   v=true
  else
   tile=mget(flr(x/8),flr(y/8))
   if fget(tile,0) then v=true end
  end
  if v then
   self.force=self.force*self.b
   self.angle=(1-self.angle) % 1
  end
  self.dx=cos(self.angle)*self.force
  self.dy=-sin(self.angle)*self.force
 end,

 shells=function(self)
  affector.gravity(self)
  affector.bounce(self)
  affector.update(self)
 end,

 size=function(self)
  self.size=self.size*self.shrink
  if self.size<0.5 then self.complete=true end
 end,

 smoke=function(self)
  self.dx=cos(self.angle)*self.force
  self.dy=-sin(self.angle)*self.force
  affector.size(self)
  affector.update(self)
 end,

 update=function(self)
  self.x=self.x+round(self.dx)
  self.y=self.y+round(self.dy)
 end
}

shells={
 create=function(self,x,y,col,count)
  for i=1,count do
   local s=spark:create(
    {
     x=x,
     y=y,
     col=col,
     life={30,60},
     force=mrnd({1,2},false),
     g=0.2,
     b=0.7,
     angle=mrnd({0.6,0.9},false)
    }
   )
   s.update=affector.shells
   particles:add(s)
  end
 end
}

smoke={
 create=function(self,x,y,col,count)
  for i=1,count do
   local s=circle:create(
    {
     x=x,
     y=y,
     col=col,
     life={10,20},
     force=mrnd({0.2,1},false),
     angle=mrnd({0,1},false),
     size=mrnd({3,6}),
     shrink=0.8
    }
   )
   s.update=affector.smoke
   particles:add(s)
  end
 end
}
