--pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
--
-- The mapped address for the spritesheet is stored at 0x5f54,
-- and the mapped address for the screen is stored at 0x5f55.

cls()
poke(0x5f55, 0x00)
rect(8,0, 15,7,1)
circfill(11, 3, 3, 9)

poke(0x5f55, 0x60)
-- poke(0x5f54, 0x00)

spr(1, 60, 60)
spr(1, 80, 80)

