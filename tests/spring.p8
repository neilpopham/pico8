pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- spring
-- by neil popham

local p1={x=30,y=50,v=0}
local p2={x=120,y=50,v=0}

local rest=20
local k=0.3
local b=0.2
local f=0

function _init()
 poke(0x5f2d,1)
end

function _update60()
 mb,mx,my=stat(34),stat(32)-1,stat(33)-1
 local x=p2.x-p1.x
 f=-k*x-b*p2.v
 p2.v+=f
 local v=flr(p2.v)
 p2.x+=v
 if abs(v)<1 then f=0 end
 if mb==1 then
  p2.x=mx
  p2.v=0
 end
 if btnp(1) then k+=0.01 end
 if btnp(0) then k-=0.01 end
 if btnp(2) then b+=0.01 end
 if btnp(3) then b-=0.01 end
end

function _draw()
 cls()
 line(p1.x,p1.y,p2.x,p2.y,12)
 circfill(p1.x,p1.y,2,9)
 circfill(p2.x,p2.y,2,8)
 pset(mx,my,7)
 print('f '..f,0,0,2)
 print('k '..k,0,10,2)
 print('b '..b,0,20,2)
end
