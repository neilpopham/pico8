pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- testing rand function
-- by neil popham

function rand(value,floor)
 if floor==nil then floor=true end
 local v=(rnd(value[2]-value[1]))+value[1]
 return floor and flr(v) or v
end

function _init()
 min=10000 max=0
end

function _update()
 x=rand({0.5,2.5},false)
 if x<min then min=x end
 if x>max then max=x end
end

function _draw()
 cls()
 print("min:"..min,0,0)
 print("max:"..max,0,10)
 print("x:"..x,0,20)
end
