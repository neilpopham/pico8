player = entity:new({
    x = nil,
    y = nil,
    dx = 0,
    particles = {},
    init = function(_ENV)
        -- x, y = 256, 48
        x, y = ox, 48
    end,
    update = function(_ENV)
        dx = 0
        if btn(0) then dx = -2 end
        if btn(1) then dx = 2 end
        x += dx

        for px in all(particles) do
            px.x += px.dx
            px.dy += .1
            if px.y + px.dy >= 56 then
                px.dy = -px.dy *.7
                -- px.t -= 30
            end
            px.y += px.dy
            px.t -= 1
            if px.t < 1 then del(particles, px) end

        end
    end,
    draw = function(_ENV)
        if s == 1 then
            spr(48, x, y + 32)
        end
        for px in all(particles) do
            pset(px.x, px.y + 32, 3)
        end

    end,
    explode = function(_ENV)
        if s > 1 then return end
        sfx(3)
        for i = 1, 64 do
            -- -> .85-.95
            -- <- .55-.65
            local a = .75 + ((dx > 0 and -2 or 2) * rnd() / 10)
            local s = rnd(5)
            add(
                particles,
                {
                    x = dx > 0 and x + 7 or x,
                    y = y + i % 8,
                    s = s,
                    dx = cos(a) * s,
                    dy = -sin(a) * s,
                    t = 120
                }
            )
        end
        s = 2
    end
})