modes.test = class:new({
    mouse = {},
    x = 10,
    y = 10,
    init = function(_ENV)
        poke(0x5f2d, 1)
        local l = stat(34) & 1 > 0
        local r = stat(34) & 2 > 0
        mouse = { left = { down = l, active = l }, right = { down = r, active = r } }
    end,
    update = function(_ENV)

-- ⬅️➡️⬆️⬇️🅾️❎

        if stat(34) & 1 > 0 then
            mouse.left.active = not mouse.left.down
            mouse.left.down = true
        else
            mouse.left = { down = false, active = false }
        end
        if stat(34) & 2 > 0 then
            mouse.right.active = not mouse.right.down
            mouse.right.down = true
        else
            mouse.right = { down = false, active = false }
        end

        -- if btn(⬅️)

    end,
    draw = function(_ENV)

    end
})