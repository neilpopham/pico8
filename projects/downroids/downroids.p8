pico-8 cartridge // http://www.pico-8.com
version 27
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
-- #include objects.lua
-- #include counter.lua
-- #include button.lua
#include stages.lua
#include collection.lua
#include entity.lua
#include bullet.lua
#include player.lua
#include enemy.lua
#include pickup.lua
#include stars.lua
#include particles.lua

function _init()
 printh("==== _init() ====")
 stage=stage_intro
 stage:init()
 stars:create()
 p=player:create()
 bullets=collection:create()
 particles=collection:create()
 enemies=collection:create()
 pickups=collection:create()
end

function _update60()
 stage:update()
 if enemies.count<10 and rnd()<0.05 then
  enemies:add(enemy:create())
 end
 if pickups.count<3 and rnd()<0.005 then
  pickups:add(pickup:create())
 end
 stars:update()
 enemies:update()
 pickups:update()
end

function _draw()
 cls(0)
 stars:draw()
 enemies:draw()
 pickups:draw()
 stage:draw()
 if p.health>0 then line(0,0,p.health*6,0,11) end
 if p.shield.health>0 then line(127-p.shield.health*6,0,127,0,15) end
 dprint(lpad(p.score,6),52,3,6,2)
 stages:draw()
end
__sfx__
000100001605017050190501a0501b050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200002c650246501c6501465007650036500065000600006000060000600006000060000600006000160001600016000060000600000000000000000000000000000000000000000000000000000000000000
000200001b3501d3501e3501f33021320233102435005300053001b330233402a3503235000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400000372005720000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
