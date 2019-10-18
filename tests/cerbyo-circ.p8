pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--
-- by Neil Popham

function _init()
 ca=0.25
end

function _update60()
 ca=ca+0.005%1
end

function _draw()
 cls()
 for i=1,100 do
  circ(64+54*cos(ca),64,10+i,11)
 end
end
