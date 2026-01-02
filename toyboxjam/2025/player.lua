-- ⬅️➡️⬆️⬇️🅾️❎

player = class:new({
    x = 16,
    y = 240,
    dx = 0,
    dy = 0,
    dir = 1,
    wall = 0,
    frame = 1,
    keys = 0,
    done = false,
    active = false,
    jumping = nil,
    falling = nil,
    grounded = nil,
    sliding = nil,
    cycle = nil,
    s = 128,
    rx = 0,
    ry = 0,
    -- still = { 128, 129 },
    -- run = { 144, 145, 146, 147 },
    -- jump = { 131 },
    -- fall = { 130 },
    -- die = { 132, 133, 134 },
    still = { start = 128, count = 2, loop = true },
    run = { start = 144, count = 4, loop = true },
    jump = { start = 130, count = 2, loop = false },
    fall = { start = 130, count = 1, loop = false },
    slide = { start = 162, count = 1, loop = false },
    die = { start = 132, count = 3, loop = false },
    reset = function(_ENV)
        x = 16
        y = 240
        rx = x
        ry = y
        dx = 0
        dy = 0
        wall = 0
        dir = 1
        frame = 1
        keys = 0
        done = false
        active = false
        cycle = still
        button = class:new({
            limit = { counter = 16, cayote = 2, buffer = 4 },
            down = false,
            counter = 0,
            cayote = 0,
            buffer = 0,
            update = function(_ENV)
                if btn(🅾️) or btn(❎) then
                    if not down or buffer > 0 then
                        if player.grounded or cayote > 0 or player.wall != 0 then
                            counter = limit.counter
                            buffer = 0
                            player.dy = 0
                            sfx(3)
                            if not player.grounded and player.wall != 0 then
                                local px, py = player.rx + (player.wall > 0 and 7 or 0), player.ry + 7
                                for i = 1, 4 do
                                    create_dust(px, py)
                                    create_spark(px, py, player.wall < 0 and 1 or 0.5)
                                end
                            end
                        elseif buffer == 0 then
                            buffer = limit.buffer
                        end
                    end
                    down = true
                else
                    down = false
                    counter = 0
                end
                cayote = max(0, cayote - 1)
                buffer = max(0, buffer - 1)
                counter = max(0, counter - 1)
            end,
            active = function(_ENV)
                return counter > 0
            end,
            falling = function(_ENV)
                cayote = limit.cayote
            end
        })
    end,
    hit = function(_ENV)
        done = true
        active = false
        frame = 0
        sfx(4)
    end,
    update = function(_ENV)
        local hit, tx, ty, ti

        if player.active then
            -- horizontal movement
            if btn(⬅️) then
                dx -= .3
            end
            if btn(➡️) then
                dx += .3
            end
        end

        dx = mid(dx * 0.8, -1, 1)
        if abs(dx) < 0.2 then dx = 0 end

        hit = false
        rdx = pixel(dx)
        tx = tile(x + rdx + (rdx > 0 and 7 or 0))
        for ty in all({ tile(y), tile(y + 7) }) do
            ti = mget(tx, ty)
            hit = fget(ti, 0)
            if hit then break end
        end

        if hit then
            x = (tx - sgn(dx)) * 8
            wall = sgn(dx)
            dir = -wall
            sliding = true
            dx = 0
        end

        if not player.done then
            if dx == 0 then
                if dt % 8 == 0 then
                    frame += 1
                end
                cycle = still
            else
                dir = sgn(dx)
                -- may need a counter to prevent wall from being reset too soon
                -- if dir != wall then wall = 0 end
                if dt % 6 == 0 then
                    frame += 1
                end
                cycle = run
            end
        end

        x += dx
        rx = round(x)

        if player.active then
            -- vetical movement
            button:update()
            if button:active() then
                dy -= 1
                wall = 0
            end
        end

        dy = mid(dy + 0.3, -2, 5)
        rdy = pixel(dy)
        ty = tile(y + rdy + (rdy > 0 and 7 or 0))
        for tx in all({ tile(x), tile(x + 7) }) do
            ti = mget(tx, ty)
            hit = fget(ti, 0)
            if hit then break end
        end

        if hit then
            if dy > 0 then
                grounded = true
                jumping = false
                falling = false
            else
                button.counter = 0
                falling = true
                jumping = false
                grounded = false
            end
            y = (ty - sgn(dy)) * 8
            dy = 0
            wall = 0
        end

        if dy < 0 then
            cycle = jump
            jumping = true
            falling = false
            grounded = false
        elseif dy > 0 then
            cycle = wall == 0 and fall or slide
            if grounded then
                button:falling()
            end
            falling = true
            jumping = false
            grounded = false
        end

        y += dy
        ry = round(y)

        if player.done then
            cycle = die
            if dt % 3 == 2 then
                frame += 1
            end
        end

        -- set sprite
        s = cycle.start + mid(0, frame, cycle.loop and frame % cycle.count or cycle.count - 1)
    end,
    draw = function(_ENV)
        spr(s, rx, ry, 1, 1, dir < 0)
    end
})