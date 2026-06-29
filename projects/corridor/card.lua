card = entity:new({
    a = 0,
    type = types.card,
    init = function(_ENV)
        entity.init(_ENV)
    end,
    update = function(_ENV)
        if s == 1 then
            a += .04
            dy = sin(a) / 2
            y += dy
            if t > 0 then
                t -= 1
            elseif in_range(_ENV) then
                if btnp(🅾️) then
                    s = 2
                    cartset(_ENV)
                    -- dset(x + (s<<13))
                    -- inv:add({idx = idx, x = x, sp = sp, c = c, type = type})
                    inv:add(_ENV)
                end
                action_msg('pick up', c, type_names[type])
            end
        end
    end,
    draw = function(_ENV)
        if s == 1 then
            pal(15, c)
            spr(sp, x, y + 32)
            pal()
        end
    end
})