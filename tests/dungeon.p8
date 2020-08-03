pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--
-- by Neil Popham

function mrnd(x,f)
 if f==nil then f=true end
 local r=x[1]+rnd((f and 1 or 0)+x[2]-x[1])
 return f and flr(r) or r
end

function in_array(a,i)
 for k,v in pairs(a) do
  if v==i then return true end
 end
 return false
end

-- #include dungeon_attempt_1.lua
-- #include dungeon_attempt_2.lua
-- include dungeon_attempt_3.lua
#include dungeon_attempt_2.lua

__gfx__
00000000ffffffff777777771111111199999999ccccccccaaaaaaa9000000001000000100000000000000001cc77cc1cccccccc00000000aaaaaaa900000000
00000000ffffffff777777771111111194644642cccccccca9999994000000000000000000000000000000001cc77cc1cccccccc00000000a999999400000000
00000000ffffffff777777771111111142222222cccccccc94444444000000000000000000000000000000001cc77cc1cccccccc00000000a999999400000000
00000000ffffffff777777771111111194444442cccccccc6ddddddd000000000001100000000000000000001cc77cc1cccccccc00000000a999999400000b30
00000000ffffffff777777771111111194444442cccccccc7666666d000000000001100000000000000000001cc77cc1cccccccc00000000a99999940000bbb3
00000000ffffffff777777771111111199999999cccccccc7666666d000000000000000000000000aaaaaaa91cc77cc1cccccccc00000000a999999400003b33
00000000ffffffff777777771111111194644642cccccccc7666666d000000000000000000000000a99999941cc77cc1cccccccc00000000a99999940006d330
00000000ffffffff777777771111111142222222cccccccc6ddddddd3bb77bb31000000100000000944444441cc77cc1cccccccc00000000944444440006d000
