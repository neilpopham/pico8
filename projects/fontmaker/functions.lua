function lpad(x, n)
    n = n or 2
    return sub("0000000" .. x, -n)
end

function aabb(x1, y1, x2, y2, x3, y3, x4, y4)
    return x1 < x4 and x2 > x3 and y1 < y4 and y2 > y3
end

function check_shortcuts()
    if key.key == 'q' then
        -- previous character
        spinners.index:decrease()
    elseif key.key == 'w' then
        -- next character
        spinners.index:increase()
    elseif key.key == 'c' and key.ctrl then
        -- copy character
        for y = 1, state.height do
            clip[y] = {}
            for x = 1, state.current.width do
                clip[y][x] = state.current.grid:get(x, y)
            end
        end
    elseif key.key == 'v' and key.ctrl then
        -- paste character
        if not clip then return end
        for y = 1, state.height do
            if clip[y] then
                for x = 1, state.current.width do
                    state.current.grid:set(x, y, clip[y][x])
                end
            end
        end
    elseif key.key == 'f' or key.key == 'h' then
        -- flip horizontally
        local tmp = {}
        for y = 1, state.height do
            tmp[y] = {}
            for x = 1, state.current.width do
                tmp[y][x] = state.current.grid:get(x, y)
            end
        end
        for x = 1, state.current.width do
            for y = 1, state.height do
                state.current.grid:set(x, y, tmp[y][state.current.width - x + 1])
            end
        end
    elseif key.key == 'v' then
        -- flip vertically
        local tmp = {}
        for y = 1, state.height do
            tmp[y] = {}
            for x = 1, state.current.width do
                tmp[y][x] = state.current.grid:get(x, y)
            end
        end
        for y = 1, state.height do
            for x = 1, state.current.width do
                state.current.grid:set(x, y, tmp[state.height - y + 1][x])
            end
        end
    end

    if btnp(0) then
        -- left
        local tmp = {}
        for y = 1, state.height do
            tmp[y] = {}
            for x = 1, state.current.width do
                tmp[y][x] = state.current.grid:get(x, y)
            end
        end
        for x = 1, state.current.width - 1 do
            for y = 1, state.height do
                state.current.grid:set(x, y, tmp[y][x + 1])
            end
        end
        for y = 1, state.height do
            state.current.grid:set(state.current.width, y, tmp[y][1])
        end
    elseif btnp(1) then
        -- right
        local tmp = {}
        for y = 1, state.height do
            tmp[y] = {}
            for x = 1, state.current.width do
                tmp[y][x] = state.current.grid:get(x, y)
            end
        end
        for x = state.current.width, 2, -1 do
            for y = 1, state.height do
                state.current.grid:set(x, y, tmp[y][x - 1])
            end
        end
        for y = 1, state.height do
            state.current.grid:set(1, y, tmp[y][state.current.width])
        end
    elseif btnp(2) then
        -- up
        local tmp = {}
        for y = 1, state.height do
            tmp[y] = {}
            for x = 1, state.current.width do
                tmp[y][x] = state.current.grid:get(x, y)
            end
        end
        for y = 1, state.height - 1 do
            for x = 1, state.current.width do
                state.current.grid:set(x, y, tmp[y + 1][x])
            end
        end
        for x = 1, state.current.width do
            state.current.grid:set(x, state.height, tmp[1][x])
        end
    elseif btnp(3) then
        -- down
        local tmp = {}
        for y = 1, state.height do
            tmp[y] = {}
            for x = 1, state.current.width do
                tmp[y][x] = state.current.grid:get(x, y)
            end
        end
        for y = state.height, 2, -1 do
            for x = 1, state.current.width do
                state.current.grid:set(x, y, tmp[y - 1][x])
            end
        end
        for x = 1, state.current.width do
            state.current.grid:set(x, 1, tmp[state.height][x])
        end
    end
end

function save_adjustments()
    local adjustments = 0
    local offsets = 0
    for c = 16, 255 do
        local nibble = char[c]:get_nibble()
        if nibble > 0 then adjustments = 1 end
        if c % 2 == 0 then
            offsets = nibble
        else
            offsets += (nibble << 4)
            poke(0x5608 + c \ 2 - 8, offsets)
            offsets = 0
        end
    end
    poke(0x5605, adjustments + (state.relative and 2 or 0))
end

function save_font()
    local s = 'poke(0x5600,unpack(split"'
    for i = 0, 0x800 do
        s ..= peek(0x5600 + i) .. (i < 0x800 and "," or "")
    end
    s ..= '"))'
    printh(s, '@clip')
end