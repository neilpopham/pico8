pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- rle
-- by neil popham

function compress()
 local room,row,previous,count={},{},nil,0
 local sprite
 for y=0,63,2 do
  row={}
  count=0
  for x=0,129,2 do
   if x<128 then sprite=mget(x,y) else sprite=nil end
    --printh("cell:"..x..","..y.." sprite:"..(sprite and sprite or "nil").." previous:"..(previous and previous or "nil").." count:"..count)
   if sprite==previous or previous==nil then
    --printh("here1")
    count=count+1
   elseif count==1 then
    --printh("here2")
    add(row,previous)
    add(row,sprite)
    count=0
    previous=nil
   else
    --printh("here3")
    add(row,count+128)
    add(row,previous)
    count=1
   end
   previous=sprite
  end --x
  add(row,128)
  add(row,1)
  add(room,row)
  --return room -- #####################
 end --y
 return room
end

function decompress()
 local collection,room,row={},{},{}
 for y=0,31 do
  for x=0,127,2 do
   local sprite1,sprite2=mget(x,y),mget(x+1,y)
   if sprite1>0 then
    if sprite1>127 then
     if sprite1==128 then
      add(room,row)
      row={}
      if sprite2==0 then -- beginning of new room
       add(collection,room)
       room={}
      end
     else -- repeat sprite 2
      sprite1=sprite1-128
      for n=1,sprite1 do
       add(row,sprite2)
      end
     end
    else
     add(row,sprite1)
     add(row,sprite2)
    end
   end
  end
 end
 add(room,row)
 add(collection,room)
 return collection
end

function _init()
 cls()
 --[[
 local t=decompress()
 printh("============================")
 for _,c in pairs(t) do
  printh("collection")
  for _,r in pairs(c) do
   printh("row")
   for _,s in pairs(r) do
    printh(s)
   end
  end
 end
 ]]
 local t=compress()
 printh("============================")
 for _,r in pairs(t) do
  printh("row")
  for _,s in pairs(r) do
   printh(s)
  end
 end
end

function _update60()

end

function _draw()

end

--[[
XXYY
if XX=128 then if YY=0 then new room if YY=1 then new row
if XX>128 then repeat YY XX-128 times
]]

--[[
-- __map__
0102030480018a02030480000506070880018509
]]

