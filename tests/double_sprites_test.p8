pico-8 cartridge // http://www.pico-8.com
version 43
__lua__

poke(0x5f54,0x00)
for y=0,7 do
    for x=0,15 do
        sset(x,y,2)
    end
end

poke(0x5f54,0x80)
for y=0,7 do
    for x=0,15 do
        sset(x,y,3)
    end
end

-- poke(0x5f54,0x43)
-- for y=0,7 do
--     for x=0,15 do
--         sset(x,y,7)
--     end
-- end

cls()

poke(0x5f54,0x00)
spr(1,20,20)
poke(0x5f54,0x80)
spr(1,30,20)
-- poke(0x5f54,0x43)
-- spr(1,40,20)
