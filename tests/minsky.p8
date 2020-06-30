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
  mn,mx=max(0,flr(y+k)),min(31,ceil(y-k))
  if x+ij<32 then
   if data[x+ij]==nil then data[x+ij]={x1=127,x2=0} end
   if mn<data[x+ij].x1 then data[x+ij].x1=mn end
   if mx>data[x+ij].x2 then data[x+ij].x2=mx end
  end
  if x-ij>1 then
   if data[x-ij]==nil then data[x-ij]={x1=127,x2=0} end
   if mn<data[x-ij].x1 then data[x-ij].x1=mn end
   if mx>data[x-ij].x2 then data[x-ij].x2=mx end
  end
  ik=round(k)
  mn,mx=max(0,flr(y-j)),min(31,ceil(y+j))
  if x+ik>1 then
   if data[x+ik]==nil then data[x+ik]={x1=127,x2=0} end
   if mn<data[x+ik].x1 then data[x+ik].x1=mn end
   if mx>data[x+ik].x2 then data[x+ik].x2=mx end
  end
  if x-ik<32 then
   if data[x-ik]==nil then data[x-ik]={x1=127,x2=0} end
   if mn<data[x-ik].x1 then data[x-ik].x1=mn end
   if mx>data[x-ik].x2 then data[x-ik].x2=mx end
  end
 end
 if data[x]==nil then data[x]={x1=127,x2=0} end
 if y-r<data[x].x1 then data[x].x1=max(0,y-r) end
 if y+r>data[x].x2 then data[x].x2=min(31,y+r) end
 local mx,my={min=31,max=0},{min=31,max=0}
 for y,d in pairs(data) do
  if y<my.min then my.min=y end
  if y>my.max then my.max=y end
  if d.x1<mx.min then mx.min=d.x1 end
  if d.x2>mx.max then mx.max=d.x2 end
 end
 if my.min>2 then
  rectfill(0,8,127,(my.min*4)-1,0)
 end
 if my.max<31 then
  rectfill(0,my.max*4+4,127,127,0)
 end
 for y,d in pairs(data) do
  if d.x1>0 then rectfill(0,y*4,(d.x1*4)-1,y*4+3,0) end
  if d.x2<31 then rectfill(d.x2*4+4,y*4,127,y*4+3,0) end
 end
end

function _init()
 r=0
 i=1
 t=0
 s=0
 x=round(rnd(31))
 y=round(rnd(29)+2)
end

function _update60()
 --if t>1 then r+=i t=0 end
 t+=1
 r+=i
 if r>42 then i=-1 r=42 end
 srand(t)
 if r<0 then i=1 r=0 x=round(rnd(31)) y=round(rnd(29)+2) s+=1 end
end

function _draw()
 cls(1)
 srand(65)
 for i=1,20 do
  circfill(rnd(127),rnd(127),rnd(40),rnd(11)+4)
 end
 if r>=0 then minskycircfilld(x,y,r) else rectfill(0,8,127,127,0) end
 print(r,0,0,7)
 print(stat(0),40,0,7)
 print(stat(1),80,0,7)
 print(flr(stat(7)),120,0,7)
end

-- 1. Paste this at the very bottom of your PICO-8
--    cart
-- 2. Hit return and select the menu item to save
--    a slow render gif (it's all automatic!)
-- 3. Tweet the gif with #PutAFlipInIt
--
-- Notes:
--
-- This relies on the max gif length being long
-- enough. This can be set with the -gif_len
-- command line option, e.g.:
--
--   pico8.exe -gif_len 30
--
-- The gif is where it would be when you hit F9.
-- Splore doesn't play nicely with this, you
-- need to save the splore cart locally and load
-- it.
--
-- You might need to remove unnecessary
-- overrides to save tokens. pset() override
-- flips every 4th pset() call.
--
-- This doesn't always play nicely with optional
-- parameters, e.g. when leaving out the color
-- param.
--
-- Name clashes might happen, didn't bother
-- to namespace etc.


function cflip() if(slowflip)flip()
end
ospr=spr
function spr(...)
ospr(...)
cflip()
end
osspr=sspr
function sspr(...)
osspr(...)
cflip()
end
omap=map
function map(...)
omap(...)
cflip()
end
orect=rect
function rect(...)
orect(...)
cflip()
end
orectfill=rectfill
function rectfill(...)
orectfill(...)
cflip()
end
ocircfill=circfill
function circfill(...)
ocircfill(...)
cflip()
end
ocirc=circ
function circ(...)
ocirc(...)
cflip()
end
oline=line
function line(...)
oline(...)
cflip()
end
opset=pset
psetctr=0
function pset(...)
opset(...)
psetctr+=1
if(slowflip and psetctr%4==0)flip()
end
odraw=_draw
function _draw()
if(slowflip)extcmd("rec")
odraw()
if(slowflip)for i=0,99 do flip() end extcmd("video")cls()stop("gif saved")
end
menuitem(1,"put a flip in it!",function() slowflip=not slowflip end)
