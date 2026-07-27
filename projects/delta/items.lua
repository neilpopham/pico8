item = class:new({
    px = 0,
    py = 0,
    active = true,
    super = function(_ENV)
        px = (x - 1) * 6 + 1
        py = (y - 1) * 6 + 1
    end,
    update = function(_ENV) end,
    draw = function(_ENV)
        spr(s, px, py)
    end
})

corner = item:new({
    count = 0,
    disolves = false,
    accepts = function(d)
        local m = {
            { [1] = 2, [4] = 3 },
            { [1] = 4, [2] = 3 },
            { [3] = 4, [2] = 1 },
            { [3] = 2, [4] = 1 }
        }
        return m[d]
    end,
    init = function(_ENV)
        super(_ENV)
    end,
    update = function(_ENV) end,
    -- draw = function(_ENV)
    --     spr(s, px, py)
    -- end,
    collide = function(_ENV, ball)
        if count > 0 then
            count -= 1
            return
        end
        local acc = accepts(dir)
        for from, to in pairs(acc) do
            if from == ball.dir then
                if ball.px == px + 1 and ball.py == py + 1 then
                    ball:rotate(to)
                    count = 4
                    if disolves then active = false end
                end
                return
            end
        end
        ball.active = false
    end
})

portal = item:new({
    sibling = nil,
    init = function(_ENV)
        super(_ENV)
    end,
    update = function(_ENV) end,
    draw = function(_ENV)
        pal(15, colours[m], 0)
        spr(s, px, py)
    end,
    collide = function(_ENV, ball)
        local offsets = { { 1, -4 }, { 6, 1 }, { 1, 6 }, { -4, 1 } }
        -- ball.dir = sibling.dir
        ball:rotate(sibling.dir)
        ball.px = sibling.px + offsets[sibling.dir][1]
        ball.py = sibling.py + offsets[sibling.dir][2]
    end
})

entrance = item:new({
    init = function(_ENV)
        super(_ENV)
    end,
    update = function(_ENV) end,
    -- draw = function(_ENV)
    --     spr(s, px, py)
    -- end,
    collide = function(_ENV, ball)
        ball:reset()
    end
})

exit = item:new({
    init = function(_ENV)
        super(_ENV)
    end,
    update = function(_ENV) end,
    -- draw = function(_ENV)
    --     spr(s, px, py)
    -- end,
    collide = function(_ENV, ball)
        local reset = false
        for e in all(mode.entities) do
            if e.s == 12 and e.active then
                reset = true
            end
        end
        if reset then
            ball:reset()
            return
        end
        stop()
    end
})

bug = item:new({
    init = function(_ENV)
        super(_ENV)
    end,
    update = function(_ENV) end,
    -- draw = function(_ENV)
    --     spr(s, px, py)
    -- end,
    collide = function(_ENV, ball)
        active = false
    end
})

block = item:new({
    init = function(_ENV)
        super(_ENV)
    end,
    update = function(_ENV) end,
    -- draw = function(_ENV)
    --     spr(s, px, py)
    -- end,
    collide = function(_ENV, ball)
        ball:reset()
    end
})