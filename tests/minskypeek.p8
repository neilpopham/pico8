pico-8 cartridge // http://www.pico-8.com
version 27
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
 a=1
 x=64
 y=64
end

function _update60()
 if a==1 then r+=i end
 if r>54 then i=-1 r=54 end
 if r<1 then i=1 r=1 end
 if btnp(4) then v=v==1 and 2 or 1 end
 if btnp(5) then a=a==1 and 2 or 1 end
 --[[
 if btn(0) then x-=1 end
 if btn(1) then x+=1 end
 if btn(2) then y-=1 end
 if btn(3) then y+=1 end
 ]]
 if a==2 then
  if btn(0) then r-=1 end
  if btn(1) then r+=1 end
  if btn(2) then r-=1 end
  if btn(3) then r+=1 end
 end
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
__label__
70707070000070707770000000000000000000000000000000000000000000000000000077707770000000000000000000000000000000777770000007000777
70707070000070707070000000000000000000000000000000000000000070007000000000700070000000000000000000000000000000077700000007000707
70707070000077707070000000000000000000000000000000000000000007070700000077700770000000000000000000000000000000007000000007770707
70707070000000707070000000000000000000000000000000000000000000700070000070000070000000000000000000000000000000077700000007070707
70707070000000707770000000000000000000000000000000000000000000000000000077707770000000000000000000000000000000777770000007770777
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000111111111111000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000001111111111111111111100000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000001111111111111111111111111100000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000001111111111111111111111111111111100000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000011111111111111111111111111111111110000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000001111111111111111111111111111111111111100000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000111111111111111111111111111111111111111111000000000000000000000000000000000000000000
00000000000000000000000000000000000000000001111111111111111111111111111111111111111111100000000000000000000000000000000000000000
00000000000000000000000000000000000000000011111111111111111111111111111111111111111111110000000000000000000000000000000000000000
00000000000000000000000000000000000000000111111111111111111111111111111111111111111111111000000000000000000000000000000000000000
00000000000000000000000000000000000000001111111111111111111111111111111111111111111111111100000000000000000000000000000000000000
00000000000000000000000000000000000000011111111111111111111111111111111111111111111111111110000000000000000000000000000000000000
00000000000000000000000000000000000000116161666111116661666166116611111166616661661111116161000000000000000000000000000000000000
00000000000000000000000000000000000001116161611111116111161161616161111166616111616111116161600000000000000000000000000000000000
00000000000000000000000000000000000001116161661111116611161161616161111161616611616111116161600000000000000000000000000000000000
00000000000000000000000000000000000111116661611111116111161161616161111161616111616111116661616000000000000000000000000000000000
00000000000000000000000000000000000111116661666111116111666161616661111161616661616111116661616000000000000000000000000000000000
00000000000000000000000000000000001111111111111111111111111111111111111111111111111111111111111100000000000000000000000000000000
00000000000000000000000000000000001111111111111111111111111111111111111111111111111111111111111100000000000000000000000000000000
00000000000000000000000000000000061111116161666166616611111111111661166161116661661111116661616160000000000000000000000000000000
00000000000000000000000000000000016111116161616161616161111111116111616161111611616111111611616110000000000000000000000000000000
00000000000000000000000000000000616111116661666166116161111111116661616161111611616111111611666116000000000000000000000000000000
00000000000000000000000000000000616111116161616161616161161111111161616161111611616111111611616116000000000000000000000000000000
00000000000000000000000000000001616111116161616161616661611111116611661166616661666111111611616166600000000000000000000000000000
00000000000000000000000000000001111111111111111111111111111111111111111111111111111111111111111111100000000000000000000000000000
00000000000000000000000000000001111111111111111111111111111111111111111111111111111111111111111111100000000000000000000000000000
00000000000000000000000000000061111166616611111166616111666116611661666111116161661166616161666166610000000000000000000000000000
00000000000000000000000000000011111161616161111161616111666161616111161111116161616116116161611161610000000000000000000000000000
00000000000000000000000000000061111166616161111166616111616161616661161111116161616116116161661166110000000000000000000000000000
00000000000000000000000000000061111161616161111161616111616161611161161111116161616116116661611161610000000000000000000000000000
00000000000000000000000000000611111161616161111161616661616166116611161111111661616166611611666161616000000000000000000000000000
00000000000000000000000000000111111111111111111111111111111111111111111111111111111111111111111111111000000000000000000000000000
00000000000000000000000000000111111111111111111111111111111111111111111111111111111111111111111111111000000000000000000000000000
00000000000000000000000000000161111166616611166161616661666116611111666166116611111161616661611166611000000000000000000000000000
00000000000000000000000000000161111161616161611161616111616161111111616161616161111161616161611161111000000000000000000000000000
00000000000000000000000000000661111166616161666161616611661166611111666161616161111166616661611166116000000000000000000000000000
00000000000000000000000000000161111161616161116166616111616111611111616161616161111161616161611161111000000000000000000000000000
00000000000000000000000000000661111161616161661166616661616166111111616161616661111161616161666161111000000000000000000000000000
00000000000000000000000000000111111111111111111111111111111111111111111111111111111111111111111111111000000000000000000000000000
00000000000000000000000000000111111111111111111111111111111111111111111111111111111111111111111111111000000000000000000000000000
00000000000000000000000000000611166111111111111111111111111111111111111111111111111111111111111111111000000000000000000000000000
00000000000000000000000000000061611111111111111111111111111111111111111111111111111111111111111111110000000000000000000000000000
00000000000000000000000000000061666111111111111111111111111111111111111111111111111111111111111111110000000000000000000000000000
00000000000000000000000000000061116111111111111111111111111111111111111111111111111111111111111111110000000000000000000000000000
00000000000000000000000000000061661116111111111111111111111111111111111111111111111111111111111111110000000000000000000000000000
00000000000000000000000000000001111111111111111111111111111111111111111111111111111111111111111111100000000000000000000000000000
00000000000000000000000000000001111111111111111111111111111111111111111111111111111111111111111111100000000000000000000000000000
00000000000000000000000000000001666166616661661116611111166116616661666111116661666116616661611166600000000000000000000000000000
00000000000000000000000000000000616161611611616161111111611161616661611111116161611161616161611161000000000000000000000000000000
00000000000000000000000000000000666166611611616166611111666161616161661111116661661161616661611166000000000000000000000000000000
00000000000000000000000000000000011161611611616111611111116161616161611111116111611161616111611160000000000000000000000000000000
00000000000000000000000000000000011161616661616166111111661166116161666111116111666166116111666160000000000000000000000000000000
00000000000000000000000000000000001111111111111111111111111111111111111111111111111111111111111100000000000000000000000000000000
00000000000000000000000000000000001111111111111111111111111111111111111111111111111111111111111100000000000000000000000000000000
00000000000000000000000000000000000166111661111166611661111166616161666166116161111111111111111000000000000000000000000000000000
00000000000000000000000000000000000161616111111116116161111116116161161161616161111111111111111000000000000000000000000000000000
00000000000000000000000000000000000001616111111116116161111116116661161161616611111111111111100000000000000000000000000000000000
00000000000000000000000000000000000001616161111116116161111116116161161161616161111111111111100000000000000000000000000000000000
00000000000000000000000000000000000000616661111116116611111116116161666161616161161111111111000000000000000000000000000000000000
00000000000000000000000000000000000000011111111111111111111111111111111111111111111111111110000000000000000000000000000000000000
00000000000000000000000000000000000000001111111111111111111111111111111111111111111111111100000000000000000000000000000000000000
00000000000000000000000000000000000000000111111111111111111111111111111111111111111111111000000000000000000000000000000000000000
00000000000000000000000000000000000000000011111111111111111111111111111111111111111111110000000000000000000000000000000000000000
00000000000000000000000000000000000000000001111111111111111111111111111111111111111111100000000000000000000000000000000000000000
00000000000000000000000000000000000000000000111111111111111111111111111111111111111111000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000001111111111111111111111111111111111111100000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000011111111111111111111111111111111110000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000001111111111111111111111111111111100000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000001111111111111111111111111100000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000001111111111111111111100000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000111111111111000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33303330333003303330303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33303000333030003030303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
30303300303030003330333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
30303000303030003000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
30303330303003303000333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
