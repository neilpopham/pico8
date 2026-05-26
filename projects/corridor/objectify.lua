entities = {}

dummy = function(x, y, s, idx, flags) return nil end

function getx(tx, ty) return (ty \ 8 * 1024) + (tx * 8) end
function getc(flags) return colours[flags & 7] end

make_door = function(x, y, s, idx, flags)
    return door:new({ox = getx(x, y), c = getc(flags), sp = s, idx = idx})
end

make_card = function(x, y, s, idx, flags)
    return card:new({ox = getx(x, y), c = getc(flags), sp = s, idx = idx})
end

make_stone = function(x, y, s, idx, flags)
    return stone:new({ox = getx(x, y), c = getc(flags), sp = s, idx = idx})
end

make_portal = function(x, y, s, idx, flags)
    return portal:new({ox = getx(x, y), sp = s, idx = idx})
end

make_player = function(x, y, s, idx, flags)
    printh(x)
    printh(y)
    printh(s)
    printh(flags)
    plr = player:new({ox = getx(x, y), sp = s, idx = idx})
end

converters={
    [2]   = make_portal,
    [48]  = make_player,
    [127] = make_door,
    [126] = make_card,
    [125] = make_stone,
}

-- Flags 0-3 colour
-- Flags 4-7 index
for idx, tile in ipairs(split(__tif__)) do
    local x, y, s, f = unpack(split(tile, ":"))
    local entity = converters[s](x, y, s, idx, f)
    if entity then
        -- entity.idx = idx
        entity:init()
        -- entity.hide = f & 64 == 64
        add(entities, entity)
    end
end