pico-8 cartridge // http://www.pico-8.com
version 42
__lua__

-- https://pico-8.fandom.com/wiki/P8FileFormat
-- https://pico-8.fandom.com/wiki/Memory#Music
-- https://pico-8.fandom.com/wiki/Music
-- https://pico-8.fandom.com/wiki/Cstore

-- 0x3100	0x31ff	Music
-- 0x3200	0x42ff	Sound effects
-- 0x4300	0x55ff	General use (or work RAM)

-- visible=false,
-- trigger={6,6},
-- dir=1,
-- origin={1,3},
-- spr={
--     {3,3,3,3,3,3},
--     {3,3,3,3,3,3},
--     {3,3,3,3,3,3},
--     {3,3,3,3,3,5}
-- },
-- objects={
--     {2,2,6}
-- }

-- FORMAT:
-- TX TY OX OY DD WW HH S1 S2 S3 ...
-- 31 BYTES FOR ROOM ABOVE
-- 8 ROOMS

-- There are 64 music frames.
-- Each frame (from 0 to 63) uses four consecutive bytes
-- corresponding with the four PICO-8 sound channels,
-- for a total of 256 bytes.
-- S0 MULTIPLES OF 4


print(peek(0x3100))
print(peek(0x3101))

print(peek(0x3104))
print(peek(0x3105))
print(peek(0x3106))


poke(0x3100,255)
poke(0x3101,128)

poke(0x3102,0)
poke(0x3103,0)
poke(0x3104,0)
poke(0x3105,0)

-- cstore( destaddr, sourceaddr, len, [filename] )

cstore(0x3100,0x3100,2)
__music__
03 7f004344

