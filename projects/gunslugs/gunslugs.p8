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
#include pickups.lua

enemies=collection:create()
particles=collection:create()
bullets=bullet_collection:create()
destructables=collection:create()
pickups=collection:create()

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
    if data[x][l] and data[x][l]==1 then
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

   -- barrels
   local k={
    nil,
    {0.6,0.2,0.4,0.1},
    {0.4,0.1,0.2,0.05},
    {0.2,0.05,0.1,0.02}
   }
   for i,l in pairs(levels) do
    if data[x][l]==1 then
     for n=0,1 do
      for j=2,4 do
       if not data[x][l-1-n] and data[x][l-n] then
        r=rnd()
        m=data[x][l-1-n]==j and k[j][1+n*2]/i or k[j][2+n*2]/i
        if (x<16) printh("m:"..m.." r:"..r)
        if r<m then
         data[x][l-1-n]=j
         if (x<16) printh("j:"..j.." x:"..x.." y:"..(l-1-n))
        end
       end
      end
     end
    end
   end
   -- barrels

   --enemies [48]
   if x>31 and x%8==0 then
    for i,l in pairs(levels) do
     if data[x] and data[x][l]==1 then
      r=rnd()
      m=0.9/i
      if r<m then
       local p=l
       repeat
        p-=1
       until data[x][p]==nil
       data[x][p]=48
      end
     end
    end
   end
   --enemies

   --medikit [40]
   if x>31 and x%16==0 then
    for i,l in pairs(levels) do
     if data[x] and data[x][l]==1 then
      r=rnd()
      m=0.25
      if r<m then
       data[x][l-3]=40
       break      
      end
     end
    end
   end
   --medikit

  end

  -- ropes
  --[[
  if x%4==0 then
   r=rnd()
   if r<0.25 then
    r=mrnd({1,5})
    for i=0,r do data[x][i]=14 end
    data[x][r]=15
   end
  end
  ]]
  -- ropes

  -- bricks
  ---[[
  if x>0 then
   for y=2,9 do
    if not data[x][y] or (data[x][y]>=9 and data[x][y]<=13) then
     r=rnd()
     m=0.5/y
     if data[x][y-1] and data[x][y-1]>=9 and data[x][y-1]<=14 then m=0.8/y end
     if data[x-1][y] and data[x-1][y]>=9 and data[x-1][y]<=13 then m=1.4/y end
     if r<m then
      data[x][y]=13
      r=rnd()
      if r<0.2 then data[x][y]=mrnd({9,13}) end
      if x<127 and not data[x+1] then data[x+1]={} end
      if not data[x-1][y] then data[x-1][y]=9 end
      if data[x+1] and not data[x+1][y] then data[x+1][y]=10 end
      if not data[x][y-1] then data[x][y-1]=11 end
      if not data[x][y+1] then data[x][y+1]=12 end
     end
    end
   end
  end
  --]]
  -- bricks

 end

 for x=0,127 do
  for y=0,15 do
   if data[x][y]==2 then
    destructables:add(destructable:create(x*8,y*8,2))
   elseif data[x][y]==3 then
    destructables:add(destructable:create(x*8,y*8,3))
   elseif data[x][y]==4 then
    destructables:add(destructable:create(x*8,y*8,4))
   elseif data[x][y]==48 then
    local r=rnd()
    local type=r<0.25 and 2 or 1
    enemies:add(enemy:create(x*8,y*8,type))
   elseif data[x][y]==40 then
    pickups:add(medikit:create(x*8,y*8))
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

 local cx=p.camera:position()
 local cx2=cx+screen.width
 for _,o in pairs(destructables.items) do
  o.visible=(o.complete==false and o.x>=cx and o.x<=cx2)
 end
 for _,o in pairs(enemies.items) do
  o.visible=(o.complete==false and o.x>=cx and o.x<=cx2)
 end
 for _,o in pairs(pickups.items) do
  o.visible=(o.complete==false and o.x>=cx and o.x<=cx2)
 end

 enemies:update()
 destructables:update()
 pickups:update()
 particles:update()
end

function _draw()
 cls()
 p.camera:map()
 enemies:draw()
 pal()
 bullets:draw()
 destructables:draw()
 pickups:draw()
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
 local cx=p.camera:position()
 print(cx)
 print(flr(stat(0)))
 print(flr(stat(1)*100))

 for i=1,p.max.health/100 do
  spr(p.health>=i*100 and 47 or 46,88+(8*(i-1)),1)
 end

--]]

end

