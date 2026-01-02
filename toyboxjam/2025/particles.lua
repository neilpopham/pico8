particles = {}

function create_particle(x, y)
    add(
        particles,
        class:new({
            x = x,
            y = y,
            a = rnd(),
            s = range(1, 3),
            ttl = range(10, 30),
            done = false,
            update = function(_ENV)
                x += cos(a) * s
                y -= sin(a) * s
                ttl -= 1
                if ttl == 0 then done = true end
            end,
            draw = function(_ENV)
                pset(x, y, 7)
            end
        })
    )
end

function create_dust(x, y)
    add(
        particles,
        class:new({
            x = x,
            y = y,
            a = rnd(),
            s = range(1, 6),
            c = rnd({ 7, 9, 10 }),
            ttl = range(10, 30),
            done = false,
            update = function(_ENV)
                y += 0.3 * s
                ttl -= 1
                if ttl == 0 then done = true end
            end,
            draw = function(_ENV)
                pset(x, y, c)
            end
        })
    )
end

function create_spark(x, y, as)
    add(
        particles,
        class:new({
            x = x,
            y = y,
            a = as - 0.2 + rnd() / 2,
            s = range(1, 3),
            c = rnd({ 7, 9, 10 }),
            ttl = range(5, 10),
            done = false,
            update = function(_ENV)
                x += cos(a) * s
                y -= sin(a) * s
                ttl -= 1
                if ttl == 0 then done = true end
            end,
            draw = function(_ENV)
                pset(x, y, c)
            end
        })
    )
end