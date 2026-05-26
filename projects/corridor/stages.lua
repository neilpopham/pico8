stages = {
    set = function(new)
        _stage = new
    end,
    check = function()
        if _stage then
            stage = _stage
            stage:init()
            _stage = nil
        end
    end,
    shared = function()
        -- do shared drawing
    end
}

stages.intro = {
    init = function(self)
    end,
    update = function(self)
    end,
    draw = function(self)
        stages.shared()
    end
}

stages.game = {
    init = function(self)
        -- door distance
        poke2(0x4300, 32767)

        -- plr = player:new()
        plr:init()
        inv = inventory:new()
        inv:init()
    end,
    update = function(self)
        msg = nil
        plr:update()
        for e in all(entities) do
            e:update()
        end
        inv:update()
    end,
    draw = function(self)
        cls()

        if plr.x > 8124 then
            camera(8064, 0)
        elseif plr.x > 60 then
            camera(plr.x - 60, 0)
        end

        map(0, 0, 0, 32, 128, 8)
        map(0, 8, 128 * 8, 32, 128, 8)
        map(0, 16, 128 * 8 * 2, 32, 128, 8)
        map(0, 24, 128 * 8 * 3, 32, 128, 8)
        map(0, 32, 128 * 8 * 4, 32, 128, 8)
        map(0, 40, 128 * 8 * 5, 32, 128, 8)
        map(0, 48, 128 * 8 * 6, 32, 128, 8)
        map(0, 56, 128 * 8 * 7, 32, 128, 8)

        for e in all(entities) do
            e:draw()
        end

        plr:draw()


        camera()
        inv:draw()

        -- print(plr.x, 0, 0, 7)
        -- print(mget(plr.x\8, (plr.y)\8 + 1), 0, 10, 5)
        -- print(plr.x\8, 20, 10, 5)
        -- print(plr.y\8 + 1, 50, 10, 5)
        -- print(#entities, 0, 20, 12)
        -- print(inv.items[1], 20, 20, 12)
        -- print(plr.x-60, 0, 26, 15)

        if msg then print(msg, 0, 106, 7) end

        stages.shared()
    end
}

stages.outro = {
    init = function(self)
    end,
    update = function(self)
    end,
    draw = function(self)
        stages.shared()
    end
}