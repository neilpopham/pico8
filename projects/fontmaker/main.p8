pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
printh('============')

-- palette
poke(0x5f2e, 1)
pal({ [0] = 0, 1, -15, -16, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 }, 1)

-- mouse and keyboard input
poke(0x5f2d, 0x3)

--constants
repeat_initital = 15
repeat_delay = 4

-- globals
cursor = { chr = 18, col = 7, ox = -1, oy = -2 }
font = { width1 = 5, width2 = 8, height = 7 }
clip = {}

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
        width1 = create_spinner(state, 'width1', 'width1', 0, 84, 2, 1, 8),
        width2 = create_spinner(state, 'width2', 'width2', 48, 84, 2, 1, 8),
        height = create_spinner(state, 'height', 'height', 96, 84, 2, 1, 8),
        offsetx = create_spinner(state, 'offsetx', 'offset x', 0, 102, 2, 0, 8),
        offsety = create_spinner(state, 'offsety', 'offset y', 48, 102, 2, 0, 8),
        tab = create_spinner(state, 'tab', 'tab', 0, 120, 2, 0, 8)
    }
    checkboxes = {
        raise = create_checkbox(state.current, 'raise', 'raise 1px', 67, 50),
        relative = create_checkbox(state, 'relative', 'relative', 48, 120)
    }
    spinners.index.val = function(self, value)
        state.current = char[self:clamp(value)]
        self.src = state.current
        spinners.width.src = state.current
        checkboxes.raise.src = state.current
        if state.current.grid.empty then
            state.current.width = state.width1
        end
    end
    function update_width(value)
        if state.current.grid.empty then
            state.current.width = value
        end
    end
    spinners.width1.val = function(self, value)
        state.width1 = self:clamp(value)
        update_width(state.width1)
    end
    spinners.width2.val = function(self, value)
        state.width2 = self:clamp(value)
        update_width(state.width2)
    end
end

function _update()
    cursor = { chr = 18, col = 7, ox = -1, oy = -2 }
    check_keyboard()
    check_mouse()
    check_controller()
    state.current.grid:update()
    for _, spinner in pairs(spinners) do
        spinner:update()
    end
    for _, checkbox in pairs(checkboxes) do
        checkbox:update()
    end

    if btn(4) then
        save_font()
    end

    -- poke(0x5600, state.width1)
    -- poke(0x5601, state.width2)
    -- poke(0x5602, state.height)
    -- poke(0x5603, state.offsetx)
    -- poke(0x5604, state.offsety)
    -- poke(0x5605, 1 + (state.relative and 2 or 0))
    -- poke(0x5606, state.tab)
    -- for c = 16, 255 do
    --     local bytes = char[c].grid:get_bytes()

    --     for i, v in ipairs(bytes) do
    --         poke(0x5600 + c * 8 + i - 1, v)
    --     end

    --     local width = c < 128 and state.width1 or state.width2
    --     local adjust = mid(-4, char[c].width - width, 3)
    --     local bp = adjust < 0 and (8 + adjust) or adjust
    --     local b = 1 << (bp - 1)
    --     if char[c].raise then b += 128 end
    --     poke(0x508 + (c - 16), b)
    -- end
end

function _draw()
    cls()
    for _, spinner in pairs(spinners) do
        spinner:draw()
    end
    for _, checkbox in pairs(checkboxes) do
        checkbox:draw()
    end
    state.current:draw(0, 0)
    -- rectfill(70, 0, 85, 11, 3)
    rectfill(70,0,state.current.index < 128 and 77 or 85,11,2)
    print('\^w\^t' .. chr(state.current.index), 70, 0, 7)
    print(chr(cursor.chr), mouse.x + cursor.ox, mouse.y + cursor.oy, cursor.col)

    -- print(mouse.cx, 0, 4, 7)
    -- print(mouse.cy, 0, 11, 7)
    print("\14abcd", 100, 120, 7)
end
