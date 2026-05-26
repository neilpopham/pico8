portal = entity:new({
    init = function(_ENV)
        entity.init(_ENV)
        y = 56
    end,
    update = function(_ENV)
        if s == 1 then
            for i = 0, 3 do
                local cx = x + i * 8
                if plr.x + 4 >= cx and plr.x <= cx + 3 then
                    local v = (1 << 3 -   i)
                    for i = 1, 2 do
                        local item = inv.items[i]
                        if item and item.type == types.stone and colour_values[item.c] == v then
                            -- _G.msg = '\f3🅾️\fd use \f' .. hex(item.c) .. colour_names[item.c] .. '\fd stone'
                            if btnp(🅾️) then
                                inv:use(i, cx)
                            end
                            _G.msg = action_msg('use', item.c, type_names[types.stone])
                        end
                    end
                end
            end
        end
    end,
    draw = function(_ENV)
        for i = 0, 3 do
            -- printh(sp)
            -- printh(x + i * 8)
            -- printh(y + 32)
            spr(sp, x + i * 8, y + 32)
        end
    end
})