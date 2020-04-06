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
#include player.lua
#include stars.lua
#include particles.lua

function _init()
 p=player:create()
 bullets=collection:create()
 stars:create()
 particles=collection:create()
end

function _update60()
 bullets:update()
 particles:update()
 p:update()
 stars:update()
end

function _draw()
 cls()
 stars:draw()
 bullets:draw()
 particles:draw()
 p:draw()
end
