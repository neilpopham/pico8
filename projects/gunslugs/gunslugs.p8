pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

#include objects.lua

local data={}

function _init()

 local levels,r,m={15,11,7}

 for x=0,127 do

  if not data[x] then data[x]={} end
  data[x][15]=1

  if x>7 then

   -- levels [1]
   if x%4==0 then
    r=rnd()
    m=0.5
    if r<m then
     for i=x,x+3 do
      printh("  i : "..i)
      if not data[i] then data[i]={} end
      data[i][levels[2]]=1
     end
    end
    if (x>3) and (data[x-3][l1]==1) then
     r=rnd()
     m=0.3
     if r<m then
      for i=x,x+3 do
       if not data[i] then data[i]={} end
       data[i][levels[3]]=1
      end
     end
    end
   end
   -- levels

   -- crates [2]
   for i,l in pairs(levels) do
    if data[x][l] then
     r=rnd()
     m=data[x][l-1]==2 and 0.75/i or 0.25/i
     if r<m then
      data[x][l-1]=2
      r=rnd()
      m=data[x][l-2]==2 and 0.6/i or 0.2/i
      if r<m then
       data[x][l-2]=2
      end
     end
    end
   end
   -- crates

   -- barrels [3]
   for i,l in pairs(levels) do
    if (data[x][l]) and (not data[x][l-1]) then
     r=rnd()
     m=data[x][l-1]==3 and 0.4/i or 0.1/i
     if r<m then
      data[x][l-1]=3
      r=rnd()
      m=data[x][l-2]==3 and 0.2/i or 0.05/i
      if r<m then
       data[x][l-2]=3
      end
     end
    end
   end
   -- barrels

   --enemies [4]
   if x>31 and x%8==0 then
    -- pick a random square 4 spaces either side of the current x
    --local xx=x+flr(rnd()*8)-4
    for i,l in pairs(levels) do
     if data[x] and data[x][l] then
      r=rnd()
      m=0.9/i
      if r<m then
       local p=l
       repeat
        p-=1
       until data[x][p]==nil
       data[x][p]=4
      end
     end
    end
   end
   --enemies

  end
 end


 for x=0,127 do
  for y=0,15 do
   mset(x,y,data[x][y])
  end
 end





end

function _update60()


end

function _draw()
 cls()
 map()

 for x=0,127 do
  for y=0,15 do
   if data[x][y] then
    if data[x][y]==1 then pset(x,y,7) end
    if data[x][y]==2 then pset(x,y,9) end
    if data[x][y]==3 then pset(x,y,8) end
    if data[x][y]==4 then pset(x,y,12) end
   end
  end
 end
end


__gfx__
00000000666666669999999988888888cccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000666666669999999988888888cccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000666666669999999988888888cccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000666666669999999988888888cccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000666666669999999988888888cccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000666666669999999988888888cccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000666666669999999988888888cccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000666666669999999988888888cccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
