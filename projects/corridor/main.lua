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
    s = 1,
    t = 0,
    x = 0,
    y = 0,
    in_range = function(_ENV)
        return s == 1 and plr.x + 7 >= x and plr.x <= x + 7
    end
})

colours = {8, 9, 11, 12}
colour_names = {[8] = 'ember', [9] = 'orange', [11] = 'lime', [12] = 'sky'}

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