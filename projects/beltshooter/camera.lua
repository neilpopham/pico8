cam = class:new({
    x = 0,
    y = 0,
    s = 0,
    on = true,
    draw = function(_ENV)
        local cx, cy = x + rnd(s), y + rnd(s)
        camera(cx, cy)
        s = max(0, s - .06)
    end,
    shake = function(_ENV, v)
        s = min(on and 5 or 0, s + v)
    end
})