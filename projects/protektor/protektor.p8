pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- Protektor
-- by Neil Popham

screen={width=128,height=128,x2=127,y2=127}
pad={left=0,right=1,up=2,down=3,btn1=4,btn2=5}

#include functions.lua
#include collection.lua
#include particles.lua
#include stages.lua

#include entity.lua
#include player.lua
#include bullet.lua
#include enemy.lua
#include pickup.lua

--[[
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
]]

function _init()
 stage=stage_main
 stage:init()
end

function _update60()
 stage:update()
end

function _draw()
 cls()
 stage:draw()
 stages:draw()
end
