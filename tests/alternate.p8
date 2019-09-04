pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--
-- by Neil Popham

for i=0,15 do
 pal(i,i+128,1)
end
poke(0x5f2e,1)

menuitem(1,"palette",function() p8ap=bxor(p8ap,128) for i=0,15 do pal(i,i+p8ap,1) end end)
