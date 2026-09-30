pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
printh('============')

-- palette
poke(0x5f2e, 1)
pal({ [0] = 0, 1, -15, -16, -11, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 }, 1)

-- mouse and keyboard input
poke(0x5f2d, 0x3)

--constants
repeat_initital = 15
repeat_delay = 4
addresses = {
    width1 = 0x5600,
    width2 = 0x5601,
    height = 0x5602,
    offsetx = 0x5603,
    offsety = 0x5604,
    -- adjustments = 0x5605,
    tab = 0x5606
}

-- globals
cursor = { chr = 18, col = 7, ox = -1, oy = -2 }
font = { width1 = 5, width2 = 8, height = 7 }
clip = {}
cursors = {
    pointer = { chr = 94, col = 10, ox = -1, oy = 0 },
}

#include input.lua
#include grid.lua
#include functions.lua
#include controls.lua

char = {}
for i = 16, 255 do
    char[i] = {
        grid = make_grid(),
        index = i,
        width = 5,
        raise = false,
        font_width = function(self)
            return self.index < 128 and state.width1 or state.width2
        end,
        set_width = function(self, width)
            self.width = width
            self.grid:set_width(width)
            self:save_adjustment()
        end,
        get_width = function(self)
            return self.grid.empty and self:font_width() or self.width
        end,
        get_nibble = function(self)
            if self.grid.empty then return 0 end
            local adjust = mid(-4, self:get_width() - self:font_width(), 3)
            local nibble = adjust < 0 and (8 + adjust) or adjust
            if nibble > 0 then
                poke(0x5605, 1 + (state.relative and 2 or 0))
            end
            if self.raise then nibble += 8 end
            return nibble
        end,
        save_adjustment = function(self)
            local nibble = self:get_nibble()
            local addr = 0x5600 + self.index \ 2
            local shft = (self.index & 1) * 4
            local mask = 0xf << shft
            poke(addr, (peek(addr) & ~mask) | (nibble << shft))
        end,
        update = function(self)
            self.grid:update()
            if self.grid.changes and not mouse.left.down then
                self.grid.changes = false
                local bytes = self.grid:get_bytes()
                local empty = true
                for i, v in ipairs(bytes) do
                    if v > 0 then empty = false end
                    poke(0x5600 + self.index * 8 + i - 1, v)
                end
                self.grid.empty = empty
            end
        end,
        draw = function(self, x, y)
            self.grid:draw(x, y, self.width, state.height)
        end
    }
    char[i].grid:init()
end

state = {
    current = char[16],
    width1 = 5,
    width2 = 8,
    height = 7,
    offsetx = 0,
    offsety = 0,
    relative = false,
    tab = 5,
    increase = function(self)
        local i = self.current.index + 1
        self.current = char[min(i, 255)]
    end,
    decrease = function(self)
        local i = self.current.index - 1
        self.current = char[max(i, 16)]
    end
}

