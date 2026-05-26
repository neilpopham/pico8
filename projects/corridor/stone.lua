stone = entity:new({
    a = 0,
    type = types.stone,
    init = function(_ENV)
        entity.init(_ENV)
        -- y = 42
        -- -- 8192  -- 0010 0000 0000 0000
        -- -- 16384 -- 0100 0000 0000 0000
        -- -- 24576 -- 0110 0000 0000 0000
        -- x = dget(idx) & 8191
        -- if x == 0 then x = ox end
        -- s = dget(idx) & 24576
        -- if s == 0 then s = 1 end
        -- dset(idx, x)
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
            end
        end
    end,
    draw = function(_ENV)
        if s != 2 then
            pal(15, c)
            spr(sp, x, y + 32)
            pal()
            if in_range(_ENV) then
                _G.msg = action_msg('pick up', c, type_names[type])
            end
        end
    end,
    use = function(_ENV, nx)
        s, x, y, t = 3, nx, 20, 10
        cartset(_ENV)
    end
})
