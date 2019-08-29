pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--
-- by Neil Popham

function round(x)
 return flr(x+0.5)
end

function minskycircfilld(y,x,r)
 local data={}
 --[[
 if r==1 then
  if y>0 then data[y-1]={x1=x,x2=x} end
  data[y]={x1=max(0,x-1),x2=min(15,x+1)}
  if y<15 then data[y+1]={x1=x,x2=x} end
 end
 ]]
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

function _init()
 r=0
 i=1
 t=0
end

function _update()
 if t>0 then r+=i t=0 end
 t+=1
 if r>20 then i=-1 r=20 end
 if r<0 then i=1 r=0 end
end

function _draw()
 cls(1)
 for i=1,10 do
  circfill(rnd(127),rnd(127),rnd(60),rnd(10)+4)
 end
 minskycircfilld(2,14,r)
 print(r,0,0,7)
end
