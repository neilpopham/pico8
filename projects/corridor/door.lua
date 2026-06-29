door = entity:new({
    particles = {},
    x = nil,
    y = 0,
    yb = 55,
    d = 999,
    init = function(_ENV)
        x = ox
        s = cartval(idx, 1)
        particles = {}
        if s == 1 then
            for i = 1, 48 do
                local e = i % 2 == 0
                add(particles, maker(_ENV, e))
            end
        sfx(4)
        end
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
            d = manhattan(x, yb, plr.x, plr.y)
            if d < %0x4300 then poke2(0x4300, d) end
            if in_range(_ENV) then
                plr:explode()
            elseif (plr.x < x and x < plr.x + 15) or (plr.x > x and x > plr.x - 16) then
                for i = 1, 2 do
                    local item = inv.items[i]
                    if item and item.type == types.card and item.c == c then
                        if btnp(❎) then
                            s = 2
                            dset(idx, s)
                        end
                        action_msg('use', item.c, type_names[item.type], '❎')
                    end
                end
            end
        elseif s == 2 then
            sfx(4, -2)
            sfx(5)
            s = 3
            dset(idx, s)
        elseif s == 3 then
            if #particles == 0 then
                -- printh('door '..idx..' fully open')
                del(entities,_ENV)
            end
        end
    end,
    draw = function(_ENV)
        for px in all(particles) do
            pset(px.x, px.y + 32, px.c)
        end
        if s == 1 then
            if %0x4300 == d then
                local maxd = 240
                if d > maxd then
                    sfx(4, -2)
                else
                    local v = ceil(mid(0, (maxd - d) / (maxd / 7 ), 7))
                    set_volumes(4,0,{v,v,v})
                    sfx(4)
                end
                poke2(0x4300, 32767)
            end
        end
        -- printh('door '..idx..' particles '..#particles)
    end,
    maker = function(_ENV, e)
        return {
            x = x + flr(rnd(8)),
            y = e and y or yb,
            d = e and 1 or - 1,
            s = rnd(2) + 1,
            c = rnd() < .2 and 7 or c
        }
    end
})