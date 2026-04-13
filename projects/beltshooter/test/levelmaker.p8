pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
-- beltshooter
-- by neil popham

-- set palette
poke(0x5f2e, 1)
pal({ [0] = 0, -15, -4, 12, 8, 14, 3, 11, 5, 6, -12, 4, -7, -9, -16, 7 }, 1)

_G = _ENV

class = setmetatable(
    {
        new = function(_ENV, tbl)
            return setmetatable(tbl or {}, { __index = _ENV })
        end
    },
    { __index = _ENV }
)

function make_level(level)
    memset(0x2000, 0, 0x1000)
    local floors = 112
    for x = 0, 127 do
        mset(x, 15, 5)
        if x > 7 and x < 121 then
            if x % 4 == 0 then
                for y in all({ 11, 7 }) do
                    if rnd() < .5 then
                        local start = 7
                        if mget(x - 1, y) == 9 then
                            mset(x - 1, y, 8)
                            start = 8
                        end
                        for dx = 0, 3 do
                            mset(
                                x + dx,
                                y,
                                dx == 0 and start or (dx == 3 and 9 or 8)
                            )
                        end
                        floors += 4
                    end
                end
            end
        end
    end
    local count = floors * 2
    local red = flr(flr(level / 2) + floors / 24)
    local green = flr(level + floors / 20)
    local blue = flr(level + floors / 8)
    local total = max(flr(floors / 1.5), flr(level + floors / 4))
    local pool = {}
    for i = 1, red do
        add(pool, 1)
    end
    for i = 1, green do
        add(pool, 2)
    end
    for i = 1, blue do
        add(pool, 3)
    end
    for i = #pool + 1, total do
        add(pool, rnd() < .5 and 4 or 12)
    end
    printh('floors: ' .. floors)
    printh('red: ' .. red)
    printh('green: ' .. green)
    printh('blue: ' .. blue)
    printh('total: ' .. total)
    for x = 8, 127 do
        for y in all({ 15, 11, 7 }) do
            local r = #pool / floors
            if r > 0 and mget(x, y) > 0 then
                if rnd() < r then
                    local d = rnd(pool)
                    del(pool, d)
                    mset(x, y - 1, d)
                    if rnd() < .2 then
                        local d = rnd(pool)
                        del(pool, d)
                        mset(x, y - 2, d)
                        -- floors -= 1
                    end
                end
                floors -= 1
            end
            printh('x: ' .. x .. ' floors: ' .. floors .. ' pool: ' .. #pool .. ' chance' .. r)
        end
    end
    -- for i = 1, count do
    --     local x = rnd(120) + 4
    --     local y = rnd(12) + 2
    --     if mget(x, y) == 0 then
    --         mset(x, y, 1)
    --     end
    -- end
end

function _init()
    cam = class:new({
        x = 0,
        y = 0,
        s = 0,
        on = 1,
        draw = function(_ENV)
            local cx, cy = x + rnd(s), y + rnd(s)
            camera(cx, cy)
            s = max(0, s - .06)
        end,
        shake = function(_ENV, v)
            s = min(on > 0 and 5 or 0, s + v)
        end
    })

    menuitem(1, 'toggle camshake', function() cam.on = ~cam.on end)

    make_level(20)
end

function _update60()
    cam.x += 1
    if btnp(4) then cam:shake(1) end
    if btnp(5) then cam:shake(2) end
end

function _draw()
    cls(0)
    cam:draw()
    map()
    camera()
    print(cam.s, 0, 0)
end

__gfx__
000000005fff55447fff77663fff3322cccccccbffffffff09900000fffffffffffffffffffffff907760000eeabcdfffffffff9000000000000000000000000
0000000045f5444467f7666623f32222cbbbbbba999999999f980000f999999999999999999999987fd760000eabcdfff999999800066700cc0cc0cc00008990
000000005fff55447fff77663fff3322baaaaaaa99999999998800009888888888888888888888887d76600000000000988888880066d760cb0cb0cb00099f90
00000000544455447666776632223322cbbbbbba9999999908800000f999999999999999999999986766600000000000f9999998066d6760cb0cb0cb0089f980
000000004f4f45446f6f67662f2f2322cbbbbbba9999999900000000f999999999999999999999980666000000000000f999999806d67660ba0ba0ba08989900
00000000544455447666776632223322ccccccca9999999900000000fffffffffffffffffffffff80000000000000000fffffff807776600cb0cb0cb0cd98000
000000005fff55447fff77663fff3322cbbbbbba9999999900000000f999999999999999999999980000000000000000f999999800666000aa0aa0aa0cc80000
0000000045f5444467f7666623f32222baaaaaaa8888888800000000988888888888888888888888000000000000000098888888000000000000000000000000
000000000aaaaaaa0aaaaaaa8889ff98000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04404400aaabbbbaaaacccca88111118000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44544440aabbababaacc1c1c8889ff98000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
45f54440aabbbbbbaacccccc8889ff98000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4454444004abbbb004acccc004444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04444400044444400444449904444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00444000044444400444444004444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400000a0000a00a0000a000a00a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
