door = entity:new({
    particles = {},
    x = nil,
    y = 0,
    yb = 55,
    d = 999,
    init = function(_ENV)
        x = ox
        s = cartval(idx, 1)
        for i = 1, 48 do
            local e = i % 2 == 0
            add(particles, maker(_ENV, e))
        end
        sfx(4)
    end,
    update = function(_ENV)
        for k, px in ipairs(particles) do
            px.y += px.d * px.s
            if px.y < y or px.y > yb then
                if s == 1 then
                    particles[k] = maker(_ENV, px.y > y)
                else
                    del(particles, px)
                end
            end
        end
        if s == 1 then
            -- if btn(4) then s = 2 end
            d = manhattan(x, yb, plr.x, plr.y)
            if d < %0x4300 then poke2(0x4300, d) end
            if in_range(_ENV) then
                plr:explode()
            end
        elseif s == 2 then
            sfx(4, -2)
            sfx(5)
            t = 0
            -- play sound
            -- remove flags that block player?
            s = 3
        elseif s == 3 then
            if #particles == 0 then
                printh('door '..x..' fully open')
                del(entities,_ENV)
            end
        end
        dset(idx, s)
    end,
    draw = function(_ENV)
        for px in all(particles) do
            pset(px.x, px.y + 32, px.c)
        end
        if %0x4300 == d then
            local max = 240
            if d > max then
                sfx(4, -2)
            else
                local v = ceil(mid(0, (max - d) / (max / 7 ), 7))
                set_volumes(4,0,{v,v,v})
                sfx(4)
            end
            poke2(0x4300, 32767)
        end
    end,
    maker = function(_ENV, e)
        return {
            x = x + flr(rnd(8)),
            y = e and y or yb,
            d = e and 1 or - 1,
            s = rnd(3) + 2,
            c = rnd() < .2 and 7 or c
        }
    end
})