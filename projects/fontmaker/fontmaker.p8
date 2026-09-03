pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
printh('============')
--[[
There are 256 currentacters mapped to each of the 256 P8SCII codes. Each currentacter consists of 8 bytes for each of its 8 rows of pixels, with the first byte being the top-most row, for a total of 2 KB (256 * 8 = 2048 bytes). Each byte consists of 8 pixels, with the left-most pixel in the LSB (bit 0, value 1), and the right-most pixel in the MSB (bit 7, value 128). This is reverse from the binary representation.

Since currentacters 0..15 are never drawn, their data in memory is purposed by PICO-8 to store default attributes for the font. From the manual:

0x5600 currentacter width in pixels (can be more than 8, but only 8 pixels are drawn)
0x5601 currentacter width for currentacter 128 and above
0x5602 currentacter height in pixels
0x5603 draw offset x
0x5604 draw offset y
0x5605 flags: 0x1 apply_size_adjustments  0x2: apply tabs relative to cursor home
0x5606 tab width in pixels (used only when alt font is drawn)
0x5607 unused

The remaining 120 bytes are used to adjust the width and vertical offset of currentacters 16..255. Each nibble (low nibbles first) describes the adjustments for one currentacters:

bits 0x7: adjust currentacter width by 0,1,2,3,-4,-3,-2,-1
bit  0x8: when set, draw the currentacter one pixel higher (useful for latin accents)

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
poke(0x5F2D, 0x3)

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
font = { width1 = 5, width2 = 8, height = 8 }
char = {}
for i = 16, 255 do
    char[i] = { adjustment = 0, raise = nil }
end
spinners = {
    { x = 67, y = 12, v = current, min = 16, max = 255, width = 3, label = 'char' },
    { x = 67, y = 30, v = 5, min = 1, max = 8, width = 2, label = 'width' },
    { x = 80, y = 100, v = 12, min = 0, max = 99, width = 2, label = '' },
    { x = 80, y = 110, v = 0, min = 0, max = 15, width = 2, label = 'height' }
}
for s in all(spinners) do
    s.ix = s.x + 6 + s.width * 4
end
checkboxes = {
    { x = 122, y = 40, checked = false, label = 'raise' }
}

-- char[16].adjustment = 1
-- font.height = 6

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
    if stat(30) then
        printh(stat(31))
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
        cursor.chr = 0
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
                current = s.v
                local width = current < 128 and font.width1 or font.width2
                width += char[current].adjustment
                set_spinner('width', width)
                set_checkbox('raise', char[current].raise)
            end
            if s.label == 'width' then
                char[current].adjustment = get_adjustment(s.v)
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

    -- print(mouse.cx, 100, 0, 3)
    -- print(mouse.cy, 100, 6, 3)
    -- print(mouse.left.down, 100, 12, 5)
    -- print(mouse.right.down, 100, 18, 5)
    -- print(bool, 100, 24, 6)

    -- for i = 10, 30 do
    --     print(i .. ' ' .. chr(i), (i \ 16) * 24, i % 16 * 8, 15)
    -- end
    -- print(chr(250), 80, 0, 7)

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

    print('width adjustment', 0, 66, 6)
    print('raise 1px', 7, 73, 6)

    print('\^w\^t' .. chr(current), 70, 0, 7)
    -- print(lpad(current, 3), 67, 12, 5)
    print('width', 67, 22, 6)
    print('raise 1px', 67, 40, 6)

    -- print('offsets', 66, 0, 6)
    -- print('x', 66, 7, 6)

    --     raw offset x
    -- 0x5604 draw offset y
    -- 0x5605 flags: 0x1 apply_size_adjustments  0x2: apply tabs relative to cursor home
    -- 0x5606 tab width in pixe

    -- print(chr(22) .. chr(23), 80, 20, 7)
    -- print('\')

    -- pset(stat(32), stat(33), 7)

    print(chr(cursor.chr), mouse.x + cursor.ox, mouse.y + cursor.oy, cursor.col)

    print('width 1', 0, 123, 5)
    print('8', 32, 123, 6)
    print('width 2', 48, 123, 5)
    print('8', 80, 123, 6)
    print('height', 96, 123, 5)
    print('8', 124, 123, 6)
end
