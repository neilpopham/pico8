inventory = class:new({
    items = {nil, nil},
    idx = nil,
    init = function(_ENV)
        local dval = dget(0)
        if dval == 0 then
            items = {nil, nil}
        else
            idx = {[1] = dval & 63, [2] = (dval & 4032) >> 6}
            -- printh('idx1 =' .. idx[1])
            -- printh('idx2 =' .. idx[2])
            -- printh('dval '..dval)
            for i = 1, 2 do
                if idx[i] == 0 then
                    items[i] = nil
                else
                    local e = get_entity(_ENV, idx[i])
                    if e then
                        items[i] = e -- {idx = e.idx, sp = e.sp, c = e.c, type = e.type}
                    end
                end
            end
        end
        cartset(_ENV)
    end,
    update = function(_ENV)
    end,
    draw = function(_ENV)
        for i = 1, 2 do
            if items[i] then
                pal(15, items[i].c)
                spr(items[i].sp, (i - 1) * 10, 97)
                pal()
            end
        end
    end,
    add = function(_ENV, item)
        add(items, item, 1)
        -- printh('items ' .. #items)
        if #items == 3 then
            -- local e = get_entity(_ENV, items[3].idx)
            -- deli(items, 3)
            -- if e then e:drop(item.x) end
            items[3]:drop(item.x)
            deli(items, 3)
        end
        -- for k,v in pairs(items) do printh(k.. '=' .. v.idx) end
        -- if items[2] then
        --     local e = get_entity(_ENV, items[2].idx)
        --     if e then e:drop(item.x) end
        -- end
        -- if items[1] then
        --     items[2] = items[1] -- clone(items[1])
        -- end
        -- -- items[2] = items[1] and clone(items[1]) or nil
        -- items[1] = item -- clone(item)
        cartset(_ENV)
    end,
    use = function(_ENV, i, nx)
        items[i]:use(nx)
        items[i] = nil
        if i == 1 then
            items[1] = items[2]
        end
        items[2] = nil
        cartset(_ENV)
    end,
    get_entity = function(_ENV, idx)
        for e in all(entities) do
            if e.idx == idx then return e end
        end
        return nil
    end,
    -- contains = function(_ENV, type, v)
    --     for i = 1, 2 do
    --         local item = inv.items[i]
    --         if item and item.type == type and colour_values[item.c] == v then
    --             return i, item
    --         end
    --     end
    -- end,
    cartset = function(_ENV)
        idx = {
            items[1] and (items[1].idx) or 0,
            items[2] and (items[2].idx << 6) or 0
        }
        -- printh('setting... '..(idx[1] + idx[2]))
        -- printh('idx1 ' ..idx[1])
        -- printh('idx2 ' ..idx[2])
        dset(0, idx[1] + idx[2])
    end
})