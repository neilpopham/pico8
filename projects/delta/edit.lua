modes.edit = class:new({
    sprite = nil,
    entities = {},
    items = { 1, 2, 3, 4, 5, 7, 8, 9, 10, 11, 12, 13, 17, 18, 19, 20, 16, 33, 34, 35 },
    palette = { on = false, x = 101, y = 5, h = 66 },
    x = 0,
    cx = 0,
    y = 0,
    cy = 0,
    b = 0,
    dt = 0,
    l = stat(34) & 1 > 0,
    r = stat(34) & 2 > 0,
    mouse = { left = { down = l, active = l }, right = { down = r, active = r } },
    init = function(_ENV)
        poke(0x5f2d, 1)
        sprite = 5
        for ey = 1, 21 do
            entities[ey] = {}
            for ex = 1, 21 do
                entities[ey][ex] = { 0, 1 }
            end
        end
    end,
    update = function(_ENV)
        cx = stat(32) \ 6
        cy = stat(33) \ 6
        x = cx * 6 + 1
        y = cy * 6 + 1

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

        if y < 0 then
            palette.on = true
            y = 1
        elseif palette.on and y > 6 then
            palette.on = false
        end

        if palette.on then
            if mouse.left.active then
                local s = items[cx + 1]
                if s == 16 then
                    s = sprite
                end
                if s == 35 then
                    local data = ''
                    local i = 0
                    for ey, row in pairs(entities) do
                        for ex, s in pairs(row) do
                            if s[1] > 0 then
                                data = data .. hp(ex) .. hp(ey) .. hp(s[1]) .. hp(s[2])
                                poke(0x2000 + i, ex)
                                i += 1
                                poke(0x2000 + i, ey)
                                i += 1
                                poke(0x2000 + i, s[1])
                                i += 1
                                poke(0x2000 + i, s[2])
                                i += 1
                            end
                        end
                    end
                    data = data .. 'ff'
                    poke(0x2000 + i, 255)
                    printh(data)
                    for i = 0, 4 do
                        printh(@(0x2000 + i))
                    end
                end
                sprite = s
            end
        else
            if mouse.left.active then
                local s = sprite
                local m = entities[cy + 1][cx + 1][2]
                if s == 33 then s = 0 end
                if s == 34 then
                    s = 999
                    m = (m + 1) % 4
                    entities[cy + 1][cx + 1][2] = m + 1
                end
                if s != 999 then entities[cy + 1][cx + 1] = { s, m } end
            end
        end
        dt += 1
    end,
    draw = function(_ENV)
        cls()

        for i = 1, 127, 6 do
            line(1, i, 127, i, 1)
        end
        for i = 1, 127, 6 do
            line(i, 1, i, 127, 1)
        end

        for ey, row in pairs(entities) do
            for ex, s in pairs(row) do
                if s[1] > 0 then
                    if s[1] >= 7 and s[1] <= 10 then
                        pal(15, colours[s[2]], 0)
                    end
                    spr(s[1], (ex - 1) * 6 + 1, (ey - 1) * 6 + 1)
                end
            end
        end
        pal(15, 7, 0)

        if palette.on then
            rectfill(0, 0, 127, 7, 0)
            line(1, 8, 127, 8, 2)
            for i, s in ipairs(items) do
                spr(s, (i - 1) * 6 + 1, 1)
            end
            if y > 0 then
                fillp(▒)
                rect(x, y, x + 5, y + 5, 2)
                fillp()
            end
        else
            spr(sprite, x, y)
        end
    end
})