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
   ry=self.ty+y
   if ry>0 and ry<16 then
    ry*=8
    for x=-r,r do
     rx=self.tx+x
     if rx>-1 and rx<16 and x*x+y*y<=r2 then
      rx*=8
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

--[[
function minskycircfill(y,x,r)
 local data={}
 --if r==1 then
  --if y>0 then data[y-1]={x1=x,x2=x} end
  --data[y]={x1=max(0,x-1),x2=min(15,x+1)}
  --if y<15 then data[y+1]={x1=x,x2=x} end
 --end
 local j,k,rat=r,0,1/r
 for i=1,r*0.786 do
  k=k-rat*j
  j=j+rat*k
  ij=round(j)
  mn,mx=max(0,flr(y+k)),min(15,ceil(y-k))
  if x+ij<16 then
   if data[x+ij]==nil then data[x+ij]={x1=127,x2=0} end
   if mn<data[x+ij].x1 then data[x+ij].x1=mn end
   if mx>data[x+ij].x2 then data[x+ij].x2=mx end
  end
  if x-ij>0 then
   if data[x-ij]==nil then data[x-ij]={x1=127,x2=0} end
   if mn<data[x-ij].x1 then data[x-ij].x1=mn end
   if mx>data[x-ij].x2 then data[x-ij].x2=mx end
  end
  ik=round(k)
  mn,mx=max(0,flr(y-j)),min(15,ceil(y+j))
  if x+ik>0 then
   if data[x+ik]==nil then data[x+ik]={x1=127,x2=0} end
   if mn<data[x+ik].x1 then data[x+ik].x1=mn end
   if mx>data[x+ik].x2 then data[x+ik].x2=mx end
  end
  if x-ik<16 then
   if data[x-ik]==nil then data[x-ik]={x1=127,x2=0} end
   if mn<data[x-ik].x1 then data[x-ik].x1=mn end
   if mx>data[x-ik].x2 then data[x-ik].x2=mx end
  end
 end
 if data[x]==nil then data[x]={x1=127,x2=0} end
 if y-r<data[x].x1 then data[x].x1=max(0,y-r) end
 if y+r>data[x].x2 then data[x].x2=min(15,y+r) end
 local mx,my={min=15,max=0},{min=15,max=0}
 for y,d in pairs(data) do
  if y<my.min then my.min=y end
  if y>my.max then my.max=y end
  if d.x1<mx.min then mx.min=d.x1 end
  if d.x2>mx.max then mx.max=d.x2 end
 end
 if my.min>1 then
  rectfill(0,8,127,(my.min*8)-1,0)
 end
 if my.max<15 then
  rectfill(0,my.max*8+8,127,127,0)
 end
 for y,d in pairs(data) do
  if d.x1>0 then rectfill(0,y*8,(d.x1*8)-1,y*8+7,0) end
  if d.x2<15 then rectfill(d.x2*8+8,y*8,127,y*8+7,0) end
 end
end

minsky_in={
 create=function(self,x,y)
  local o=transition.create(self,x,y)
  o.tx,o.ty=flr(x/8),flr(y/8)
  return o
 end,
 radius=function(self)
  return self.t
 end,
 draw=function(self)
  minskycircfill(self.tx,self.ty,self:radius())
  if self.t>20 then self.complete=true end
  self.t+=1
  return self.complete
 end
} setmetatable(squares_in,{__index=transition})

minsky_out={
 create=function(self,x,y)
  return squares_in.create(self,x,y)
 end,
 radius=function(self)
  return 20-self.t
 end
} setmetatable(squares_out,{__index=squares_in})
]]
