pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- minsky test
-- by Neil Popham

function copy_range(x1,y,x2)
 x1=max(0,x1)
 x2=min(127,x2)
 local a1=max(0,flr(x1/2)+(y*64))
 local a2=min(0x7fff,flr(x2/2)+(y*64))
 memcpy(a1,0x6000+a1,a2-a1+1) -- copy from screen to sprite memory
 if x1%2==1 then
  poke(a1,peek(a1)&240) -- clear left pixel
 end
 if x2%2==0 then
  poke(a2,peek(a2)&15)  -- clear right pixel
 end
end

function minskycircfill(x,y,r)
 x,y=x+0.5,y+0.5
 local j,k,rat=r,0,1/r
 memset(0,0,0x2000) -- clear the sprite memory
 for i=1,r*0.786 do
  k-=rat*j
  j+=rat*k
  local tx={{flr(x+k),ceil(x-k)},{flr(x-j),ceil(x+j)}}
  local ty={{flr(y+j),flr(y-j)},{flr(y+k),flr(y-k)}}
  copy_range(tx[1][1],ty[1][1],tx[1][2])
  copy_range(tx[1][1],ty[1][2],tx[1][2])
  copy_range(tx[2][1],ty[2][1],tx[2][2])
  copy_range(tx[2][1],ty[2][2],tx[2][2])
 end
 copy_range(flr(x-r),flr(y),ceil(x+r))
 memcpy(0x6000,0,0x2000) -- copy sprite memory to screen
end

function minskycircfilld(x,y,r)
 x,y=x+0.5,y+0.5
 local j,k,rat=r,0,1/r
 color(0)
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
 x=64
 y=64
end

function _update60()
 r+=i
 if r>54 then i=-1 r=54 end
 if r<1 then i=1 r=1 end
 if btnp(4) then v=v==1 and 2 or 1 end
 --[[
 if btn(0) then x-=1 end
 if btn(1) then x+=1 end
 if btn(2) then y-=1 end
 if btn(3) then y+=1 end
 ]]
 if btn(0) then r-=1 end
 if btn(1) then r+=1 end
 if btn(2) then r-=1 end
 if btn(3) then r+=1 end
end

function _draw()
 cls(1)
 srand(65)
 for i=1,20 do
  circfill(rnd(127),rnd(127),rnd(40),rnd(11)+4)
 end
 color(6)
 print("rarely do we find men who willingly",0,41)
 print("engage in hard, solid thinking.",0,48)
 print("there is an almost universal quest",0,55)
 print("for easy answers and half-baked",0,62)
 print("solutions.",0,69)
 print("nothing pains some people more",0,76)
 print("than having to think.",0,83)
 if v==1 then
  minskycircfill(x,y,r)
  print("memcpy",0,120,3)
 else
  minskycircfilld(x,y,r)
  print("rectfill",0,120,3)
 end
 print("\153 "..ceil(stat(0)),0,0,7)
 print("\150 "..ceil(stat(1)*100),60,0,7)
 print("\147 "..stat(7),109,0,7)
end
