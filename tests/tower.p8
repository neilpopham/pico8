pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--
-- by Neil Popham

local pad={left=0,right=1,up=2,down=3,btn1=4,btn2=5}

function decompress()
 local collection,room,row={},{},{}
 local mx,my,x,y,r=0,0,1,1,1
 local s=mget(mx,my)
 while s>0 do
  local t=band(s,3)
  local c=shr(s-t,2)
  for i=1,c do
   row[x]=t
   x+=1
  end
  if x>25 then
   room[y]=row
   x,row=1,{}
   y+=1
   if y>25 then
    add(collection,room)
    y,room=1,{}
   end
  end
  mx+=1
  if mx>127 then
   mx=0
   my+=1
  end
  s=mget(mx,my)
 end
 return collection
end

function storeroom(level)
 --memset(0x0000,0,0x2000)
 local cols={3,4,11,12}
 for y=1,25 do
  for x=1,25 do
   for py=2,6 do
    for px=2,6 do
     sset((x-1)*5+px,(y-1)*5+py,cols[rooms[level][y][x]+1])
    end
   end
  end
 end
 --cstore(0x0000,0x0000,0x2000)
end

function _init()
 rooms=decompress()
 level=1
 storeroom(level)
 p={x=0,y=0,col=7}
end

function _update60()
 if btnp(pad.left) then p.x=p.x-1 end
 if btnp(pad.right) then p.x=p.x+1 end
 if btnp(pad.up) then p.y=p.y-1 end
 if btnp(pad.down) then p.y=p.y+1 end
 p.x=p.x%25
 p.y=p.y%25
 local tile=rooms[2][p.y+1][p.x+1]
 if tile==0 then p.col=7 else p.col=8 end
end

function _draw()
 cls()
 sspr(0,0,128,128,0,0)
 rect(p.x*5+1,p.y*5+1,p.x*5+7,p.y*5+7,p.col)
end

__map__
646464641c29201c29201c29201c0d100d201c0d100d201c0d100d2029100d2029100d2029100d20380d20380d201406200d200c06080a180d20100f0a140d200c170a100d200406041706140d20120f1c0d20040a10060406100d20100a200d202006140d20380d20646464641c29201c29201c29201c0d100d201c0d100d20
1c0d100d2029100d2029100d2029100d20380d20380d201406200d200c06080a180d20100f0a140d200c170a100d200406041706140d20120f1c0d20040a10060406100d20100a200d202006140d20380d2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
