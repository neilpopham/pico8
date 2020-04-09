pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--
-- by Neil Popham

-- https://www.lexaloffle.com/bbs/?tid=35462
_pal={0,128,132,4,142,137,9,10,135,3,139,11,129,1,140,12}
for i,c in pairs(_pal) do
	pal(i-1,c,1)
end

screen={width=128,height=128,x2=127,y2=127}
pad={left=0,right=1,up=2,down=3,btn1=4,btn2=5}

#include functions.lua
#include objects.lua
#include counter.lua
#include button.lua
#include collection.lua
#include entity.lua
#include bullet.lua
#include player.lua
#include enemy.lua
#include pickup.lua
#include stars.lua
#include particles.lua

function _init()
 printh("=======================")
 p=player:create()
 bullets=collection:create()
 stars:create()
 particles=collection:create()
 enemies=collection:create()
 pickups=collection:create()
 t=0
end

function _update60()

 if enemies.count<10 and rnd()<0.05 then
  enemies:add(enemy:create())
 end

 if pickups.count<2 and rnd()<0.05 then
  pickups:add(pickup:create())
 end

 p:update()
 bullets:update()
 particles:update()
 stars:update()
 enemies:update()
 pickups:update()

 t=t+1
 if t>79 then t=0 end
end

function _draw()
 cls()
 stars:draw()
 bullets:draw()
 enemies:draw()
 pickups:draw()
 p:draw()
 particles:draw()

 print(p.health,0,0,11)
 print(p.shield.health,64,0,15)
 for k,v in pairs(pickups.items) do
  print(v.ttl,0,10+k*8,11)
 end


end
