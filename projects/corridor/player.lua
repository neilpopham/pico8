player = entity:new({
    dx = 0,
    particles = {},
    init = function(_ENV)
        -- entity.init(_ENV)
        -- x, y = 256, 48
        printh('player idx '..idx)
        x, y = cartval(idx, ox), 48
        -- y = 48
        -- 8192  -- 0010 0000 0000 0000
        -- 16384 -- 0100 0000 0000 0000
        -- 24576 -- 0110 0000 0000 0000
        -- x = dget(idx) & 8191
        -- if x == 0 then x = ox end
        -- x = cartval(idx, ox)
        dset(idx, x)
    end,
    update = function(_ENV)
        if s == 1 then
            dx = 0
            if btn(0) then dx = -1 end
            if btn(1) then dx = 1 end
            x += dx
        elseif s == 2 then
            for px in all(particles) do
                local dx = cos(px.a) * px.s
                local dy = -sin(px.a) * px.s + .2
                px.a = atan2(dx, -dy)
                px.s = sqrt((dx ^ 2) + (dy^2))
                if px.y + dy >= 56 then
                    px.a = (1 - px.a) % 1
                    px.s *= .5
                    if dy < 2 then del(particles, px) end
                    dy = -dy
                end
                px.y += dy
                px.x += dx
                px.t -= 1
                if px.t < 1 then del(particles, px) end
            end
            if #particles == 0 then s = 3 end
        elseif s == 3 then
            stop()
        end
    end,
    draw = function(_ENV)
        if s == 1 then
            spr(sp, x, y + 32)
        end
        for px in all(particles) do
            pset(px.x, px.y + 32, 3)
        end
    end,
    explode = function(_ENV)
        if s > 1 then return end
        sfx(3)
        for i = 1, 64 do
            add(
                particles,
                {
                    x = dx > 0 and x + 7 or x,
                    y = y + i % 8,
                    a = .75 + ((dx > 0 and -2 or 2) * rnd() / 10),
                    s = rnd(7),
                    dx = cos(a) * s,
                    dy = -sin(a) * s,
                    t = 180
                }
            )
        end
        s = 2
    end
})