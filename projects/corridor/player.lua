player = class:new({
    x = nil,
    y = nil,
    init = function(_ENV)
        x, y = 256, 48
    end,
    update = function(_ENV)
        local dx = 0
        if btn(0) then dx = -2 end
        if btn(1) then dx = 2 end
        x += dx
    end,
    draw = function(_ENV)
        spr(48, x, y + 32)
    end
})