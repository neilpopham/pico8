transition={
 create=function(self,x,y)
  local o=setmetatable(
   {
    x=x,
    y=y,
    t=0,
    complete=false
   },
   self
  )
  self.__index=self
  return o
 end
}

--[[
fade_in={
 create=function(self,x,y)
  return transition.create(self,x,y)
 end,
 draw=function(self)
  local f=flr(self.t/2)
  if f<6 then
   for y=8,127,8 do
    for x=0,127,8 do
     circfill(x+3,y+3,6-f,0)
    end
   end
  else
   self.complete=true
  end
  self.t+=1
  return self.complete
 end
} setmetatable(fade_in,{__index=transition})

fade_out={
 create=function(self,x,y)
  return transition.create(self,x,y)
 end,
 draw=function(self)
  local f=flr(self.t/2)
  if f<6 then
   for y=8,127,8 do
    for x=0,127,8 do
     circfill(x+3,y+3,f,0)
    end
   end
  else
   self.complete=true
  end
  self.t+=1
  return self.complete
 end
} setmetatable(fade_out,{__index=transition})

blinds_in={
 create=function(self,x,y)
  return transition.create(self,x,y)
 end,
 draw=function(self)
  rectfill(0,8,127,128-self.t*8,0)
  if self.t>14 then self.complete=true end
  self.t+=1
  return self.complete
 end
} setmetatable(blinds_in,{__index=transition})

blinds_out={
 create=function(self,x,y)
  return transition.create(self,x,y)
 end,
 draw=function(self)
  rectfill(0,8,127,self.t*8,0)
  if self.t>14 then self.complete=true end
  self.t+=1
  return self.complete
 end
} setmetatable(blinds_out,{__index=transition})

blinds_in={
 create=function(self,x,y)
  return transition.create(self,x,y)
 end,
 draw=function(self)
  for y=1,15 do
   rectfill(-8,y*8,mid(-1,127,(15+y-self.t)*8),(y+1)*8,0)
  end
  if self.t>30 then self.complete=true end
  self.t+=1
  return self.complete
 end
} setmetatable(blinds_in,{__index=transition})
]]

squares_in={
 create=function(self,x,y)
  local o=transition.create(self,x,y)
  o.tx,o.ty=flr(x/8),flr(y/8)
  return o
 end,
 radius=function(self)
  return 20-self.t
 end,
 draw=function(self)
  local r=self:radius()
  local r2=r*r
  for y=-r,r do
   for x=-r,r do
    if x*x+y*y<=r2 then
     local rx,ry=self.tx+x,self.ty+y
     if rx>-1 and rx<16 and ry>0 and ry<16 then
      rx*=8
      ry*=8
      rectfill(rx,ry,rx+7,ry+7,0)
     end
    end
   end
  end
  if self.t>20 then self.complete=true end
  self.t+=1
  return self.complete
 end
} setmetatable(squares_in,{__index=transition})

squares_out={
 create=function(self,x,y)
  return squares_in.create(self,x,y)
 end,
 radius=function(self)
  return self.t
 end
} setmetatable(squares_out,{__index=squares_in})
