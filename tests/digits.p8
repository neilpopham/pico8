pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--
-- by neil popham

function round(x)
 return flr(x+0.5)
end

function lpad(x,n)
 n=n or 2
 return sub("0000000"..x,-n)
end

--[[
|  | |  |
1  2 3  4

_ 1
_ 2

_ 3
_ 4

_ 5
_ 6

 ]]

 map={
  {
   {1,1,4,2},
   {1,5,4,6},
   {1,1,2,6},
   {3,1,4,6}
  },
  {
   {3,1,4,6,2},
   {2,1,4,2},
  },
  {
   {1,1,4,2},
   {1,3,4,4},
   {1,5,4,6},
   {3,1,4,4},
   {1,3,2,6}
  },
  {
   {1,1,4,2},
   {2,3,4,4},
   {1,5,4,6},
   {3,1,4,6}
  },
  {
   {3,1,4,6},
   {1,1,2,4},
   {1,3,4,4}
  },
  {
   {1,1,4,2},
   {1,3,4,4},
   {1,5,4,6},
   {1,1,2,4},
   {3,3,4,6}
  },
  {
   {1,1,2,6},
   {1,3,4,4},
   {1,5,4,6},
   {3,3,4,6}
  },
  {
   {1,1,4,2},
   {3,1,4,6}
  },
  {
   {1,1,4,2},
   {1,3,4,4},
   {1,5,4,6},
   {1,1,2,6},
   {3,1,4,6}
  },
  {
   {1,1,4,2},
   {1,3,4,4},
   {1,1,2,4},
   {3,1,4,6}
  }
 }

function drawdigit_old(d,x,y,c,w,h)
 d=tonum(d)
 local w2=flr(2*w/5)
 local h2=flr(h/7)
 local h3=h2/2
 w-=1
 h-=1
 local xp={0,w2,w-w2,w}
 local yp={0,h2,h/2-h3,h/2-h3+h2,h-h2,h}
 local mp=map[d+1]
 if mp[1][5] then
  xo=xp[mp[1][5]]
 else
  xo=0
 end
 for p in all(mp) do
  rectfill(x+xp[p[1]]-xo,y+yp[p[2]],x+xp[p[3]]-xo,y+yp[p[4]],c)
 end
 return w-xo+1
end

function drawdigit(d,x,y,c,w,h)
 d=tonum(d)
 local w2=flr(w/2.5)
 local h2=ceil(h/7)
 local h3=flr((h-h2*3)/2)
 w-=1
 h-=1
 local xp={0,w2-1,w-w2+1,w}
 local yp={0,h2-1,h2+h3,h2*2+h3-1,h-h2+1,h}
 local mp=map[d+1]
 if mp[1][5] then
  xo=xp[mp[1][5]]
 else
  xo=0
 end
 for p in all(mp) do
  rectfill(x+xp[p[1]]-xo,y+yp[p[2]],x+xp[p[3]]-xo,y+yp[p[4]],c)
 end
 return w-xo+1
end

function drawnumber(n,x,y,c,w,h)
 w=w or 16
 h=h or 24
 local s=tostr(n)
 for i=1,#s do
  local w=drawdigit(sub(s,i,i),x,y,c,w,h)
  x+=w+1
 end
end

function _init()
 dw=16
 dh=16
end

function _update60()

end

function _draw()
 cls(1)
 --drawdigit(flr(t()%10),5,5,1)
 --drawdigit(flr(t()%10),4,4,3)

 --drawdigit(flr((t()*2)%10),70,70,1)

 --drawnumber(21378,4,41,8,flr((t()*32)%32),flr((t()*32)%32))
 --drawnumber(21378,4,40,7,flr((t()*32)%32),flr((t()*32)%32))

if btnp(0) then dw-=1 end
if btnp(1) then dw+=1 end
if btnp(2) then dh-=1 end
if btnp(3) then dh+=1 end

local n=7819
drawnumber(n,30,41,8,dw,dh)
drawnumber(n,30,40,7,dw,dh)



 --drawnumber(21378,4,40,7)

 --rectfill(0,40,7,47,15)

end
