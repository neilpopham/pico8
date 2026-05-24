stone = entity:new({
    x = nil,
    y = nil,
    a = 0,
    init = function(_ENV)
        x = ox
        y = 42
    end,
    update = function(_ENV)
        if s == 1 then
            a += .04
            dy = sin(a) / 2
            y += dy
            if in_range(_ENV) then
                if btn(🅾️) then
                    s = 2
                    add(plr.inv, {c = c})
                end
            end
        end
    end,
    draw = function(_ENV)
        if s == 1 then
            pal(15, c)
            spr(125, x, y + 32)
            pal()
            if in_range(_ENV) then
                print('🅾️ pick up ' .. colour_names[c] .. ' stone', 0, 100, 7)
            end

        end
    end
})