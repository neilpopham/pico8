ball = item:new({
    -- dir = 1,
    -- dx = 0,
    -- dy = 0,
    state = 1,
    dt = 120,
    -- start = { dx = 0, dy = 0, x = 0, y = 0 },
    init = function(_ENV)
        super(_ENV)
        py += 1
        rotate(_ENV, 2)
        start = { dx, dy, px, py, dir }
    end,
    reset = function(_ENV)
        state = 1
        dx, dy, px, py, dir = unpack(start)
        for e in all(mode.entities) do
            e.active = true
        end
    end,
    update = function(_ENV)
        if state == 1 then
            dt -= 1
            if dt == 0 then
                state = 2
                dt = 120
            end
            return
        end
        -- if not active then return end
        px += dx
        py += dy
        if px > 127 or px < -3 or py > 127 or py < -3 then
            -- state = 1
            reset(_ENV)
            return
        end
        for e in all(mode.entities) do
            if e.active and e.s != 6 then
                if aabb(px, py, px + 4, py + 4, e.px, e.py, e.px + 6, e.py + 6) then
                    e:collide(_ENV)
                end
            end
        end
    end,
    draw = function(_ENV)
        -- if not active then return end
        spr(s, px, py)
    end,
    rotate = function(_ENV, d)
        local offsets = { { 0, -1 }, { 1, 0 }, { 0, 1 }, { -1, 0 } }
        if d == 5 then d = 1 end
        dir = d
        dx, dy = unpack(offsets[d])
    end
})