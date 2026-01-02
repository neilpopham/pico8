entities = {}

converters = {
    [182] = makebird,
    [104] = makesnake,
    [30] = makekey,
    [16] = makedoor
}

-- Flags 0-3 to store UID
-- Flag 4 unused
-- Flag 5 unused
-- Flag 6 for visibility. 0: Visible; 1: Hidden
-- Flag 7 for direction. 0: Right; 1: Left
for tile in all(split(__tif__)) do
    local x, y, s, f = unpack(split(tile, ":"))
    local entity = converters[s](x, y, f)
    entity:reset()
    entity.id = f & 15
    entity.hide = f & 64 == 64
    add(entities, entity)
end