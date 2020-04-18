pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--
-- by Neil Popham

function parsetiled()
#include td-levels.lua
end

memset(0x1000,0,0x2000)
tiled=parsetiled()
mx,my=0,0
for l,layer in pairs(tiled.layers) do
 local i=1
 for y=0,layer.height-1 do
  local row,count,previous={},0,nil
  for x=0,layer.width-1 do
   sprite=layer.data[i]-1
   if sprite==previous or previous==nil then
    count=count+1
   else
    mset(mx,my,shl(count,2)+previous)
    mx+=1
    if mx>127 then mx=0 my+=1 end
    count=1
   end
   previous=sprite
   i+=1
  end
  mset(mx,my,shl(count,2)+previous)
  mx+=1
  if mx>127 then mx=0 my+=1 end
 end
end
cstore(0x1000,0x1000,0x2000)

__map__
