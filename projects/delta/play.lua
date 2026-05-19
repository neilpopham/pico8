modes.play = class:new({
    entities = {},
    init = function(_ENV)
        v = @0x2000
        data = {}
        entities = {}
        portals = {}
        b = 1
        while v != 255 do
            add(data, v)
            if b % 4 == 0 then
                local s = data[3]
                local es = makers[s](unpack(data))
                for e in all(es) do
                    e:init()
                    if s >= 7 and s <= 10 then
                        if portals[data[4]] then
                            portals[data[4]].sibling = e
                            e.sibling = portals[data[4]]
                        else
                            portals[data[4]] = e
                        end
                    end
                    add(entities, e)
                end
                data = {}
            end
            v = @(0x2000 + b)
            b += 1
        end
    end,
    update = function(_ENV)
        player:update()
        for e in all(entities) do
            e:update()
        end
    end,
    draw = function(_ENV)
        cls()
        for e in all(entities) do
            e:draw()
        end
    end
})