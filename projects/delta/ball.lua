ball = item:new({
    dir = 1,
    dx = 0,
    dy = 0,
    init = function(_ENV)
        super(_ENV)
        py += 1
        rotate(_ENV, 2)
    end,
    update = function(_ENV)
        if not active then return end
        px += dx
        py += dy
        for e in all(mode.entities) do
            if e.s != 6 then
                if aabb(px, py, px + 4, py + 4, e.px, e.py, e.px + 6, e.py + 6) then
                    e:collide(_ENV)
                end
            end
        end
    end,
    draw = function(_ENV)
        if not active then return end
        spr(s, px, py)
    end,
    rotate = function(_ENV, d)
        local offsets = { {0, -1}, {1, 0}, {0, 1}, {-1, 0} }
        if d == 5 then d = 1 end
        dir = d
        dx, dy = unpack(offsets[d])
    end
})