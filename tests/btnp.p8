pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--
-- by Neil Popham

-- btnp initial delay
poke(0x5f5c,8)
-- btnp repeat delay
poke(0x5f5d,2)

_set_fps(60)

function _init()
 t=0
 cls()
 local id=peek(0x5f5c)
 local rd=peek(0x5f5d)
 if id==0 then id=15 end
 if rd==0 then rd=4 end
 local fps=stat(8)
 print("fps is "..fps)
 -- id*=fps/30
 -- rd*=fps/30
 if fps==60 then
  id*=2
  rd*=2
 end
 print("initial delay of "..id)
 print("repeat delay of "..rd)
 cx=peek(0x5f26) cy=peek(0x5f27)
end

function _update60()
 color(7)
 if btnp(4) then
  cursor(cx,cy)
  print(t)
  cx=peek(0x5f26) cy=peek(0x5f27)
 end
 t+=1
 rectfill(100,0,127,7,0)
 print(btn(),100,0,5)
end

function _draw()


end