function _init()
    mouse = {
        x = 0,
        y = 0,
        cx = 0,
        cy = 0,
        left = make_button(1, stat(34) & 1 > 0),
        right = make_button(2, stat(34) & 2 > 0)
    }
    spinners = {
        index = create_spinner(state.current, 'index', nil, 67, 14, 3, 16, 255),
        width = create_spinner(state.current, 'width', 'width', 67, 32, 2, 1, 8),
        width1 = create_spinner(state, 'width1', 'width 1', 0, 84, 2, 1, 8),
        width2 = create_spinner(state, 'width2', 'width 2', 48, 84, 2, 1, 8),
        height = create_spinner(state, 'height', 'height', 96, 84, 2, 1, 8),
        offsetx = create_spinner(state, 'offsetx', 'offset x', 0, 102, 2, 0, 8),
        offsety = create_spinner(state, 'offsety', 'offset y', 48, 102, 2, 0, 8),
        tab = create_spinner(state, 'tab', 'tab', 0, 120, 2, 0, 8)
    }
    checkboxes = {
        raise = create_checkbox(state.current, 'raise', 'raise 1px', 67, 50),
        relative = create_checkbox(state, 'relative', 'relative', 48, 120)
    }
    buttons = {
        save = create_button('save', 109, 117)
    }
    spinners.index.val = function(self, value)
        state.current = char[self:clamp(value)]
        self.src = state.current
        spinners.width.src = state.current
        checkboxes.raise.src = state.current
        if state.current.grid.empty then
            -- local width = self.index < 128 and state.width1 or state.width2
            state.current:set_width(state.current:font_width())
        end
    end
    spinners.index.increase = function(self)
        self:val(self.src[self.prop] + 1)
    end
    spinners.index.decrease = function(self)
        self:val(self.src[self.prop] - 1)
    end
    function update_width(value)
        if state.current.grid.empty then
            state.current:set_width(value)
        end
    end
    spinners.width.val = function(self, value)
        local font_width = state.current:font_width()
        -- clamp according to font width for current char, and min/max size adjustnment values
        state.current:set_width(mid(max(0, font_width - 4), value, min(8, font_width + 3)))
    end
    spinners.width1.val = function(self, value)
        state.width1 = self:clamp(value)
        if state.current.index < 128 then
            update_width(state.width1)
        end
        save_adjustments()
    end
    spinners.width2.val = function(self, value)
        state.width2 = self:clamp(value)
        if state.current.index >= 128 then
            update_width(state.width2)
        end
        save_adjustments()
    end
    checkboxes.raise.val = function(self, value)
        self:toggle()
        state.current:save_adjustment()
    end
    checkboxes.relative.val = function(self, value)
        self:toggle()
        local adjustments = 1
        poke(0x5605, adjustments + (state.relative and 2 or 0))
    end
    buttons.save.click = function(self)
        save_font()
    end
    -- init font data
    memset(0x5600, 0, 0x800)
    poke(0x5600, state.width1)
    poke(0x5601, state.width2)
    poke(0x5602, state.height)
    poke(0x5603, state.offsetx)
    poke(0x5604, state.offsety)
    poke(0x5605, state.relative and 2 or 0)
    poke(0x5606, state.tab)

    poke(0x5600, unpack(split "6,8,6,0,0,0,5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,31,27,31,27,27,0,0,0,31,27,31,27,31,0,0,0,31,3,3,3,31,0,0,0,15,27,27,27,31,0,0,0,31,3,15,3,31,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0"))

    if peek(0x5600) > 0 and peek(0x5601) > 0 and peek(0x5602) > 0 then
        state.width1 = peek(0x5600)
        state.width2 = peek(0x5601)
        state.height = peek(0x5602)
        state.offsetx = peek(0x5603)
        state.offsety = peek(0x5604)
        state.relative = peek(0x5605) == 2
        state.tab = peek(0x5606)
        printh(state.width1)
    end
end

function _update()
    cursor = { chr = 18, col = 7, ox = -1, oy = -2 }
    check_keyboard()
    check_mouse()
    check_controller()
    check_shortcuts()
    state.current:update()
    for _, spinner in pairs(spinners) do
        spinner:update()
    end
    for _, checkbox in pairs(checkboxes) do
        checkbox:update()
    end
    for _, button in pairs(buttons) do
        button:update()
    end

    if btn(4) then
        save_font()
    end
    if btn(5) then
        save_font()
    end
end

function _draw()
    cls()
    for _, spinner in pairs(spinners) do
        spinner:draw()
    end
    for _, checkbox in pairs(checkboxes) do
        checkbox:draw()
    end
    for _, button in pairs(buttons) do
        button:draw()
    end
    state.current:draw(0, 0)
    rectfill(70, 0, state.current.index < 128 and 77 or 85, 11, 2)
    print('\^w\^t' .. chr(state.current.index), 70, 0, 7)
    print(chr(cursor.chr), mouse.x + cursor.ox, mouse.y + cursor.oy, cursor.col)

    print("\14abcde", 0, 68, 7)

    print("food", 80, 68, 7)
    print(  "|", 82, 68, 5)
end