__gfx__
66666666dddddddd9999999966666666000000000000000000000000000000000000000000000000777777787777777600000000000000000000000000000000
66666666dddddddd9999999966666666000000000000000000000000000000000000000000000000788888827666666d00000000000000000000000000000000
66666666dddddddd9999999966666666000000000000000000000000000000000000000000000000788888827666666d00000000000000000000000000000000
66666666dddddddd9999999966666666000000000000000000000000000000000000000000000000788888827666666d00000000000000000000000000000000
66666666dddddddd9999999966666666000000000000000000000000000000000000000000000000788888827666666d00000000000000000000000000000000
66666666dddddddd9999999966666666000000000000000000000000000000000000000000000000788888827666666d00000000000000000000000000000000
66666666dddddddd9999999966666666000000000000000000000000000000000000000000000000788888827666666d00000000000000000000000000000000
66666666dddddddd9999999966666666000000000000000000000000000000000000000000000000822222226ddddddd00000000000000000000000000000000
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc0000000000000000000000000000000000000000000000000000000000000000
cccc000ccccc000ccccc00cccccc000ccccc00cccccc000ccccc000ccccc0c0c0000000000000000000000000000000000000000000000000000000000000000
cccccc0ccccccc0cccccc0cccccc0c0cccccc0cccccccc0ccccccc0ccccc0c0c0000000000000000000000000000000000000000000000000000000000000000
c00c000cc00c000cc00cc0cccccc0c0cccccc0cccccc000ccccc000ccccc000c0000000000000000000000000000000000000000000000000000000000000000
cccccc0ccccc0cccccccc0cccccc0c0cccccc0cccccc0ccccccccc0ccccccc0c0000000000000000000000000000000000000000000000000000000000000000
cccc000ccccc000ccccc000ccccc000ccccc000ccccc000ccccc000ccccccc0c0000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc0000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc0000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc0000000000000000000000000000000000000000000000000000000000000000
cccc0cccc0cccccccccc0ccccccccc0cccc0ccccc0000cccccc0ccccccc0000c0000000000000000000000000000000000000000000000000000000000000000
ccccc0cccc0ccccccccc0cccccccc0cccc0cccccc00ccccccc000cccccccc00c0000000000000000000000000000000000000000000000000000000000000000
c000000cccc0cc0ccccc0cccc0cc0cccc000000cc0c0ccccc0c0c0cccccc0c0c0000000000000000000000000000000000000000000000000000000000000000
ccccc0cccccc0c0ccc0c0c0cc0c0cccccc0cccccc0cc0cccccc0ccccccc0cc0c0000000000000000000000000000000000000000000000000000000000000000
cccc0cccccccc00cccc000ccc00cccccccc0ccccccccc0ccccc0cccccc0ccccc0000000000000000000000000000000000000000000000000000000000000000
ccccccccccc0000ccccc0cccc0000ccccccccccccccccc0cccc0ccccc0cccccc0000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc0000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeffffffff000000000000000000000000000000000000000000000000
eeee00eeeeee000eeeee000eeeee0e0eeeee000eeeee0eeeeeee000eeeee000eeeee000effffffff000000000000000000000000000000000000000000000000
eeeee0eeeeeeee0eeeeeee0eeeee0e0eeeee0eeeeeee0eeeeeeeee0eeeee0e0eeeee0e0effffffff000000000000000000000000000000000000000000000000
eeeee0eeeeee000eeeee000eeeee000eeeee000eeeee000eeeeeee0eeeee000eeeee000effffffff000000000000000000000000000000000000000000000000
eeeee0eeeeee0eeeeeeeee0eeeeeee0eeeeeee0eeeee0e0eeeeeee0eeeee0e0eeeeeee0effffffff000000000000000000000000000000000000000000000000
eeee000eeeee000eeeee000eeeeeee0eeeee000eeeee000eeeeeee0eeeee000eeeeeee0effffffff000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeffffffff000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeffffffff000000000000000000000000000000000000000000000000
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
30303030101030303030101010101010303010101010101030303030101010101010303010101010101030303030101030303030303030303030303030303030
30301010303030301010303030303030303030301010303030301010303030303030101030303030303030301010303030303030101030303030101030303030
30303030101030303030101010101010303010101010101030303030101010101010303010101010101030303030101030303030303030303030303030303030
30301010303030301010303030303030303030301010303030301010303030303030101030303030303030301010303030303030101030303030101030303030
30303030101030303030101030303030303030303030101030303030101030303030303030303030101030303030101010103030101010103030303030303030
30301010303030303030303030303030303030301010303030303030303030303030303030303030303030303030303030303030303030303030101030303030
30303030101030303030101030303030303030303030101030303030101030303030303030303030101030303030101010103030101010103030303030303030
30301010303030303030303030303030303030301010303030303030303030303030303030303030303030303030303030303030303030303030101030303030
30303030101030303030303030303030303030303030101030303030303030303030303030303030101030303030101030303030303010103030303030303030
30301010303030301010303030303030303030301010303030301010303030303030101030303030303030301010303030303030101030303030101030303030
30303030101030303030303030303030303030303030101030303030303030303030303030303030101030303030101030303030303010103030303030303030
30301010303030301010303030303030303030301010303030301010303030303030101030303030303030301010303030303030101030303030101030303030
30303030101030303030101030303030303030303030101030303030101030303030303030303030101030303030101030303030303010103030303030303030
30301010303030301010303030303030303030301010303030301010303030303030101030303030303030301010303030303030101030303030101030303030
30303030101030303030101030303030303030303030101030303030101030303030303030303030101030303030101030303030303010103030303030303030
30301010303030301010303030303030303030301010303030301010303030303030101030303030303030301010303030303030101030303030101030303030
30303030101030303030101010101010101010101010101030303030101010101010101010101010101030303030101010101010101010101010101030301010
10101010303030301010101010101010101010101010303030301010101010101010101010101010101010101010101010101010101030303030101030303030
30303030101030303030101010101010101010101010101030303030101010101010101010101010101030303030101010101010101010101010101030301010
10101010303030301010101010101010101010101010303030301010101010101010101010101010101010101010101010101010101030303030101030303030
30303030101030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303010103030303030303030
30301010303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030101030303030
30303030101030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303010103030303030303030
30301010303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030101030303030
30303030101030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303010103030303030303030
30301010303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030101030303030
30303030101030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303010103030303030303030
30301010303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030101030303030
30303030101010101010101030301010101010101010101030301010101010103030303010101010101030301010101010103030303010103030303030303030
30301010303030301010101010103030101010101010303030301010101010101010303010101010101010101010101010103030101010101010101030303030
30303030101010101010101030301010101010101010101030301010101010103030303010101010101030301010101010103030303010103030303030303030
30301010303030301010101010103030101010101010303030301010101010101010303010101010101010101010101010103030101010101010101030303030
30303030101030303030303030303030303010103030303030303030303010103030303010103030303030303030303010103030303010103030303030303030
30301010303030301010303030303030303030301010303030301010303030303030303030303030303010103030303030303030303030303030101030303030
30303030101030303030303030303030303010103030303030303030303010103030303010103030303030303030303010103030303010103030303030303030
30301010303030301010303030303030303030301010303030301010303030303030303030303030303010103030303030303030303030303030101030303030
30303030101030303030303030303030303010103030303030303030303010103030303010103030303030303030303010103030303010103030303030303030
30301010303030301010303030303030303030301010303030301010303030303030303030303030303010103030303030303030303030303030101030303030
30303030101030303030303030303030303010103030303030303030303010103030303010103030303030303030303010103030303010103030303030303030
30301010303030301010303030303030303030301010303030301010303030303030303030303030303010103030303030303030303030303030101030303030
30303030101030303030303030303030303030303030303030303030303010103030303010101010101010101010101010103030303010101010101030301010
10101010303030301010101010101010101010101010303030303030303030303030303030303030303010103030303030303030303030303030101030303030
30303030101030303030303030303030303030303030303030303030303010103030303010101010101010101010101010103030303010101010101030301010
10101010303030301010101010101010101010101010303030303030303030303030303030303030303010103030303030303030303030303030101030303030
30303030101030303030303030303030303010103030303030303030303010103030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030301010303030303030303030303030303010103030303030303030303030303030101030303030
30303030101030303030303030303030303010103030303030303030303010103030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030301010303030303030303030303030303010103030303030303030303030303030101030303030
30303030101030303030303030303030303010103030303030303030303010103030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030301010303030303030303030303030303010103030303030303030303030303030101030303030
30303030101030303030303030303030303010103030303030303030303010103030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030301010303030303030303030303030303010103030303030303030303030303030101030303030
30303030101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101030303030
30303030101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
__gff__
0001000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303
0303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303
0303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303
0303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303
0303030301010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010103030303
0303030301010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010103030303
0303030301010303030303030303030301010303030303030303030303030303010103030303030301010303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030101030303030303030303030101030303030303010103030303030303030303010103030303
0303030301010303030303030303030301010303030303030303030303030303010103030303030301010303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030101030303030303030303030101030303030303010103030303030303030303010103030303
0303030301010303030303030303030301010303030303030303030303030303010103030303030301010303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030101030303030303030303030101030303030303010103030303030303030303010103030303
0303030301010303030303030303030301010303030303030303030303030303010103030303030301010303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030101030303030303030303030101030303030303010103030303030303030303010103030303
0303030301010303030303030303030301010303030303030303030303030303010103030303030301010303030301010101010101010101010101010303010101010101030303030101010101010101010101010101030303030101030303030303030303030101030303030303010103030303030303030303010103030303
0303030301010303030303030303030301010303030303030303030303030303010103030303030301010303030301010101010101010101010101010303010101010101030303030101010101010101010101010101030303030101030303030303030303030101030303030303010103030303030303030303010103030303
0303030301010303030303030303030301010303030303030303030303030303010103030303030301010303030301010303030303030303030303030303030303030101030303030101030303030303030303030101030303030101030303030303030303030101030303030303010101010101030301010101010103030303
0303030301010303030303030303030301010303030303030303030303030303010103030303030301010303030301010303030303030303030303030303030303030101030303030101030303030303030303030101030303030101030303030303030303030101030303030303010101010101030301010101010103030303
0303030301010101010103030101010101010101010101010303010101010101010101010303010101010303030301010303030303030303030303030303030303030101030303030101030303030303030303030101030303030101030303030303030303030303030303030303030303030303030303030303010103030303
0303030301010101010103030101010101010101010101010303010101010101010101010303010101010303030301010303030303030303030303030303030303030101030303030101030303030303030303030101030303030101030303030303030303030303030303030303030303030303030303030303010103030303
0303030301010303030303030303030303030303030303030303030303030303030303030303030303030303030301010303030303030303030303030303030303030101030303030303030303030303030303030101030303030101030303030303030303030101030303030303030303030303030303030303010103030303
0303030301010303030303030303030303030303030303030303030303030303030303030303030303030303030301010303030303030303030303030303030303030101030303030303030303030303030303030101030303030101030303030303030303030101030303030303030303030303030303030303010103030303
0303030301010303030303030303030303030303030303030303030303030303030303030303030303030303030301010303030303030303030303030303030303030101030303030101030303030303030303030101030303030101030303030303030303030101030303030303030303030303030303030303010103030303
0303030301010303030303030303030303030303030303030303030303030303030303030303030303030303030301010303030303030303030303030303030303030101030303030101030303030303030303030101030303030101030303030303030303030101030303030303030303030303030303030303010103030303
0303030301010303030301010101010103030101010101010303030301010101010101010101010101010303030301010303030303030303030303030303030303030101030303030101030303030303030303030101030303030101030303030303030303030101030303030303030303030303030303030303010103030303
0303030301010303030301010101010103030101010101010303030301010101010101010101010101010303030301010303030303030303030303030303030303030101030303030101030303030303030303030101030303030101030303030303030303030101030303030303030303030303030303030303010103030303
0303030301010303030301010303030303030303030301010303030301010303030303030303030301010303030301010303030303030303030303030303030303030101030303030101010101010101010101010101030303030101010101010303010101010101010101010101010103030101010101010101010103030303
0303030301010303030301010303030303030303030301010303030301010303030303030303030301010303030301010303030303030303030303030303030303030101030303030101010101010101010101010101030303030101010101010303010101010101010101010101010103030101010101010101010103030303
0303030301010303030301010303030303030303030301010303030301010303030303030303030301010303030301010303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303010103030303
0303030301010303030301010303030303030303030301010303030301010303030303030303030301010303030301010303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303010103030303
0303030301010303030301010101010101010101010101010303030301010101010103030101010101010303030301010303030303030303030303030303030303030101030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303010103030303
0303030301010303030301010101010101010101010101010303030301010101010103030101010101010303030301010303030303030303030303030303030303030101030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303010103030303
0303030301010303030303030303030303030303030303030303030303030303030303030303030303030303030301010303030303030303030303030303030303030101030303030101010101010101010101010101030303030101010101010101010101010101010101010101010101010101010103030303010103030303
0303030301010303030303030303030303030303030303030303030303030303030303030303030303030303030301010303030303030303030303030303030303030101030303030101010101010101010101010101030303030101010101010101010101010101010101010101010101010101010103030303010103030303
0303030301010303030303030303030303030303030303030303030303030303030303030303030303030303030301010303030303030303030303030303030303030101030303030101030303030303030303030101030303030101030303030303010103030303030303030101030303030303010103030303010103030303
0303030301010303030303030303030303030303030303030303030303030303030303030303030303030303030301010303030303030303030303030303030303030101030303030101030303030303030303030101030303030101030303030303010103030303030303030101030303030303010103030303010103030303
