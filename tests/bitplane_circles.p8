pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
-- cls(15)
-- circfill(64, 64, 40, 7)
-- poke(0x5f5e, 0b01110111)
-- circfill(34, 34, 30, 6)
-- -- poke(0x5f5e, 0b11111001)
-- -- circfill(84, 14, 30, 6)
-- stop()

extcmd('rec')

function _init()
    lights = {
        { x = 34, y = 30, r = 25 },
        { x = 94, y = 30, r = 25 },
        { x = 64, y = 90, r = 25 }
    }
    l = 3
    a = 0
end

function _update()
    -- move selected light
    if btn(1) then
        lights[l].x = lights[l].x + 1
    end
    if btn(0) then
        lights[l].x = lights[l].x - 1
    end
    if btn(3) then
        lights[l].y = lights[l].y + 1
    end
    if btn(2) then
        lights[l].y = lights[l].y - 1
    end
    -- select next light
    if btnp(4) or btnp(5) then
        l += 1
        if l > #lights then l = 1 end
    end
    -- update angle for pulsing effect
    a += 0.1
end

function _draw()
    -- cls(5)
    -- -- poke(0x5f5e, 0b11111111)
    -- for l, light in pairs(lights) do
    --     circfill(light.x, light.y, light.r + (cos(a) * 2), 15)
    --     poke(0x5f5e, 0b00001010 | (1 << l + 3))
    -- end
    -- poke(0x5f5e, 0b11111111)
    -- cls(15)
    -- circfill(64, 64, 40, 7)
    -- poke(0x5f5e, 0b00010001)
    -- circfill(34, 34, 30, 6)

    -- peach 15 background
    -- white 7 circle 1
    -- silver 6 circle 2
    -- 0111 0111
    -- pink 14 + silver 6
    -- 0011 0011
    --
    -- cls(0)
    -- poke(0x5f5e, 0b00010001)
    -- circfill(44, 44, 40, 15)
    -- poke(0x5f5e, 0b00100010)
    -- circfill(84, 44, 40, 15)
    -- poke(0x5f5e, 0b01000100)
    -- circfill(44, 84, 40, 15)
    -- poke(0x5f5e, 0b10001000)
    -- circfill(84, 84, 40, 15)

    cls(0)
    for l, light in pairs(lights) do
        mask = 1 << (3 + l) | (1 << (l - 1))
        mask = 1 << (3 + l) | 15 -- circles overlap and not merge
        mask = 240 | (1 << (l - 1)) -- same as 1
        printh(mask)
        poke(0x5f5e, mask)
        circfill(light.x, light.y, light.r + (cos(a) * 2), 15)
    end
    -- pal(1, 15, 1)
    -- pal(2, 15, 1)
    -- pal(8, 15, 1)
    -- pal(3, 14, 1)
    -- pal(9, 14, 1)
    -- pal(10, 14, 1)
    -- pal(11, 13, 1)
    for l, light in pairs(lights) do
        print(light.x .. ',' .. light.y, 0, (l - 1) * 8)
    end
end
