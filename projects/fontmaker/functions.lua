function lpad(x, n)
    n = n or 2
    return sub("0000000" .. x, -n)
end

function aabb(x1, y1, x2, y2, x3, y3, x4, y4)
    return x1 < x4 and x2 > x3 and y1 < y4 and y2 > y3
end

function save_font()
    local adjustments = 0
    local offsets = 0
    for c = 16, 255 do
        -- store character bytes
        local bytes = char[c].grid:get_bytes()
        for i, v in ipairs(bytes) do
            poke(0x5600 + c * 8 + i - 1, v)
        end
        -- store width and offset adjustments in nibbles
        local font_width = c < 128 and state.width1 or state.width2
        local width = char[c].grid.empty and font_width or char[c].width
        local adjust = mid(-4, width - font_width, 3)
        local nibble = adjust < 0 and (8 + adjust) or adjust
        if nibble > 0 then
            adjustments = 1
        end
        if char[c].raise then nibble += 8 end
        if c % 2 == 0 then
            offsets = nibble
        else
            offsets += (nibble << 4)
            poke(0x5608 + c \ 2 - 8, offsets)
            offsets = 0
        end
    end
    poke(0x5600, state.width1)
    poke(0x5601, state.width2)
    poke(0x5602, state.height)
    poke(0x5603, state.offsetx)
    poke(0x5604, state.offsety)
    poke(0x5605, adjustments + (state.relative and 2 or 0))
    poke(0x5606, state.tab)
end