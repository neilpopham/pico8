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
#include dungeon_attempt_3.lua
