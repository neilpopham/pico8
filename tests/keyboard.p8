pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
-- keyboard
-- by neil popham

poke(0x5f2d, 0x3)

local key
local mouse

defaults = {
    mouse = {
        delay = { 15, 4 }
    }
}

function _init()
    local l = stat(34) & 1 > 0
    local r = stat(34) & 2 > 0
    mouse = {
        x = 0,
        y = 0,
        -- cx = 0,
        -- cy = 0,
        left = { bit = 1, down = l, active = l, delay = defaults.mouse.delay[1], dt = 0 },
        right = { bit = 2, down = r, active = r, delay = defaults.mouse.delay[1], dt = 0 }
    }
end

cls()

function check_keyboard()
    key = { ctrl = false, shift = false }
    if stat(30) then
        key.key = stat(31)
        key.code = ord(key.key)
        if key.code >= 128 and key.code <= 153 then
            key.code -= 31
            key.key = chr(key.code)
            key.shift = true
        end
        if key.code >= 192 and key.code <= 217 then
            key.code -= 95
            key.key = chr(key.code)
            key.ctrl = true
        end
    end
end

function check_button(button)
    if stat(34) & button.bit > 0 then
        button.active = not button.down
        button.down = true
    else
        button.down = false
        button.active = false
        button.delay = defaults.mouse.delay[1]
    end
    button.dt += 1
    if button.down and button.dt % button.delay == 0 then
        button.active = true
        if button.delay == defaults.mouse.delay[1] then
            button.delay = defaults.mouse.delay[2]
        end
    end
    if button.active then
        button.dt = 0
    end
end

function check_mouse()
    mouse.x = stat(32)
    mouse.y = stat(33)

    check_button(mouse.left)
    check_button(mouse.right)
    -- local width, height = get_dimensions()
    -- mouse.cx = (mouse.x >= 0 and mouse.x < width * 8 - 1) and mouse.x \ 8 + 1 or nil
    -- mouse.cy = (mouse.y >= 0 and mouse.y < height * 8 - 1) and mouse.y \ 8 + 1 or nil
    -- if stat(34) & 1 > 0 then
    --     mouse.left.active = not mouse.left.down
    --     mouse.left.down = true
    -- else
    --     mouse.left.down = false
    --     mouse.left.active = false
    --     mouse.left.delay = defaults.mouse.delay[1]
    -- end
    -- if stat(34) & 2 > 0 then
    --     mouse.right.active = not mouse.right.down
    --     mouse.right.down = true
    -- else
    --     mouse.right.down = false
    --     mouse.right.active = false
    --     mouse.right.delay = defaults.mouse.delay[1]
    -- end
    -- mouse.left.dt += 1
    -- mouse.right.dt += 1
    -- if mouse.left.down and mouse.left.dt % mouse.left.delay == 0 then
    --     mouse.left.active = true
    --     if mouse.left.delay == defaults.mouse.delay[1] then
    --         mouse.left.delay = defaults.mouse.delay[2]
    --     end
    -- end
    -- if mouse.right.down and mouse.right.dt % mouse.right.delay == 0 then
    --     mouse.right.active = true
    --     if mouse.right.delay == defaults.mouse.delay[1] then
    --         mouse.right.delay = defaults.mouse.delay[2]
    --     end
    -- end
    -- if mouse.left.active then
    --     mouse.left.dt = 0
    -- end
    -- if mouse.right.active then
    --     mouse.right.dt = 0
    -- end
end

function _update60()
    check_keyboard()
    check_mouse()
end

function _draw()
    if key.key then print(key.key .. ' ' .. key.code .. (key.ctrl and ' ctrl' or '') .. (key.shift and ' shift' or '')) end
    if mouse.left.active then
        print('left click')
    end
    if mouse.right.active then
        print('right click')
    end
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