__gfx__
0000000077777776aaaaaaa98e6e8822b6a6bb330000000000000000000000000000000000001111111000000000000011101111111011110000000000000000
000000007666666da999999428e822223b6b33330000000000000000000000000000000000001111111000000000000011101111111011110000000000000000
000000007666666d944444448e6e8822b6a6bb330000000000000000000000000000000000001111111000000000000011101111111011110000000000000000
000000007666666da999999482228822b333bb330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000007666666da99999942e2e28223a3a3b330000000000000000000000000000000000000000111111101111111000000000111111100000000000000000
000000007666666daaaaaaa482228822b333bb330000000000000000000000000000000000000000111111101111111000000000111111100000000000000000
000000007666666da99999948e6e8822b6a6bb330000000000000000000000000000000000000000111111101111111000000000111111100000000000000000
000000006ddddddd9444444428e822223b6b33330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111000000000000000011111111000000000000000000000000111111110000000000000000000000000000000000000000000000000000000000000000
04444411111111111111111111444440111111111111111100000000144444410000000000000000000000000000000000000000000000000000000000000000
01414411044444110444441111441410114444401144444000000000141441410000000000000000000000000000000000000000000000000000000000000000
04444411014144110141441111444440114414101144141000000000144444410000000000000000000000000000000000000000000000000000000000000000
04124410044444110444441101442140114444401144444000000000142112410000000000000000000000000000000000000000000000000000000000000000
63333330641244106412441003333666014421460144214600000000633333300000000000000000000000000000000000000000000000000000000000000000
03344330044333300333442003311330033113300222133000000000133333300000000000000000000000000000000000000000000000000000000000000000
02202220000022200220000002220220022200000000022000000000022002200000000000000000000000000000000000000000000000000000000000000000
a7000000ba0000000666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aa000000bb0000008222000000000000000000000000000000000000000000000888888000288800000280000002200000082000008882000550550002202200
00000000000000008882000000000000000000000000000000000000000000008887788802887880002288000002200000882200088788205ddddd5028888820
00000000000000002882000000000000000000000000000000000000000000008877778802877780002878000002200000878200087778205ddd6d502888e820
00000000000000000220000000000000000000000000000000000000000000008877778802877780002878000002200000878200087778205ddddd5028888820
000000000000000000000000000000000000000000000000000000000000000088877888028878800022880000022000008822000887882005ddd50002888200
0000000000000000000000000000000000000000000000000000000000000000088888800028880000028000000220000008200000888200005d500000282000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005000000020000
0f7fffff0000000000000000f7fffff0000000000000000000000000ff7fffff0000000000000000000000000000000000000000000000000000000000000000
0f7fffff0f7fffff0f7ffffff7fffff0f7fffff0f7fffff000000000ff7fffff000000001d6d11111d6d11111d6d111100000000000000000000000000000000
0171ffff0f7fffff0f7ffffff7ff1f10f7fffff0f7fffff000000000f1dff11f000000001d6d11111d6d11111d6d111100000000000000000000000000000000
0f7fffff0171ffff0171fffff7fffff0f7ff1f10f7ff1f1000000000ff7fffff000000001d6d11111d6d11111d6d111100000000000000000000000000000000
0f7fffff0f7fffff0f7ffffff7fffff0f7fffff0f7fffff000000000ff7fffff0000000001d1111001d1111001d1111000000000000000000000000000000000
6dddddd06f7fffff6f7fffff0dddd666f7fffff6f7fffff60000000065ddddd00000000008800000000880000000088000000000000000000000000000000000
0dd11dd0011dddd00ddd11500dd11dd00dd11dd005551dd000000000d5ddddd00000000000000000000000000000000000000000000000000000000000000000
05505550000055500550000005550550055500000000055000000000055005500000000000000000000000000000000000000000000000000000000000000000
__gff__
0003010101000000000000000000000000000000000000000000000000000000000000000000000001010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00010000300502e0502c0502a0502905028050260402504025040240402404024040230402104020070200401f0401e0401d0401c0401b0401b0401a04019040140001000013000110000e0000b0000900007000
0001000038770367703477032770307702e7702d7702b7702977028770277702577024770237702277021770207701f7701e7701e7701d7701b7701a750187501674013740117300e7300c720097200771006710
0001000027640206401b6401464008640076300563005630066300562005620056200561004600036000360003600016000660005600046000460003600036000360003600026000430003300033000330003300
00050000366502d660246601b65017650146500e640086300662004610016100161001600016001d6001c6001b6001a6001a60019600186001760017600000000000000000000000000000000000000000000000
0004000038640246401d63015630116200e6200861003610036000360002600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00060000205502355028550235501d550304003040030400304000b50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
