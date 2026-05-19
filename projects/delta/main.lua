-- poke(0x5f2e,1)
-- pal({[0]=-16,-11,2,3,4,5,6,-10,8,9,10,11,12,13,14,15},1)

_G = _ENV

class = setmetatable(
    {
        new = function(_ENV, tbl)
            return setmetatable(tbl or {}, { __index = _ENV })
        end
    },
    { __index = _ENV }
)

colours = { 8, 10, 11, 12 }

modes = {}

menuitem(
    1,
    'play mode',
    function(b)
        mode = mode == modes.edit and modes.play or modes.edit
        mode:init()
        menuitem(nil, (mode == modes.edit and 'play' or 'edit') .. ' mode')
        if b < 4 then
            return true
        end
    end
)