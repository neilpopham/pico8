_G = _ENV

class = setmetatable(
    {
        new = function(_ENV, tbl)
            return setmetatable(tbl or {}, { __index = _ENV })
        end
    },
    { __index = _ENV }
)

entity = class:new({
    idx = 0,
    s = 1,
    t = 0,
    x = 0,
    y = 0,
    sp = 0,
    init = function(_ENV)
        y = 42
        -- 8192  -- 0010 0000 0000 0000
        -- 16384 -- 0100 0000 0000 0000
        -- 24576 -- 0110 0000 0000 0000
        local v = dget(idx)
        x = v == 0 and ox or v & 8191
        s = v == 0 and 1 or (v & 24576) >> 13
        -- printh('idx '..idx)
        -- printh('dget '..dget(idx))
        -- printh('x '..x)
        -- printh('s '..s)
        cartset(_ENV)
    end,
    drop = function(_ENV, nx)
        s, x, t = 1, nx, 10
        cartset(_ENV)
    end,
    cartset = function(_ENV)
        dset(idx, x + (s << 13))
    end,
    in_range = function(_ENV)
        return s == 1 and plr.x + 7 >= x and plr.x <= x + 7
    end
})

colours = {[0] = 8, 9, 11, 12}
colour_names = {[8] = 'ember', [9] = 'orange', [11] = 'lime', [12] = 'sky'}
colour_values = {[8] = 8, [9] = 4, [11] = 2, [12] = 1}
types = {card = 1, stone = 2}
type_names = {'card', 'stone'}

cartdata('corridor_v1')

menuitem(
    1,
    'new game',
    function()
        memset(0x5e00,0,256)
        stage = stages.game
        stage:init()
    end
)

function _init()
    stage = stages.game
    stage:init()
end

function _update60()
    stage:update()
end

function _draw()
    stage:draw()
end