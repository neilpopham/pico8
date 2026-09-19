pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
printh('============')
--[[
There are 256 characters mapped to each of the 256 P8SCII codes. Each character consists of 8 bytes for each of its 8 rows of pixels, with the first byte being the top-most row, for a total of 2 KB (256 * 8 = 2048 bytes). Each byte consists of 8 pixels, with the left-most pixel in the LSB (bit 0, value 1), and the right-most pixel in the MSB (bit 7, value 128). This is reverse from the binary representation.

Since characters 0..15 are never drawn, their data in memory is purposed by PICO-8 to store default attributes for the font. From the manual:

0x5600 character width in pixels (can be more than 8, but only 8 pixels are drawn)
0x5601 character width for character 128 and above
0x5602 character height in pixels
0x5603 draw offset x
0x5604 draw offset y
0x5605 flags: 0x1 apply_size_adjustments  0x2: apply tabs relative to cursor home
0x5606 tab width in pixels (used only when alt font is drawn)
0x5607 unused

The remaining 120 bytes are used to adjust the width and vertical offset of characters 16..255. Each nibble (low nibbles first) describes the adjustments for one characters:

bits 0x7: adjust character width by 0,1,2,3,-4,-3,-2,-1
bit  0x8: when set, draw the character one pixel higher (useful for latin accents)

font
====
width 1
width 2
height
draw offset x
draw offset y
apply size adjustments (could be determined by width adjust)
apply tabs relative
tab width

character
width adjust
raise 1px

]]
-- palette
poke(0x5f2e, 1)
pal({ [0] = 0, 1, -15, -16, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 }, 1)
-- mouse
poke(0x5f2d, 0x3)

function lpad(x, n)
    n = n or 2
    return sub("0000000" .. x, -n)
end

function aabb(x1, y1, x2, y2, x3, y3, x4, y4)
    return x1 < x4 and x2 > x3 and y1 < y4 and y2 > y3
end

function isset(x, y)
    return data[current] and data[current][y] and data[current][y][x] == 1
end

function setdata(x, y, v)
    if not data[current] then
        data[current] = {}
    end
    if not data[current][y] then
        data[current][y] = {}
    end
    data[current][y][x] = v
end

function get_width()
    return current < 128 and font.width1 or font.width2
end

function get_adjustment(v)
    return v - get_width()
end

current = 16
data = {}
local l = stat(34) & 1 > 0
local r = stat(34) & 2 > 0
mouse = {
    x = 0,
    y = 0,
    cx = 0,
    cy = 0,
    left = { down = l, active = l },
    right = { down = r, active = r },
    dt = 0,
    delay = 60
}
bool = nil
cursor = { chr = 18, col = 7 }
font = { width1 = 5, width2 = 8, height = 7 }
char = {}
for i = 16, 255 do
    char[i] = { adjustment = 0, raise = nil }
end
clip = {}
spinners = {
    { x = 67, y = 12, v = current, min = 16, max = 255, width = 3, label = 'char' },
    { x = 67, y = 30, v = 5, min = 1, max = 8, width = 2, label = 'width' },
    { x = 0, y = 84, v = 5, min = 1, max = 8, width = 2, label = 'width1' },
    { x = 48, y = 84, v = 8, min = 1, max = 8, width = 2, label = 'width2' },
    { x = 96, y = 84, v = 7, min = 1, max = 8, width = 2, label = 'height' },
    { x = 0, y = 102, v = 0, min = 0, max = 8, width = 2, label = 'offsetx' },
    { x = 48, y = 102, v = 0, min = 0, max = 8, width = 2, label = 'offsety' },
    { x = 96, y = 102, v = 5, min = 1, max = 8, width = 2, label = 'tab' }
}
for s in all(spinners) do
    s.ix = s.x + 6 + s.width * 4
end
checkboxes = {
    { x = 122, y = 40, checked = false, label = 'raise' }
}

function set_current(v)
    if v < 16 or v > 255 then return end
    current = v
    local width = current < 128 and font.width1 or font.width2
    width += char[current].adjustment
    set_spinner('char', current)
    set_spinner('width', width)
    set_checkbox('raise', char[current].raise)
end

