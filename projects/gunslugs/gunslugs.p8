pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

local pad={left=0,right=1,up=2,down=3,btn1=4,btn2=5}
local screen={width=128,height=128,x2=127,y2=127}
local dir={left=1,right=2}
local drag={air=0.95,ground=0.65,gravity=0.7}
local data={}

#include functions.lua
#include particles.lua
#include camera.lua
#include objects.lua
#include button.lua
#include destructables.lua
#include enemies.lua
#include player.lua
#include bullets.lua

enemies=collection:create()
particles=collection:create()
bullets=bullet_collection:create()
destructables=collection:create()

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
      if not data[i] then data[i]={} end
      data[i][levels[2]]=1
     end
    end
    if data[x-3][levels[2]]==1 then
     r=rnd()
     m=0.5
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

   for x=20,40 do
    if not data[x] then data[x]={} end
    data[x][14]=3
    data[x][13]=2
   end

  end
 end

 for x=0,127 do
  for y=0,15 do
   if data[x][y]==2 then
    --mset(x,y,0)
    --mset(x,y,data[x][y])
    destructables:add(destructable:create(x*8,y*8,2))
   elseif data[x][y]==3 then
    --mset(x,y,0)
    --mset(x,y,data[x][y])
    destructables:add(destructable:create(x*8,y*8,3))
   elseif data[x][y]==4 then
    --mset(x,y,0)
    --mset(x,y,data[x][y])
    enemies:add(enemy:create(x*8,y*8,4))
   else
    mset(x,y,data[x][y])
   end
  end
 end

end

function _update60()
 p:update()
 p.camera:update()
 bullets:update()

 local cx,cy=p.camera:position()
 for _,o in pairs(destructables.items) do
  o.visible=(o.complete==false and o.x>=cx and o.x<=(cx+screen.width))
 end
 for _,o in pairs(enemies.items) do
  o.visible=(o.complete==false and o.x>=cx and o.x<=(cx+screen.width))
 end

 enemies:update()
 destructables:update()
 particles:update()
end

function _draw()
 cls()
 p.camera:map()
 bullets:draw()
 destructables:draw()
 enemies:draw()
 particles:draw()
 p:draw()

 -- draw hud
 camera(0,0)

--[[
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
]]

---[[
 local cx,cy=p.camera:position()
 print(cx)
 print(cy)
 print(flr(stat(0)))
 print(flr(stat(1)*100))
--]]

end

__gfx__
0000000077777776aaaaaaa98e6e8822cccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000007666666da999999428e82222cccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000007666666d944444448e6e8822cccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000007666666da99999948e7e8822cccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000007666666da99999948e6e8822cccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000007666666daaaaaaa48e6e8822cccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000007666666da99999948e6e8822cccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000006ddddddd9444444428e82222cccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111000000000000000011111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04444411111111111111111111444440111111111111111100000000000000000000000000000000000000000000000000000000000000000000000000000000
01414411044444110444441111441410114444401144444000000000000000000000000000000000000000000000000000000000000000000000000000000000
04444411014144110141441111444440114414101144141000000000000000000000000000000000000000000000000000000000000000000000000000000000
04244410044444110444441101444240114444401144444000000000000000000000000000000000000000000000000000000000000000000000000000000000
66633330642444106424441003333666014442460144424600000000000000000000000000000000000000000000000000000000000000000000000000000000
03311330033113300331222003311330033113300222133000000000000000000000000000000000000000000000000000000000000000000000000000000000
02202220000022200220000002220220022200000000022000000000000000000000000000000000000000000000000000000000000000000000000000000000
77000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0003010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
