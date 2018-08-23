pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- cells
-- by neil popham

--[[

use a table to store w and h of each sprite than is solid
will then need to use p.x and p.y to check whether it intersects.

hb{3={8,5}}
p.hb={x=8,y=8}

s.x=tx*8 -- x pos of tile
s.y=ty*8 -- y pos of tile
s.box={s.x,s.y,tx+hb.w-1,ty+hb.h-1} -- full pixel box of tile

]]

local screen={w=128,height=128}

function _init()
 x=1
 y=1
end

function _update()

 for nx=0,16,1 do for ny=0,16,1 do 
  tile=mget(nx,ny)
  if tile>9 then mset(nx,ny,tile-10) end
 end end  

 dx=x
 dy=y
 b=true

 if btn(0) then dx=x-1 end
 if btn(1) then dx=x+1 end
 if btn(2) then dy=y-1 end
 if btn(3) then dy=y+1 end

 px={dx,dx+7}
 py={dy,dy+7}

 for _,ax in pairs(px) do
  for _,ay in pairs(py) do
   tx=flr(ax/8)
   ty=flr(ay/8)
   tile=mget(tx,ty)
   if tile<10 then mset(tx,ty,tile+10) end
   if fget(tile,0) then sfx(0) b=false end
   if fget(tile,1) then sfx(1) end
  end
 end

 if b then
  x=dx
  y=dy
 end

end

function _draw()
 cls()
 map(0,0)
 spr(8,x,y) 
 print("maybe we should use hitboxes",0,120)
end

__gfx__
0000000000000003b000000033333333b3bb3bbb00000000000000000000004a99999999000000001100001177000077770000777733337777bb3b7777000077
000000000000003bbb0000000303b3b0bbbbbbbb00000000000200000000049a999999990000000010000001700000377b0000077303b3b77bbbbbb770000007
000000000000003bb0000000000300b03b3bb3b30000000000282000000049aa9999999900000000000000000000003bb0000000000300b03b3bb3b300000000
000000000000003b00000000000000004b53b53500303000028e820009999a009999999900000000000000000000003b00000000000000004b53b53500303000
0000000000000003b0000000000000004354354503383330002820004909a00099999999000000000000000000000003b0000000000000004354354503383330
0000000000000000000000000000000044544544083333830002bb004000a0009999999900000000000000000000000000000000000000004454454408333383
0000000000000003000000000000000044444444333383330033b000440990009999999900000000100000017000000770000007700000077444444773338337
0000000000000000000000000000000044444444033333300003b000044400009999999900000000110000117700007777000077770000777744447777333377
77000077770000770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70020007700004970000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00282000000049aa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
028e820009999a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
002820004909a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002bb004000a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7033b007740990070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7703b077774400770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000001010002000000000000010100020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000600070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000001040404040402000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000030000030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001040404040402000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000300030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0001000018350163501835016350163501935016350163501635016350163501a3501635016350163501635016350163501635016350163501635016350163501635016350173501735017350173501735017350
000100001405015050160501605017050190501a0501b050250501d0501f05020050220502305024050250502605027050280502a0502a0502c0502c0502d0502e050200502e0502f05030050330503405036050