function update_mouse()
    mouse.x = stat(32)
    mouse.y = stat(33)
    local width, height = get_dimensions()
    mouse.cx = (mouse.x >= 0 and mouse.x < width * 8 - 1) and mouse.x \ 8 + 1 or nil
    mouse.cy = (mouse.y >= 0 and mouse.y < height * 8 - 1) and mouse.y \ 8 + 1 or nil
    if stat(34) & 1 > 0 then
        mouse.left.active = not mouse.left.down
        mouse.left.down = true
    else
        mouse.left = { down = false, active = false }
        mouse.delay = 60
    end
    if stat(34) & 2 > 0 then
        mouse.right.active = not mouse.right.down
        mouse.right.down = true
    else
        mouse.right = { down = false, active = false }
    end
    if mouse.left.active then mouse.dt = 0 end
    mouse.dt += 1
end

function check_keyboard()
    local width, height = get_dimensions()
    if stat(30) then
        local k = stat(31)
        local v = ord(k)
        printh(k)
        printh(#k)
        printh(ord(k))
        -- previous character
        if k == 'q' then
            set_current(current - 1)
            -- next character
        elseif k == 'w' then
            set_current(current + 1)
            -- copy character
        elseif v == 194 then
            for y = 1, height do
                clip[y] = {}
                for x = 1, width do
                    clip[y][x] = isset(x, y) and 1 or nil
                end
            end
            -- paste character
        elseif v == 213 then
            if not clip then return end
            for y = 1, height do
                if clip[y] then
                    for x = 1, width do
                        setdata(x, y, clip[y][x] and 1 or nil)
                    end
                end
            end
            -- flip horizontally
        elseif k == 'f' or k == 'h' then
            local tmp = {}
            for y = 1, height do
                tmp[y] = {}
                for x = 1, width do
                    tmp[y][x] = isset(x, y) and 1 or nil
                end
            end
            for x = 1, width do
                for y = 1, height do
                    setdata(x, y, tmp[y][width - x + 1])
                end
            end
            -- flip vertically
        elseif k == 'v' then
            local tmp = {}
            for y = 1, height do
                tmp[y] = data[current][y]
            end
            for y = 1, height do
                data[current][y] = tmp[height - y + 1]
            end
        end
    end

    -- left
    if btnp(0) then
        tmp = {}
        for y = 1, height do
            tmp[y] = isset(1, y) and 1 or nil
        end
        for x = 1, width - 1 do
            for y = 1, height do
                setdata(x, y, isset(x + 1, y) and 1 or nil)
            end
        end
        for y = 1, height do
            setdata(width, y, tmp[y])
        end
        -- right
    elseif btnp(1) then
        tmp = {}
        for y = 1, height do
            tmp[y] = isset(width, y) and 1 or nil
        end
        for x = width, 2, -1 do
            for y = 1, height do
                setdata(x, y, isset(x - 1, y) and 1 or nil)
            end
        end
        for y = 1, height do
            setdata(1, y, tmp[y])
        end
        -- up
    elseif btnp(2) then
        local tmp = data[current][1]
        for y = 1, height - 1 do
            data[current][y] = data[current][y + 1]
        end
        data[current][height] = tmp
        -- down
    elseif btnp(3) then
        local tmp = data[current][height]
        for y = height, 2, -1 do
            data[current][y] = data[current][y - 1]
        end
        data[current][1] = tmp
    end
end

function check_grid()
    if mouse.cx and mouse.cy then
        if mouse.left.active then
            printh('here')
            bool = isset(mouse.cx, mouse.cy) and 0 or 1
            printh(bool)
        end

        if mouse.left.down then
            if not data[current] then
                data[current] = {}
            end
            if not data[current][mouse.cy] then
                data[current][mouse.cy] = {}
            end
            data[current][mouse.cy][mouse.cx] = bool
        end

        cursor = { chr = 31, col = 12, ox = -1, oy = -1 }
    elseif mouse.x < 0 or mouse.y < 0 or mouse.x > 127 or mouse.y > 127 then
        cursor = { chr = 0, col = 0, ox = 0, oy = 0 }
    else
        cursor = { chr = 18, col = 7, ox = -1, oy = -2 }
    end
end

function check_spinners()
    local active = mouse.left.active
    if mouse.left.down and mouse.dt % mouse.delay == 0 then
        active = true
        if mouse.delay == 60 then mouse.delay = 15 end
    end
    for s in all(spinners) do
        s.inc = false
        s.dec = false
        local ix, v, hit, click = s.x + 6 + s.width * 4
        if aabb(mouse.x - 1, mouse.y - 1, mouse.x + 1, mouse.y + 1, s.x, s.y, s.x + 2, s.y + 4) then
            hit = true
            s.dec = true
            if active then
                v = -1
            end
            if mouse.right.active then
                v = -10
            end
        end
        if aabb(mouse.x - 1, mouse.y - 1, mouse.x + 1, mouse.y + 1, ix, s.y, ix + 2, s.y + 4) then
            hit = true
            s.inc = true
            if active then
                v = 1
            end
            if mouse.right.active then
                v = 10
            end
        end
        if v then
            s.v = mid(s.min, s.v + v, s.max)
            click = true
        end
        if hit then
            -- cursor = { chr = 19, col = 10, ox = -1, oy = -2 }
            cursor = { chr = 94, col = 10, ox = -1, oy = 0 }
            -- cursor.chr = 0
            -- cursor = { chr = 27, col = 10, ox = -1, oy = -2 }
        end
        if click then
            if s.label == 'char' then
                set_current(s.v)
            elseif s.label == 'width' then
                char[current].adjustment = get_adjustment(s.v)
                for x = s.v + 1, 8 do
                    for y = 1, 8 do
                        setdata(x, y, nil)
                    end
                end
            elseif s.label == 'width1' then
                font.width1 = s.v
                -- set_spinner('width', s.v)
                -- if current < 128 then
                --     local adjustment = char[current].adjustment
                --     -- local width = get_spinner('width')
                --     char[current].adjustment = font.width1 - adjustment
                -- end

                -- char[current].adjustment = get_adjustment(s.v)

                -- local width = current < 128 and font.width1 or font.width2
                -- width += char[current].adjustment
                -- set_spinner('width', width)
            elseif s.label == 'width2' then
                font.width2 = s.v
            elseif s.label == 'height' then
                font.height = s.v
            elseif s.label == 'offsetx' then
            elseif s.label == 'offsety' then
            elseif s.label == 'tab' then
            end
        end
    end
end

function set_spinner(label, v)
    for s in all(spinners) do
        if s.label == label then
            s.v = v
            break
        end
    end
end

function check_checkboxes()
    local hit
    for c in all(checkboxes) do
        local click
        if aabb(mouse.x - 1, mouse.y - 1, mouse.x + 1, mouse.y + 1, c.x, c.y, c.x + 4, c.y + 4) then
            hit = true
            if mouse.left.active then
                c.checked = not c.checked
                click = true
            end
        end
        if hit then
            cursor = { chr = 27, col = 10, ox = -1, oy = -2 }
        end
        if click then
            if c.label == 'raise' then
                char[current].raise = c.checked and 1 or nil
                printh(char[current].raise)
            end
        end
    end
end

function set_checkbox(label, v)
    for c in all(checkboxes) do
        if c.label == label then
            c.checked = v and true or false
            break
        end
    end
end

function _update60()
    update_mouse()
    check_keyboard()
    check_grid()
    check_spinners()
    check_checkboxes()
end

function get_dimensions()
    local width = current < 128 and font.width1 or font.width2
    width += char[current].adjustment
    return width, font.height
end

function _draw()
    cls()

    local width, height = get_dimensions()

    rectfill(0, 0, width * 8 - 2, height * 8 - 2, 2)
    for y = 0, 7 do
        for x = 0, 7 do
            local dx, dy, c = x + 1, y + 1, 1
            if isset(dx, dy) then
                c = 7
            elseif dy > height or dx > width then
                c = 3
            end
            rectfill(x * 8, y * 8, x * 8 + 6, y * 8 + 6, c)
        end
    end

    for s in all(spinners) do
        print('\022', s.x, s.y, s.dec and 9 or 5)
        print(lpad(s.v, s.width), s.x + 5, s.y, 7)
        print('\023', s.x + 6 + s.width * 4, s.y, s.inc and 9 or 5)
    end

    for c in all(checkboxes) do
        rect(c.x, c.y, c.x + 4, c.y + 4, c.checked and 6 or 5)
        if c.checked then
            rectfill(c.x + 1, c.y + 1, c.x + 3, c.y + 3, 8)
        end
    end

    print('\^w\^t' .. chr(current), 70, 0, 7)
    -- print(lpad(current, 3), 67, 12, 5)
    print('width', 67, 22, 6)
    print('raise 1px', 67, 40, 6)

    print('font settings', 0, 67, 5)

    print('width 1', 0, 76, 6)
    print('width 2', 48, 76, 6)
    print('height', 96, 76, 6)

    print('x offset', 0, 94, 6)
    print('y offset', 48, 94, 6)
    print('tab', 96, 94, 6)

    print('relative tabs', 0, 112, 6)

    print(chr(cursor.chr), mouse.x + cursor.ox, mouse.y + cursor.oy, cursor.col)
end
