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

function make_button(bit, down)
    return {
        bit = bit,
        down = down,
        active = down,
        dt = 0,
        delay = repeat_initital,
        clicked = function(self)
            return self.active and self.delay == repeat_initital
        end
    }
end

function check_button(button)
    if stat(34) & button.bit > 0 then
        button.active = not button.down
        button.down = true
    else
        button.down = false
        button.active = false
        button.delay = repeat_initital
    end
    button.dt += 1
    if button.down and button.dt % button.delay == 0 then
        button.active = true
        if button.delay == repeat_initital then
            button.delay = repeat_delay
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
    mouse.cx = (mouse.x >= 0 and mouse.x < state.current.width * 8 - 1) and mouse.x \ 8 + 1 or nil
    mouse.cy = (mouse.y >= 0 and mouse.y < state.height * 8 - 1) and mouse.y \ 8 + 1 or nil
end

function check_controller()
    if btn(0) then
        -- horizontal_shift(-1)
    end
    if btn(1) then
        -- horizontal_shift(1)
    end
    if btn(2) then
        -- vertical_shift(-1)
    end
    if btn(3) then
        -- vertical_shift(1)
    end
    if btn(4) then
        -- next_char()
    end
    if btn(5) then
        -- prev_char()
    end
end