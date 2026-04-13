player = class:new({
    x = 0,
    y = 0,
    dx = 0,
    dy = 0,
    reset = function(_ENV)
        x = 0
        y = 0
        dx = 0
        dy = 0
    end,
    update = function(_ENV)
        x += dx
        y += dy
    end,
    draw = function(_ENV)
        pset(x, y, 7)
    end
})