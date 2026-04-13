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