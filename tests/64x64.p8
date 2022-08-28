pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--
-- by neil popham

function _init()
 poke(0x5f2c, 3)
end

function _update()

end

function _draw()
 cls(0)
 print('hello',0,0,9)
end
