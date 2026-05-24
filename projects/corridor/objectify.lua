entities = {}

dummy = function(x, y, flags) return nil end

function getx(tx, ty) return (ty \ 8 * 1024) + (tx * 8) end
function getc(flags) return colours[flags & 7] end

-- Flags 0-3 colour
-- Flags 4-7 index
make_door = function(x, y, flags)
    return door:new({ox = getx(x, y), c = getc(flags), idx = flags & 240})
end

make_card = function(x, y, flags)
    return card:new({ox = getx(x, y), c = getc(flags)})
end

make_stone = function(x, y, flags)
    return stone:new({ox = getx(x, y), c = getc(flags)})
end

make_player = function(x, y, flags)
    plr = player:new({ox = getx(x, y)})
end

converters={
    [48]=make_player,
    [127]=make_door,
    [126]=make_card,
    [125]=make_stone,
}

-- Flags 0-3 to store UID
-- Flag 4 unused
-- Flag 5 unused
-- Flag 6 for visibility. 0: Visible; 1: Hidden
-- Flag 7 for direction. 0: Left; 1: Right

for tile in all(split(__tif__)) do
    local x, y, s, f = unpack(split(tile, ":"))
    local entity = converters[s](x,y,f)
    if entity then
        entity:init()
        -- entity.hide = f & 64 == 64
        add(entities,entity)
    end
end