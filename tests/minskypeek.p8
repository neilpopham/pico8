pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--
-- by Neil Popham

function get_offset(x,y)
 return flr(x/2)+(y*64)
end

function minskycircfill(x,y,r)
 x,y=x+0.5,y+0.5
 local j,k,rat=r,0,1/r
 memset(0x0,0,0x2000)
 for i=1,r*0.786 do
  k-=rat*j
  j+=rat*k
  local tx={{flr(x+k),ceil(x-k)},{flr(x-j),ceil(x+j)}}
  local ty={{flr(y+j),flr(y-j)},{flr(y+k),flr(y-k)}}
  if ty[1][1]>=0 and ty[1][1]<=127 then
   local a1=get_offset(tx[1][1],ty[1][1])
   local a2=get_offset(tx[1][2],ty[1][1])
   memcpy(0x0+a1,0x6000+a1,a2-a1)
  end
  if ty[1][2]>=0 and ty[1][2]<=127 then
   local a1=get_offset(tx[1][1],ty[1][2])
   local a2=get_offset(tx[1][2],ty[1][2])
   memcpy(0x0+a1,0x6000+a1,a2-a1)
  end
  if ty[2][1]>=0 and ty[2][1]<=127 then
   local a1=get_offset(tx[2][1],ty[2][1])
   local a2=get_offset(tx[2][2],ty[2][1])
   memcpy(0x0+a1,0x6000+a1,a2-a1)
  end
  if ty[2][2]>=0 and ty[2][2]<=127 then
   local a1=get_offset(tx[2][1],ty[2][2])
   local a2=get_offset(tx[2][2],ty[2][2])
   memcpy(0x0+a1,0x6000+a1,a2-a1)
  end
 end
 local a1=get_offset(flr(x-r),flr(y))
 local a2=get_offset(ceil(x+r),flr(y))
 memcpy(0x0+a1,0x6000+a1,a2-a1)
 cls(3)
 memcpy(0x6000,0x0,0x2000)
end

function minskycircfilld(x,y,r,c)
 x,y=x+0.5,y+0.5
 local j,k,rat=r,0,1/r
 poke(0x5f25,c)
 rectfill(x+r,0,127,127)
 rectfill(0,0,x-r,127)
 for i=1,r*0.786 do
  k-=rat*j
  j+=rat*k
  rectfill(x+j,0,x+j,y+k)
  rectfill(x+j,y-k,x+j,127)
  rectfill(x-j,0,x-j,y+k)
  rectfill(x-j,y-k,x-j,127)
  rectfill(x-k,0,x-k,y-j)
  rectfill(x-k,y+j,x-k,127)
  rectfill(x+k,0,x+k,y-j)
  rectfill(x+k,y+j,x+k,127)
 end
 rectfill(x,0,x,y-r)
 rectfill(x,y+r,x,127)
end

function _init()
 r=1
 i=1
 v=1
 f=-1
end

function _update60()
 r+=i
 if r>54 then i=-1 r=54 end
 if r<1 then i=1 r=1 end
 if btnp(4) then v=v==1 and 2 or 1 end
 --if btnp(0) then r-=1 end
 --if btnp(1) then r+=1 end
end

function _draw()
 cls(1)
 color(6)
 print("rarely do we find men who willingly",0,41)
 print("engage in hard, solid thinking.",0,48)
 print("there is an almost universal quest",0,55)
 print("for easy answers and half-baked",0,62)
 print("solutions.",0,69)
 print("nothing pains some people more",0,76)
 print("than having to think.",0,83)
 if v==1 then
  minskycircfill(64,64,r)
  print("memcpy",0,120,3)
 elseif v==2 then
  minskycircfilld(64,64,r,0)
  print("rectfill",0,120,3)
 end
 print("\153 "..ceil(stat(0)),0,0,7)
 print("\150 "..ceil(stat(1)*100),60,0,7)
 print("\147 "..stat(7),109,0,7)
 print(r,100,120,3)
end
