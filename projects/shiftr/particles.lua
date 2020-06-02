particle={
 create=function(self,params)
  params=params or {}
  params.life=params.life or {60,120}
  local o=params
  o.x=params.x
  o.y=params.y
  o.life=mrnd(params.life)
  o.complete=false
  --o=extend(o,{x=params.x,y=params.y,life=mrnd(params.life),complete=false}) 2 tokens more
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

affector={
 beamer=function(self)
  self.y-=self.dy
  if self.y<0 then
   self.complete=true
  elseif self.dy>1 then
   self.dy*=0.98
  end
 end,
 smoke=function(self)
  self.x=self.x+1-rnd(2)
  self.y-=self.dy
  self.dy=self.dy*.97
  if self.dy<0.2 then self.complete=true end
 end
}

beam={
 create=function(self,x,y,cols,count)
  for i=1,count do
   local s=spark:create(
    {
     x=x+rnd(7),
     y=y,
     col=cols[mrnd({1,#cols})],
     dy=mrnd({1,20},false),
     life={30,60}
    }
   )
   s.update=affector.beamer
   particles:add(s)
  end
 end
}

smoke={
 create=function(self,x,y,cols,count)
  for i=1,count do
   local s=spark:create(
    {
     x=x+6-rnd(4),
     y=y,
     col=cols[mrnd({1,#cols})],
     dy=1,
     life={10,40}
    }
   )
   s.update=affector.smoke
   particles:add(s)
  end
 end
 }
