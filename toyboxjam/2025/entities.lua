makebird = function(x, y, flags)
    return bird:new({
        ox = x * 8,
        oy = y * 8,
        od = dirfrom(flags),
        cycle = { 182, 183, 184 }
    })
end

makesnake = function(x, y, flags)
    return snake:new({
        ox = x * 8,
        oy = y * 8,
        od = dirfrom(flags),
        cycle = { 104, 105 }
    })
end

makekey = function(x, y, flags)
    return key:new({
        ox = x * 8,
        oy = y * 8
    })
end

makedoor = function(x, y, flags)
    return door:new({
        ox = x * 8,
        oy = y * 8
    })
end

enemy = class:new({
    yo1 = 0,
    yo2 = 7,
    init = function(_ENV)
        x, y = ox, oy
        dir = od
        dx = 0
        frame = 1
    end,
    collide = function(_ENV)
        if player.done then return false end
        if aabb(player.x, player.y, player.x + 7, player.y + 7, x, y + yo1, x + 7, y + yo2) then
            player:hit()
        end
    end,
    draw = function(_ENV)
        spr(s, x, y, 1, 1, dir < 0)
    end
})

bird = enemy:new({
    reset = function(_ENV)
        init(_ENV)
    end,
    update = function(_ENV)
        dx = 0.5 * dir
        local hit = false
        rdx = pixel(dx)
        tx = tile(x + rdx + (rdx > 0 and 7 or 0))
        ty = tile(y)
        ti = mget(tx, ty)
        hit = fget(ti) & 3 > 0

        if hit then
            dx = 0
            dir = -dir
        end
        -- rdx = round(dx)
        x += dx
        if dt % 6 == 0 then
            frame += 1
        end
        collide(_ENV)
        -- set sprite
        s = cycle[(frame % #cycle) + 1]
    end
})

snake = enemy:new({
    reset = function(_ENV)
        init(_ENV)
        -- dx = 0.34 * dir
    end,
    update = function(_ENV)
        dx = 0.34 * dir
        local hit = false
        rdx = pixel(dx)
        tx = tile(x + rdx + (rdx > 0 and 7 or 0))
        ty = tile(y)
        ti = mget(tx, ty)
        hit = fget(ti) & 3 > 0

        if hit then
            dx = 0
            dir = -dir
        end
        -- rdx = round(dx)
        x += dx
        if dt % 6 == 0 then
            frame += 1
        end
        collide(_ENV)
        -- set sprite
        s = cycle[(frame % #cycle) + 1]
    end
})

key = class:new({
    reset = function(_ENV)
        x, y = ox, oy
        done = false
    end,
    update = function(_ENV)
        if done then return end
        if player.done then return end
        if aabb(player.x, player.y, player.x + 7, player.y + 7, x + 2, y, x + 5, y + 7) then
            done = true
            player.keys += 1
            sfx(12)
        end
    end,
    draw = function(_ENV)
        if done then return end
        spr(30, x, y)
    end
})

door = class:new({
    reset = function(_ENV)
        x, y1, y2 = ox, oy, oy
        local tx = x \ 8
        local ty = y1 \ 8
        while true do
            y2 = ty * 8
            ty += 1
            if fget(mget(tx, ty), 0) then
                break
            end
        end
        -- set to flag 2 tile to repel enemies
        mset(tx, ty - 1, 10)
        done = false
    end,
    update = function(_ENV)
        if done then return end
        if player.done then return end
        if aabb(player.x, player.y, player.x + 7, player.y + 7, x, y1, x + 7, y2 + 7) then
            if player.keys > 0 then
                done = true
                mset(x \ 8, y2 \ 8, 0)
                -- store checkpoint
                dset(data.exists, 1)
                dset(data.player_x, x + 8)
                dset(data.player_y, y2)
                -- deduct key
                player.keys -= 1
                sfx(9)
            else
                player:hit()
            end
        end
    end,
    draw = function(_ENV)
        if done then return end
        for y = y1, y2, 8 do
            spr(16, x, y)
        end
    end
})