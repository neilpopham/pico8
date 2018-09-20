pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--
-- by neil popham

--[[

http://pico-8.wikia.com/wiki/memory
http://pico-8.wikia.com/wiki/peek
http://pico-8.wikia.com/wiki/memcpy
http://pico-8.wikia.com/wiki/memset
http://pico-8.wikia.com/wiki/drawstate

]]

function get_screen_value(c1,c2)
 return shl(c2,4)+c1
end

function _init()
 cls()
 d=0x6000+128
end

function _update()
 if btnp(4) then
  memcpy(0x6000 + 1024 + rnd(1024), 0x6000 + rnd(255), rnd(128))
 end
end

function _draw()
    -- 128 64 32 16 8 4 2 1
    -- 8   7  6  5  4 3 2 1
    --poke(0x6000 + rnd(255), flr(rnd(15)+1))

    a=flr(rnd(15))+1
    a=shl(a,4)
    b=flr(rnd(15))+1

    --a=shl(7,4)
    --b=10

    --poke(d,get_screen_value(1,13))
    poke(d,a+b)
    d=d+1
    --if d>0x7fff then d=0x6000 end

    print("abcdefghijklmnopqrstuvwxyz1234567890",0,100)
end
