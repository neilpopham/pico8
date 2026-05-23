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
        plr = player:new()
        plr:init()
        dr = door:new({x = 0, y = 0, c = 14})
        dr:init()
    end,
    update = function(self)
        door_distance = 999
        plr:update()
        for e in all(entities) do
            e:update()
        end
    end,
    draw = function(self)
        cls()

        camera(plr.x - 60, 0)

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
        print(plr.x, 0, 0, 7)
        print(mget(plr.x\8, (plr.y)\8 + 1), 0, 10, 5)
        print(plr.x\8, 20, 10, 5)
        print(plr.y\8 + 1, 50, 10, 5)
        print(#entities, 0, 20, 12)
        print(door_distance, 0, 30, 5)

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