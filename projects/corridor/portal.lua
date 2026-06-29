portal = entity:new({
    sockets = {},
    init = function(_ENV)
        particles = {}
        value = dget(idx)
        x, y = ox, 56
        for i = 0, 3 do
            mset(tx + i, ty, 2)
        end
    end,
    update = function(_ENV)
        if s == 1 then
            for k = 0, 3 do
                local cx = x + k * 8
                if plr.x + 4 >= cx and plr.x <= cx + 3 then
                    local v = (1 << 3 - k)
                    for i = 1, 2 do
                        local item = inv.items[i]
                        if item and item.type == types.stone and colour_values[item.c] == v then
                            if btnp(❎) then
                                -- inv:use(i, cx)
                                if value & v > 0 then
                                    value -= v
                                else
                                    value += v
                                end
                                -- printh('portal '..idx..' value = '..value)
                                dset(idx, value)
                            end
                            action_msg('use', item.c, type_names[item.type], '❎')
                        end
                    end
                end
            end
            if value > 0 and plr.x >= x and plr.x <= x + 31 then
                if btn(⬆️) then
                    s = 2
                end
                _G.msg = _G.msg .. '\f3⬆️\fd use portal\n'
            end
            if value > 0 and rnd() < .25 then
                add(
                    particles,
                    {
                        x = x + flr(rnd(31)),
                        y = y,
                        s = ceil(rnd(12)),
                        c = 11,
                        t = 32
                    }
                )
            end
        elseif s == 2 then
            for i = 1, 32 do
                add(
                    particles,
                    {
                        x = plr.x + flr(rnd(7)),
                        y = y + i % 7,
                        s = ceil(rnd(12)),
                        c = 3,
                        t = 32
                    }
                )
            end
            plr.s = 4
            s = 3
        elseif s == 3 then
            if #particles == 0 then s = 4 end
            printh('particles ' .. #particles)
        elseif s == 4 then
            for p in all(portals) do
                if p.no == value then
                    s = 1
                    local d = plr.x - x
                    plr:teleport(p.x + d)
                end
            end
            -- stop()
        end
        for px in all(particles) do
            px.y -= px.s
            px.t -= 1
            if px.y < 0 or px.t == 0 then del(particles, px) end
        end
    end,
    draw = function(_ENV)
        if value > 0 then
            for i = 1, 32 do
                -- pset(x + flr(rnd(31)), y + 32, 11)
            end
            for i = 1, 12 do
                pset(x + flr(rnd(31)), y + 31, 11)
            end
            for k = 0, 3 do
                local cx = x + k * 8
                local v = (1 << 3 - k)
                if value & v > 0 then
                    pal(15, colours[k])
                    spr(125, cx, y + 32)
                    pal()
                end
            end
        end
        -- if s > 1 then
            for px in all(particles) do
                pset(px.x, px.y + 32, px.c)
            end
        -- end
    end
})